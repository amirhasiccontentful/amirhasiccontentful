public with sharing class BillingAccountTriggerHandler extends TriggerHandler { 
	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/

	public override void beforeUpdate() {
		SetCFOrganizationKeyToBillingAccount(trigger.new);
	}

	public override void beforeInsert() {
		SetCFOrganizationKeyToBillingAccount(trigger.new);
	}

	public override void afterUpdate() {
		UpdateAccountBillingAddress(trigger.new, (Map<Id, Zuora__CustomerAccount__c>)trigger.oldMap);
		CalculateFieldsOnAccount(trigger.new, (Map<Id, Zuora__CustomerAccount__c>)trigger.oldMap);
	}

	public override void afterInsert() {
		UpdateAccountBillingAddress(trigger.new, null);
		CalculateFieldsOnAccount(trigger.new, (Map<Id, Zuora__CustomerAccount__c>)trigger.oldMap);
	}

	/****************************************************/
	/* TRIGGER METHODS									*/
	/****************************************************/

	// Name: SetCFOrganizationKeyToBillingAccount
	// Description: Populates CF_Organization__c field on Billing Account object
	private void SetCFOrganizationKeyToBillingAccount(List<Zuora__CustomerAccount__c> billingAccounts) {
		Set<String> organizationKeys = new Set<String>();
		List<Zuora__CustomerAccount__c> billingAccountsToUpdate = new List<Zuora__CustomerAccount__c>();

		for(Zuora__CustomerAccount__c billingAccount : billingAccounts) {
			if(String.IsNotBlank(billingAccount.Organization_Key__c) && String.isBlank(billingAccount.CF_Organization__c)) {
				organizationKeys.add(billingAccount.Organization_Key__c);
				billingAccountsToUpdate.add(billingAccount);
			}
		}

		Map<String, Id> cfOrganizationsByGKKey = new Map<String, Id>();
		for(CF_Organization__c cfOrg : [SELECT gk_key__c FROM CF_Organization__c WHERE gk_key__c IN :organizationKeys]) {
			cfOrganizationsByGKKey.put(cfOrg.gk_key__c, cfOrg.Id);
		}

		for(Zuora__CustomerAccount__c ba : billingAccountsToUpdate) {
			ba.CF_Organization__c = cfOrganizationsByGKKey.get(ba.Organization_Key__c);
		}
	}

	// Name: UpdateAccountBillingAddress
	// Description: Set Zuora Billing information to Account
	private void UpdateAccountBillingAddress(List<Zuora__CustomerAccount__c> billingAccounts, Map<Id, Zuora__CustomerAccount__c> oldBillingAccounts) {
		Set<Id> accountIds = new Set<Id>();
		Map<Id, Zuora__CustomerAccount__c> billingAccountsMap = new Map<Id, Zuora__CustomerAccount__c>();
		List<Account> accountsToUpdate = new List<Account>();

		for(Zuora__CustomerAccount__c billingAccount : billingAccounts) {
			if(billingAccount.Zuora__Account__c != null) {
				if(oldBillingAccounts != null) {
					Zuora__CustomerAccount__c oldBillingAccount = oldBillingAccounts.get(billingAccount.Id);
					if(oldBillingAccount != null) {
						if(oldBillingAccount.Zuora__BillToAddress1__c != billingAccount.Zuora__BillToAddress1__c || oldBillingAccount.Zuora__BillToCity__c  != billingAccount.Zuora__BillToCity__c || oldBillingAccount.Zuora__BillToState__c != billingAccount.Zuora__BillToState__c || oldBillingAccount.Zuora__BillToCountry__c != billingAccount.Zuora__BillToCountry__c || oldBillingAccount.Zuora__BillToPostalCode__c != billingAccount.Zuora__BillToPostalCode__c) {
							accountIds.add(billingAccount.Zuora__Account__c);
							billingAccountsMap.put(billingAccount.Zuora__Account__c, billingAccount);
						}
					}
				}
				else {
					accountIds.add(billingAccount.Zuora__Account__c);
					billingAccountsMap.put(billingAccount.Zuora__Account__c, billingAccount);
				}
			}
		}

		List<Account> accounts = [SELECT BillingStreet FROM Account WHERE id IN :accountIds];

		for(Account account : accounts) {
			Zuora__CustomerAccount__c billingAccount = billingAccountsMap.get(account.Id);
			
			if(String.isBlank(account.BillingStreet) ) { // only update if not set already
				account.BillingStreet = billingAccount.Zuora__BillToAddress1__c;
		        account.BillingCity = billingAccount.Zuora__BillToCity__c;
		        
		        if (billingAccount.Zuora__BillToCountry__c == 'United States' && String.isBlank(billingAccount.Zuora__BillToState__c) == false && billingAccount.Zuora__BillToState__c.contains('Armed Forces') == false) { // can only use state for the US
		        	account.BillingState = billingAccount.Zuora__BillToState__c;	
		        }
		        
		        account.BillingCountry = billingAccount.Zuora__BillToCountry__c;
		        account.BillingPostalCode = billingAccount.Zuora__BillToPostalCode__c;
		        accountsToUpdate.add(account);			
			}

		}    
	
	   	// If the duplicate rule is an alert rule, we can try to bypass it
	    Database.DMLOptions dml = new Database.DMLOptions(); 
	    dml.DuplicateRuleHeader.AllowSave = true;
	    Database.update(accountsToUpdate, dml);	
	}

	// Name: CalculateFieldsOnAccount
	// Description: Update calculated fields on Account every time Billing Account is updated
	private void CalculateFieldsOnAccount(List<Zuora__CustomerAccount__c> billingAccounts, Map<Id, Zuora__CustomerAccount__c> oldBillingAccounts) {
		Set<Id> accountIds = new Set<Id>();

		for(Zuora__CustomerAccount__c billingAccount : billingAccounts) {
			if(billingAccount.Zuora__Account__c != null) {
				
				if(oldBillingAccounts != null) {
					Zuora__CustomerAccount__c oldBillingAccount = oldBillingAccounts.get(billingAccount.Id);
					if(oldBillingAccount != null) {
						if((billingAccount.Zuora__Balance__c != oldBillingAccount.Zuora__Balance__c) || (billingAccount.Zuora__Credit_Balance__c != oldBillingAccount.Zuora__Credit_Balance__c)){
							accountIds.add(billingAccount.Zuora__Account__c);
						}
					} else if(billingAccount.Zuora__Balance__c != null || billingAccount.Zuora__Credit_Balance__c != null){
						accountIds.add(billingAccount.Zuora__Account__c);
					}
				}
				else if(billingAccount.Zuora__Balance__c != null || billingAccount.Zuora__Credit_Balance__c != null){
					accountIds.add(billingAccount.Zuora__Account__c);
				}
			}
		}

		if(!accountIds.isEmpty()){
			
			List<Account> accountsToUpdate = new List<Account>([SELECT Zuora_Total_Bill_To_Account_Balance__c, Zuora_Total_Credit_Balance__c, (SELECT Zuora__Balance__c, Zuora__Credit_Balance__c FROM R00N40000001kyLcEAI) FROM Account WHERE Id IN :accountIds]);

			for(Account account : accountsToUpdate) {
				account.Zuora_Total_Bill_To_Account_Balance__c = 0;
				account.Zuora_Total_Credit_Balance__c = 0;
				for(Zuora__CustomerAccount__c billingAccount : account.R00N40000001kyLcEAI) {
					if(billingAccount.Zuora__Balance__c != null) {
						account.Zuora_Total_Bill_To_Account_Balance__c += billingAccount.Zuora__Balance__c;
					}
					if(billingAccount.Zuora__Credit_Balance__c != null) {
						account.Zuora_Total_Credit_Balance__c += billingAccount.Zuora__Credit_Balance__c;
					}
				}
			}
			if(!accountsToUpdate.isEmpty()) {
				 // If the duplicate rule is an alert rule, we can try to bypass it
		   	 	Database.DMLOptions dml = new Database.DMLOptions(); 
		    	dml.DuplicateRuleHeader.AllowSave = true;
		    	Database.update(accountsToUpdate, dml);	
			}
		}
		
	}
}