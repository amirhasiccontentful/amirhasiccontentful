@isTest
public class CF_Test_LeadSource {
	
	/*@testSetup
	static void TEST_Setup() {

		Lead lead = new Lead(
			Company = 'Test Comapny',
			LastName = 'Doe',
			LeadSource = 'Other');

		insert lead;
	}

	@isTest
	static void TEST_ValidateLeadSourceOnDelete_AppNewUser() {
		Test.startTest();

		Lead lead = [SELECT LeadSource FROM Lead LIMIT 1];

		// TEST LeadSource = App - New User
		lead.LeadSource = 'App - New User';
		update lead;

		Lead testLead = [SELECT LeadSource FROM Lead LIMIT 1];

		Database.DeleteResult deleteResult = Database.delete(testLead, false);
		System.assertEquals(false, deleteResult.isSuccess());

		for(Database.Error err : deleteResult.getErrors()) {
			System.assertEquals('Cannot Delete App Leads', err.getMessage());
		}

		Test.stopTest();
	}

	@isTest
	static void TEST_ValidateLeadSourceOnDelete_AppInvited() {
		Test.startTest();

		Lead lead = [SELECT LeadSource FROM Lead LIMIT 1];

		// TEST LeadSource = App - New User
		lead.LeadSource = 'App - Invited';
		update lead;

		Lead testLead = [SELECT LeadSource FROM Lead LIMIT 1];

		Database.DeleteResult deleteResult = Database.delete(testLead, false);
		System.assertEquals(false, deleteResult.isSuccess());

		for(Database.Error err : deleteResult.getErrors()) {
			System.assertEquals('Cannot Delete App Leads', err.getMessage());
		}	

		Test.stopTest();
	}
	
	@isTest
	static void TEST_ValidateLeadSourceOnDelete_Other() {
		Test.startTest();

		Lead lead = [SELECT LeadSource FROM Lead LIMIT 1];

		// TEST LeadSource = Other
		lead.LeadSource = 'Other';
		update lead;

		Lead leadOther = [SELECT LeadSource FROM Lead LIMIT 1];
		delete leadOther;

		List<Lead> leadTest = [SELECT LeadSource FROM Lead];	
		System.assertEquals(0, leadTest.size());

		Test.stopTest();
	}*/
}