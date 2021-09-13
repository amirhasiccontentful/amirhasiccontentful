@isTest
public with sharing class LeadTriggerHandler_Test {
    @testSetup static void setupTestData(){
        List<Territory_Maps__c> territoryMaps = TestDataFactory.CreateTerritoryMaps();
        insert territoryMaps;

        //PM User created like this to avoid MIX DML operations for setup and non setup objects
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs ( thisUser ) {

            String userRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Partners_Manager_EMEA' LIMIT 1].Id;
            User partnerManager = TestDataFactory.CreateUser('PM', 'EMEA', 'pmemea@test.test', 'Partnerships', 'Partner Manager', userRoleId);
            User partnerManager2 = TestDataFactory.CreateUser('PM2', 'EMEA', 'pmemea2@test.test', 'Partnerships', 'Partner Manager', userRoleId);
        }
    }
 
    //Unit test failing because custom matching logic is commented out within the trigger
    /*
    public static testMethod void MatchingAccountOwnerAssignment_Insert_Test(){


        //Arrange 
        User pm = [SELECT Id FROM User WHERE Email = 'pmemea@test.test' LIMIT 1];
        User pm2 = [SELECT Id FROM User WHERE Email = 'pmemea2@test.test' LIMIT 1];
        
        Account matchingAccount = TestDataFactory.CreateAccount();  
        matchingAccount.Name = 'Contentful 1';
        matchingAccount.OwnerId = pm.Id;
        matchingAccount.Website = 'testing1.test';
        update matchingAccount;

        Account matchingAccount2 = TestDataFactory.CreateAccount();  
        matchingAccount2.Name = 'Contentful 2';
        matchingAccount2.OwnerId = pm2.Id;
        matchingAccount2.Website = 'tested2.test';
        update matchingAccount2;

        //Act 
        List<Lead> listOfLeads = new List<Lead> {
            new Lead(LeadSource = 'Drift', LastName = 'Test 1', Company = 'My Company', Email = 'test1@testing1.test', Website = 'testing1.test'),
            new Lead(LeadSource = 'Drift', LastName = 'Test 3', Company = 'My Company', Email = 'test3@testing1.test', Website = 'testing1.test'),
            new Lead(LeadSource = 'Drift', LastName = 'Test 4', Company = 'My Company', Email = 'test4@testing1.test', Website = 'testing1.test'),
            new Lead(LeadSource = 'Drift', LastName = 'Test 5', Company = 'My Company 2', Email = 'test5@tested2.test', Website = 'tested2.test'),
            new Lead(LeadSource = 'Drift', LastName = 'Test 6', Company = 'My Company 2', Email = 'test6@tested2.test', Website = 'tested2.test'),
            new Lead(LeadSource = 'Drift', LastName = 'Test 2', Company = 'My Company 2', Email = 'test2@testing.test')
        }; 

        Test.startTest();

        insert listOfLeads;

        Test.stopTest(); 
 
        List<Lead> allLeads = [SELECT Id, Email, OwnerId FROM Lead];
   
        //Assert 
        for(Lead lead : allLeads){ 

            if(lead.Email == 'test2@testing.test'){
                System.assertNotEquals(null, lead.OwnerId); 
            }

            if(lead.Email.contains('testing1')){
                System.assertEquals(pm.Id, lead.OwnerId); 
            }

            if(lead.Email.contains('tested2')){
                System.assertEquals(pm2.Id, lead.OwnerId); 
            }
        }  
    }

    public static testMethod void MatchingAccountOwnerAssignment_Update_Test(){

        //Arrange 
        User pm = [SELECT Id FROM User WHERE Email = 'pmemea@test.test' LIMIT 1];
        
        Account matchingAccount = TestDataFactory.CreateAccount();   
        matchingAccount.Name = 'Contentful 1';
        matchingAccount.OwnerId = pm.Id;
        matchingAccount.Website = 'testing1.test';
        update matchingAccount;

        //Act 

        Lead newLead = new Lead(LeadSource = 'Drift', LastName = 'Test 1', Company = 'My Company', Email = 'test1@testing.test', Website = 'testing1.test');
        insert newLead;

        Test.startTest();

        newLead.Revenue_Cycle_Stage__c = 'MQL';
        update newLead;
    
        Test.stopTest(); 
 
        List<Lead> allLeads = [SELECT Id, OwnerId FROM Lead];
   
        //Assert 
        System.assertEquals(pm.Id, allLeads[0].OwnerId); 
    }

    public static testMethod void MatchingAccountOwnerAssignment_Update_Test_2(){

        //Arrange 
        User pm = [SELECT Id FROM User WHERE Email = 'pmemea@test.test' LIMIT 1];
        
        Account matchingAccount = TestDataFactory.CreateAccount();  
        matchingAccount.Name = 'Contentful 1';
        matchingAccount.OwnerId = pm.Id;
        matchingAccount.Website = 'testing1.test';
        update matchingAccount;

        //Act 

        Lead newLead = new Lead(LeadSource = 'Drift', LastName = 'Test 1', Status = 'Open', Company = 'My Company', Email = 'test1@testing.test');
        insert newLead;
        
        newLead.Website = 'testing1.test';

        Test.startTest();
        
        update newLead;
        
        Test.stopTest(); 
 
        List<Lead> allLeads = [SELECT Id, OwnerId FROM Lead];
   
        //Assert 
        System.assertEquals(pm.Id, allLeads[0].OwnerId); 
    }
    */

    public static testMethod void MatchingAccountLeadOwnerManualChangeTest(){

        //Arrange 
        User pm = [SELECT Id FROM User WHERE Email = 'pmemea@test.test' LIMIT 1];
        User pm2 = [SELECT Id FROM User WHERE Email = 'pmemea2@test.test' LIMIT 1];
        
        Account matchingAccount = TestDataFactory.CreateAccount();  
        matchingAccount.Name = 'Contentful 1';
        matchingAccount.OwnerId = pm.Id;
        matchingAccount.Website = 'testing1.test';
        update matchingAccount;

        //Act 

        Lead newLead = new Lead(LeadSource = 'Drift', LastName = 'Test 1', Status = 'Open', Company = 'My Company', Email = 'test1@testing.test');
        insert newLead;
        
        newLead.Website = 'testing1.test';
        newLead.OwnerId = pm2.Id;

        Test.startTest();
        
        update newLead;
        
        Test.stopTest(); 
 
        List<Lead> allLeads = [SELECT Id, OwnerId, Known_Account__c FROM Lead];
   
        //Assert 
        System.assertEquals(pm2.Id, allLeads[0].OwnerId); 
    }

    public static testMethod void MatchingAccountSDRAssignment_Insert_Test(){

        //Arrange 
        Account matchingAccount = TestDataFactory.CreateAccount();
        Account matchingAccountNoSDR = TestDataFactory.CreateAccount(); 
        User SDR = TestDataFactory.CreateUser('SDRstestmail@test.test');
        matchingAccount.Prospecting_Manager__c = SDR.Id;
        update matchingAccount;

        //Act 
        Test.startTest();

        List<Lead> listOfLeads = new List<Lead> {
            new Lead(LeadSource = 'Drift', LastName = 'Test 1', Company = 'Testing', Email = 'test1@testing.test', Revenue_Cycle_Stage__c = 'MQL', LeanData__Reporting_Matched_Account__c = matchingAccount.Id),
            new Lead(LeadSource = 'Drift', LastName = 'Test 2', Company = 'Testing', Email = 'test2@testing.test', Revenue_Cycle_Stage__c = 'MQL', LeanData__Reporting_Matched_Account__c = matchingAccountNoSDR.Id)
        }; 

        insert listOfLeads;

        Test.stopTest(); 
 
        List<Lead> allLeads = [SELECT Id, Email, Prospecting_Manager__c, Matched_Account__r.Prospecting_Manager__c FROM Lead];
   
        //Assert 
        for(Lead lead : allLeads){ 

            if(lead.Email == 'test2@testing.test'){
                System.assertEquals(null, lead.Prospecting_Manager__c); 
            }

            if(lead.Email == 'test1@testing.test'){
                System.assertEquals(lead.Matched_Account__r.Prospecting_Manager__c, lead.Prospecting_Manager__c); 
            }
        }  
    }

    public static testMethod void MatchingAccountSDRAssignment_Update_Test(){

        //Arrange 
        Account matchingAccount = TestDataFactory.CreateAccount();  
        User SDR = TestDataFactory.CreateUser('SDRstestmail@test.test');
        matchingAccount.Prospecting_Manager__c = SDR.Id;
        update matchingAccount;

        //Act 
        Test.startTest();

        Lead newLead = new Lead(LeadSource = 'Drift', LastName = 'Test 1', Company = 'Testing', Email = 'test1@testing.test', LeanData__Reporting_Matched_Account__c = matchingAccount.Id);
        insert newLead;

        newLead.Revenue_Cycle_Stage__c = 'MQL';
        update newLead;
    
        Test.stopTest(); 
 
        List<Lead> allLeads = [SELECT Id, Email, Prospecting_Manager__c FROM Lead];
   
        //Assert 
        System.assertEquals(SDR.Id, allLeads[0].Prospecting_Manager__c); 
    }

    public static testMethod void TerritoryAssignment_Insert_Test(){

        //Arrange 
        List<Lead> listOfLeads = new List<Lead> {
            new Lead(LeadSource = 'Drift', Country = 'Bosnia and Herzegovina', LastName = 'Test 1', Company = 'Testing', Email = 'test1@testing.test'),
            new Lead(LeadSource = 'Drift', Country = 'Canada', State = 'Ontario', LastName = 'Test 2', Company = 'Testing', Email = 'test2@testing.test')
        }; 

        //Act 

        Test.startTest();

        insert listOfLeads;

        Test.stopTest(); 
 
        List<Lead> allLeads = [SELECT Id, Email, Company_HQ_Country__c, Company_HQ_State__c, Company_HQ_Sales_Region__c, Company_HQ_Sales_Territory__c FROM Lead];
   
        //Assert
        for(Lead lead : allLeads){ 

            if(lead.Email == 'test2@testing.test'){
                System.assertEquals('Canada', lead.Company_HQ_Country__c);
                System.assertEquals('Ontario', lead.Company_HQ_State__c);
                System.assertEquals('NA', lead.Company_HQ_Sales_Region__c);
                System.assertEquals('Great Lakes', lead.Company_HQ_Sales_Territory__c);
            }

            if(lead.Email == 'test1@testing.test'){
                System.assertEquals('Bosnia and Herzegovina', lead.Company_HQ_Country__c);
                System.assertEquals(null, lead.Company_HQ_State__c);
                System.assertEquals('EMEA', lead.Company_HQ_Sales_Region__c);
                System.assertEquals('ROE', lead.Company_HQ_Sales_Territory__c);
            }
        }  
    }

    public static testMethod void TerritoryAssignment_Update_Test(){

        //Arrange 
        Lead leadBiH = new Lead(LeadSource = 'Drift', Country = 'Bosnia and Herzegovina', LastName = 'Test 1', Company = 'Testing', Email = 'test1@testing.test'); 
  
        //Act 

        Test.startTest();

        insert leadBiH;

        leadBiH.Company_HQ_Country__c = 'United States';
        leadBiH.Company_HQ_State__c = 'California';
        update leadBiH;

        Test.stopTest(); 
 
        List<Lead> allLeads = [SELECT Id, Email, Company_HQ_Country__c, Company_HQ_State__c, Company_HQ_Sales_Region__c, Company_HQ_Sales_Territory__c FROM Lead];
   
        //Assert   
        System.assertEquals('NA', allLeads[0].Company_HQ_Sales_Region__c);
        System.assertEquals('California', allLeads[0].Company_HQ_Sales_Territory__c); 
    }

    public static testMethod void TerritoryAssignmentCountryChange_Update_Test(){

        //Arrange 
        Lead leadBiH = new Lead(LeadSource = 'Drift',  LastName = 'Test 1', Company = 'Testing', Email = 'test1@testing.test'); 
  
        //Act 

        Test.startTest();

        insert leadBiH;
        leadBiH.Country = 'United States';
        leadBiH.State = 'California';
        update leadBiH;

        Test.stopTest(); 
 
        List<Lead> allLeads = [SELECT Id, Email, Company_HQ_Country__c, Company_HQ_State__c, Company_HQ_Sales_Region__c, Company_HQ_Sales_Territory__c FROM Lead];
   
        //Assert   
        System.assertEquals('United States', allLeads[0].Company_HQ_Country__c);
        System.assertEquals('California', allLeads[0].Company_HQ_State__c);
        System.assertEquals('NA', allLeads[0].Company_HQ_Sales_Region__c);
        System.assertEquals('California', allLeads[0].Company_HQ_Sales_Territory__c); 
    }

    public static testMethod void Insert_Test(){

        //Arrange
        //
        Account testAccount = TestDataFactory.CreateAccount('www.test.com');
        insert testAccount;
        User testUser = TestDataFactory.CreateUser('username-test@test.com');
        insert testUser;
        Marketing_Resource__c testMarketingResource = TestDataFactory.CreateMarketingResource();
        insert testMarketingResource;
        EmailOptOutDefinitions__c newDefinition = TestDataFactory.CreateEmailOptOutDefinitions();
        insert newDefinition;
   
        //Act
        //

        List<Lead> leadsToInsert = new List<Lead>();

        Lead convertedLead = TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,'SMB','1',true,'www.test.com',testAccount.Id,false,false,100000000,10000);
        convertedLead.OwnerId = testUser.Id;
        convertedLead.Country = 'United States';
        convertedLead.CountryCode = 'US';
        convertedLead.State = 'California';
        convertedLead.StateCode = 'CA';
        convertedLead.Email = 'test1@test.com';
        leadsToInsert.add(convertedLead);

        Lead nonConvertedLead = TestDataFactory.CreateLead('Wcompanyw2','Company Data Fox 2', true,'Agency','1',true,'www.test2.com',testAccount.Id,false,false,100000005, 1005);
        leadsToInsert.add(nonConvertedLead);

        Test.startTest();

        insert leadsToInsert;

        Test.stopTest();

        Marketing_Resource_Lead__c testMarketingResourceLead = TestDataFactory.CreateMarketingResourceLead(leadsToInsert[0].Id, testMarketingResource.Id);
        insert testMarketingResourceLead;

        //Pull Data From Salesforce
        Lead nullTierLead = [SELECT Id, Tier__c, Company_HQ_Country__c,Company_HQ_State__c, Company_HQ_Sales_Region__c, Company_HQ_Sales_Territory__c FROM Lead WHERE Id =:convertedLead.Id];
 
        //Assert
        //
        //Is Tier Null If Classification != Enterprise
        System.assertEquals(null, nullTierLead.Tier__c);
        System.assertEquals('United States', nullTierLead.Company_HQ_Country__c);
        System.assertEquals('California', nullTierLead.Company_HQ_State__c);
        System.assertEquals('NA', nullTierLead.Company_HQ_Sales_Region__c);
        System.assertEquals('California', nullTierLead.Company_HQ_Sales_Territory__c);
    }

    public static testMethod void Update_Test(){

        //Arrange
        //
        Test.startTest();

        Account testAccount = TestDataFactory.CreateAccount('www.test.com');
        insert testAccount;

        User testUser = TestDataFactory.CreateUser('username-test@test.com');
        insert testUser;

        Marketing_Resource__c newMarketingResource = TestDataFactory.CreateMarketingResource();
        insert newMarketingResource;

        List<Lead> listOfLeadsForUpdate = TestDataFactory.CreateLeads();
        insert listOfLeadsForUpdate;

        TestDataFactory.UpdateLeadsRevenuesNumberOfEmployees(listOfLeadsForUpdate);

        // FunnelBeamIndustryMap__c industry = TestDataFactory.CreateFunnelBeamIndustryMap();
        // insert industry;
        EmailOptOutDefinitions__c newDefinition = TestDataFactory.CreateEmailOptOutDefinitions();
        insert newDefinition;

        //Act
        //
        update listOfLeadsForUpdate;
        // update industry;
        update newDefinition;

        Test.stopTest();

        //Pull data from Salesforce
        //
        Set<Id> idsOfUpdatedLeads = new Set<Id>();
        for(Lead updatedLead : listOfLeadsForUpdate){
            idsOfUpdatedLeads.add(updatedLead.Id);
        }

        List<Lead> updatedLeadsForAssert = TestDataFactory.GetLeadsById(idsOfUpdatedLeads);

        Lead largeEnterpriseLead = updatedLeadsForAssert[0];
        Lead bigEnterpriseLead = updatedLeadsForAssert[1];
        Lead mediumEnterpriseLead = updatedLeadsForAssert[2];
        Lead largeLeadBlankClassification = updatedLeadsForAssert[3];
        Lead bigLeadBlankClassification = updatedLeadsForAssert[4];
        Lead mediumLeadBlankClassification = updatedLeadsForAssert[5];
        Lead SMBLeadBlankClassification = updatedLeadsForAssert[6];
        Lead elseLead = updatedLeadsForAssert[8];
        Lead leadWithCompanyIndustry = updatedLeadsForAssert[9];
        Lead dfoxLargeEnterpriseLead = updatedLeadsForAssert[10];
        Lead dfoxBigEnterpriseLead = updatedLeadsForAssert[11];
        Lead dfoxMediumEnterpriseLead = updatedLeadsForAssert[12];
        Lead dfoxLargeLeadBlankClassification = updatedLeadsForAssert[13];
        Lead dfoxBigLeadBlankClassification = updatedLeadsForAssert[14];
        Lead dfoxMediumLeadBlankClassification = updatedLeadsForAssert[15];
        Lead dfoxSMBLeadBlankClassification = updatedLeadsForAssert[16];
        Lead dfoxLeadWithCompanyIndustry = updatedLeadsForAssert[17];

        //Assert
        //
        //DFOX Enterprise Lead With >= 10000 Employees
        System.assertEquals('1', dfoxLargeEnterpriseLead.Tier__c);
        //DFOX Enterprise Lead With >= 1000 Employees
        System.assertEquals('2', dfoxBigEnterpriseLead.Tier__c);
        //DFOX Enterprise Lead With >= 100 Employees
        System.assertEquals('3', dfoxMediumEnterpriseLead.Tier__c);
        //Blank Classification Lead With >= 10000 Employees
        System.assertEquals('Enterprise', dfoxLargeLeadBlankClassification.Classification__c);
        System.assertEquals('1', dfoxLargeLeadBlankClassification.Tier__c);
        //Blank Classification Lead With >= 1000 Employees
        System.assertEquals('2', dfoxBigLeadBlankClassification.Tier__c);
        //Blank Classification Lead With >= 100 Employees
        System.assertEquals('3', dfoxMediumLeadBlankClassification.Tier__c);
        //Blank Classification Lead With > 0 Employees - SMB
        System.assertEquals('SMB', dfoxSMBLeadBlankClassification.Classification__c);
        System.assertEquals(null, dfoxSMBLeadBlankClassification.Tier__c);
        //DFOX Lead With FunnelBeam Company Industry

        System.assertEquals('Germany', updatedLeadsForAssert[0].Company_HQ_Country__c);
        System.assertEquals('EMEA', updatedLeadsForAssert[0].Company_HQ_Sales_Region__c);

    }

    public static testMethod void Delete_Test(){
        //Arrange
        //
        Lead lead = TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,'Enterprise','1',true,'www.test.com', null,true,false,100000000,10001);
        insert lead;
        //Act
        //
        delete lead;
        //Assert
        //
    }
    
    public static testMethod void Test_LeadConversion(){

        //Arrange
        Account testAccount = TestDataFactory.CreateAccount('www.test.com');
        insert testAccount;

        Lead lead = TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,'SMB','1',true,'www.test.com',testAccount.Id,false,false,100000000,10000);
        lead.Status = 'Converted'; 

        //Act 

        Test.startTest();

        insert lead;  

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id); 
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Test.stopTest(); 

        //Assert   

        List<Contact> contactsList = [SELECT Id, Contact_Status__c FROM Contact];

        System.assert(lcr.isSuccess()); 
        System.AssertEquals (1, contactsList.size());
        System.AssertEquals (lead.Status, contactsList[0].Contact_Status__c); 

    }

    public static testMethod void Test_LeadMerging(){
 
         //Arrange
        Account testAccount = TestDataFactory.CreateAccount(); 

        Lead lead = TestDataFactory.CreateLead('Master', 'Lead', 'Contentful', 'Open', 'master@test.aaa', 'Germany', 'Field Event');
        Lead duplicateLead = TestDataFactory.CreateLead('Duplicate 1', 'Lead', 'Contentful', 'Open', 'dup1@test.aaa', 'Germany', 'Organic Search');
        Lead duplicateLead2 = TestDataFactory.CreateLead('Duplicate 2', 'Lead', 'Contentful', 'Open', 'dup2@test.aaa', 'Germany', 'Developer Event');
        
        List<Lead> duplicates = new List<Lead> { duplicateLead, duplicateLead2 };

        //Act 

        Test.startTest();

        // Merge leads into master lead
        Database.MergeResult[] results = Database.merge(lead, duplicates, false);

        Test.stopTest(); 

        //Assert   

        List<Lead> leadList = [SELECT Id, FirstName, LeadSource FROM Lead];

        System.AssertEquals (1, leadList.size());
        System.AssertEquals ('Master', leadList[0].FirstName); 
        System.AssertEquals ('Developer Event', leadList[0].LeadSource); 

    }

}