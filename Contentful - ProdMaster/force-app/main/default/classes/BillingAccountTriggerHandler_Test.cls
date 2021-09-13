@isTest 
public class BillingAccountTriggerHandler_Test { 
	@testSetup static void loadTestData() {
		//Load CSV file saved in static resource  
        List<SObject> lstAcc = Test.loadData(Account.sObjectType,'testAccounts');
	}

	@isTest static void TEST_SetCFOrganizationKeyToBillingAccount() {
		Test.startTest();

		Account account = [SELECT Id FROM Account LIMIT 1];

		CF_Organization__c cfOrg = new CF_Organization__c(Name = 'test', gk_Name__c = 'test', gk_key__c = '123456789', gk_id__c = 123, Account__c = account.Id);
		insert cfOrg;

		Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Organization_Key__c = '123456789', Zuora__Account__c = account.Id);
		insert billingAccount;

		Test.stopTest();

		Zuora__CustomerAccount__c results = [SELECT CF_Organization__c FROM Zuora__CustomerAccount__c WHERE Id = :billingAccount.Id];

		System.assertEquals(cfOrg.Id, results.CF_Organization__c);

	}

	@isTest static void TEST_UpdateAccountBillingAddress_Insert() {
		Test.startTest();

		Account account = new Account(Name = 'Test Account');
		insert account;

		Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__Account__c = account.Id, Zuora__BillToAddress1__c = 'Test Address',  Zuora__BillToCity__c = 'Berlin',
																					Zuora__BillToCountry__c = 'Germany', Zuora__BillToPostalCode__c = '13351');
		insert billingAccount;

		Test.stopTest();

		Account results = [SELECT BillingStreet, BillingCity, BillingCountry, BillingPostalCode FROM Account WHERE Id = :account.Id];

		System.assertEquals('Test Address', results.BillingStreet);
		System.assertEquals('Berlin', results.BillingCity);
		System.assertEquals('Germany', results.BillingCountry);
		System.assertEquals('13351', results.BillingPostalCode);
	}

	@isTest static void TEST_UpdateAccountBillingAddress_Update() {
		Test.startTest();

		Account account = new Account(Name = 'Test Account');
		insert account;

		Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__Account__c = account.Id);
		insert billingAccount;

		billingAccount.Zuora__BillToAddress1__c = 'Test Address';
		billingAccount.Zuora__BillToCity__c = 'San Francisco';
		billingAccount.Zuora__BillToState__c = 'California';
		billingAccount.Zuora__BillToCountry__c = 'United States';
		billingAccount.Zuora__BillToPostalCode__c = '94341';

		update billingAccount;

		Test.stopTest();

		Account results = [SELECT BillingStreet, BillingState, BillingCity, BillingCountry, BillingPostalCode FROM Account WHERE Id = :account.Id];

		System.assertEquals('Test Address', results.BillingStreet);
		System.assertEquals('San Francisco', results.BillingCity);
		System.assertEquals('California', results.BillingState);
		System.assertEquals('United States', results.BillingCountry);
		System.assertEquals('94341', results.BillingPostalCode);
	}

	@isTest static void TEST_CalculateFieldsOnAccount() {
		Test.startTest();

		Account account = [SELECT Id FROM Account LIMIT 1];

		Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__Balance__c = 100, Zuora__Credit_Balance__c = 200, Zuora__Account__c = account.Id);
		insert billingAccount;

		Test.stopTest();

		Account results = [SELECT Zuora_Total_Bill_To_Account_Balance__c, Zuora_Total_Credit_Balance__c FROM Account WHERE Id = :account.Id];

		System.assertEquals(100, results.Zuora_Total_Bill_To_Account_Balance__c);
		System.assertEquals(200, results.Zuora_Total_Credit_Balance__c);


	}
}