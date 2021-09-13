public with sharing class ZuoraSubscriptionTriggerHandler extends TriggerHandler {
	
	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/

	//to uncomment if needed
	// public override void beforeUpdate() {
	// }

	//to uncomment if needed
	// public override void beforeInsert() {
	// }

	public override void afterUpdate() {
		accountZuoraRollups(Trigger.new, (Map<Id, Zuora__Subscription__c>)trigger.oldMap);
	}

	public override void afterInsert() {
		accountZuoraRollups(Trigger.new, (Map<Id, Zuora__Subscription__c>)trigger.oldMap);
	}

	public override void afterDelete() { 
		accountZuoraRollups(Trigger.new, (Map<Id, Zuora__Subscription__c>)trigger.oldMap);
	}

	public override void afterUnDelete() { 
		accountZuoraRollups(Trigger.new, (Map<Id, Zuora__Subscription__c>)trigger.oldMap);
	}

	/****************************************************/
	/* HELPER FUNCTIONS									*/
	/****************************************************/

	// can we use list names that are easier to understand e.g. newSubscriptionList and oldSubscriptionMap
	private void accountZuoraRollups(List<Zuora__Subscription__c> newSubscriptionList, Map<Id, Zuora__Subscription__c> oldSubscriptionMap){

		Set<Id> accountIds = new Set<Id>();
		Boolean executeFromCustomSetting = false;
		Boolean executeLogic = true;

		ExecuteSetting__c zuoraAccountRollupsSetting = new ExecuteCodeLogic().checkIfCodeLogicShouldBeExecuted('Zuora Account Rollups');

		if(zuoraAccountRollupsSetting != null){
			executeLogic = zuoraAccountRollupsSetting.Active__c;
			executeFromCustomSetting = zuoraAccountRollupsSetting.Execute__c;
		}
		
		//stop code execution
		if(!executeLogic) return; 

		if(Trigger.isDelete){
			newSubscriptionList = oldSubscriptionMap.values();
		}

		for(Zuora__Subscription__c zS : newSubscriptionList){

			Zuora__Subscription__c oldRecord = oldSubscriptionMap != null ? oldSubscriptionMap.get(zs.Id) : null;

			// also if subscription is moved to another account
			if(oldRecord == null){
				accountIds.add(zs.Zuora__Account__c);
			} else if(
						oldRecord != null && 
						(
						zs.Zuora__Status__c != oldRecord.Zuora__Status__c || 
						zs.Zuora__MRR__c != oldRecord.Zuora__MRR__c || 
						zs.Zuora__TCV__c != oldRecord.Zuora__TCV__c || 
						zs.Zuora__RenewalTerm__c != oldRecord.Zuora__RenewalTerm__c ||
						zs.Zuora__SubscriptionStartDate__c != oldRecord.Zuora__SubscriptionStartDate__c ||
						zs.Zuora__NextRenewalDate__c != oldRecord.Zuora__NextRenewalDate__c || 
						zs.Zuora__SubscriptionStartDate__c != oldRecord.Zuora__SubscriptionStartDate__c || 
						zs.Primary_Product_Rate_Plan__c != oldRecord.Primary_Product_Rate_Plan__c || 
						zs.CMRR_After_Discount__c != oldRecord.CMRR_After_Discount__c || 
						zs.Zuora__Account__c != oldRecord.Zuora__Account__c || 
						zs.CurrencyISOCode != oldRecord.CurrencyISOCode || 
						executeFromCustomSetting ||
						Trigger.isDelete
						)
					){
 
				if(zs.Zuora__Account__c != null){
					accountIds.add(zs.Zuora__Account__c);
				}
				
				if(oldRecord.Zuora__Account__c != null){
					accountIds.add(oldRecord.Zuora__Account__c);
				}
			}
		}
		
		if(accountIds.size() == 0) return;
		
		accountZuoraRollupsExecute(accountIds);
	} 

	public static void accountZuoraRollupsExecute(Set<Id> accountIds){

		List<Account> lstOfAccountsForUpdate = new List<Account>();
		Boolean currencyUpdated = false;

		for(Account acc : [SELECT Id, Name, Type, Zuora_Current_Contract_Start_Date__c, Zuora_Active_Paying_Subscriptions__c, 
								(SELECT Id,
									Zuora__Account__c, 
									Zuora__Status__c,
									Zuora__SubscriptionStartDate__c, 
									Zuora__RenewalTerm__c,
									CMRR_After_Discount__c,
									Zuora__MRR__c,
									Zuora__TCV__c,
									Zuora__NextRenewalDate__c,
									Primary_Product_Rate_Plan__c,
									Primary_Product_Rate_Plan_Plan_Type__c,
									CurrencyISOCode
								FROM Zuora__Subscriptions__r
								ORDER BY Zuora__MRR__c DESC)
							FROM Account WHERE Id IN :accountIds]){

			Decimal zuoraSubscriptionMRR = 0.00;

			acc.Zuora_Total_CMRR__c = 0.00;
			acc.Zuora_Active_Paying_Subscriptions__c = 0;
			acc.Zuora_Cancelled_Subscriptions__c = 0;
			acc.Zuora_Total_TCV__c = 0;
			acc.Zuora_Active_Enterprise_Subscriptions__c = 0;
			acc.Zuora_Act_Partnership_Subscriptions__c = 0;
			acc.Zuora_Act_Enterprise_Trial_Sub__c = 0;
			acc.Zuora_Pro_Bono_Subscriptions__c = 0;
			acc.Zuora_Current_Contract_Start_Date__c = null;
			acc.Zuora_Next_Annual_Renewal_Date__c = null;
			acc.Zuora_Subscriptions__c = acc.Zuora__Subscriptions__r.size();

			for(Zuora__Subscription__c subscription : acc.Zuora__Subscriptions__r){

				if(subscription != null){
					if(subscription.Zuora__RenewalTerm__c != null && subscription.Zuora__Status__c == 'active' && subscription.Zuora__MRR__c > 0 && subscription.Zuora__SubscriptionStartDate__c != null){
						if(subscription.Zuora__MRR__c > zuoraSubscriptionMRR){
							acc.Zuora_Current_Contract_Start_Date__c = subscription.Zuora__SubscriptionStartDate__c;
						} 
					}
					if(subscription.Zuora__Status__c == 'active' && subscription.CMRR_After_Discount__c != null){
						acc.Zuora_Total_CMRR__c += subscription.CMRR_After_Discount__c;
					}
					if(subscription.Zuora__Status__c == 'active' && subscription.Zuora__MRR__c > 0){
						acc.Zuora_Active_Paying_Subscriptions__c += 1;
						if(subscription.Primary_Product_Rate_Plan_Plan_Type__c == 'Enterprise'){
							acc.Enterprise_Subscription__c = subscription.Id;
						}
					}
					if(subscription.Zuora__Status__c == 'cancelled' && subscription.Zuora__MRR__c > 0){
						acc.Zuora_Cancelled_Subscriptions__c += 1;
					}
					if(subscription.Zuora__Status__c == 'active' && subscription.Zuora__TCV__c != null){
						acc.Zuora_Total_TCV__c += subscription.Zuora__TCV__c;
					}
					if(subscription.Zuora__NextRenewalDate__c != null && subscription.Zuora__Status__c == 'active' && subscription.Zuora__MRR__c > 0){
						if(subscription.Zuora__MRR__c > zuoraSubscriptionMRR){
							acc.Zuora_Next_Annual_Renewal_Date__c = subscription.Zuora__NextRenewalDate__c;
						}
					}
					if(subscription.Zuora__Status__c == 'active' && subscription.Zuora__MRR__c > 0 && subscription.Primary_Product_Rate_Plan__c != null && subscription.Primary_Product_Rate_Plan_Plan_Type__c != null && subscription.Primary_Product_Rate_Plan_Plan_Type__c == 'Enterprise'){
						acc.Zuora_Active_Enterprise_Subscriptions__c += 1;
					}
					if(subscription.Zuora__Status__c == 'active' && subscription.Primary_Product_Rate_Plan__c != null && subscription.Primary_Product_Rate_Plan_Plan_Type__c != null && subscription.Primary_Product_Rate_Plan_Plan_Type__c == 'Partner - Agency'){
						acc.Zuora_Act_Partnership_Subscriptions__c += 1;
					}
					if(subscription.Zuora__Status__c == 'active' && subscription.Primary_Product_Rate_Plan__c != null && subscription.Primary_Product_Rate_Plan_Plan_Type__c != null && subscription.Primary_Product_Rate_Plan_Plan_Type__c == 'Enterprise Trial'){
						acc.Zuora_Act_Enterprise_Trial_Sub__c += 1;
					}
					if(subscription.Zuora__Status__c == 'active' && subscription.Primary_Product_Rate_Plan__c != null && subscription.Primary_Product_Rate_Plan_Plan_Type__c != null && subscription.Primary_Product_Rate_Plan_Plan_Type__c.contains('pro_bono')){
						acc.Zuora_Pro_Bono_Subscriptions__c += 1;
					}

					if(subscription.Zuora__MRR__c > zuoraSubscriptionMRR && subscription.Zuora__Status__c == 'active'){
						zuoraSubscriptionMRR = subscription.Zuora__MRR__c;
					}	
					
					if(subscription.CurrencyISOCode != null && subscription.Zuora__Status__c == 'active' 
						&& acc.CurrencyISOCode != subscription.CurrencyISOCode && !currencyUpdated){
						acc.CurrencyISOCode = subscription.CurrencyISOCode; 
						currencyUpdated = true;
					}
				}				
			}

			if(acc.Zuora_Active_Enterprise_Subscriptions__c > 0){
				acc.Type = 'Customer - Enterprise';
			} else if (acc.Zuora_Act_Partnership_Subscriptions__c > 0){
				acc.Type = 'Customer - Partner';
			} else if (acc.Zuora_Active_Paying_Subscriptions__c > 0){
				acc.Type = 'Customer - Self Service';
			} else if (acc.Zuora_Active_Paying_Subscriptions__c == 0 && acc.Zuora_Cancelled_Subscriptions__c > 0){
				acc.Type = 'Former Customer';
			} else {
				acc.Type = '';
			}

			lstOfAccountsForUpdate.add(acc);
		}

		if(!lstOfAccountsForUpdate.isEmpty()){

			try {
				update lstOfAccountsForUpdate;
			} catch (Exception e){

				//Set Header values of the file

				String csvHeader = 'Record Id, Name \n';
				String mainContent = csvHeader;

				for (Account acc : lstOfAccountsForUpdate){
				    //Adding records in a string
				    String recordString = acc.Id+','+acc.Name +'\n';
				    mainContent += recordString;
				}

				Messaging.EmailFileAttachment csvAttcmnt = new Messaging.EmailFileAttachment ();

				//Create CSV file using Blob
				Blob csvBlob = Blob.valueOf(mainContent);
				String csvname = 'Zuora Account Rollup Failed.csv';
				csvAttcmnt.setFileName(csvname);
				csvAttcmnt.setBody(csvBlob);
				Messaging.SingleEmailMessage singEmail = new Messaging.SingleEmailMessage ();
				List<String> toAddresses = new List<String> {'salesforce-admin@contentful.com'};

				//Set recipient list
				singEmail.setToAddresses(toAddresses);

				String subject = 'Zuora Account Rollup Failed CSV';
				singEmail.setSubject(subject);
				singEmail.setPlainTextBody ('Zuora Account Rollup Failed CSV - ' + e);

				//Set blob as CSV file attachment
				singEmail.setFileAttachments (new Messaging.EmailFileAttachment []{csvAttcmnt});

				try{
					Messaging.SendEmailResult [] r = Messaging.sendEmail (new Messaging.SingleEmailMessage [] {singEmail});
				} catch (Exception ex){
					System.debug('ZuoraSubscriptionTriggerHandler:accountZuoraRollups:ex:---- ' + ex);
				}
				
			}
		}
	}
}