@isTest 
public with sharing class CF_UserTest {
	public static CF_User__c testObject() {
	   CF_User__c user = new CF_User__c();
       
       user.gk_id__c = 1;
       user.gk_key__c = 'abc';
       user.gk_first_name__c = 'first_name';
       user.gk_last_name__c = 'last_name';
       user.gk_email__c = 'email@test.com';
       user.gk_imported_at__c = null;
       
       return user;
	}
		
    static testMethod void testCreateLead() {       
       CF_User__c user = CF_UserTest.testObject();
       
       insert user;
       
       // Lead lead = [SELECT id, CF_User__r.id FROM Lead WHERE CF_User__r.id =:user.Id];
       
       // System.assertEquals(lead.CF_User__r.id, user.id);
    }
    
    static testMethod void testContactFromUser() {       
       CF_User__c user = CF_UserTest.testObject();
       
       insert user;
       
       Contact c = CF_User.contactFromUser(user);
       
       // Lead lead = [SELECT id, CF_User__r.id FROM Lead WHERE CF_User__r.id =:user.Id];
       
       // System.assertEquals(lead.CF_User__r.id, user.id);
    }    
    
    static testMethod void testSkipCreateLead() {       
       CF_User__c user = CF_UserTest.testObject();
	   user.gk_imported_at__c = Datetime.now(); 
	   
       insert user;
       
       //try {
       //		Lead lead = [SELECT id, CF_User__r.id FROM Lead WHERE CF_User__r.id =:user.Id];
       //} catch(QueryException e) {
       	
       //}
    }    
}