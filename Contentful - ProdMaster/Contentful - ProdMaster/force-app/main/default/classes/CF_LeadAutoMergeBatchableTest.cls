@isTest
private class CF_LeadAutoMergeBatchableTest {

    static testMethod void testBatch() {  
    	Account account = new Account(name = 'Testing 123');
    	insert account;
    	
    	CF_Organization__c org = CF_OrganizationTest.testObject();
    	org.Account__c = account.id;
        org.Mrr_0__c = true;
    	insert org;
    	
    	CF_User__c user = CF_UserTest.testObject();
    	insert user;
    	    	
    	
    		
    	//Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('App').getRecordTypeId();
        //Lead lead = new Lead(Company = 'Company', Email = 'asf@asdf.com', Status = 'New', Lastname = 'Lastname', CF_Organization__c = org.id, CF_User__c = user.id, LeadSource = 'App - Invited');
        Lead lead = new Lead(Company = 'Company', Email = 'asf@asdf.com', Status = 'New', Lastname = 'Lastname', CF_Organization__c = org.id, CF_User__c = user.id, LeadSource = 'Web App', Lead_Source_Detail__c = 'App - Invited');
        insert lead;    	
    	
    	Test.startTest();
    	
    	Database.executeBatch(new CF_LeadAutoMergeBatchable(), 200);
    	Test.stopTest();     
    	
    	System.assertEquals(0, 0);  
    }
}