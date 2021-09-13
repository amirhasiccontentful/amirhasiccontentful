@isTest
public with sharing class OpportunityTriggerHandler_Test { 

    @isTest static void TEST_CalculateFieldsOnAccount_Open() {
        Test.startTest();

        UserRole r2 = new UserRole(DeveloperName = 'AccountExecutive1', Name = 'Account Executive');
        insert r2;

        User u2 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales - AE'].Id,
             LastName = 'last',
             Email = 'ae000@amamama.com',
             Username = 'ae000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             UserRoleId = r2.Id
        );

        insert u2;

        System.runAs(u2){ 
            Account newAccount = new Account();
            newAccount.Name = 'TEST';
            newAccount.Zuora_Active_Enterprise_Subscriptions__c = 1;
            newAccount.Zuora_Total_CMRR__c = 10000;
            newAccount.IsCreatedByLead__c = true;
            insert newAccount;

            Contact con = new Contact();
            con.AccountId = newAccount.Id;
            con.FirstName = 'Fname';
            con.LastName = 'Lname';
            insert con;

            Opportunity opp = new Opportunity();
            opp.Name = 'Test';
            opp.Project_Name__c = 'New Project';
            opp.SLA_Name__c = 'Gold';
            opp.AccountId = newAccount.Id;
            opp.CloseDate = System.today();
            opp.Effective_Date__c = System.today();
            opp.Amount = 1000; 
            opp.StageName = 'Qualification'; 
            opp.Primary_Contact__c = con.Id;
            opp.Competitors__c = 'Prismic';
            opp.SE_Technical_Risk__c = 'Low';
            opp.Project_Significance__c = 'Core';
            opp.Term__c = '1';
            opp.LeadSource = 'Sales Generated';
            opp.Use_Case__c = 'Static Site';
            opp.Description = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
            opp.Related_Services_Opportunity__c = 'No';
            insert opp;

            opp.Amount = 1000;
            opp.OwnerId = u2.Id;
            opp.Effective_Date__c = System.today();
            update opp;
        }

        Test.stopTest();
    }

    @isTest static void TEST_CalculateFieldsOnAccount_ClosedWon() {
        Test.startTest();
        
        Account newAccount = new Account();
        newAccount.Name = 'TEST';
        newAccount.Zendesk_SLA_Support_Plan__c = 'Gold';
        newAccount.IsCreatedByLead__c = true;
        insert newAccount;

        Contact con = new Contact();
        con.AccountId = newAccount.Id;
        con.FirstName = 'Fname';
        con.LastName = 'Lname';
        insert con;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.Project_Name__c = 'New Project';
        opp.SLA_Name__c = 'Gold';
        opp.AccountId = newAccount.Id;
        opp.CloseDate = System.today();
        opp.Effective_Date__c = System.today();
        opp.Amount = 1000;
        opp.StageName = 'Qualification';  
        opp.Primary_Contact__c = con.Id;
        opp.Competitors__c = 'Prismic';
        opp.SE_Technical_Risk__c = 'Low';
        opp.Project_Significance__c = 'Core';
        opp.Term__c = '1';
        opp.LeadSource = 'Sales Generated';
        opp.Use_Case__c = 'Static Site';
        opp.Description = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc ac tellus lacus.';
        opp.Related_Services_Opportunity__c = 'No';
        insert opp;

        opp.Amount = 1000; 
        opp.StageName = 'Discovery';
        opp.Effective_Date__c = System.today(); 
        opp.SE_Technical_Risk__c = 'Low';
        opp.Competitors__c = 'Prismic'; 
        opp.Term__c = '1';
        opp.Use_Case__c = 'Static Site';
        opp.Description = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc ac tellus lacus.';
        update opp;
        
        Test.stopTest();    
    }

    @isTest static void test_SLAfields(){
        zqu__ZProduct__c  newZProduct = new zqu__ZProduct__c();
        newZProduct.Name = 'Test';
        insert newZProduct;
        
        zqu__ProductRatePlan__c  newProductRatePlan = new zqu__ProductRatePlan__c ();
        newProductRatePlan.Name = 'Platinum';
        newProductRatePlan.zqu__ZProduct__c  = newZProduct.Id;
        newProductRatePlan.PlanType__c = 'Enterprise';
        insert newProductRatePlan;
        
        Account newAccount = new Account();
        newAccount.Name = 'TEST';
        newAccount.Zuora_Active_Enterprise_Subscriptions__c = 1;
        newAccount.Zuora_Total_CMRR__c = 10000;
        newAccount.IsCreatedByLead__c = true;
        insert newAccount;

        Contact con = new Contact();
        con.AccountId = newAccount.Id;
        con.FirstName = 'Fname';
        con.LastName = 'Lname';
        insert con;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.Project_Name__c = 'New Project';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Expand').getRecordTypeId();
        opp.AccountId = newAccount.Id;
        opp.SLA_Name__c = 'Gold';
        opp.Expansion_Type__c = 'Cross-Sell';
        opp.AccountId = newAccount.Id;
        opp.CloseDate = System.today();
        opp.Effective_Date__c = System.today();
        opp.Closed_Won_Information__c = 'Testing';
        opp.Amount = 1000; 
        opp.StageName = 'Qualification'; 
        opp.Primary_Contact__c = con.Id;
        opp.Competitors__c = 'Prismic';
        opp.SE_Technical_Risk__c = 'Low';
        opp.Project_Significance__c = 'Core';
        opp.Term__c = '1';
        opp.LeadSource = 'Sales Generated';
        opp.Use_Case__c = 'Static Site';
        opp.Related_Services_Opportunity__c = 'No';
        opp.Description = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc ac tellus lacus.';
        insert opp;

        zqu__Quote__c quote = new zqu__Quote__c();
        quote.zqu__Opportunity__c = opp.Id;
        quote.zqu__Account__c = newAccount.Id;
        quote.Initial_Term__c = 1;
        quote.zqu__PaymentTerm__c = 'Due Upon Receipt';
        quote.Renewal_Term__c = 1;
        insert quote;

        opp.Current_Quote__c = quote.Id;
        opp.StageName = 'Discovery';
        opp.Expansion_Type__c = 'Upsell';
        update opp;

        zqu__QuoteAmendment__c amendment = new zqu__QuoteAmendment__c();
        amendment.Name = 'test amend';
        amendment.zqu__Quote__c = quote.Id;
        amendment.zqu__Status__c = 'Draft';
        insert amendment;

        zqu__QuoteRatePlan__c  newQuoteRatePlan = new zqu__QuoteRatePlan__c ();
        newQuoteRatePlan.Name = 'Platinum SLA';
        newQuoteRatePlan.zqu__ProductRatePlan__c = newProductRatePlan.Id;
        newQuoteRatePlan.zqu__Quote__c = quote.Id;
        newQuoteRatePlan.zqu__QuoteAmendment__c = amendment.Id;
        insert newQuoteRatePlan;

        List<OpportunityContactRole> checkRoles = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId =: opp.Id];
        System.assertEquals(1, checkRoles.size());
    }

    @isTest static void Test_OpportunityTypeChanges() {

        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);  
        Sales_Account_Plan__c sap = TestDataFactory.CreateSalesAccountPlan(account.Id); 
        Opportunity initialOpp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Initial', 2000, true, 'Validation', Date.today());   

        //Act
        Test.startTest();

        initialOpp.Type = 'Renewal'; 
        update initialOpp;

        Test.stopTest(); 

        //Assert   
        List<Opportunity> opportunitiesList = [SELECT Id, RecordType.Name FROM Opportunity WHERE Id =: initialOpp.Id];
        System.assertEquals('Enterprise Renewal', opportunitiesList[0].RecordType.Name);  
    }

    /*
    @isTest static void leadConversionCurrencyUpdatesForExistingOpps(){

        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id); 
        Sales_Account_Plan__c sap = TestDataFactory.CreateSalesAccountPlan(account.Id); 
        Opportunity initialOpp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Initial', 1000, true, 'Closed Won', Date.today());  
        Lead lead = TestDataFactory.CreateLead('Test', 'Lead', 'Contentful', 'Open', 'test@test.aaa', 'Germany', 'Field Event', 'EUR');

        //Act 

        Test.startTest();

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id); 
        lc.setDoNotCreateOpportunity(true);
        lc.setOpportunityId(initialOpp.Id); 
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Test.stopTest(); 

        //Assert   

        List<Opportunity> opportunitiesList = [SELECT Id, CurrencyIsoCode, Lead_Currency__c FROM Opportunity];

        System.assert(lcr.isSuccess()); 
        System.AssertEquals (1, opportunitiesList.size());
        System.AssertEquals ('USD', opportunitiesList[0].CurrencyIsoCode); 
        System.AssertEquals ('', opportunitiesList[0].Lead_Currency__c); 
    }
    */

    @isTest static void CalculateFieldsOnAccountWithoutOpportunities() {

        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Account accountWHopps = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id); 
        Sales_Account_Plan__c sap = TestDataFactory.CreateSalesAccountPlan(account.Id); 
        
        Set<Id> accountsIds = new Set<Id>();
        accountsIds.add(account.Id);
        accountsIds.add(accountWHopps.Id);

        //Act

        Test.startTest();

        Opportunity opp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id); 
        Opportunity opp2 = TestDataFactory.CreateOpportunity(accountWHopps.Id, primaryContact.Id, sap.Id); 
        Opportunity opp3 = TestDataFactory.CreateOpportunity(accountWHopps.Id, primaryContact.Id, sap.Id); 

        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        opp2.AccountId = account.Id;
        opp3.AccountId = account.Id;
        opportunitiesToUpdate.add(opp2);
        opportunitiesToUpdate.add(opp3);

        update opportunitiesToUpdate;

        Test.stopTest(); 

        //Assert  
        List<Account> accounstList = [SELECT Id, Won_Opportunities__c, Lost_Opportunities__c, Open_Opportunities__c FROM Account WHERE Id IN: accountsIds];

        for(Account acc : accounstList) {
            if(account.Id == acc.Id) {
                System.assertEquals(0, acc.Won_Opportunities__c);  
                System.assertEquals(0, acc.Lost_Opportunities__c);  
                System.assertEquals(100, acc.Open_Opportunities__c);     
            }

            if(accountWHopps.Id == acc.Id) {
                System.assertEquals(0, acc.Won_Opportunities__c);  
                System.assertEquals(0, acc.Lost_Opportunities__c);  
                System.assertEquals(0, acc.Open_Opportunities__c);     
            }
        } 

    }

    @isTest static void CalculateFieldsOnAccountWithWonOpportunities() {
        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id); 
        Sales_Account_Plan__c sap = TestDataFactory.CreateSalesAccountPlan(account.Id); 
        Opportunity closedWon = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id); 

        //Act
        Test.startTest(); 

        Opportunity initialOpp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Initial', 1000, true, 'Closed Won', Date.today());  

        Test.stopTest(); 

        //Assert  
        List<Account> accounstList = [SELECT Id, Won_Opportunities__c FROM Account WHERE Id =: account.Id];
        System.assertEquals(1000, accounstList[0].Won_Opportunities__c);  

    }

    @isTest static void CalculateFieldsOnAccountWithLostOpportunities() {
        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id); 
        Sales_Account_Plan__c sap = TestDataFactory.CreateSalesAccountPlan(account.Id); 

        //Act 
        Test.startTest();
 
        Opportunity initialOpp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Initial', 1000, true, 'Closed Lost', Date.today());  

        Test.stopTest(); 

        //Assert   
        List<Account> accounstList = [SELECT Id, Lost_Opportunities__c FROM Account WHERE Id =: account.Id];
        System.assertEquals(1000, accounstList[0].Lost_Opportunities__c);   

    }

    @isTest static void CalculateFieldsOnAccountWithDeletedOpportunities() {
     
        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id); 
        Sales_Account_Plan__c sap = TestDataFactory.CreateSalesAccountPlan(account.Id); 
        Opportunity opp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id); 

        //Act
        delete opp;

        //Assert  
        Test.startTest(); 

        List<Account> accounstList = [SELECT Id, (SELECT StageName, IsClosed, Amount FROM Opportunities WHERE Type = 'Initial' OR Type = 'Expansion') FROM Account WHERE Id =: account.Id];
        System.assertEquals(0, accounstList[0].Opportunities.size());  

        Test.stopTest(); 
    }

    @isTest static void CalculateFieldsOnAccountWithUndeletedOpportunities() {
        Test.startTest();
        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id); 
        Sales_Account_Plan__c sap = TestDataFactory.CreateSalesAccountPlan(account.Id); 
        Opportunity opp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id); 

        //Act
        delete opp;
        undelete opp;

        //Assert  
        List<Account> accounstList = [SELECT Id, (SELECT StageName, IsClosed, Amount FROM Opportunities WHERE Type = 'Initial' OR Type = 'Expansion') FROM Account WHERE Id =: account.Id];
        System.assertEquals(1, accounstList[0].Opportunities.size());  

        Test.stopTest(); 
    }

    @isTest static void Test_PartnerDetalStagesBasedOnOppStageChanges() {
        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);  
        Sales_Account_Plan__c sap = TestDataFactory.CreateSalesAccountPlan(account.Id); 
        Opportunity opp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id); 
        Partner_Deals__c pd = TestDataFactory.CreatePartnerDeal(opp.Id, account.Id, account.Id, 'Partner Sourced');   

        //Act
        Test.startTest();

        TestDataFactory.getClosedWonOrClosedLostOpportunity(opp, true, primaryContact.Id, sap.Id); 

        Test.stopTest(); 

        //Assert  
        List<Partner_Deals__c> partnerDealsList = [SELECT Id, Stage__c, Closed_Stage__c FROM Partner_Deals__c];
        
        System.assertEquals('Closed', partnerDealsList[0].Stage__c);  
        System.assertEquals('Closed Won', partnerDealsList[0].Closed_Stage__c);
    }

    /*
	// NOTES:: Proces will be handled manually by Deal Desk team until the new Quantity based model has been released. 
    @isTest static void Test_OpportunityRollupsForInitialAndExpansionOpp() {

        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);  
        Sales_Account_Plan__c sap = TestDataFactory.CreateSalesAccountPlan(account.Id); 
        
        //Act
        Test.startTest();

        Opportunity initialOpp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Initial', 1000, true, 'Closed Won', Date.today());  
        Opportunity renewalOpp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Renewal', 1000, true, 'Validation', Date.today().addYears(1));  
       
        //Simulating Zuora subscriptions
        account.Zuora_Total_CMRR__c = 100;
        account.Zuora_Active_Enterprise_Subscriptions__c = 1;
        update account;

        Opportunity expansionOpp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Expansion', 500, true, 'Submitted', Date.today().addMonths(5)); 

        expansionOpp.StageName = 'Closed Won';
        update expansionOpp;

        Test.stopTest(); 

        //Assert  
        List<Account> accountsList = [SELECT Id, Primary_Opportunity__c FROM Account WHERE Id = :account.Id];
        List<Opportunity> primaryOppList = [SELECT Id, Amount FROM Opportunity WHERE Type = 'Renewal'];
        List<Opportunity> expansionOppList = [SELECT Id, Parent_Opportunity__c FROM Opportunity WHERE Type = 'Expansion'];
            
        System.assertEquals(primaryOppList[0].Id, accountsList[0].Primary_Opportunity__c);    
        System.assertEquals(primaryOppList[0].Id, expansionOppList[0].Parent_Opportunity__c); 
        System.assertEquals(1500, primaryOppList[0].Amount);    
    }

    @isTest static void Test_OpportunityRollupsForInitialAndMoreExpansionAndRenewalOpp() {

        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);  
        Sales_Account_Plan__c sap = TestDataFactory.CreateSalesAccountPlan(account.Id); 

        Opportunity initialOpp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Initial', 2000, true, 'Closed Won', Date.today());    

        //Simulating Zuora subscriptions
        account.Zuora_Total_CMRR__c = 100;
        account.Zuora_Active_Enterprise_Subscriptions__c = 1;
        update account;

        Opportunity renewal1 = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Renewal', 2000, true, 'Validation', Date.today().addYears(1));
        Opportunity expansionOpp1 = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Expansion', 2500, true, 'Submitted', Date.today().addMonths(2)); 
        Opportunity expansionOpp2 = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Expansion', 3000, true, 'Submitted', Date.today().addMonths(3)); 

        //Act
        Test.startTest();

        expansionOpp1.StageName = 'Closed Won';
        expansionOpp2.StageName = 'Closed Won';

        List<Opportunity> oppsToUpdate = new List<Opportunity> { expansionOpp1, expansionOpp2 };
        update oppsToUpdate;

        Test.stopTest(); 

        //Assert  
        List<Account> accountsList = [SELECT Id, Primary_Opportunity__c FROM Account WHERE Id = :account.Id];
        List<Opportunity> renewalOppList = [SELECT Id, Amount FROM Opportunity WHERE Type = 'Renewal' ORDER BY CreatedDate DESC];
         
        System.assertEquals(7500, renewalOppList[0].Amount);    
        System.assertEquals(accountsList[0].Primary_Opportunity__c, renewalOppList[0].Id);    
    } 
    */

    @isTest static void Test_OpportunityRollupsForInitialDowngrade() {

        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);  
        Sales_Account_Plan__c sap = TestDataFactory.CreateSalesAccountPlan(account.Id); 
        Opportunity initialOpp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, sap.Id, '', 'Initial', 2000, true, 'Submitted', Date.today());   

        //Act
        Test.startTest();

        initialOpp.StageName = 'Closed Won';
        initialOpp.Amount = 1500;
        update initialOpp;

        Test.stopTest(); 

        //Assert  
        List<Account> accountsList = [SELECT Id, Primary_Opportunity__c FROM Account WHERE Id = :account.Id];
        List<Opportunity> opportunitiesList = [SELECT Id, Amount FROM Opportunity WHERE RecordType.Name = 'Enterprise Renewal'];
         
        System.assertEquals(1500, opportunitiesList[0].Amount);   
        System.assertEquals(1, opportunitiesList.size());  
        System.assertEquals(accountsList[0].Primary_Opportunity__c, opportunitiesList[0].Id);   
    }

    @isTest static void Test_salesSegmentForRelatedAccount() {
        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);   

        //Act
        Test.startTest();

        Opportunity opp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null);   

        Test.stopTest(); 

        //Assert  
        List<Account> accountsList = [SELECT Id, Sales_Segment__c FROM Account];
        
        System.assertEquals('Territory', accountsList[0].Sales_Segment__c);   
    }

    @isTest static void test_setRelatedCFOrganizationInfo() {
        
        Test.startTest();

        //Arrange
        Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id); 
        CF_Organization__c cfOrg = TestDataFactory.CreateCF_Organization(null, 'CF Org 1', 1, 'GK_Key_1');
        Opportunity opp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null, 'GK_Key_1'); 

        //Act

        opp.Is_this_opportunity_related_to_Trial__c = 'Yes';
        update opp;
        Test.stopTest(); 

        //Assert  
        List<Opportunity> oppList = [SELECT Id, Related_CF_Organization_Record__c FROM Opportunity];
        List<CF_Organization__c> cfOrgList = [SELECT Id, Account__c FROM CF_Organization__c];

        System.assertEquals(cfOrg.Id, oppList[0].Related_CF_Organization_Record__c);  
        System.assertEquals(account.Id, cfOrgList[0].Account__c);  
    }

    @isTest static void test_scheuledRelatedCFOrganizationInfo() {
        //Just testing query retrieve since logic tested test_setRelatedCFOrganizationInfo.
        OpportunityTriggerHandler.setOppRealtedCFOrganization();
    } 
}