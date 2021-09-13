@isTest
private class CF_LeadIdleBatchableTest {
    static testMethod void test() { 
    	Test.startTest();            	
    	Database.executeBatch(new CF_LeadIdleBatchable(), 200);
    	
    	Test.stopTest();    	
    }
}