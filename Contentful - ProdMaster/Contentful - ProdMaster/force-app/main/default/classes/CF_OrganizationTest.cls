@isTest 
public with sharing class CF_OrganizationTest {
	public static CF_Organization__c testObject() {
	   CF_Organization__c o = new CF_Organization__c();
       
       o.gk_id__c = 100;
       o.gk_key__c = 'abc';
       o.gk_name__c = 'name';
       
       return o;		
	}
    
    public static testMethod void testCFOrganization(){
        
        List<CF_Organization__c> cforgs = new List<CF_Organization__c>();
        
        Lead lead = TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,'Enterprise','1',true,'www.test.com', null,true,false,100000000,10001);
        insert lead;
        
    	CF_Organization__c org1 = CF_OrganizationTest.testObject();
    	org1.gk_revenued_at__c = DateTime.now();
    	insert org1;
        
        cforgs.add(org1);

    	CF_User__c user = CF_UserTest.testObject();
        user.Lead__c = lead.Id;
    	insert user;
        
        lead.CF_Organization__c = org1.Id;
        lead.CF_User__c = user.Id;
        update lead;
    	
    	CF_Organization_Membership__c om = CF_Organization_MembershipTest.testObject();
    	om.gk_organization__c = org1.id;
    	om.gk_user__c = user.id;
    	om.gk_role__c = 'owner';
    	insert om;
        
        CF_Organization.createAccountsAndContactsForOrganizations(cforgs, false);
        
    }
}