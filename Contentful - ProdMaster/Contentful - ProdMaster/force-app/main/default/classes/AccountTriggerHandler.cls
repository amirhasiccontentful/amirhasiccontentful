public with sharing class AccountTriggerHandler extends TriggerHandler {

	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/

	public override void beforeUpdate() { 
		populateBillingAddressFromDataFox(Trigger.new);
		removeTierIfQualificationIsNotEnterprise(trigger.new, (Map<Id, Account>)trigger.oldMap);
		IndustryMapping(trigger.new, (Map<Id, Account>)trigger.oldMap);
		SetUltimateParent(trigger.new, (Map<Id, Account>)trigger.oldMap); 
		accountClassification(trigger.new, (Map<Id, Account>)trigger.oldMap);
        SetZendeskFields(trigger.new, (Map<Id, Account>)trigger.oldMap);
		setSalesSegmentOnOwnerChange(trigger.new, (Map<Id, Account>)trigger.oldMap);
	}

	public override void beforeInsert() { 
		removeTierIfQualificationIsNotEnterprise(trigger.new, (Map<Id, Account>)trigger.oldMap);
		SetUltimateParent(trigger.new, (Map<Id, Account>)trigger.oldMap);
        SetZendeskFields(trigger.new, (Map<Id, Account>)trigger.oldMap);  
	}

	public override void afterUpdate() { 
		// if(!Test.isRunningTest()){
		// 	updateContactOwnership(trigger.new, (Map<Id, Account>)trigger.oldMap); 
		// }

		SetUltimateParentForChildAccounts(trigger.new, (Map<Id, Account>)trigger.oldMap);  
	}

	//To uncomment when needed
	// public override void afterInsert() {

	// }

	//To uncomment when needed
	// public override void afterDelete() {
		
	// }

	/****************************************************/
	/* HELPER FUNCTIONS									*/
	/****************************************************/

	// Name: setSalesSegmentOnOwnerChange
	// Description: Sets Sales Segment when Account owner has changed and the account Sales Segment is empty.
	private void setSalesSegmentOnOwnerChange(List<Account> accounts, Map<Id, Account> oldAccountsMap) {
		
		Set<Id> userIds = new Set<Id>();
		
		for(Account account : accounts) {
			if(oldAccountsMap != null){
				Account oldAccount = oldAccountsMap.get(account.Id);
				if(oldAccount != null){
					if(account.OwnerId != oldAccount.OwnerId && (account.Sales_Segment__c == null || account.Sales_Segment__c == 'AM Segment' || account.Sales_Segment__c == 'Non-sales Segmented')) {
						userIds.add(account.OwnerId);
					}
				}
			} 
		}
		
		if(userIds.size() > 0){	

			for(User dbUser : [SELECT Id
							   FROM User 
							   WHERE Id IN :userIds AND Title LIKE '%Territory%']) {     

				for(Account account : accounts) {	       		

					if(account.OwnerId == dbUser.Id) {
						account.Sales_Segment__c = 'Territory';
					}
					
				}
			}
		}
		
	} 

	// Name: SetUltimateParentForChildAccounts
	// Description: Sets the Ultimate parent for all child accounts. If subchilds exist this method is called recursivly by trigger
	private void SetUltimateParentForChildAccounts(List<Account> accounts, Map<Id, Account> oldAccountsMap) {
		
		Set<Id> accountIds = new Set<Id>();
		
		for(Account account : accounts) {
			if(oldAccountsMap != null){
				Account oldAccount = oldAccountsMap.get(account.Id);
				if(oldAccount != null){
					if(account.Ultimate_Parent__c != oldAccount.Ultimate_Parent__c) {
						accountIds.add(account.Id);
					} 
				}
			}			
		}
		
		if(accountIds.size() > 0){	

			Map<Id, Account> accountsToUpdateMap = new Map<Id, Account>();

			//get all child records for the accounts where the Ultimate Parent has changed
			for(Account dbChildAccount : [SELECT Id, Name, ParentId, Parent.Ultimate_Parent__c
									 FROM Account 
									 WHERE ParentId IN :accountIds]) {     

				for(Account account : accounts) {	
					
					if(account.Id == dbChildAccount.ParentId) {
						dbChildAccount.Ultimate_Parent__c = account.Ultimate_Parent__c; 
						accountsToUpdateMap.put(dbChildAccount.Id, dbChildAccount);
					}

				}
			}

			if(accountsToUpdateMap.size() > 0) {
				update accountsToUpdateMap.values();
			}
		}
		
	}

	// Name: SetUltimateParent
	// Description: Sets the highest Parent in the Account Hierarchy as Ultimate Parent on Account
	private void SetUltimateParent(List<Account> accounts, Map<Id, Account> oldAccountsMap) {
		
		Set<Id> accountIds = new Set<Id>();
		
		for(Account account : accounts) {
			if(oldAccountsMap != null){
				Account oldAccount = oldAccountsMap.get(account.Id);
				if(oldAccount != null){
					if(account.ParentId != oldAccount.ParentId && account.ParentId != null) {
						accountIds.add(account.ParentId);
					}

					//Remove ultimate parent if Parent removed
					if(account.ParentId == null && account.ParentId != oldAccount.ParentId) { 
						account.Ultimate_Parent__c = null;
					}
				}
			} else if(account.ParentId != null) {
				accountIds.add(account.ParentId);
			}
		}
		
		if(accountIds.size() > 0){	

			for(Account dbAccount : [SELECT Id, Ultimate_Parent__c
									 FROM Account 
									 WHERE Id IN :accountIds]) {     

				for(Account account : accounts) {	       		

					if(account.ParentId == dbAccount.Id) {
						//if parent account has ultimate parent set, set the same ultimate parent for the child as well
						//if parent does not have an ultimate parent means he is the top level account or ultimate parent
						account.Ultimate_Parent__c = dbAccount.Ultimate_Parent__c != null ? dbAccount.Ultimate_Parent__c : dbaccount.Id;
					}
					
				}
			}
		}
		
	}

	private void accountClassification(List<Account> accounts, Map<Id, Account> oldAccounts) {

		Set<String> setOfCountries = new Set<String>();
		Set<String> setOfStates = new Set<String>();

		//all the country codes in the ORG
		Schema.DescribeFieldResult fieldResultCountryCode = User.Countrycode.getDescribe();
		List<Schema.PicklistEntry> countries = fieldResultCountryCode.getPicklistValues();
		
		for(Schema.PicklistEntry c : countries){
			setOfCountries.add(c.getLabel());
		}

		//all the state codes in the ORG
		Schema.DescribeFieldResult fieldResultStateCode = User.statecode.getDescribe();
		List<Schema.PicklistEntry> states = fieldResultStateCode.getPicklistValues();
		
		for(Schema.PicklistEntry s : states){
			setOfStates.add(s.getLabel());
		}


		//add country to hq qoutry
		Map<String, FunnelBeamIndustryMap__c> mapOfFunnelBeamIndustries = new Map<String, FunnelBeamIndustryMap__c>();

		for(FunnelBeamIndustryMap__c industryValue : FunnelBeamIndustryMap__c.getall().values()){
			mapOfFunnelBeamIndustries.put(industryValue.FunnelBeam_Industry__c, industryValue);
		}

		for (Account acc : accounts) {
			Account oldAccount = oldAccounts.get(acc.Id);
			if(acc.Auto_classification_done__c == false && (acc.dfox__Revenue_Estimate__c != oldAccount.dfox__Revenue_Estimate__c || acc.NumberOfEmployees != oldAccount.NumberOfEmployees || acc.Auto_classification_done__c != oldAccount.Auto_classification_done__c)) {
				if(acc.Classification__c == 'Enterprise' && acc.Tier__c != null) {
					if(acc.dfox__Revenue_Estimate__c >= 1000000000 || acc.NumberOfEmployees >= 10000) {
						acc.Classification__c = 'Enterprise';
						acc.Tier__c = '1';
						acc.First_Class__c = false;
						acc.Auto_classification_done__c = true;
					} else if ((acc.dfox__Revenue_Estimate__c >= 100000000 && acc.dfox__Revenue_Estimate__c < 1000000000) || (acc.NumberOfEmployees >= 1000 && acc.NumberOfEmployees <= 10000)) {
						acc.Classification__c = 'Enterprise';
						acc.Tier__c = '2';
						acc.First_Class__c = false;
						acc.Auto_classification_done__c = true;
					} else if ((acc.dfox__Revenue_Estimate__c >= 10000000 && acc.dfox__Revenue_Estimate__c < 100000000) || (acc.NumberOfEmployees >= 100 && acc.NumberOfEmployees <= 1000)) {
						acc.Classification__c = 'Enterprise';
						acc.Tier__c = '3';
						acc.First_Class__c = false;
						acc.Auto_classification_done__c = true;
					}
				}
				else if((acc.Classification__c == null || (acc.Classification__c == 'Enterprise' && acc.Tier__c == null) || acc.Classification__c == 'SMB' || acc.Classification__c =='Unknown')) {
					if(acc.dfox__Revenue_Estimate__c >= 1000000000 || acc.NumberOfEmployees >= 10000) {
						acc.Classification__c = 'Enterprise';
						acc.Tier__c = '1';
						acc.First_Class__c = false;
						acc.Auto_classification_done__c = true;
					} else if ((acc.dfox__Revenue_Estimate__c >= 100000000 && acc.dfox__Revenue_Estimate__c < 1000000000) || (acc.NumberOfEmployees >= 1000 && acc.NumberOfEmployees <= 10000)) {
						acc.Classification__c = 'Enterprise';
						acc.Tier__c = '2';
						acc.First_Class__c = false;
						acc.Auto_classification_done__c = true;
					} else if ((acc.dfox__Revenue_Estimate__c >= 10000000 && acc.dfox__Revenue_Estimate__c < 100000000) || (acc.NumberOfEmployees >= 100 && acc.NumberOfEmployees <= 1000)) {
						acc.Classification__c = 'Enterprise';
						acc.Tier__c = '3';
						acc.First_Class__c = false;
						acc.Auto_classification_done__c = true;
					} else if (acc.dfox__Revenue_Estimate__c > 0 || acc.NumberOfEmployees > 0) {
						acc.Classification__c = 'SMB';
						acc.Tier__c = '';
						acc.First_Class__c = false;
						acc.Auto_classification_done__c = true;
					} else {
						acc.Classification__c = 'Unknown';
						acc.Tier__c = '';
						acc.First_Class__c = false;
						acc.Auto_classification_done__c = true;
					}	
					if(acc.Industry != null) {
						FunnelBeamIndustryMap__c industries = mapOfFunnelBeamIndustries.get(acc.Industry);
						if(industries != null) {
							Boolean isAgency = industries.IsAgency__c;
							if(isAgency) {
								acc.Classification__c = 'Agency';
								acc.Tier__c = '';
								acc.Auto_classification_done__c = true;
								if (acc.NumberOfEmployees >= 5)
									acc.First_Class__c = true;
							}
						}
					}
				}
			}
		}
	}

	//Faruk Update - Code modified to pull the value from the FunnelBeam_Industry__c field instead of name
	private void IndustryMapping(List<Account> accounts, Map<Id, Account> oldAccounts) {

		Map<String, FunnelBeamIndustryMap__c> mapOfFunnelBeamIndustries = new Map<String, FunnelBeamIndustryMap__c>();

		for(FunnelBeamIndustryMap__c industryValue : FunnelBeamIndustryMap__c.getall().values()){
			mapOfFunnelBeamIndustries.put(industryValue.FunnelBeam_Industry__c, industryValue);
		}

		for(Account account : accounts) {
			Account oldAccount = oldAccounts.get(account.Id);
			if(account.Industry != null && account.Industry != oldAccount.Industry) {
				FunnelBeamIndustryMap__c industry = mapOfFunnelBeamIndustries.get(account.Industry);
				if(industry != null) {
					account.Industry = industry.Salesforce_Industry__c;
				}
			} 
		}
	}

	private void removeTierIfQualificationIsNotEnterprise(List<Account> newAccountList, Map<Id, Account> oldAccounts) {

		for(Account acc : newAccountList){
			if(oldAccounts != null){
				Account oldAccount = oldAccounts.get(acc.Id);
				if(oldAccount != null){
					if(acc.Classification__c != oldAccount.Classification__c && acc.Classification__c != 'Enterprise'){
						acc.Tier__c = null;
					}
				} else if(acc.Classification__c != oldAccount.Classification__c && acc.Classification__c != 'Enterprise'){
						acc.Tier__c = null;
				}
			}

			else if(acc.Classification__c != 'Enterprise'){
				acc.Tier__c = null;
			}
		}
	}

	private void populateBillingAddressFromDataFox(List<Account> newAccountList){

		for(Account acc : newAccountList){
			if(String.isBlank(acc.BillingCountry) && !String.isBlank(acc.DF_Company_Country__c)){
				acc.BillingStreet = acc.DF_Company_Street__c;
				acc.BillingCity = acc.DF_City__c;
				acc.BillingState = acc.DF_State__c;
				acc.BillingPostalCode = acc.DF_Country_Postal_Code__c;
				acc.BillingCountry = acc.DF_Company_Country__c;
			}
		}
	}

	//To check if this can be removed
	/*
	private void updateContactOwnership(List<Account> newAccounts, Map<Id, Account> oldAccounts){

		Map<Id, Id> scopedAccountOwnerIds = new Map<Id, Id>();

		for(Account acc : newAccounts){
			Account oldAccount = oldAccounts.get(acc.Id);
			if(acc.OwnerId != oldAccount.OwnerId){
				scopedAccountOwnerIds.put(acc.Id, acc.OwnerId);
			}
		}

		if(!scopedAccountOwnerIds.isEmpty() != null){

			List<Contact> contactsForUpdate = new List<Contact>();

			for(Contact con : [SELECT Id, AccountId, OwnerId FROM Contact WHERE AccountId IN :scopedAccountOwnerIds.keySet() AND Owner_is_SDR_PDR__c = FALSE AND Revenue_Cycle_Stage__c != 'MQL']){
				if(con != null){
					con.OwnerId = scopedAccountOwnerIds.get(con.AccountId);
					contactsForUpdate.add(con);
				}
			}

			if(!contactsForUpdate.isEmpty()){
				update contactsForUpdate;
			}
		}
	}
	*/
    
    private void SetZendeskFields(List<Account> newAccounts, Map<Id, Account> oldAccounts){
        Set<Id> userIds = new Set<Id>();
        for(Account newAccount : newAccounts){
            userIds.add(newAccount.CF_Customer_Success_Manager__c);
            userIds.add(newAccount.SA__c);
            userIds.add(newAccount.TA__c);
        }
        
        if(userIds.isEmpty())return;
        
        Set<User> users = new Set<User>([SELECT Id, Name, CSM_Digital_Touch_Region__c, Digital_Touch_CSM__c FROM User WHERE Id IN :userIds]);
 
        Map<Id, User> mapOfUsers = new Map<Id, User>();
        if(users.size() > 0){
            for(User u : users){
                mapOfUsers.put(u.Id, u);
            }
        }              
        
        if(Trigger.isInsert){           
            for(Account newAccount : newAccounts){
                if(newAccount.CF_Customer_Success_Manager__c != null){
					if(newAccount.CSM_Engagement_Level__c == 'Digital Touch' && mapOfUsers.get(newAccount.CF_Customer_Success_Manager__c).CSM_Digital_Touch_Region__c == 'EMEA'){
						newAccount.Zendesk_CSM__c = 'csm_digital_emea';
					} else if(newAccount.CSM_Engagement_Level__c == 'Digital Touch' &&  mapOfUsers.get(newAccount.CF_Customer_Success_Manager__c).CSM_Digital_Touch_Region__c == 'NA'){
						newAccount.Zendesk_CSM__c = 'csm_digital_na';
					} else {
						newAccount.Zendesk_CSM__c = mapOfUsers.get(newAccount.CF_Customer_Success_Manager__c).Name;
					}
                }
                
                if(newAccount.SA__c != null)                    
                	newAccount.Zendesk_SA__c = mapOfUsers.get(newAccount.SA__c).Name;
                
                if(newAccount.TA__C != null)
                	newAccount.Zendesk_TA__c = mapOfUsers.get(newAccount.TA__c).Name; 
            }
        }
        else{
            for(Account newAccount : newAccounts){
                Account oldAccount = oldAccounts.get(newAccount.Id);
                
                if(newAccount.CF_Customer_Success_Manager__c != oldAccount.CF_Customer_Success_Manager__c || newAccount.CSM_Engagement_Level__c != oldAccount.CSM_Engagement_Level__c){
                    if(newAccount.CF_Customer_Success_Manager__c != null){
						if(newAccount.CSM_Engagement_Level__c == 'Digital Touch' && mapOfUsers.get(newAccount.CF_Customer_Success_Manager__c).CSM_Digital_Touch_Region__c == 'EMEA'){
							newAccount.Zendesk_CSM__c = 'csm_digital_emea';
						} else if(newAccount.CSM_Engagement_Level__c == 'Digital Touch' && mapOfUsers.get(newAccount.CF_Customer_Success_Manager__c).CSM_Digital_Touch_Region__c == 'NA'){
							newAccount.Zendesk_CSM__c = 'csm_digital_na';
						} else {
							newAccount.Zendesk_CSM__c = mapOfUsers.get(newAccount.CF_Customer_Success_Manager__c).Name;
						}
                    }
                    else
                        newAccount.Zendesk_CSM__c = null;  
                }
                      
                if(newAccount.SA__c != oldAccount.SA__c)
                    newAccount.Zendesk_SA__c = newAccount.SA__c != null ?
                    				           mapOfUsers.get(newAccount.SA__c).Name : null;                
                              
                if(newAccount.TA__c != oldAccount.TA__c)
                    newAccount.Zendesk_TA__c = newAccount.TA__c != null ?
                    						   mapOfUsers.get(newAccount.TA__c).Name : null; 
            }
        }
    }
}