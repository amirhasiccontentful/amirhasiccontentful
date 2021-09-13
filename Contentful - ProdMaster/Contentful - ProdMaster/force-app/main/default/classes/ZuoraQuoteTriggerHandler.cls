public with sharing class ZuoraQuoteTriggerHandler extends TriggerHandler {
	public static Boolean runOnce = true;
	public ZuoraQuoteTriggerHandler() {
		//this.setMaxLoopCount(5);
	}

	public override void beforeUpdate() {
		if(runOnce) {
			runOnce = false;
			SetTerms(trigger.new);
			setPrimaryQuote(trigger.new);
			originalSubscriptionValues(trigger.new);
		}
	}

	public override void beforeInsert() {
		if(runOnce) {
			runOnce = false;
			SetTerms(trigger.new);
			setPrimaryQuote(trigger.new);
			originalSubscriptionValues(trigger.new);
		}
	}

	public override void afterUpdate() {
		setQuoteOnOpportunity(trigger.new);
	}

	public override void afterInsert() {	
		setQuoteOnOpportunity(trigger.new);
	}

	// HELPER METHODS

	private void originalSubscriptionValues(List<zqu__Quote__c> quotes){

		List<Account> accountsForUpdate = new List<Account>();
		//List<zqu__QuoteRatePlan__c> quoteRatePlansForUpdate = new List<zqu__QuoteRatePlan__c>();


		List<zqu__QuoteRatePlanCharge__c> quoteRatePlanCharges = [SELECT 
															Id, 
															zqu__Quantity__c, 
															zqu__EffectivePrice__c, 
															Name, InternalName__c, 
															zqu__ProductRatePlanCharge__r.InternalName__c,
															zqu__QuoteRatePlan__r.zqu__Quote__c,
															zqu__Discount__c,
															zqu__QuoteRatePlan__r.Quantity__c
														FROM zqu__QuoteRatePlanCharge__c 
														WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN :quotes AND 
                                                           (zqu__ProductRatePlanCharge__r.InternalName__c = 'additional_api_calls' OR
                                                            zqu__ProductRatePlanCharge__r.InternalName__c = 'organization_memberships' OR
                                                            zqu__ProductRatePlanCharge__r.InternalName__c = 'additional_bandwidth' OR 
                                                            zqu__ProductRatePlanCharge__r.InternalName__c LIKE '%_sla%' OR
															zqu__ProductRatePlanCharge__r.InternalName__c = 'discount'
                                                        )];

		List<zqu__QuoteCharge_Tier__c> scopedChargeRecords = [SELECT Id, 
																	zqu__Tier__c, 
																	zqu__RatePlanCharge__r.InternalName__c, 
																	zqu__StartingUnit__c, 
																	zqu__EndingUnit__c, 
																	zqu__QuoteRatePlanCharge__r.Name,
																	zqu__QuoteRatePlanCharge__r.zqu__QuoteRatePlan__r.zqu__Quote__c
																	FROM zqu__QuoteCharge_Tier__c 
																	WHERE (zqu__RatePlanCharge__r.InternalName__c = 'asset_bandwidth' OR 
																	zqu__RatePlanCharge__r.InternalName__c = 'api_requests' OR 
																	zqu__RatePlanCharge__r.InternalName__c = 'additional_users')
																	AND zqu__QuoteRatePlanCharge__r.zqu__QuoteRatePlan__r.zqu__Quote__c IN :quotes];  

		if(!scopedChargeRecords.isEmpty() || !quoteRatePlanCharges.isEmpty()){

			for(zqu__Quote__c q : quotes){

				if(q.RecordTypeId == Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('Amendment').getRecordTypeId()){

					if(!scopedChargeRecords.isEmpty()){

						for(zqu__QuoteCharge_Tier__c zqct : scopedChargeRecords){

							if(zqct.zqu__QuoteRatePlanCharge__r.zqu__QuoteRatePlan__r.zqu__Quote__c == q.Id){

								if(zqct.zqu__RatePlanCharge__r.InternalName__c == 'additional_users' && q.Original_Subscription_Users_Tier_1__c == null){
								
									if(zqct.zqu__Tier__c == 1){
										q.Original_Subscription_Users_Tier_1__c = zqct.zqu__EndingUnit__c;
									} 
								}
					                                      
								if(zqct.zqu__RatePlanCharge__r.InternalName__c == 'asset_bandwidth' && q.Original_Subscription_Asset_Tier_1__c == null) {
						
									if(zqct.zqu__Tier__c == 1){
										q.Original_Subscription_Asset_Tier_1__c = zqct.zqu__EndingUnit__c;
									}         
								}
					                                       
								if(zqct.zqu__RatePlanCharge__r.InternalName__c == 'api_requests' && q.Original_Subscription_API_Tier_1__c == null) {
					                                                        
									if(zqct.zqu__Tier__c == 1){
										q.Original_Subscription_API_Tier_1__c = zqct.zqu__EndingUnit__c;
									}  
								} 
							}
						}
					}

					if(!quoteRatePlanCharges.isEmpty()){

						for(zqu__QuoteRatePlanCharge__c qrp : quoteRatePlanCharges){

							if(qrp.zqu__QuoteRatePlan__r.zqu__Quote__c == q.Id){

								/*if(qrp.zqu__QuoteRatePlan__r.Quantity__c != null && qrp.zqu__QuoteRatePlan__r.Quantity__c > 0){
									for(Integer i = 1; i<qrp.zqu__QuoteRatePlan__r.Quantity__c; i++){
										zqu.zChargeGroup zcg = zqu.zQuoteUtil.getChargeGroup(q.Id, (Id) qrp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c);
										zqu.zQuoteUtil.addChargeGroup(zcg);
									}
									//qrp.zqu__QuoteRatePlan__r.Quantity__c = 0;
									zqu__QuoteRatePlan__c ratePlanForUpdate = new zqu__QuoteRatePlan__c(Id = qrp.zqu__QuoteRatePlan__c, Quantity__c = 0);
									quoteRatePlansForUpdate.add(ratePlanForUpdate);
								}*/

								if(qrp.zqu__ProductRatePlanCharge__r.InternalName__c == 'additional_api_calls'){
									if(q.Original_Subscription_Additional_API__c == null){
										q.Original_Subscription_Additional_API__c = qrp.zqu__Quantity__c;
									}
								}

								if(qrp.zqu__ProductRatePlanCharge__r.InternalName__c == 'discount'){
									if(q.Original_Subscription_Discount__c == null){
										q.Original_Subscription_Discount__c = qrp.zqu__Discount__c;
									}
								}
								
								if(qrp.zqu__ProductRatePlanCharge__r.InternalName__c == 'organization_memberships'){ //additional users in production
									if(q.Original_Subscription_Additional_Users__c == null){
										q.Original_Subscription_Additional_Users__c = qrp.zqu__Quantity__c;
									}
								}
								
								if(qrp.zqu__ProductRatePlanCharge__r.InternalName__c == 'additional_bandwidth'){
									if(q.Original_Subscription_Additional_Asset__c == null){
										q.Original_Subscription_Additional_Asset__c = qrp.zqu__Quantity__c;
									}
								}
							}
						}
					}


					q.zqu__CommunicationProfile__c = String.valueOf(Label.Zuora_Communication_Profile);

			        if(q.Bill_From__c == 'Contentful GmbH'){
			           //q[0].zqu__InvoiceTemplate__c = String.valueof(Label.Zuora_Invoice_Id_Contenful_GmbH);
			        } else if(q.Bill_From__c == 'Contentful Inc.'){
			           //q[0].zqu__InvoiceTemplate__c = String.valueof(Label.Zuora_Invoice_Id_Contenful_Inc);
			           //q.zqu__Certificate_ID__c = 'non-eu';
			        }

			        if(q.zqu__StartDate__c != null){
			                q.zqu__BillCycleDay__c = String.valueOf(q.zqu__StartDate__c.day());
			        }

			        if(q.zqu__StartDate__c != null){
			                q.Bill_Cycle_Month__c = String.valueOf(q.zqu__StartDate__c.month());
			        }

			        
					q.Bill_Run_Frequency_in_months__c = '3';
					
			        if(q.CF_Organization_Key__c != '' && q.CF_Organization_Key__c != null){
			                q.organization_key__c = q.CF_Organization_Key__c;
			        }

			        if(q.zqu__Account__c != null){

						Account acc = new Account(Id = q.zqu__Account__c);

						if(q.CF_Organization_Key__c != '' && q.CF_Organization_Key__c != null){
							acc.organization_key__c = q.CF_Organization_Key__c;
						}

						if(q.Bill_From__c != null){
							if(q.Bill_From__c == 'Contentful GmbH'){
								acc.Billing_Entity__c = 'gmbh';
							} else if(q.Bill_From__c == 'Contentful Inc.'){
								acc.Billing_Entity__c = 'inc';
							}
						}

					if(q.zqu__StartDate__c != null){
						acc.Bill_Cycle_Month__c = String.valueOf(q.zqu__StartDate__c.month());
					}
			                
					
					acc.Bill_Run_Frequency_in_months__c = '3';
					  
					accountsForUpdate.add(acc);
				}
			}

		}
	}

		if(!accountsForUpdate.isEmpty()) update accountsForUpdate;
		//if(!quoteRatePlansForUpdate.isEmpty()) update quoteRatePlansForUpdate;
	}

	private void SetTerms(List<zqu__Quote__c> quotes) {
		for(zqu__Quote__c quote : quotes) {
			if(quote.Initial_Term__c != null & quote.Renewal_Term__c != null) {
				if(quote.Payment__c != null) {
					if(quote.Payment__c == 'Quarterly') {
						quote.zqu__InitialTerm__c = quote.Initial_Term__c * 3;
						quote.zqu__InitialTermPeriodType__c = 'Month';
						quote.zqu__RenewalTerm__c = quote.Renewal_Term__c * 3;
						quote.zqu__RenewalTermPeriodType__c = 'Month';
					} else if (quote.Payment__c == 'Annual') {
						quote.zqu__InitialTerm__c = quote.Initial_Term__c;
						quote.zqu__InitialTermPeriodType__c = 'Year';
						quote.zqu__RenewalTerm__c = quote.Renewal_Term__c;
						quote.zqu__RenewalTermPeriodType__c = 'Year';
					} else {
						quote.zqu__InitialTerm__c = quote.Initial_Term__c;
						quote.zqu__InitialTermPeriodType__c = 'Month';
						quote.zqu__RenewalTerm__c = quote.Renewal_Term__c;
						quote.zqu__RenewalTermPeriodType__c = 'Month';
					}
				}
			}
		}
	}


	// Set Current Quote on Opportunity
	private void setQuoteOnOpportunity(List<zqu__Quote__c> quotes) {
		List<Opportunity> updateOpportunities = new List<Opportunity>();
		Set<Id> primaryOpportunityIds = new Set<Id>();
		Map<Id, zqu__Quote__c> oppIdQuoteId = new Map<Id, zqu__Quote__c>();
		
		for(zqu__Quote__c quote : quotes) {
			if(quote.zqu__Primary__c) {
				primaryOpportunityIds.add(quote.zqu__Opportunity__c);
				oppIdQuoteId.put(quote.zqu__Opportunity__c, quote);
			}
		}

		if(!primaryOpportunityIds.isEmpty()) {
			List<Opportunity> opportunities = [SELECT Current_Quote__c, Amount FROM Opportunity WHERE Id IN :primaryOpportunityIds AND isClosed = FALSE];

			for(Opportunity opp : opportunities) {
				Boolean addOpp = false;
				if(opp.Current_Quote__c != oppIdQuoteId.get(opp.Id).Id) {
					opp.Current_Quote__c = oppIdQuoteId.get(opp.Id).Id;
					addOpp = true;
			    }
			    /*if(opp.Amount != oppIdQuoteId.get(opp.Id).Quote_Amount__c && !opp.Closed) {
					opp.Amount = oppIdQuoteId.get(opp.Id).Quote_Amount__c;
					addOpp = true;
			    }*/
			    if(addOpp)
					updateOpportunities.add(opp);
			}

			if(!updateOpportunities.isEmpty()) {
				update updateOpportunities;
			}
		}
	
	}

	// First quote is always primary quote. If there is an existing primary quote when adding new primary
	// quote old primary quote will be removed. When cloning primary quote, new quote becomes primary automatically.
	private void setPrimaryQuote(List<zqu__Quote__c> quotes) {
		Set<Id> quoteIds = new Set<Id>();
		Set<Id> opportunityIds = new Set<Id>();

		for(zqu__Quote__c quote : quotes) {
			quoteIds.add(quote.Id);
			opportunityIds.add(quote.zqu__Opportunity__c);
		}

		Map<Id, List<zqu__Quote__c>> allQuotesByOpportunityId = new Map<Id, List<zqu__Quote__c>>();
		List<zqu__Quote__c> updateQuotes = new List<zqu__Quote__c>();

		for(zqu__Quote__c q : [SELECT Id, zqu__Opportunity__c, zqu__Primary__c FROM zqu__Quote__c WHERE zqu__Opportunity__c IN :opportunityIds AND Id NOT IN :quoteIds]) {
			if(allQuotesByOpportunityId.containsKey(q.zqu__Opportunity__c)) {
				List<zqu__Quote__c> addQuotes = allQuotesByOpportunityId.get(q.zqu__Opportunity__c);
				addQuotes.add(q);
				allQuotesByOpportunityId.put(q.zqu__Opportunity__c, addQuotes);
			} else {
				allQuotesByOpportunityId.put(q.zqu__Opportunity__c, new List<zqu__Quote__c> { q });
			}
		}

		for(zqu__Quote__c quote : quotes) {
			List<zqu__Quote__c> getQuotes = new List<zqu__Quote__c>(allQuotesByOpportunityId.get(quote.zqu__Opportunity__c));
			if(!getQuotes.isEmpty()) {
				if(quote.zqu__Primary__c) {
					for(zqu__Quote__c q : getQuotes) {
						q.zqu__Primary__c = false;
						updateQuotes.add(q);
					} 
				} //else {
					//quote.zqu__Primary__c = true;
				//}
			} else {
				quote.zqu__Primary__c = true;
			}
		}

		if(!updateQuotes.isEmpty()) {
			update updateQuotes;
		}
	}	
	

}