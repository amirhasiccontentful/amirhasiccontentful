@isTest
private class CF_ContactCleanupZendeskBatchableTest {
    static testMethod void test() {
    	Test.startTest();
    	Contact contact1 = new Contact(Firstname = 'Bla', Lastname = 'Bla');
    	insert contact1;
    	
    	Contact contact2 = new Contact(Firstname = 'Firstname', Lastname = 'Lastname', Zendesk__zendesk_id__c = '123');
    	insert contact2;    	
            	
    	Database.executeBatch(new CF_ContactCleanupZendeskBatchable(), 200);
    	
    	Test.stopTest();
    	
    	List<Contact> withZendeskId = [SELECT Id FROM Contact WHERE Zendesk__zendesk_id__c != null LIMIT 1];
    	List<Contact> noZendeskId = [SELECT Id FROM Contact WHERE Zendesk__zendesk_id__c = null LIMIT 1];
    	
    	System.assertEquals(withZendeskId.size(), 0);
    	System.assertEquals(noZendeskId.size(), 1);
    	
    	
    }
}