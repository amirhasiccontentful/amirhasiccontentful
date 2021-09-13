@isTest
public class CF_Test_LeadContacts {
/*@testSetup 
	static void TEST_Setup() {

		Lead lead = new Lead(
			Company = 'Test Comapny',
			LastName = 'Doe',
			LeadSource = 'Other');

		insert lead;
	}

	@isTest
	static void TEST_AssignLeadContacts_Sales() {
		Test.startTest();
		
		Map<String, User> usersByProfileNameMap = new Map<String, User>();

		List<User> users = [SELECT Profile.Name FROM User WHERE IsActive = true];
		List<Lead> leads = [SELECT Owner.Profile.Name, Sales_Manager__c, Customer_Success_Manager__c, Prospecting_Manager__c, Product_Expert__c FROM Lead];
		
		for (User user : users) {
			usersByProfileNameMap.put(user.Profile.Name, user);
		}

		// TEST CF - Sales
		User testUser = usersByProfileNameMap.get('CF - Sales');
		System.runAs(testUser) {
			leads[0].OwnerId = testUser.Id;
			update leads;

			List<Lead> testLeads = [SELECT Sales_Manager__c, Customer_Success_Manager__c, Prospecting_Manager__c, Product_Expert__c, OwnerId FROM Lead];
			System.assertEquals(testLeads[0].OwnerId, testLeads[0].Sales_Manager__c);
			System.assertEquals(null, testLeads[0].Customer_Success_Manager__c);
			System.assertEquals(null, testLeads[0].Prospecting_Manager__c);
			System.assertEquals(null, testLeads[0].Product_Expert__c);
		}

		Test.stopTest();
	}

	@isTest
	static void TEST_AssignLeadContacts_CustomerSuccess() {
		Test.startTest();
		
		Map<String, User> usersByProfileNameMap = new Map<String, User>();

		List<User> users = [SELECT Profile.Name FROM User WHERE IsActive = true];
		List<Lead> leads = [SELECT Owner.Profile.Name, Sales_Manager__c, Customer_Success_Manager__c, Prospecting_Manager__c, Product_Expert__c FROM Lead];
		
		for (User user : users) {
			usersByProfileNameMap.put(user.Profile.Name, user);
		}

		// TEST CF - Customer Success
		User testUser = usersByProfileNameMap.get('CF - Customer Success');
		System.runAs(testUser) {
			leads[0].OwnerId = testUser.Id;
			update leads;

			List<Lead> testLeads = [SELECT Sales_Manager__c, Customer_Success_Manager__c, Prospecting_Manager__c, Product_Expert__c, OwnerId FROM Lead];
			System.assertEquals(null, testLeads[0].Sales_Manager__c);
			System.assertEquals(testLeads[0].OwnerId, testLeads[0].Customer_Success_Manager__c);
			System.assertEquals(null, testLeads[0].Prospecting_Manager__c);
			System.assertEquals(null, testLeads[0].Product_Expert__c);
		}

		Test.stopTest();
	}

	@isTest
	static void TEST_AssignLeadContacts_Prospecting() {
		Test.startTest();
		
		Map<String, User> usersByProfileNameMap = new Map<String, User>();

		List<User> users = [SELECT Profile.Name FROM User WHERE IsActive = true];
		List<Lead> leads = [SELECT Owner.Profile.Name, Sales_Manager__c, Customer_Success_Manager__c, Prospecting_Manager__c, Product_Expert__c FROM Lead];
		
		for (User user : users) {
			usersByProfileNameMap.put(user.Profile.Name, user);
		}

		// TEST CF - Prospecting
		User testUser = usersByProfileNameMap.get('CF - Prospecting');
		System.runAs(testUser) {
			leads[0].OwnerId = testUser.Id;
			update leads;

			List<Lead> testLeads = [SELECT Sales_Manager__c, Customer_Success_Manager__c, Prospecting_Manager__c, Product_Expert__c, OwnerId FROM Lead];
			System.assertEquals(null, testLeads[0].Sales_Manager__c);
			System.assertEquals(null, testLeads[0].Customer_Success_Manager__c);
			System.assertEquals(testLeads[0].OwnerId, testLeads[0].Prospecting_Manager__c);
			System.assertEquals(null, testLeads[0].Product_Expert__c);
		}

		Test.stopTest();
	}

	@isTest
	static void TEST_AssignLeadContacts_ProductExpert() {
		Test.startTest();
		
		Map<String, User> usersByProfileNameMap = new Map<String, User>();

		List<User> users = [SELECT Profile.Name FROM User WHERE IsActive = true];
		List<Lead> leads = [SELECT Owner.Profile.Name, Sales_Manager__c, Customer_Success_Manager__c, Prospecting_Manager__c, Product_Expert__c FROM Lead];
		
		for (User user : users) {
			usersByProfileNameMap.put(user.Profile.Name, user);
		}

		// TEST CF - Product Expert
		User testUser = usersByProfileNameMap.get('CF - Product Expert');
		System.runAs(testUser) {
			leads[0].OwnerId = testUser.Id;
			update leads;

			List<Lead> testLeads = [SELECT Sales_Manager__c, Customer_Success_Manager__c, Prospecting_Manager__c, Product_Expert__c, OwnerId FROM Lead];
			System.assertEquals(null, testLeads[0].Sales_Manager__c);
			System.assertEquals(null, testLeads[0].Customer_Success_Manager__c);
			System.assertEquals(null, testLeads[0].Prospecting_Manager__c);
			System.assertEquals(testLeads[0].OwnerId, testLeads[0].Product_Expert__c);
		}

		Test.stopTest();
	}

	@isTest
	static void TEST_AssignLeadContacts_Admin() {
		Test.startTest();
		
		Map<String, User> usersByProfileNameMap = new Map<String, User>();

		List<User> users = [SELECT Profile.Name FROM User WHERE IsActive = true];
		List<Lead> leads = [SELECT Owner.Profile.Name, Sales_Manager__c, Customer_Success_Manager__c, Prospecting_Manager__c, Product_Expert__c FROM Lead];
		
		for (User user : users) {
			usersByProfileNameMap.put(user.Profile.Name, user);
		}

		// TEST CF - Product Expert
		User testUser = usersByProfileNameMap.get('System Administrator');
		System.runAs(testUser) {
			leads[0].OwnerId = testUser.Id;
			update leads;

			List<Lead> testLeads = [SELECT Sales_Manager__c, Customer_Success_Manager__c, Prospecting_Manager__c, Product_Expert__c, OwnerId FROM Lead];
			System.assertEquals(null, testLeads[0].Sales_Manager__c);
			System.assertEquals(null, testLeads[0].Customer_Success_Manager__c);
			System.assertEquals(null, testLeads[0].Prospecting_Manager__c);
			System.assertEquals(null, testLeads[0].Product_Expert__c);

		}

		Test.stopTest();
	}*/
}