@isTest
public with sharing class CF_UserCreateLeadBatchableTest {

    static testMethod void test(){
		
        CF_Organization__c org = new CF_Organization__c();
        org.Name = 'Test';
        org.gk_name__c = 'Test';
        org.gk_id__c = 2;
        org.gk_key__c = '2';
        insert org;
        
    	Test.startTest();
    	CF_User__c user1 = CF_UserTest.testObject();
    	insert user1;
        
        CF_organization_Membership__c member = new CF_organization_Membership__c();
        member.name = 'Test';
        member.gk_organization__c = org.Id;
        member.gk_user__c = user1.Id;
        member.gk_id__c = 1; 
        member.gk_key__c = '1';
        member.gk_organization_id__c = 2;
        member.gk_user_id__c = 1;
        insert member;
            	
    	Database.executeBatch(new CF_UserCreateLeadBatchable(), 200);
    	
    	Test.stopTest();
    	

    	
    }
}