@isTest
public class CF_Test_LeadBulk {
	@testSetup 
	static void Test_BulkInsert() {
		List<Lead> leads = new List<Lead>();
		for (Integer i = 0; i < 1000; i++) {
			Lead lead = new Lead(LastName = 'Test Contact', Company = 'Test Company', LeadSource = 'Other');
			leads.add(lead);
		}
		if (!leads.isEmpty()) {
			insert leads;
		}
	}

	@isTest
	static void Test_BulkUpdate() {
		List<Lead> leads = [SELECT Id FROM Lead];
		if (!leads.isEmpty()) {
			update leads;
		}
	}

	@isTest
	static void Test_BulkDelete() {
		List<Lead> leads = [SELECT Id FROM Lead];
		if (!leads.isEmpty()) {
			delete leads;
		}
	}
}