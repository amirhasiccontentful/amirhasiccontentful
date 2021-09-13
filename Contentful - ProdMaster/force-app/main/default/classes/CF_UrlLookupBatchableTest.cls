@isTest
private class CF_UrlLookupBatchableTest {

    static testMethod void myUnitTest() {
    	Test.startTest();
    	CF_Organization__c org = CF_OrganizationTest.testObject();
    	insert org; 	
            	
    	Database.executeBatch(new CF_UrlLookupBatchable(), 200);
    	
    	Test.stopTest();
    } 
}