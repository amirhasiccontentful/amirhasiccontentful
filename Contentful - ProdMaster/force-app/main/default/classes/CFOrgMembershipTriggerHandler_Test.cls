@isTest
public class CFOrgMembershipTriggerHandler_Test {
	
    private static testMethod void cfOrganizationMemberships_test(){
        
        ExecuteSetting__c newSetting = new ExecuteSetting__c();
        newSetting.Name = 'CF Organization Membership Rollup';
        newSetting.Active__c = true;
        newSetting.Execute__c = false;
        insert newSetting;

        Lead newSignUP = new Lead();
		newSignUP.FunnelBeam_Company_Revenue__c = 1000000;
		newSignUP.Company = 'Test';
        newSignUP.LastName = 'test2';
        newSignUP.LeadSource = 'Website Direct';
        newSignUP.FunnelBeam_Enrichment_Done__c = false;
        newSignUp.Title = 'CTO';
        newSignUP.Email = 'test@abc.com';
		insert newSignUP;

		CF_User__c newCFUser = new CF_User__c();
		newCFUser.Name = 'Test';
		newCFUser.Lead__c = newSignUP.Id;
		newCFUser.gk_id__c = 123255;
		newCFUser.gk_key__c = '1aynj3UZRtqU6NJ1y8a53h';
		newCFUser.gk_first_visit_url__c = 'https://www.contentful.com/faq/search-and-content-organization/';
		newCFUser.gk_email__c = 'test@abc.com';
		newCFUser.BI_User_Activated_At__c = System.now();
		insert newCFUser;

		List<CF_Organization__c> lstOfSFOrgsForInsert = new List<CF_Organization__c>();

		CF_Organization__c newCFOrg = new CF_Organization__c();
		newCFOrg.Name = 'Test CF';
		newCFOrg.gk_first_visit_url__c = 'https://www.contentful.com/faq/search-and-content-organization/';
		newCFOrg.gk_first_visit_referer__c = 'https://www.contentful.com/faq/search-and-content-organization/';
		newCFOrg.gk_last_visit_url__c = 'https://www.contentful.com/faq/search-and-content-organization/';
		newCFOrg.gk_last_visit_referer__c = 'https://www.contentful.com/faq/search-and-content-organization/';
		newCFOrg.gk_id__c = 123255;
		newCFOrg.gk_key__c = '1aynj3UZRtqU6NJ1y8a53g';
		newCFOrg.gk_name__c = 'Test CF';
		
		lstOfSFOrgsForInsert.add(newCFOrg);

		/*CF_Organization__c newCFOrg2 = new CF_Organization__c();
		newCFOrg2.Name = 'Test';
		newCFOrg2.gk_first_visit_url__c = 'https://www.contentful.com/faq/search-and-content-organization/';
		newCFOrg2.gk_first_visit_referer__c = 'https://www.contentful.com/faq/search-and-content-organization/';
		newCFOrg2.gk_last_visit_url__c = 'https://www.contentful.com/faq/search-and-content-organization/';
		newCFOrg2.gk_last_visit_referer__c = 'https://www.contentful.com/faq/search-and-content-organization/';
		newCFOrg2.gk_id__c = 123255;
		newCFOrg2.gk_key__c = '1aynj3UZRtqU6NJ1y8a53h';
		newCFOrg2.gk_name__c = 'Test';
		newCFOrg2.Lead__c = newSignUP.Id;
		lstOfSFOrgsForInsert.add(newCFOrg2);*/

		insert lstOfSFOrgsForInsert;

		CF_Organization_Membership__c newOrgMembership = new CF_Organization_Membership__c();
		newOrgMembership.Name = 'Test Org Membership';
		newOrgMembership.gk_id__c = 123255;
		newOrgMembership.gk_key__c = '1aynj3UZRtqU6NJ1y8a53h';
		newOrgMembership.gk_user_id__c = 123255;
		newOrgMembership.gk_organization_id__c = 123255;
		newOrgMembership.gk_organization__c = newCFOrg.Id;
		newOrgMembership.gk_user__c = newCFUser.Id;
		
        Test.startTest();
        insert newOrgMembership;
		new CFOrgMembershipRollupsOnSchedule().execute(null);
        Test.stopTest();
		
		List<CF_Organization__c> checkCFOrg = [SELECT Id, Name, cf_user_count__c FROM CF_Organization__c];
		System.assertEquals(1, checkCFOrg.size());
		System.assertEquals(1, checkCFOrg[0].cf_user_count__c);

		List<CF_User__c> checkCFUser = [SELECT Id, Name, Organization_Count__c, BI_User_Activated_At__c FROM CF_User__c];
		System.assertEquals(1, checkCFUser.size());
		System.assertEquals(1, checkCFUser[0].Organization_Count__c);
    }
}