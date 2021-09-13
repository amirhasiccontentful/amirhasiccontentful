@isTest
public class LeadCFOrganizationRollups_Test {
    private static testMethod void testLeadCFOrganizationRollups(){
    
        CF_Organization__c cfOrg = new CF_Organization__c();
        cfOrg.Name = 'Test';
        cfOrg.gk_id__c = 111111;
        cfOrg.gk_key__c = '222222';
        cfOrg.gk_name__c = 'Test';
        insert cfOrg;
        
        Lead g = new Lead();
        g.Company = 'ttt';
        g.LastName = 'ttt';
        g.LeadSource = 'Signup Role';
        g.Email = 'test@test.com';
        g.Title = 'Editor';
        g.CF_Organization__c = cfOrg.Id;
        insert g;

        Test.startTest();
            new GainsightLeadUsageRollups_Scheduled().execute(null);
        Test.stopTest();
    }
}