@isTest
private class CF_LeadUpdateOpportunityTypeTriggerTest {

    static testMethod void myUnitTest() {
    	//Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('General').getRecordTypeId();
        Lead lead = new Lead(Lastname = 'Abc', Company = 'XYZ', Email = 'bla@gmail.com', Classification__c = 'Agency', LeadSource = 'Other');
        insert lead;
        
        lead.Firstname = 'asdf';
        lead.Classification__c = 'Enterprise';
        update lead;
    }
}