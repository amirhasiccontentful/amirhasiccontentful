public with sharing class SubscriptionProductChargeTriggerHandler extends TriggerHandler { 

	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/

	public override void afterUpdate() {
		PopulateSubscriptionCustomFields(trigger.new);
	}

	public override void afterInsert() {
		PopulateSubscriptionCustomFields(trigger.new);
	}

	/****************************************************/
	/* HELPER FUNCTIONS									*/
	/****************************************************/

	// Name: UpdateSubscriptions
	// Description: Triggers update on Subscription in order to recalculate values that are pulled from Subscription Product Charges records
	private void PopulateSubscriptionCustomFields(List<Zuora__SubscriptionProductCharge__c> subscriptionProductCharges) {
		Set<Id> subscriptionIds = new Set<Id>();
		Set<String> ratePlanNamesAndProductNames = new Set<String>();
		Map<Id, List<Zuora__SubscriptionProductCharge__c>> subscriptionProductChargesBySubscriptionId = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();

		for(Zuora__SubscriptionProductCharge__c subscriptionProductCharge : subscriptionProductCharges) {
			subscriptionIds.add(subscriptionProductCharge.Zuora__Subscription__c);
			ratePlanNamesAndProductNames.add(subscriptionProductCharge.Zuora__RatePlanName__c + subscriptionProductCharge.Zuora__ProductName__c);

			if(subscriptionProductChargesBySubscriptionId.containsKey(subscriptionProductCharge.Zuora__Subscription__c)) {
				List<Zuora__SubscriptionProductCharge__c> addSubscriptionProductCharge = new List<Zuora__SubscriptionProductCharge__c>(subscriptionProductChargesBySubscriptionId.get(subscriptionProductCharge.Zuora__Subscription__c));
				addSubscriptionProductCharge.add(subscriptionProductCharge);
				subscriptionProductChargesBySubscriptionId.put(subscriptionProductCharge.Zuora__Subscription__c, addSubscriptionProductCharge);
			} else {
				subscriptionProductChargesBySubscriptionId.put(subscriptionProductCharge.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c> { subscriptionProductCharge });
			}
		}

		List<Zuora__Subscription__c> subscriptionsToUpdate = [SELECT Primary_Product_Rate_Plan__c, Primary_Product_Rate_Plan_Failed_Lookup__c, Zuora__MRR__c FROM Zuora__Subscription__c WHERE Id IN :subscriptionIds];
		List<zqu__ProductRatePlan__c> productRatePlans = [SELECT Name_And_Product_Name__c  FROM zqu__ProductRatePlan__c WHERE zqu__Deleted__c = false AND Name_And_Product_Name__c IN :ratePlanNamesAndProductNames];
		Map<String, zqu__ProductRatePlan__c> productRatePlanByRatePlanNameAndProductName = new Map<String, zqu__ProductRatePlan__c>();

		for(zqu__ProductRatePlan__c productRatePlan : productRatePlans) {
			productRatePlanByRatePlanNameAndProductName.put(productRatePlan.Name_And_Product_Name__c, productRatePlan);
		}

		if(!subscriptionsToUpdate.isEmpty()) {
			for(Zuora__Subscription__c subscription : subscriptionsToUpdate) {
				List<Zuora__SubscriptionProductCharge__c> subProductCharges = new List<Zuora__SubscriptionProductCharge__c>(subscriptionProductChargesBySubscriptionId.get(subscription.Id));
				if(!subProductCharges.isEmpty()) {
					for(Zuora__SubscriptionProductCharge__c subProductCharge : subProductCharges) {
						if(String.isBlank(subProductCharge.Zuora__UOM__c) == true && !subProductCharge.Name.containsIgnoreCase('roles') && !subProductCharge.Name.containsIgnoreCase('api') && subProductCharge.Zuora__Type__c == 'Recurring') {
							if(!productRatePlanByRatePlanNameAndProductName.isEmpty()) {
								zqu__ProductRatePlan__c productRatePlan = productRatePlanByRatePlanNameAndProductName.get(subProductCharge.Zuora__RatePlanName__c + subProductCharge.Zuora__ProductName__c);
								if(productRatePlan != null) {
									subscription.Primary_Product_Rate_Plan__c = productRatePlan.Id;
									subscription.Primary_Product_Rate_Plan_Failed_Lookup__c = false;
								} else {
									subscription.Primary_Product_Rate_Plan_Failed_Lookup__c = true;
								}
							}
						}
						if(subProductCharge.Name.containsIgnoreCase('discount')) {
							if(subProductCharge.Zuora__Price__c != null && subscription.Zuora__MRR__c != null) {
								subscription.CMRR_After_Discount__c = subscription.Zuora__MRR__c - ((subscription.Zuora__MRR__c * subProductCharge.Zuora__Price__c)/100);//subProductCharge.Zuora__Price__c);
							}
						}
					}
				}
			}
			update subscriptionsToUpdate;
		}
	}  
}