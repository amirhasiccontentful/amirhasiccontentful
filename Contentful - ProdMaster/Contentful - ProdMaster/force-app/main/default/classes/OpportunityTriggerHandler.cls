public without sharing class OpportunityTriggerHandler extends TriggerHandler { 
	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/

	public override void beforeInsert() {  
		populateLeadSourceFromPrimaryContact(trigger.new);
		InheritOpportunityManagers(trigger.new); 
		CurrentSubscriptionPlan(trigger.new);
		opportunityPipelineSource(trigger.new, 'insert');
		copyAccountType(trigger.new);
		setRelatedCFOrganizationInfo(trigger.new, false);  
		removeLeadFieldMappingOnLeadConversion(trigger.new); 
	}

	public override void beforeUpdate() {   
		ClosedLostOpportunity(trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
		CurrentSubscriptionPlan(trigger.new);
		OpportunityPushCounter(trigger.new, (Map<Id, Opportunity>)trigger.oldMap); 
		opportunityPipelineSource(trigger.new, 'update');
        opportunityCreatedBySDR(trigger.new); 
		setRelatedCFOrganizationInfo(trigger.new, false); 
		//setPrimaryOpportunityForClosedExpansionOpps(trigger.new, (Map<Id, Opportunity>)trigger.oldMap); //Changes to be Released after quantity based model has been enabled.
		resetOpportunityCurrencyOnLeadConversion(trigger.new, (Map<Id, Opportunity>)trigger.oldMap); 
		resetOppClosedDateWhenOppIsClosedWon(trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
		setRecordTypeWhenTypeIsChanged(trigger.new, (Map<Id, Opportunity>)trigger.oldMap); 
	}
	
	//To uncomment when needed
	// public override void beforeDelete() { 

	// }

	public override void afterInsert() {  
		CalculateFieldsOnAccount(trigger.new, null);
		addPrimaryContactToContactRoles(trigger.new); 
		setSalesSegmentForRelatedAccount(trigger.new);
		//setParentOpportunityOnRenewalCreation(trigger.new); //Changes to be Released after quantity based model has been enabled.
	}

	public override void afterUpdate() {  
		CalculateFieldsOnAccount(trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
		OpportunityOwnerBecomesAccountOwner(trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
		mapOppManagersToAccount(trigger.new, (Map<Id, Opportunity>)trigger.oldMap); 
		setPartnerDetalStagesBasedOnOppStageChanges(trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
		//setPrimaryOppAmountAfterExtensionOppClosedWon(trigger.new, (Map<Id, Opportunity>)trigger.oldMap); //Changes to be Released after quantity based model has been enabled.
		createNewRenewalOpportunityWhenInitialOrRenewalOppisClosedWon(trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
	}

	public override void afterDelete() {
		CalculateFieldsOnAccount(trigger.old, null);
	}
 
	public override void afterUndelete() {
		CalculateFieldsOnAccount(trigger.new, null);
	}

	/****************************************************/
	/* HELPER FUNCTIONS									*/
	/****************************************************/

	// Name: setRecordTypeWhenTypeIsChanged
	// Description: sets the opportunity RecordType if the opportunity Type has changed and the wrong Record Type is assigned
	private void setRecordTypeWhenTypeIsChanged(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
  
		String initialRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Initial').getRecordTypeId();
		String renewalRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Renewal').getRecordTypeId();
		String expandRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Expand').getRecordTypeId();

		for(Opportunity opp : opportunities) {

			Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id); 

			if(opp.Type != oldOpp.Type && opp.Type == 'Initial' && opp.RecordTypeId != initialRTId) { 
				opp.RecordTypeId = initialRTId;  
			} 

			if(opp.Type != oldOpp.Type && opp.Type == 'Expansion' && opp.RecordTypeId != expandRTId) { 
				opp.RecordTypeId = expandRTId;  
			} 

			if(opp.Type != oldOpp.Type && opp.Type == 'Renewal' && opp.RecordTypeId != renewalRTId) { 
				opp.RecordTypeId = renewalRTId;  
			} 
		}
	}

	// Name: resetOppClosedDateWhenOppIsClosedWon
	// Description: resets Opportunity Close Date if it was changed by Salesforce standard functionality on Stage set to Closed Won  
	//				and close date in future which is setting the Close Date for the Opportunity to TODAYs date
	private void resetOppClosedDateWhenOppIsClosedWon(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
  
		for(Opportunity opp : opportunities) {

			Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id); 

			if(opp.CloseDate != oldOpp.CloseDate && opp.StageName != oldOpp.StageName &&
			   opp.StageName == 'Closed Won' && oldOpp.CloseDate > Date.today() && opp.CloseDate == Date.today()) { 
				opp.CloseDate = oldOpp.CloseDate; 
				opp.Name = oldOpp.Name; 
			} 
		}
	}

	// Name: removeLeadFieldMappingOnLeadConversion
	// Description: Removes lead to opportunity field mapping for field used to solve Currency issues when lead is converted into an existing Opportunity
	private void removeLeadFieldMappingOnLeadConversion(List<Opportunity> opportunities) {
		for(Opportunity opp : opportunities) { 
			if(opp.IsCreatedByLead__c){
				opp.Lead_Currency__c = '';  
			}
		}
	}

	// Name: resetOpportunityCurrencyOnLeadConversion
	// Description: Checks if opportunity Currency has changed for existing opportunity on lead conversion
	private void resetOpportunityCurrencyOnLeadConversion(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
  
		for(Opportunity opp : opportunities) {

			Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);

			if(opp.CurrencyIsoCode != oldOpp.CurrencyIsoCode && String.isNotEmpty(opp.Lead_Currency__c)) { 
				opp.CurrencyIsoCode = oldOpp.CurrencyIsoCode;
				opp.Lead_Currency__c = ''; 
			}
		}
	}

	// Name: createNewRenewalOpportunityWhenInitialOrRenewalOppisClosedWon
	// Description: Creates a new Renewal specific opps are closed
	private void createNewRenewalOpportunityWhenInitialOrRenewalOppisClosedWon(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunitiesMap) {

		Set<Id> accountIds = new Set<Id>();
		Set<Id> closedWonOppIds = new Set<Id>();

		List<Opportunity> opportunitiesToCreate = new List<Opportunity>();
		List<Account> accountsToUpdate = new List<Account>();

		String initialRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Initial').getRecordTypeId();
		String renewalRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Renewal').getRecordTypeId();
		String expandRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Expand').getRecordTypeId();

		for(Opportunity opp : opportunities) {
			accountIds.add(opp.AccountId);
		}

		if(accountIds.size() > 0) {
				
			Map<Id, Account> accountMaps = new Map<Id, Account>([SELECT Id, Name, OwnerId, Zuora_Customer_Type__c, Primary_Opportunity__c,
																(
																 SELECT Id 
																 FROM Opportunities 
																 WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND Type = 'Renewal'
																 ORDER BY CreatedDate DESC
																 LIMIT 1
																) 
																FROM Account 
																WHERE Id IN :accountIds]);

			for(Opportunity opp : opportunities) {

				Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);

				if(oldOpp != null) {

					Account currentAccount = accountMaps.get(opp.AccountId);

					if( opp.StageName == 'Closed Won' && oldOpp.StageName != opp.StageName && currentAccount.Opportunities.size() == 0 &&
					    (opp.RecordTypeId == initialRTId || opp.RecordTypeId == renewalRTId || 
						(opp.RecordTypeId == expandRTId && currentAccount.Zuora_Customer_Type__c != 'Enterprise')) ) {
							closedWonOppIds.add(opp.Id);
						}
				}
			}

			if(closedWonOppIds.size() > 0) {

				for(Opportunity opp : opportunities) {
							
					if(closedWonOppIds.contains(opp.Id)){

						Account currentAccount = accountMaps.get(opp.AccountId);

						Opportunity newRenewalOpp = new Opportunity(); 
						
						newRenewalOpp.CloseDate = opp.Subscription_End_Date1__c != null ? opp.Subscription_End_Date1__c.adddays(1) : opp.CloseDate.addYears(Integer.valueOf(opp.Term__c)).adddays(1);
						newRenewalOpp.Name = currentAccount.Name + ' Renewal ';
						newRenewalOpp.StageName = 'Validation';
						newRenewalOpp.Amount = opp.Amount;
						newRenewalOpp.AccountId = currentAccount.Id;
						newRenewalOpp.CF_Customer_Success_Manager_M__c = opp.CF_Customer_Success_Manager_M__c;
						newRenewalOpp.CurrencyIsoCode = opp.CurrencyIsoCode;
						newRenewalOpp.Description = opp.Description; 
						newRenewalOpp.OwnerId = currentAccount.OwnerId;
						newRenewalOpp.Primary_Contact__c = opp.Primary_Contact__c;
						newRenewalOpp.RecordTypeId = renewalRTId;
						newRenewalOpp.Renewal_Amount__c = opp.Amount;
						newRenewalOpp.Team_Region__c = opp.Team_Region__c;
						newRenewalOpp.Type = 'Renewal'; 
						newRenewalOpp.Term__c = opp.Term__c;

						opportunitiesToCreate.add(newRenewalOpp);  
					} 
				}  

				if(opportunitiesToCreate.size() > 0) {
					insert opportunitiesToCreate;

					//Set Primary Opportunity for related accounts
					for(Opportunity createdOpp : opportunitiesToCreate) { 
						Account currentAccount = new Account(Id = createdOpp.AccountId, Primary_Opportunity__c = createdOpp.Id);
						accountsToUpdate.add(currentAccount); 
					}
 
					if(accountsToUpdate.size() > 0) {
						update accountsToUpdate;
					} 
				}
			}
		}
	}

	/*
	// NOTES:: Proces will be handled manually by Deal Desk team until the new Quantity based model has been released. 
	// Name: setPrimaryOpportunityForClosedExpansionOpps
	// Description: Rolls up all existing account expansion opps to the new Primary Opportunity
	private void setPrimaryOpportunityForClosedExpansionOpps(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunitiesMap) {

		Set<Id> accountIds = new Set<Id>();  
		Set<Id> expansionOppIds = new Set<Id>();  

		List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

		String expandOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Expand').getRecordTypeId();

		for(Opportunity opp : opportunities) {

			if(oldOpportunitiesMap == null) continue;

			Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);

			if(oldOpp != null) {
				if(opp.RecordTypeId == expandOppRecordTypeId && opp.StageName == 'Closed Won' && oldOpp.StageName != opp.StageName) {
					accountIds.add(opp.AccountId); 
					expansionOppIds.add(opp.Id);
				} 
			} 
		} 

		if(accountIds.size() > 0) { 
			Map<Id, Account> accountMaps = new Map<Id, Account>([SELECT Id, 
																(
																 SELECT Id, CloseDate 
																 FROM Opportunities 
																 WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND Type = 'Renewal'
																 ORDER BY CreatedDate DESC
																 LIMIT 1
																) 
																FROM Account 
																WHERE Id IN :accountIds]);
 
			for(Opportunity opp : opportunities) { 
				if(expansionOppIds.contains(opp.Id)) { 
					Account acc = accountMaps.get(opp.AccountId);  
					if(acc != null && acc.Opportunities.size() > 0) { 
						Opportunity primaryOpp = acc.Opportunities[0];  
						if(opp.CloseDate < primaryOpp.CloseDate) { 
							opp.Parent_Opportunity__c = primaryOpp.Id;
						} 
					}  
				}  
			}  
		}

	}
	*/
 
	/*
	// NOTES:: Proces will be handled manually by Deal Desk team until the new Quantity based model has been released. 
	// Name: setPrimaryOppAmountAfterExtensionOppClosedWon
	// Description: Set the primary Opp amount when an Expansion opp is closed
	private void setPrimaryOppAmountAfterExtensionOppClosedWon(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunitiesMap) {

		Set<Id> parentOppIds = new Set<Id>();   
		List<Opportunity> opportunitiesToUpdate = new List<Opportunity>(); 

		String expandOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Expand').getRecordTypeId();

		for(Opportunity opp : opportunities) {

			if(oldOpportunitiesMap == null) continue;

			Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);

			if(opp.RecordTypeId == expandOppRecordTypeId && opp.StageName == 'Closed Won' && oldOpp.StageName != opp.StageName && opp.Parent_Opportunity__c != null) {
				parentOppIds.add(opp.Parent_Opportunity__c); 
			} 
		} 

		if(parentOppIds.size() > 0) { 

			List<Opportunity> childOpportunities = [SELECT Id, Amount, Parent_Opportunity__c
													FROM Opportunity 
													WHERE Parent_Opportunity__c IN :parentOppIds AND StageName = 'Closed Won'];

			Map<Id, List<Opportunity>> parentToChilOpportunitiesMap = new Map<Id, List<Opportunity>>();

			for(Opportunity childOpp : childOpportunities) { 
				if(parentToChilOpportunitiesMap.containsKey(childOpp.Parent_Opportunity__c)) {
					List<Opportunity> relatedOpportunities = parentToChilOpportunitiesMap.get(childOpp.Parent_Opportunity__c);
					relatedOpportunities.add(childOpp);
					parentToChilOpportunitiesMap.put(childOpp.Parent_Opportunity__c, relatedOpportunities);
				} else {
					parentToChilOpportunitiesMap.put(childOpp.Parent_Opportunity__c, new List<Opportunity> { childOpp });
				} 
			} 

			for(Id parentOppId : parentOppIds) {
				
				List<Opportunity> childOpps = parentToChilOpportunitiesMap.get(parentOppId);  
				
				if(childOpps.size() > 0) { 
					Decimal sum = 0;
					for(Opportunity opp : childOpps){
						sum+= opp.Amount;
					} 
					Opportunity primaryOpp = new Opportunity(Id = parentOppId, Amount = sum);
					opportunitiesToUpdate.add(primaryOpp);
				}     
			} 

			if(opportunitiesToUpdate.size() > 0) {
				update opportunitiesToUpdate;
			} 
		} 

	}
	*/

	/*
	// NOTES::Logic will be released after Quantity based model has been released.
	// Name: setParentOpportunityOnRenewalCreation
    // Description: Sets the Parent opportunity for existing initial or renewal opps when new renewal is created
    private void setParentOpportunityOnRenewalCreation(List<Opportunity> opportunities) {

        Set<Id> accountIds = new Set<Id>();   
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>(); 

        String renewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Renewal').getRecordTypeId();

        for(Opportunity opp : opportunities) {
            if(opp.RecordTypeId == renewalOppRecordTypeId) {
                accountIds.add(opp.AccountId);  
            } 
        } 
		 
        if(accountIds.size() > 0) {
 
			List<Opportunity> closedNonExpansionOppsList = [SELECT Id, AccountId, Type, Parent_Opportunity__c
															FROM Opportunity 
															WHERE AccountId IN :accountIds AND StageName = 'Closed Won' AND (Type = 'Renewal' OR Type = 'Initial')
															ORDER BY CloseDate DESC];

			Map<Id, List<Opportunity>> accountOpportunitiesMap = new Map<Id, List<Opportunity>>();

			for(Opportunity closedOpp : closedNonExpansionOppsList) { 
				if(accountOpportunitiesMap.containsKey(closedOpp.AccountId)) {
					List<Opportunity> relatedOpportunities = accountOpportunitiesMap.get(closedOpp.AccountId);
					relatedOpportunities.add(closedOpp);
					accountOpportunitiesMap.put(closedOpp.AccountId, relatedOpportunities);
				} else {
					accountOpportunitiesMap.put(closedOpp.AccountId, new List<Opportunity> { closedOpp });
				} 
			} 

            for(Account account : [SELECT Id, Primary_Opportunity__c
                                   FROM Account 
                                   WHERE Id IN :accountIds]) {
   
				List<Opportunity> relatedOpportunities = accountOpportunitiesMap.get(account.Id);  

				if(relatedOpportunities != null && relatedOpportunities.size() > 0) { 
					for(Opportunity opp : relatedOpportunities){
						if(opp.Type == 'Renewal' && opp.Parent_Opportunity__c == null) {
							opp.Parent_Opportunity__c = primaryOppId;
							opportunitiesToUpdate.add(opp);  
							break;
						} else if(opp.Type == 'Initial' && opp.Parent_Opportunity__c == null) {
							opp.Parent_Opportunity__c = primaryOppId;
							opportunitiesToUpdate.add(opp);  
							break;
						}
					} 
				}   
            }  

            if(opportunitiesToUpdate.size() > 0) {
                update opportunitiesToUpdate;
            }  
        }   
    } 
	*/

	private void setSalesSegmentForRelatedAccount(List<Opportunity> opportunities) {

        Map<Id, String> opportunityStagesMap = new Map<Id, String>();
		Set<Id> accountsIds = new Set<Id>();

        for(Opportunity opp : opportunities) {
            accountsIds.add(opp.AccountId);
        }

        if(accountsIds.size() > 0){
            List<Account> accountsList = [SELECT Id, Sales_Segment__c
                                          FROM Account 
                                          WHERE Id IN: accountsIds AND Sales_Segment__c != 'Territory' 
										  		AND Sales_Segment__c != 'Named' AND Type != 'Internal/Test'];

            if(accountsList.size() > 0) {
                 
				for(Account acc : accountsList) {
					acc.Sales_Segment__c = 'Territory';
				}
    
                update accountsList;
            }
        }
    }

	private void setPartnerDetalStagesBasedOnOppStageChanges(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunitiesMap) {

        Map<Id, String> opportunityStagesMap = new Map<Id, String>();

        for(Opportunity opp : opportunities) {
            Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);
 
            if(opp.StageName.Contains('Closed') && oldOpp.StageName != opp.StageName) {
                opportunityStagesMap.put(opp.Id, opp.StageName);
            }
        }

        if(opportunityStagesMap != null && opportunityStagesMap.size() > 0){
            List<Partner_Deals__c> partnerDeals = [SELECT Id, Stage__c, Closed_Stage__c, Opportunity_Name__c, Opportunity_Name__r.StageName
                                                   FROM Partner_Deals__c 
                                                   WHERE Opportunity_Name__c IN: opportunityStagesMap.keyset()];

            if(partnerDeals.size() > 0) {
                for(Partner_Deals__c pd : partnerDeals) {
                    if(pd.Closed_Stage__c != 'Closed - Not Selected') {
                        pd.Stage__c = 'Closed';
                        pd.Closed_Stage__c = opportunityStagesMap.get(pd.Opportunity_Name__c);
                    }
                }
    
                update partnerDeals;
            }
        }
    }
 
	// Name: setRelatedCFOrganizationInfo
    // Description: Sets the Primary Opportunity for the Account
	// Parameters: isScheduled attribute added because of schedule call which needs to do the same thing on daily basis.  
	private static void setRelatedCFOrganizationInfo(List<Opportunity> opportunities, Boolean isScheduled) {

		Set<String> cfIds = new Set<String>();

		for(Opportunity opp : opportunities) {
			if(opp.Is_this_opportunity_related_to_Trial__c == 'Yes' && opp.Enterprise_CF_Organization__c != null && opp.Related_CF_Organization_Record__c == null) {
				cfIds.add(opp.Enterprise_CF_Organization__c);
			}
		}

		if(cfIds.size() > 0) { 

			List<CF_Organization__c> cfOrgsToUpdate = new List<CF_Organization__c>();

			for(CF_Organization__c cfOrg : [SELECT Id, gk_key__c, Account__c FROM CF_Organization__c WHERE gk_key__c IN: cfIds]) {
				for(Opportunity opp : opportunities) {
					if(opp.Enterprise_CF_Organization__c == cfOrg.gk_key__c) {
						opp.Related_CF_Organization_Record__c = cfOrg.Id;

						cfOrg.Account__c = opp.AccountId;
						cfOrgsToUpdate.add(cfOrg);
					}
				}
			}

			if(isScheduled){
				Database.update(opportunities, false);
			}

			if(cfOrgsToUpdate.size() > 0) {
				update cfOrgsToUpdate;
			}
		}
	}  

	// Name: InheritOpportunityManagers
	// Description: When opportunity is created all Users that are managing Account should be copied to Opportunity
	private void InheritOpportunityManagers(List<Opportunity> opportunities) {
		Set<Id> accountIds = new Set<Id>();

		for(Opportunity opportunity : opportunities) {
			accountIds.add(opportunity.AccountId);
		}

		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Initial_Expansion_Won__c, SE__c, Product_Expert__c, Prospecting_Manager__c, CF_Customer_Success_Manager__c, TA__c, SA__c FROM Account WHERE Id IN: accountIds]);

		for(Opportunity opportunity : opportunities) {
			Account account = accounts.get(opportunity.AccountId);
			
			if (account != null) {
				if(account.Initial_Expansion_Won__c > 0){ 
					if(account.SE__c != null)
						opportunity.Product_Expert__c = account.SE__c; 

					if(account.CF_Customer_Success_Manager__c != null && opportunity.CF_Customer_Success_Manager_M__c == null)
						opportunity.CF_Customer_Success_Manager_M__c = account.CF_Customer_Success_Manager__c;

					if(account.TA__c != null && opportunity.TA__c == null)
						opportunity.TA__c = account.TA__c;

					if(account.SA__c != null && opportunity.SA__c == null)
						opportunity.SA__c = account.SA__c;
				}
			}
		}
	}
    
    private void opportunityCreatedBySDR(List<Opportunity> opportunities){
        for(Opportunity opp : opportunities){
            if(opp.Prospecting_Manager__c == null && opp.Created_By_Role__c == 'SDR' && opp.Type != 'Renewal'){
                opp.Prospecting_Manager__c = opp.CreatedById;
            }
        }
    }

	private void mapOppManagersToAccount(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities) {

		Set<Id> accountIds = new Set<Id>();
		List<Opportunity> lstOfOpps =  new List<Opportunity>();

		for(Opportunity opp : opportunities){
            Opportunity oldOpp = oldOpportunities.get(opp.Id);
			if(opp.StageName == 'Closed Won' && (oldOpp.StageName != opp.StageName || oldOpp.Prospecting_Manager__c != opp.Prospecting_Manager__c || oldOpp.Product_Expert__c != opp.Product_Expert__c || oldOpp.TA__c != opp.TA__c || oldOpp.SA__c != opp.SA__c)){
				lstOfOpps.add(opp);
			}
		}

		if(!lstOfOpps.isEmpty()){
			
			Map<Id, Account> mapOfScopedAccounts = new Map<Id, Account>();

			for(Opportunity scopedOpp : lstOfOpps){

				Account acc = new Account(Id = scopedOpp.AccountId);
                if(scopedOpp.Prospecting_Manager__c != null){
                    acc.Prospecting_Manager__c = scopedOpp.Prospecting_Manager__c;
                }
                if(scopedOpp.Product_Expert__c != null){
                    acc.SE__c = scopedOpp.Product_Expert__c;
                } 
                if(scopedOpp.TA__c != null && scopedOpp.Is_Services_Opportunity__c == true){
                    acc.TA__c = scopedOpp.TA__c;
                }
                if(scopedOpp.SA__c != null && scopedOpp.Is_Services_Opportunity__c == true){
                    acc.SA__c = scopedOpp.SA__c;
                }
                
				mapOfScopedAccounts.put(acc.Id, acc);
			}

			if(mapOfScopedAccounts.size() > 0){
				update mapOfScopedAccounts.values();
			}
		}
	}

	// Name: OpportunityOwnerBecomesAccountOwner
	// Description: 
	private void OpportunityOwnerBecomesAccountOwner(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities) {
		if(UserInfo.getUserRoleId() == null)
			return;
		Set<Id> ownerIds = new Set<Id>();
		Set<Id> accountIds = new Set<Id>();
		List<Account> updateAccounts = new List<Account>();

		for(Opportunity opportunity : opportunities) {
			Opportunity oldOpp = oldOpportunities.get(opportunity.Id);
			if(oldOpp != null && oldOpp.OwnerId != opportunity.OwnerId){
				ownerIds.add(opportunity.OwnerId);
				accountIds.add(opportunity.AccountId);
			}
		}

		if(!ownerIds.isEmpty() && !accountIds.isEmpty()){
			Map<Id, User> users = new Map<Id, User>([SELECT Profile.Name, UserRole.Name FROM User WHERE Id IN :ownerIds]);
			Map<Id, Account> accounts = new Map<Id, Account>([SELECT OwnerId FROM Account WHERE Id IN: accountIds]);
			List<UserRole> currentUserRole = [SELECT Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId() LIMIT 1];

			if(!currentUserRole.isEmpty()){
				if(currentUserRole[0].Name == 'SDR') {
					for(Opportunity opportunity : opportunities) {
						Account acc = accounts.get(opportunity.AccountId);
						User owner = users.get(opportunity.OwnerId);

						if(owner.UserRole.Name == 'Account Executive' && acc.OwnerId != opportunity.OwnerId) {
							acc.OwnerId = opportunity.OwnerId;
							updateAccounts.add(acc);
						}
					}

					if(!updateAccounts.isEmpty()) {
						update updateAccounts;
					}
				}
			}
		}
	}

	// Name: CalculateFieldsOnAccount
	// Description: Recalculate fields on Account based on the Opportunity stage
	private void CalculateFieldsOnAccount(List<Opportunity> opportunities, Map<Id, Opportunity> oldObjectMap) {

		Set<Id> accountIds = new Set<Id>(); 
		List<Account> accountsToUpdate = new List<Account>();

		for(Opportunity opportunity : opportunities) {
			
			if(!Trigger.isUpdate)
				accountIds.add(opportunity.AccountId);

			if(oldObjectMap == null) continue;

			//Add changed opp account Id to list to reset account numbers  
			Opportunity oldOpp = oldObjectMap.get(opportunity.Id);

			if(
				(oldOpp.AccountId != opportunity.AccountId && String.isNotEmpty(oldOpp.AccountId)) || 
				oldOpp.StageName != opportunity.StageName || 
				oldOpp.Amount != opportunity.Amount
			) {
				accountIds.add(oldOpp.AccountId);
			} 
		}

		for(Account account : [SELECT Won_Opportunities__c, Lost_Opportunities__c, Open_Opportunities__c, 
									  All_Renewal_Won__c, Professional_Service_Total_Won__c, Professional_Service_Total_Lost__c,
								(SELECT StageName, IsClosed, Amount, Type, RecordType.Name FROM Opportunities) 
							   FROM Account 
							   WHERE Id IN :accountIds]) {
			
			account.Won_Opportunities__c = 0;
			account.Lost_Opportunities__c = 0;
			account.Open_Opportunities__c = 0;
			account.Professional_Service_Total_Won__c = 0; 
			account.Professional_Service_Total_Lost__c = 0; 
			account.All_Renewal_Won__c = 0;

			if(account.Opportunities.size() > 0) {

				Decimal wonOpp = 0;
				Decimal psWonOpp = 0;
				Decimal lostOpp = 0;
				Decimal psLostOpp = 0;
				Decimal openOpp = 0;
				Decimal reWonOpp = 0;
				
				for(Opportunity opportunity : account.Opportunities) {

					if(opportunity.StageName == 'Closed Won' && (opportunity.Type == 'Initial' || opportunity.Type == 'Expansion'))
						wonOpp += opportunity.Amount != null ? opportunity.Amount : 0;

					if (opportunity.StageName == 'Closed Lost' && (opportunity.Type == 'Initial' || opportunity.Type == 'Expansion'))
						lostOpp += opportunity.Amount != null ? opportunity.Amount : 0;

					if (!opportunity.IsClosed && (opportunity.Type == 'Initial' || opportunity.Type == 'Expansion'))
						openOpp += opportunity.Amount != null ? opportunity.Amount : 0;

					if(opportunity.StageName == 'Closed Won' && opportunity.RecordType.Name == 'Services')
						psWonOpp += opportunity.Amount != null ? opportunity.Amount : 0;

					if(opportunity.StageName == 'Closed Lost' && opportunity.RecordType.Name == 'Services')
						psLostOpp += opportunity.Amount != null ? opportunity.Amount : 0;

					if (opportunity.StageName == 'Closed Won' && opportunity.Type == 'Renewal')
						reWonOpp += opportunity.Amount != null ? opportunity.Amount : 0;

				}

				account.Won_Opportunities__c = wonOpp;
				account.Lost_Opportunities__c = lostOpp;
				account.Open_Opportunities__c = openOpp; 
				account.All_Renewal_Won__c = reWonOpp;
				account.Professional_Service_Total_Won__c = psWonOpp; 
				account.Professional_Service_Total_Lost__c = psLostOpp; 
			} 

			accountsToUpdate.add(account);
		} 

		if(accountsToUpdate.size() > 0) {
			update accountsToUpdate;
		}
	}

	// Name: ClosedLostOpportunity
	// Description: Update fields on opportunity when Stage is changed to Closed Lost
	private void ClosedLostOpportunity(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities) {
		for(Opportunity opportunity : opportunities) { 
			Opportunity oldOpportunity = oldOpportunities.get(opportunity.Id);

      		if(oldOpportunity.StageName != opportunity.StageName && opportunity.StageName == 'Closed Lost') {
      			opportunity.Lost_Stage__c = oldOpportunity.StageName;
      		}  	

      		if(oldOpportunity.StageName != opportunity.StageName) {
      			opportunity.Last_State_Change_Date__c = DateTime.now(); 
      		}	
		}
	}

	private void CurrentSubscriptionPlan(List<Opportunity> opportunities) {
		Set<Id> accountIds = new Set<Id>();
		for(Opportunity opp : opportunities) {
			accountIds.add(opp.AccountId);
		}

		List<Zuora__Subscription__c> subscriptions = [SELECT Primary_Product_Rate_Plan__c, Zuora__Account__c FROM Zuora__Subscription__c WHERE Zuora__Account__c IN :accountIds AND Zuora__Status__c = 'active'];
		if(!subscriptions.isEmpty()) {
			Map<Id, Zuora__Subscription__c> subscriptionsMap = new Map<Id, Zuora__Subscription__c>();
			for(Zuora__Subscription__c subscription : subscriptions) {
				subscriptionsMap.put(subscription.Zuora__Account__c, subscription);
			}

			for(Opportunity opp : opportunities) {
				Zuora__Subscription__c subscription = subscriptionsMap.get(opp.AccountId);
				if(subscription != null) {
					if(subscription.Primary_Product_Rate_Plan__c != null) {
						if(opp.Current_Subscription_Plan__c != subscription.Primary_Product_Rate_Plan__c) {
							opp.Current_Subscription_Plan__c = subscription.Primary_Product_Rate_Plan__c;
						}
					}
				}
			}
		}
	}

	// code used by some app Clean your room.. let's keep it for now but it might become redundant later on
	private void OpportunityPushCounter(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities) {
		Date dNewCloseDate;
		Date dOldCloseDate;
		Boolean bPushed=false;

		for (Opportunity oIterator : opportunities) { //Bulk trigger handler so that you can mass update opportunities and this fires for all'
		                                            // gets new values for updated rows
		    dNewCloseDate = oIterator.CloseDate; // get the new closedate 
		    dOldCloseDate = oldOpportunities.get(oIterator.Id).CloseDate; //get the old closedate for this opportunity
		    if (dOldCloseDate<dNewCloseDate) { //if the new date is after the old one, look if the month numbers are different
		        if (dOldCloseDate.month()<dNewCloseDate.month()) { // the month number is higher, it's been pushed out
		            bPushed=true;
		        }
		        else {
		            if (dOldCloseDate.year()<dNewCloseDate.year()) { // the month wasn't higher, but the year was, pushed!
		                bPushed=true;
		                }
		            }
		        
		    }
		    if (bPushed==true) { // let's go make them sorry
		        if (oIterator.PushCount__c==null) {
		            oIterator.PushCount__c=1;
		        }
		        else {
		        oIterator.PushCount__c++;           
		        }
		    }
		}
	}

	/*POPULATE THE Pipeline_Source_Picklist__c field based on the Type field. Field is also being updated to "Partnerships"
	  when related Partner Deal record has Partner_Customer_Relationship_Type__c = 'Partner Sourced' field value
	*/

	private void opportunityPipelineSource(List<Opportunity> opportunities, String dmlType) {

		Set<Id> matchedOppIds = new Set<Id>();

		if(dmlType == 'update'){

			List<Partner_Deals__c> partnerDeals = [SELECT Id, Partner_Customer_Relationship_Type__c, Opportunity_Name__c 
															FROM Partner_Deals__c WHERE Opportunity_Name__c IN :opportunities AND 
															Partner_Customer_Relationship_Type__c = 'Partner Sourced'];

			if(!partnerDeals.isEmpty()){
				for(Partner_Deals__c relatedPartnerDeal : partnerDeals){
					matchedOppIds.add(relatedPartnerDeal.Opportunity_Name__c);
				}
			}
		}
		
		for(Opportunity opp : opportunities){
			if(opp.Type != null){
				if(!matchedOppIds.contains(opp.Id)){
					if(opp.Type == 'Initial'){
						opp.Pipeline_Source__c = 'Inbound';
					} else if(opp.Type == 'Expansion'){
						opp.Pipeline_Source__c = 'Expansion';
					} else if(opp.Type == 'Renewal'){
						opp.Pipeline_Source__c = 'Renewal';
					}
				} else {
					opp.Pipeline_Source__c = 'Partnerships';
				}
			}
		}
	}

	private void copyAccountType(List<Opportunity> opportunities) {

		Set<Id> accountIds = new Set<Id>();
		Map<Id, String> mapOfAccountIdAndAccountType = new Map<Id, String>();

		for(Opportunity opp : opportunities){
			if(opp.AccountId != null){
				accountIds.add(opp.AccountId);
			}
		}

		if(!accountIds.isEmpty()){
			for(Account acc : [SELECT Id, Type FROM Account WHERE Id IN :accountIds AND Type != NULL]){
				mapOfAccountIdAndAccountType.put(acc.Id, acc.Type);
			}

			if(mapOfAccountIdAndAccountType != null){
				for(Opportunity o : opportunities){
					if(mapOfAccountIdAndAccountType.get(o.AccountId) != null){
						o.Account_Type_On_Opp_Creation_Date__c = mapOfAccountIdAndAccountType.get(o.AccountId);
					}
				}
			}
		}
	}

	private void populateLeadSourceFromPrimaryContact(List<Opportunity> listOfOpps){

		Set<Id> setofContactIds = new Set<Id>();
		
		for(Opportunity opp : listOfOpps){
			if(opp.Primary_Contact__c != null){
				setofContactIds.add(opp.Primary_Contact__c);
			}
		}

		if(!setofContactIds.isEmpty()){

			Map<Id,String> contactSource = new Map<Id,String>();

			for(Contact con : [SELECT Id, LeadSource FROM Contact WHERE Id IN :setofContactIds]){
				if(con.LeadSource != null){
					contactSource.put(con.Id, con.LeadSource);
				}
			}

			if(contactSource != null){
				for(Opportunity opp : listOfOpps){
					if(opp.Primary_Contact__c != null){
						if(contactSource.get(opp.Primary_Contact__c) != null){
							opp.LeadSource = contactSource.get(opp.Primary_Contact__c);
						}
					}
				}
			}
		}
	}

	private void addPrimaryContactToContactRoles(List<Opportunity> listOfOpps){

		List<OpportunityContactRole> contactRolesForInsert = new List<OpportunityContactRole>();

		for(Opportunity opp : listOfOpps){
			if(opp.Primary_Contact__c != null){
				OpportunityContactRole ocr = new OpportunityContactRole();
				ocr.OpportunityId = opp.Id;
				ocr.ContactId = opp.Primary_Contact__c;
				ocr.Role = 'Champion';
				ocr.IsPrimary = true;
				contactRolesForInsert.add(ocr);
			}
		}

		if(!contactRolesForInsert.isEmpty()) Database.insert(contactRolesForInsert, false);
	}

	@InvocableMethod(label='Set Trial Org Information' description='Sets Trial org information for Opportunities who meet the criteria' category='Opportunity')
	public static void setOppRealtedCFOrganization() {

		List<Opportunity> opportunities = [SELECT Id, Enterprise_CF_Organization__c, Related_CF_Organization_Record__c, Is_this_opportunity_related_to_Trial__c
										   FROM Opportunity 
										   WHERE Enterprise_CF_Organization__c != null AND 
										         Related_CF_Organization_Record__c = null AND 
										         Is_this_opportunity_related_to_Trial__c = 'Yes'];
				
		if(opportunities.size() > 0) {
			setRelatedCFOrganizationInfo(opportunities, true);
		}
	} 
	
}