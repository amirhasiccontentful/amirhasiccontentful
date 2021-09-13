@isTest
public with sharing class ZuoraQuoteTriggerHandler_Test {
	@testSetup
 	static void testSetup() {
		Account acc = new Account(Name = 'Test Account');
		insert acc;

		Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id, Email = 'test@acme.com');
		insert con;

		Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Appointment', CloseDate =  date.today());
		insert opp;

		zqu__Quote__c quote = new zqu__Quote__c(Name = 'Test Quote', zqu__Primary__c = true, zqu__Opportunity__c = opp.Id);
		insert quote;
        
        zqu__Quote__c quote2 = new zqu__Quote__c(Name = 'Test Quote2', zqu__Primary__c = true, zqu__Opportunity__c = opp.Id);
		insert quote2;
	}

	@isTest
	static void TEST_ZuoraQuoteTestCoverage() {
        Test.startTest();
		List<zqu__Quote__c> quotes = [SELECT Id FROM zqu__Quote__c];
        List<zqu__Quote__c> updateQuote = new List<zqu__Quote__c>();
        for(zqu__Quote__c q : quotes) {
            updateQuote.add(q);
        }
		if(!updateQuote.isEmpty()) 
			update updateQuote;
        Test.stopTest();
	}
}