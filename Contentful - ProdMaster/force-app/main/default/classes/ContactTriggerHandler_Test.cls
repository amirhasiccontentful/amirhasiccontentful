@isTest
public with sharing class ContactTriggerHandler_Test {
	
	@testSetup static void loadTestData() {
		//Load CSV file saved in static resource  
        List<SObject> lstAcc = Test.loadData(Account.sObjectType,'testAccounts');
        List<SObject> lstCon = Test.loadData(Contact.sObjectType,'testContacts');

		//PM User created like this to avoid MIX DML operations for setup and non setup objects
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs ( thisUser ) {

            String userRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Partners_Manager_EMEA' LIMIT 1].Id;
            User partnerManager = TestDataFactory.CreateUser('PM', 'EMEA', 'pmemea@test.test', 'Partnerships', 'Partner Manager', userRoleId);

        }
	}  

	@isTest
	static void TEST_CertifiedAccounts() {

		// return one account
		Account acc = new Account(Name = 'Test', Certified__c = true);
		insert acc;

		Contact con = new Contact(FirstName = 'Test', LastName = 'Test', Certified__c = true, AccountId = acc.Id);
		insert con;

		Test.startTest();
			new CertifiedAccountOnSchedule().execute(null);
		Test.stopTest();

		acc = [SELECT Certified__c FROM Account WHERE Id = :acc.Id LIMIT 1];

		System.assertEquals(acc.Certified__c, true);
	} 

	@isTest
	static void TEST_MarketingPersona() {


		EmailOptOutDefinitions__c newDefinition = new EmailOptOutDefinitions__c();
		newDefinition.Name = 'Test';
		newDefinition.Value__c = 'lilly';
		insert newDefinition;

		// return one account
		Account acc = [SELECT Certified__c, (SELECT Certified__c FROM Contacts) FROM Account LIMIT 1];

		Contact contact = new Contact(LastName = 'Test', AccountId = acc.Id, Title = 'Developer', Email = 'test@lilly.cont');

		insert contact;

		Contact contact1 = [SELECT Title FROM Contact LIMIT 1];
		contact1.Title = 'CTO';
		update contact1;

		Contact contact2 = [SELECT Title FROM Contact LIMIT 1];
		contact2.Title = 'Coordinator';
		update contact2;

		Contact contact3 = [SELECT Title FROM Contact LIMIT 1];
		contact3.Title = 'Creative';
		update contact3;

		Contact contact4 = [SELECT Title FROM Contact LIMIT 1];
		contact4.Title = 'CEO';
		update contact4;

		Contact contact5 = [SELECT Title FROM Contact LIMIT 1];
		contact5.Title = 'Chief Digital Officer';
		update contact5;

		delete contact;
		undelete contact;

	} 

    public static testMethod void MatchingAccountOwnerAssignment_Test(){

        Test.startTest();

        //Arrange 
        User pm = [SELECT Id FROM User WHERE Email = 'pmemea@test.test' LIMIT 1];
        
        Account matchingAccount = TestDataFactory.CreateAccount();  
        matchingAccount.OwnerId = pm.Id;
        update matchingAccount;

        //Act 

        List<Contact> listOfLeads = new List<Contact> {
            new Contact(LastName = 'Test 1', Email = 'test1@testing.test', AccountId = matchingAccount.Id),
            new Contact(LastName = 'Test 2', Email = 'test2@testing.test')
        }; 

        insert listOfLeads;

        Test.stopTest(); 
 
        List<Contact> allContacts = [SELECT Id, Email, OwnerId, Account.OwnerId FROM Contact];
   
        //Assert 
        for(Contact cont : allContacts){ 

            if(cont.Email == 'test2@testing.test'){
                System.assertNotEquals(null, cont.OwnerId); 
            }

            if(cont.Email == 'test1@testing.test'){
                System.assertEquals(cont.Account.OwnerId, cont.OwnerId); 
            }
        }  
    }

}