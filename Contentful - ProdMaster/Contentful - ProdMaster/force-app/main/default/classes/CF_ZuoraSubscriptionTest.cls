@isTest
private class CF_ZuoraSubscriptionTest {

    static testMethod void myUnitTest() {
    	Account a = new Account();
    	a.name = 'Account';
    	insert a;
		
		Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c();
		
		ca.Zuora__Account__c = a.id;
		ca.Zuora__BillToAddress1__c = 'asdf';
		ca.Zuora__BillToCity__c = 'new york';
		ca.Zuora__BillToCountry__c = 'United States';
		ca.Zuora__BillToState__c = 'California';
		ca.Zuora__BillToPostalCode__c = '1234';
		
		insert ca;
		
		Zuora__Subscription__c s = new Zuora__Subscription__c();
		s.Zuora__CustomerAccount__c = ca.id;
		s.Zuora__Account__c = a.id;
		s.Zuora__MRR__c = 100.0;
		s.Zuora__Status__c = 'Active';
		
		s.CurrencyIsoCode = 'USD';
		
		insert s;
		
		s.Zuora__MRR__c = 101.0;
		update s;
		
        
    }
}