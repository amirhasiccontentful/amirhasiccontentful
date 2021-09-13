@isTest
public with sharing class CF_UserDetailButtonControllerTest {

    static testMethod void testCreateLeadFromCF_User(){
    	CF_Organization__c org1 = CF_OrganizationTest.testObject();
    	insert org1;

    	CF_User__c user = CF_UserTest.testObject();
    	insert user;
    	
    	CF_Organization_Membership__c om = CF_Organization_MembershipTest.testObject();
    	om.gk_organization__c = org1.id;
    	om.gk_user__c = user.id;
    	insert om;
    	
    	CF_Organization_Membership.setRelationshipsFromId(om);
    	update om;    	

 		ApexPages.CurrentPage().getparameters().put('id', user.id);
    	ApexPages.StandardController sc = new ApexPages.standardController(user);
    	CF_UserDetailButtonController usc = new CF_UserDetailButtonController(sc);
		
		PageReference pr = usc.createLeadFromCF_User();
		
    }
}