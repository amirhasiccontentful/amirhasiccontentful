@isTest
private class CF_AccountsBatchableTest {

    static testMethod void test() {
    	CF_Organization__c org1 = CF_OrganizationTest.testObject();
    	org1.gk_revenued_at__c = DateTime.now();
    	insert org1;

    	CF_User__c user = CF_UserTest.testObject();
    	insert user;
    	
    	CF_Organization_Membership__c om = CF_Organization_MembershipTest.testObject();
    	om.gk_organization__c = org1.id;
    	om.gk_user__c = user.id;
    	om.gk_role__c = 'owner';
    	insert om;
    	
    	Database.executeBatch(new CF_AccountsBatchable(), 200);
    }
}