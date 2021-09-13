@isTest
private class CF_OrganizationUrlLookupTriggerTest {

    static testMethod void myUnitTest() {
    	CF_Organization__c org = CF_OrganizationTest.testObject();
		org.gk_first_visit_referer__c = 'http://www.teeeeeeeest.de';
		org.gk_last_visit_referer__c = 'http://www.teeeeeeeest.de';
		
		org.gk_first_visit_url__c = 'http://www.google.de';
		org.gk_last_visit_url__c = 'http://yahoo.de';    	
    	
    	insert org;
    }
}