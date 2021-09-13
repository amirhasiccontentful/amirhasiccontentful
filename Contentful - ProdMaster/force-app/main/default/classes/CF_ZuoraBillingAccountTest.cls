@isTest
private class CF_ZuoraBillingAccountTest {

    static testMethod void myUnitTest() {
    	Account a = new Account();
    	a.name = 'Account';
    	insert a;
		
		CF_Organization__c org = CF_OrganizationTest.testObject();
		org.gk_key__c = '1234';
		insert org;
		
		Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c();
		
		ca.Zuora__Account__c = a.id;
		ca.organization_key__c = '1234';
		ca.Zuora__BillToAddress1__c = 'asdf';
		ca.Zuora__BillToCity__c = 'new york';
		ca.Zuora__BillToCountry__c = 'United States';
		ca.Zuora__BillToState__c = 'California';
		ca.Zuora__BillToPostalCode__c = '1234';
		
		insert ca;
		        
        
    }
}