@isTest 
public with sharing class CF_Organization_MembershipTest {
	public static CF_Organization_Membership__c testObject() {
	   CF_Organization_Membership__c om = new CF_Organization_Membership__c();
       
       om.gk_id__c = 100;
       om.gk_key__c = 'abc';
       om.gk_organization_id__c = 200;
       om.gk_organization__c = null;
       om.gk_user_id__c = 300;
       om.gk_user__c = null;
       
       return om;		 
	}
	
    static testMethod void testUpdateRelationshipsOnSave() {
    	CF_Organization_Membership__c om = CF_Organization_MembershipTest.testObject();
    	
    	CF_User__c user = CF_UserTest.testObject();
    	user.gk_id__c = 300;
    	insert user;
    	
    	CF_Organization__c org = CF_OrganizationTest.testObject();
    	org.gk_id__c = 200;
    	insert org;
    	
    	System.assertEquals(om.gk_user__c, null);
    	System.assertEquals(om.gk_organization__c, null);
    	
    	insert om;
    	
    	//CF_Organization_Membership__c result = [select Id, gk_user__c, gk_organization__c from CF_Organization_Membership__c where id = :om.id limit 1];
        
    	//System.assertEquals(result.gk_user__c, user.id);
    	//System.assertEquals(result.gk_organization__c, org.id);    	
    }
    
    static testMethod void testSetRelationshipsFromId() {
    	CF_Organization_Membership__c om = CF_Organization_MembershipTest.testObject();
    	
    	CF_User__c user = CF_UserTest.testObject();
    	user.gk_id__c = 300;
    	insert user;
    	
    	CF_Organization__c org = CF_OrganizationTest.testObject();
    	org.gk_id__c = 200;
    	insert org;
    	
    	System.assertEquals(om.gk_user__c, null);
    	System.assertEquals(om.gk_organization__c, null);
    	
    	insert om;
    	
		CF_Organization_Membership.setRelationshipsFromId(om);
    }    
    
    static testMethod void testUpdateName() {
    	CF_Organization_Membership__c om = CF_Organization_MembershipTest.testObject();
    	
    	CF_User__c user = CF_UserTest.testObject();
    	user.gk_id__c = 300;
    	insert user;
    	
    	CF_Organization__c org = CF_OrganizationTest.testObject();
    	org.gk_id__c = 200;
    	insert org;
    	
    	System.assertEquals(om.gk_user__c, null);
    	System.assertEquals(om.gk_organization__c, null);
    	
    	insert om;
    	
		CF_Organization_Membership.updateName(om);
    }        
    
    static testMethod void testUpdateRelationshipsOnSaveWithMissingRelationship() {
    	CF_Organization_Membership__c om = CF_Organization_MembershipTest.testObject();
    	
    	CF_User__c user = CF_UserTest.testObject();
    	user.gk_id__c = 300;
    	insert user;
    	
    	System.assertEquals(om.gk_user__c, null);
    	System.assertEquals(om.gk_organization__c, null);
    	
    	insert om;
    	
    	CF_Organization_Membership__c result = [select Id, gk_user__c, gk_organization__c from CF_Organization_Membership__c where id = :om.id limit 1];
        
    	//System.assertEquals(result.gk_user__c, user.id);    	
    }   
    
    static testMethod void testUpdateNameTrigger() {
    	CF_User__c user = CF_UserTest.testObject();
    	user.gk_id__c = 300;
    	insert user;
    	
    	CF_Organization__c org = CF_OrganizationTest.testObject();
    	org.gk_id__c = 200;
    	insert org;    	
    	
    	CF_Organization_Membership__c om = CF_Organization_MembershipTest.testObject();
    	om.gk_organization_id__c = 300;
    	om.gk_user_id__c = 200;
    	insert om;
    } 
}