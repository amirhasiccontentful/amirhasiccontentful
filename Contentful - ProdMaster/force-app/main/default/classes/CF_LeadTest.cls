@isTest 
public with sharing class CF_LeadTest {
    static testMethod void testLeadFromCF_User() {
       CF_User__c user = CF_UserTest.testObject();  
       user.gk_id__c = 1;
       user.gk_imported_at__c = Datetime.now();
       insert user; 
       
       CF_Organization__c org = CF_OrganizationTest.testObject();
       org.gk_id__c = 2;
       org.gk_name__c = 'NAME';
       insert org;
       
      CF_Organization_Membership__c om = CF_Organization_MembershipTest.testObject();  
       om.gk_user_id__c = 1;
       om.gk_organization_id__c = 2;
       CF_Organization_Membership.setRelationshipsFromId(om);
       insert om;        
              
       
       System.assertEquals(user.gk_email__c, 'email@test.com');
       
       Lead lead = new Lead();
       CF_Lead.copyAttributesFromUserToLead(user, org, lead); 
       
       System.assertEquals(lead.CF_User__c, user.id);
       System.assertEquals(lead.CF_Organization__c, org.id); 
       System.assertEquals(lead.LastName, user.gk_last_name__c);
       System.assertEquals(lead.company, 'NAME');
       
       insert lead;
       
	   Lead reloadedLead = [SELECT id FROM Lead WHERE Id =:lead.Id];
       
       System.assertEquals(lead.id, reloadedLead.id);

       CF_Lead.shouldAutoMergeLead(lead);
    }
    
    static testMethod void testLeadFromCF_UserNoRelationships() {
       CF_User__c user = CF_UserTest.testObject();  
       user.gk_id__c = 1;
       user.gk_imported_at__c = Datetime.now();
       insert user; 
       
       CF_Organization__c org = CF_OrganizationTest.testObject();
       org.gk_id__c = 2;
       org.gk_name__c = 'NAME';
       insert org;
       
       CF_Organization_Membership__c om = CF_Organization_MembershipTest.testObject();  
       om.gk_user_id__c = 1;
       om.gk_organization_id__c = 2;      
       insert om;        
              
       
       System.assertEquals(user.gk_email__c, 'email@test.com');
       
       Lead lead = new Lead();
       CF_Lead.copyAttributesFromUserToLead(user, org, lead);
       
       System.assertEquals(lead.CF_User__c, user.id);
       System.assertEquals(lead.CF_Organization__c, org.id); 
       System.assertEquals(lead.LastName, user.gk_last_name__c);
       System.assertEquals(lead.company, 'NAME');
       
       insert lead;
       
	   Lead reloadedLead = [SELECT id FROM Lead WHERE Id =:lead.Id];
       
       System.assertEquals(lead.id, reloadedLead.id);

       Account acc = new Account(Name = 'Test'); insert acc;

       Contact con = new Contact(AccountId = acc.id, Lastname = 'last_name', FirstName = 'first_name'); insert con;

       CF_Lead.shouldMergeLeadWithContact(lead, con);
    }    
}