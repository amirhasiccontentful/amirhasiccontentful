@isTest
private class CF_LeadMoveToQueueTriggerTest {

    static testMethod void myUnitTest() {
    	CF_Organization__c org = CF_OrganizationTest.testObject();
    	insert org;
    	
    	CF_User__c user = CF_UserTest.testObject();
    	insert user;
    	
    	//Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('App').getRecordTypeId();
        Lead lead = new Lead(Company = 'Company', Email = 'asf@asdf.com', Status = 'New', Lastname = 'Lastname', CF_Organization__c = org.id, CF_User__c = user.id, LeadSource = 'App - Signup');
        insert lead;
        
        lead.Status = 'Qualified';
        lead.Project_Description__c = 'This is a description. This is a description. This is a description. This is a description. This is a description. This is a description. This is a description. ';
        lead.Customer_Success_Manager__c = UserInfo.getUserId();
        update lead;
    }
}