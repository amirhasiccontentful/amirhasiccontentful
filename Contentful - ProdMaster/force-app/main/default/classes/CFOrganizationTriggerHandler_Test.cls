@isTest
public with sharing class CFOrganizationTriggerHandler_Test { 
	@testSetup static void loadTestData() {
		//Load CSV file saved in static resource  
        List<SObject> lstAcc = Test.loadData(Account.sObjectType,'testAccounts');
        List<SObject> lstCFOrgs = Test.loadData(CF_Organization__c.sObjectType,'testCFOrganizations');
	}

	@isTest static void TEST_CalculateFieldsOnAccount_All() {
		Test.startTest();

		CF_Organization__c cfOrg = [SELECT Account__c FROM CF_Organization__c LIMIT 1];
		Account account = [SELECT CF_Organization_Count__c, CF_Users__c, Maximum_Totango_Active_Users__c, Maximum_Totango_Engagement__c,
							(SELECT Id, CF_User_Count__c, TotangoActive_users_last_14_days__c, TotangoEngagement__c FROM CF_Organizations__r)
							FROM Account WHERE Id = :cfOrg.Account__c];

		System.assertEquals(account.CF_Organizations__r.size(), account.CF_Organization_Count__c);
		Decimal numberOfUsers = 0;
		for(CF_Organization__c org : account.CF_Organizations__r)
			numberOfUsers += org.CF_User_Count__c;
		System.assertEquals(numberOfUsers, account.CF_Users__c);
		//System.assertEquals(null, account.Maximum_Totango_Active_Users__c);
		//System.assertEquals(null, account.Maximum_Totango_Engagement__c);

		// Add new CF org with all fields that are calcualted
		CF_Organization__c newCFOrg = new CF_Organization__c(Account__c = account.Id,Name = 'test cf org',gk_name__c = 'test cf org',gk_id__c = 3000,gk_key__c = '1c64Ja3QmE54Ou0gue2GZj',
													cf_user_count__c = 5,gk_total_cda_requests__c = 500,TotangoActive_users_last_14_days__c = 1, TotangoEngagement__c = 5);
		insert newCFOrg;

		account = [SELECT CF_Organization_Count__c, CF_Users__c, Maximum_Totango_Active_Users__c, Maximum_Totango_Engagement__c,
							(SELECT Id, CF_User_Count__c, TotangoActive_users_last_14_days__c, TotangoEngagement__c FROM CF_Organizations__r)
							FROM Account WHERE Id = :cfOrg.Account__c];

		System.assertEquals(account.CF_Organizations__r.size(), account.CF_Organization_Count__c);
		numberOfUsers = 0;
		for(CF_Organization__c org : account.CF_Organizations__r)
			numberOfUsers += org.CF_User_Count__c;
		System.assertEquals(numberOfUsers, account.CF_Users__c);
		//System.assertEquals(1, account.Maximum_Totango_Active_Users__c);
		//System.assertEquals(5, account.Maximum_Totango_Engagement__c);

		Test.stopTest();
	}

	@isTest static void testCoverate() {
		CF_Organization__c cfOrg = [SELECT Account__c FROM CF_Organization__c LIMIT 1];
		Lead lead = new Lead(LastName = 'test', Company = 'test', LeadSource = 'Other', CF_Organization__c = cfOrg.Id);
		insert lead;

		update cfOrg;
	}
}