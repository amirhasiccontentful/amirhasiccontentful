@isTest
public class PioneerContact_Batchable_Test {
    
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
    
    static testMethod void testPioneerContact() {
    	CF_Organization_Membership__c om = CF_Organization_MembershipTest.testObject();
    	
      Account acc = new Account();
      acc.name = 'Test acc';
      insert acc;
        
    	CF_User__c user = CF_UserTest.testObject();
    	user.gk_id__c = 300;
    	insert user;
    	
    	CF_Organization__c org = CF_OrganizationTest.testObject();
    	org.gk_id__c = 200;
      org.gk_created_at__c = System.today();
      org.gk_created_by_id__c = '300';
      org.Account__c = acc.Id;
    	insert org;
    	
    	insert om;
        
      Test.startTest();
       new PioneerContactBatchScheduleUpdate().execute(null);
      Test.stopTest();
        
      List<Account> accs = [SELECT Id, Pioneer_CF_User__c, Pioneer_Contact__c FROM Account WHERE Id = :acc.Id];
      System.assertEquals(user.Id, accs[0].Pioneer_CF_User__c);
      	
    }
    
}