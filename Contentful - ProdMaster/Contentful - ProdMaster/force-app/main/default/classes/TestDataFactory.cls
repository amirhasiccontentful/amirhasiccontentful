@isTest
public class TestDataFactory {
    
    public static String generateRandomString(Integer strLength) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        return key.substring(0, strLength); 
    }	

    //Create Zuora__ZInvoice__c 
    public static Zuora__ZInvoice__c CreateZuoraZInvoice(String accountId, Integer amountWithoutTax, String currencyCode){
        
        Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Zuora__Account__c = accountId;
        zInvoice.Zuora__AmountWithoutTax__c = amountWithoutTax;
        zInvoice.CurrencyIsoCode = currencyCode;
        insert zInvoice;
        return zInvoice;
    }

    //CREATE ACCOUNT//
    public static Account CreateAccount(){
        
        Account newAccount = new Account();
        newAccount.Name = generateRandomString(5);
        newAccount.Website = generateRandomString(10);
        insert newAccount;
        return newAccount;
    }

    public static Account CreateAccount(Boolean isCreatedByLeadConversion){
        
        Account newAccount = new Account();
        newAccount.Name = generateRandomString(5);
        newAccount.Website = generateRandomString(10);
        newAccount.IsCreatedByLead__c = isCreatedByLeadConversion;
        insert newAccount;
        return newAccount;
    }
    
    public static Account CreateAccount(String website){
        
        Lead lead = CreateLead('Wcompanyw','Company Data Fox', true,'Enterprise','1',true,'www.test.com', null,false,false,100000000,1000);
        
        Account newAccount = new Account();
        newAccount.Name = 'Company Data Fox';
        newAccount.dfox__Id__c = lead.Id;
        newAccount.Website = website;
        return newAccount;
    } 
    
    public static Account CreateAccount(String website, Id parentID){
        
        Account newAccount = new Account();
        newAccount.Name = generateRandomString(5);
        newAccount.Website = website;
        newAccount.ParentId = parentID;
        return newAccount;
    }
    
    public static Account CreateAccountWithOwner(Id ownerId){
        Account newAccount = TestDataFactory.CreateAccount();
        newAccount.OwnerId = ownerId;
        return newAccount;
    }
    
    public static Account CreateAccountWithProjectUsers(){   
        User zendeskCSMUser = TestDataFactory.CreateUser('zendeskCSMUser1@testing.com');
        zendeskCSMUser.FirstName = 'Melinda';
        zendeskCSMUser.LastName = 'Marczali';         
        User zendeskPMUser = TestDataFactory.CreateUser('zendeskPMUser1@testing.com');
        zendeskPMUser.FirstName = 'Katarzyna ';
        zendeskPMUser.LastName = 'Kotula';         
        User zendeskTAUser = TestDataFactory.CreateUser('zendeskTAUser1@testing.com');
        zendeskTAUser.FirstName = 'Sia';
        zendeskTAUser.LastName = 'Rad';          
        User zendeskSEUser = TestDataFactory.CreateUser('zendeskSEUser1@testing.com');
        zendeskSEUser.FirstName = 'James';
        zendeskSEUser.LastName = 'Morgan'; 
        
        List<User> testUsers = new List<User>{zendeskCSMUser, zendeskPMUser,  zendeskTAUser, zendeskSEUser};
        insert testUsers;
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Name';
        newAccount.Website = 'www.test.com';
        newAccount.Prospecting_Manager__c = zendeskPMUser.Id;
        newAccount.PM__c = zendeskPMUser.Id;
        newAccount.CF_Customer_Success_Manager__c = zendeskCSMUser.Id;
       	newAccount.TA__c = zendeskTAUser.Id;
        newAccount.SA__c = zendeskTAUser.Id;
       	newAccount.SE__c = zendeskSEUser.Id;
        return newAccount;
    }
    
    public static Account CreateAccount(Boolean autoClassification, Double revenue, Integer numberOfEmployees, String classification, String tier){
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Name';
        newAccount.Website = 'www.test.com';
        newAccount.Auto_classification_done__c = autoClassification;
        newAccount.dfox__Revenue_Estimate__c = revenue;
        newAccount.NumberOfEmployees = numberOfEmployees;
        newAccount.Classification__c = classification;
        newAccount.Tier__c = tier;
        
        return newAccount;
    }

    public static List<Account> CreateAccountsWithBillingAddress(Integer count){
        List<Account> newAccounts = new List<Account>();

        for(integer i = 0; i < count; i++){               
            Account newAccount = new Account();
            newAccount.Name = 'Test Name';
            newAccount.Website = 'www.test.com';
            newAccount.Phone = '(415) 901-7000';
            newAccount.BillingStreet = '1 Market St';
            newAccount.BillingCity = 'San Francisco';
            newAccount.BillingState = 'California';
            newAccount.BillingPostalCode = '94105';
            newAccount.BillingCountry = 'United States';
            newAccounts.Add(newAccount);
        }

        return newAccounts;
    }

    //CREATE ACCOUNTS WITH PARENT//
    public static testMethod List<Account> CreateAccountsWithParent(){
        
        List<Account> newAccounts = new List<Account>();
        
        Account master = TestDataFactory.CreateAccount(); 
        Account toplevel = TestDataFactory.CreateAccount('www.randomsite.com', master.Id);
        insert toplevel;        
        Account test2 = TestDataFactory.CreateAccount(); 
        Account test3 = TestDataFactory.CreateAccount();
        test3.ParentId = test2.id;
        update test3;        
        
        Account firstLevelParent = TestDataFactory.CreateAccount(null, test2.Id);
        insert  firstLevelParent; 
        firstLevelParent.ParentId = toplevel.id;
        update firstLevelParent;        
        
        Account secondLevelParent = TestDataFactory.CreateAccount(null, test3.Id);
        insert  secondLevelParent; 
        secondLevelParent.ParentId = firstLevelParent.Id;
        update secondLevelParent;        
        
        Account thirdLevelParent = TestDataFactory.CreateAccount(null, firstLevelParent.Id);
        insert  thirdLevelParent;  
        thirdLevelParent.ParentId = secondLevelParent.Id;
        update thirdLevelParent;        
        
        Account fourthLevelParent = TestDataFactory.CreateAccount(null, secondLevelParent.Id);
        insert  fourthLevelParent;  
        fourthLevelParent.ParentId = thirdLevelParent.Id;
        update fourthLevelParent;        
        
        Account fifthLevelParent = TestDataFactory.CreateAccount(null, thirdLevelParent.Id);		
        insert  fifthLevelParent;  
        fifthLevelParent.ParentId = fourthLevelParent.Id;
        update fifthLevelParent;
        
        newAccounts.add(master);
        newAccounts.add(test2);
        newAccounts.add(test3);
        newAccounts.add(toplevel);
        newAccounts.add(firstLevelParent);
        newAccounts.add(secondLevelParent);
        newAccounts.add(thirdLevelParent);
        newAccounts.add(fourthLevelParent);
        newAccounts.add(fifthLevelParent);
        
        return newAccounts;
    }
    
    
    //CREATE LIST ACCOUNTS//     
    public static List<Account> CreateAccounts(){
        List<Account> listOfAccountsForUpdate = new List<Account>();
        listOfAccountsForUpdate.add(TestDataFactory.CreateAccount(false,1,1,'Enterprise','1'));
        listOfAccountsForUpdate.add(TestDataFactory.CreateAccount(false,1,1,'Enterprise','1'));
        listOfAccountsForUpdate.add(TestDataFactory.CreateAccount(false,1,1,'Enterprise','1'));
        listOfAccountsForUpdate.add(TestDataFactory.CreateAccount(false,1,1,null,'1'));
        listOfAccountsForUpdate.add(TestDataFactory.CreateAccount(false,1,1,null,'1'));
        listOfAccountsForUpdate.add(TestDataFactory.CreateAccount(false,1,1,null,'1'));
        listOfAccountsForUpdate.add(TestDataFactory.CreateAccount(false,1,1,null,'1'));
        listOfAccountsForUpdate.add(TestDataFactory.CreateAccount(false,-1,-1,null,'1'));
        listOfAccountsForUpdate.add(TestDataFactory.CreateAccount(false,-1,-1,null,'1')); 
        
        return listOfAccountsForUpdate;        
    }
    
    //UPDATE ACCOUNT//    
    public static List<Account> UpdateAccountRevenuesNumberOfEmployees(List<Account> listOfAccountsForUpdate){
        
        listOfAccountsForUpdate[0].NumberOfEmployees = 10000;
        listOfAccountsForUpdate[1].NumberOfEmployees = 1000;
        listOfAccountsForUpdate[2].NumberOfEmployees = 100;
        listOfAccountsForUpdate[3].NumberOfEmployees = 10000;
        listOfAccountsForUpdate[4].NumberOfEmployees = 1000;
        listOfAccountsForUpdate[5].NumberOfEmployees = 100;
        listOfAccountsForUpdate[6].NumberOfEmployees = 10;
        listOfAccountsForUpdate[7].NumberOfEmployees = -2;
        listOfAccountsForUpdate[8].NumberOfEmployees = 100;
        listOfAccountsForUpdate[8].dfox__Revenue_Estimate__c = 10000000;
        listOfAccountsForUpdate[8].Industry = 'Technology';
        listOfAccountsForUpdate[8].DF_Company_Country__c = 'United States';
        
        return listOfAccountsForUpdate;
    }
    
    //CREATE LEAD//
    public static Lead CreateLead(String firstName, String lastName, String company, String status, 
                                  String email, String country, String leadSource){                                      
        return CreateLead(firstName, lastName, company, status, email, country, leadSource, 'EUR');
    } 

    public static Lead CreateLead(String firstName, String lastName, String company, String status, 
                                  String email, String country, String LeadSource, String currencyIsoCode){                                      
        Lead newLead = new Lead();
        newLead.LastName = lastName;
        newLead.FirstName = firstName;
        newLead.Company = company;
        newLead.Status = status;
        newLead.Email = email;
        newLead.Country = country;
        newLead.LeadSource = LeadSource; 
        newLead.CurrencyIsoCode = currencyIsoCode;
        insert newLead;
        return newLead; 
    } 
    	
    public static Lead CreateLead(String status, String description){                                      
        Lead newLead = new Lead();
        newLead.LastName = 'Doe';
        newLead.FirstName = 'John';
        newLead.Company = 'Test';
        newLead.Status = status;
        newLead.Email = 'email@test.de';
        newLead.Country = 'Germany';
        newLead.LeadSource = 'Other';
        newLead.Project_Description__c = description;
        newLead.HQ_Country__c = 'Germany';
        newLead.Referrer_Commission__c = 0;
        newLead.HQ_Territory_info_checked__c  = true;
        return newLead; 
    } 
    
    public static Lead CreateLead(String company, String companyDataFox, Boolean rerunApexLogic,String classification, String tier,
                                  Boolean firstClass, String website, Id accountId,Boolean FBEnrichmentDone,Boolean DataFoxClassified,
                                  Double companyRevenue,Double companyEmployees){                                      
        Lead newLead = new Lead();
        newLead.Company = company; 
        newLead.LastName = 'Test Lead Last Name';
        newLead.Status = 'Test Status';
        newLead.LeadSource = 'Test Lead Source';
        newLead.dfox__Company_DataFox_Id__c = companyDataFox;
        newLead.Rerun_Apex_logic__c = rerunApexLogic;
        newLead.Marketing_Resource_Short_Name__c = 'test';
        newLead.First_Touch_Lead_Source__c = 'Signup Role';
        newLead.Email = 'test@test.com';
        newLead.Phone = '';
        newLead.dfox__Company_Phone_Number__c = '11111';                              
        newLead.Classification__c = classification ;
        newLead.Tier__c = tier;
        newLead.First_Class__c = firstClass;
        newLead.Website = website;
        newLead.dfox__Company_Website__c = 'www.company.com';                            
        newLead.LeanData__Reporting_Matched_Account__c = accountId; 
        newLead.FunnelBeam_Enrichment_Done__c =  FBEnrichmentDone;
        newLead.DataFox_Classified__c = DataFoxClassified; 
        newLead.FunnelBeam_Company_Revenue__c = companyRevenue;
        newLead.FunnelBeam_Company_Employees__c = companyEmployees;
        newLead.FunnelBeam_Classified__c = false;                              
        newLead.Industry = 'Energy';
        newLead.FunnelBeam_Company_Name__c = 'Company Name';
        newLead.DF_Enriched_Address__c = false;
        newLead.FunnelBeam_Person_Title__c = 'title';
        newLead.Job_Function__c = '';
        newLead.FunnelBeam_Company_Phone__c = '123456';
        newLead.LinkedIn__c = '';
        newLead.FunnelBeam_Person_Linkedin__c = 'https://www.test.com';
        newLead.FunnelBeam_Company_Linkedin__c = 'https://www.company.com';
        newLead.Country = '';
        newLead.FunnelBeam_Company_Country__c = 'United States';
        newLead.FunnelBeam_Company_Street_Address__c = 'address';
        newLead.dfox__Company_Street_Address__c = 'add';                              
        newLead.Street = ''; 	
        newLead.PostalCode = '';
        newLead.dfox__Company_Zip_Code__c = '10000';                              
        newLead.FunnelBeam_Company_City__c = 'San Francisco';
        newLead.FunnelBeam_Company_Postal_Code__c = '11111';
        newLead.dfox__Company_City__c = 'London';                            
        newLead.City = '';
        newLead.dfox__Company_Revenue_Estimate_Amt__c = 100000000;
        newLead.dfox__Company_Number_of_Employees__c = 100;
        newLead.Address_set_by_internal_user__c = false; 
                                              
        return newLead; 
    } 
	
    //CREATE LIST OF LEADS//    
    public static List<Lead> CreateLeads(){
        List<Lead> listOfLeadsForUpdate = new List<Lead>();
        //TEST LEAD 0//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,'Enterprise','1', true,'www.test.com', null,false,false,1000000001,10001));
        //TEST LEAD 1//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw',null, true,'Enterprise','1',true,'www.test.com', null,false,false,100000002, 1002));
        //TEST LEAD 2//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw',null, true,'Enterprise','1', true,null, null,false,false, 10000003, 103));
        //TEST LEAD 3//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw',null, true,'SMB',null, true,null, null,false,false,1000000004, 10004));
        //TEST LEAD 4//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw',null, true,'Unknown','1', true,null, null,false,false,100000000, 1005));
        //TEST LEAD 5//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw',null, true,'Unknown','1', true,null, null,false,false,10000006, 106));
        //TEST LEAD 6//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Abc',null, true,'Unknown','1', true,null, null,false,false,1, 1));
        //TEST LEAD 7//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw',null, true,'Agency','1', true,null, null,false,false,null,6));
        //ELSE LEAD//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,'Enterprise','1', true,'www.test.com', null,false,false,-12,-1));
        //LEAD 9 Education Company Industry//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw',null, true,'SMB',null, true,null, null,false,false,1000000004, 10004));
        //DFOX LEAD 10//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,'Enterprise','1', true,'www.test.com', null,false,false,1000000001,10001));
        //DFOX LEAD 11//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,'Enterprise','1', true,'www.test.com', null,false,false,1000000001,10001));
        //DFOX LEAD 12//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,'Enterprise','1', true,'www.test.com', null,false,false,1000000001,10001));
        //DFOX LEAD 13//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,null,'1', true,'www.test.com', null,false,false,1000000001,10001));
        //DFOX LEAD 14//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,null,'1', true,'www.test.com', null,false,false,1000000001,10001));
        //DFOX LEAD 15//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,null,'1', true,'', null,false,false,1000000001,10001));
        //DFOX LEAD 16//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw','Company Data Fox', true,null,'1', true,'www.test.com', null,false,false,1000000001,10001));
        //LEAD 17 DFOX Education Company Industry//
        listOfLeadsForUpdate.Add(TestDataFactory.CreateLead('Wcompanyw',null, true,'SMB',null, true,null, null,false,false,1000000004, 10004));
        
        return listOfLeadsForUpdate;
    }
    
    public static List<Lead> UpdateLeadsRevenuesNumberOfEmployees(List<Lead> listOfLeadsForUpdate){
        
        listOfLeadsForUpdate[8].dfox__Company_Country__c = 'United States';
        listOfLeadsForUpdate[8].email = 'dfox@xxx.edu';
        listOfLeadsForUpdate[8].Classification__c = null;
        listOfLeadsForUpdate[8].FunnelBeam_Company_Name__c = null;
        
        listOfLeadsForUpdate[9].FunnelBeam_Company_Industry__c = 'Technology';
        listOfLeadsForUpdate[9].Marketing_Resource_Short_Name__c = 'abc';
        
        listOfLeadsForUpdate[10].dfox__Company_Revenue_Estimate_Amt__c = 1000000000;
        listOfLeadsForUpdate[10].dfox__Company_Number_of_Employees__c = 10000;
        
        listOfLeadsForUpdate[11].dfox__Company_Revenue_Estimate_Amt__c = 100000000;
        listOfLeadsForUpdate[11].dfox__Company_Number_of_Employees__c = 1000;
        
        listOfLeadsForUpdate[12].dfox__Company_Revenue_Estimate_Amt__c = 10000000;
        listOfLeadsForUpdate[12].dfox__Company_Number_of_Employees__c = 100;
        
        //ELSE IF//
        listOfLeadsForUpdate[13].dfox__Company_Revenue_Estimate_Amt__c = 1000000000;
        listOfLeadsForUpdate[13].dfox__Company_Number_of_Employees__c = 10000;
        
        listOfLeadsForUpdate[14].dfox__Company_Revenue_Estimate_Amt__c = 100000000;
        listOfLeadsForUpdate[14].dfox__Company_Number_of_Employees__c = 1000;
        
        listOfLeadsForUpdate[15].dfox__Company_Revenue_Estimate_Amt__c = 10000000;
        listOfLeadsForUpdate[15].dfox__Company_Number_of_Employees__c = 100;
        
        listOfLeadsForUpdate[16].dfox__Company_Revenue_Estimate_Amt__c = 1;
        listOfLeadsForUpdate[16].dfox__Company_Number_of_Employees__c = 1;
        
        listOfLeadsForUpdate[17].FunnelBeam_Company_Industry__c = 'Technology';
        listOfLeadsForUpdate[17].dfox__Company_Revenue_Estimate_Amt__c = 10000000;
        listOfLeadsForUpdate[17].dfox__Company_Number_of_Employees__c = 100;
        
        for(Lead currentLead : listOfLeadsForUpdate){
            currentLead.FunnelBeam_Enrichment_Done__c = true;
            currentLead.Country = 'Germany';
        	currentLead.CountryCode = 'DE';
        }
        
        return listOfLeadsForUpdate;
    }
    
    
    //CREATE CONTACT//    
    public static Contact CreateContact(){
        Account newAccount = CreateAccount();
        
        Contact newContact = new Contact();
        newContact.AccountId = newAccount.Id;
        newContact.LastName = 'Test Contact Last Name';
        newContact.LeadSource = 'Referral';
        
        return newContact;
    } 

    public static Contact CreateContact(Id accountID){        
        return CreateContact(accountID, 'Test Contact', '');
    } 

    public static Contact CreateContact(Id accountID, String lastName, String email){        
        Contact newContact = new Contact();
        newContact.AccountId = accountID;
        newContact.LastName = lastName;   
        newContact.Email = email;   
        insert newContact;     
        return newContact;
    } 

    // CREATE SALES ACCOUNT PLAN //
    public static Sales_Account_Plan__c CreateSalesAccountPlan(Id accountId) {
        Sales_Account_Plan__c sap = new Sales_Account_Plan__c();
        sap.Account_Name__c = accountId;
        insert sap;
        return sap;
    }
    
    //CREATE OPPORTUNITY//    
    public static Opportunity CreateOpportunity(){
        
        Contact testContact = CreateContact();
        insert testContact;
        Opportunity newOpportunity = new Opportunity();
        
        newOpportunity.StageName = 'Qualification';
        newOpportunity.Name = 'Test Opportunity Name';
        newOpportunity.CloseDate = Date.newInstance(2019, 7, 11);
        newOpportunity.LeadSource = 'Signup Role';
        newOpportunity.Type = 'Initial';
        newOpportunity.Project_Name__c = 'Project';
        newOpportunity.Amount = 1;
        newOpportunity.Primary_Contact__c = testContact.id;
        
        insert newOpportunity;
        return newOpportunity;
    } 
    
    public static Opportunity CreateOpportunity(String stageName, String type) {
        
        Contact testContact = CreateContact();
        insert testContact;
        Opportunity newOpportunity = new Opportunity();
        
        newOpportunity.StageName = stageName;
        newOpportunity.Name = 'Test Opportunity Name';
        newOpportunity.CloseDate = Date.newInstance(2019, 7, 11);
        newOpportunity.LeadSource = 'Signup Role';
        newOpportunity.Type = type;
        newOpportunity.Project_Name__c = 'Project';
        newOpportunity.Amount = 1;
        newOpportunity.Primary_Contact__c = testContact.id;
        
        return newOpportunity;
    } 

    public static Opportunity CreateOpportunity(Id accountId, Id primaryContactId) {
        return CreateOpportunity(accountId, primaryContactId, null, '');
    } 

    public static Opportunity CreateOpportunity(Id accountId, Id primaryContactId, Id salesAccountPlanId) {
        return CreateOpportunity(accountId, primaryContactId, salesAccountPlanId, '');
    } 

    public static Opportunity CreateOpportunity(Id accountId, Id primaryContactId, Id salesAccountPlanId, String enterpriseCfOrgId) {
        return CreateOpportunity(accountId, primaryContactId, salesAccountPlanId, enterpriseCfOrgId, 'Initial', 100, false, 'Qualification', Date.today());
    } 

    public static Opportunity CreateOpportunity(Id accountId, Id primaryContactId, Id salesAccountPlanId, String enterpriseCfOrgId,
                                                String oppType, Decimal amount, Boolean skipVR, String stageName, Date closedDate) {

        String recordTypeName = oppType == 'Initial' ? 'Enterprise Initial' : oppType == 'Expansion' ? 'Enterprise Expand' : oppType == 'Renewal' ? 'Enterprise Renewal' : 'Services';
        String oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Cont Opp';
        newOpportunity.CurrencyIsoCode = 'USD';
        newOpportunity.Stagename = stageName;
        newOpportunity.AccountId = accountId;
        newOpportunity.CloseDate = closedDate; 
        newOpportunity.Effective_Date__c = closedDate; 
        newOpportunity.Primary_Contact__c = primaryContactId;
        newOpportunity.Project_Name__c = 'Cont Project';
        newOpportunity.LeadSource = 'Sales Generated';
        newOpportunity.Amount = amount;
        newOpportunity.Competitors__c = 'ContentStack';
        newOpportunity.Sales_Account_Plan__c = salesAccountPlanId;
        newOpportunity.Type = oppType;
        newOpportunity.RecordTypeId = oppRecordTypeId;
        newOpportunity.Enterprise_CF_Organization__c = enterpriseCfOrgId;
        newOpportunity.Skip_VR__c = skipVR;
        newOpportunity.SLA_Name2__c = 'Gold';
        newOpportunity.SLA_Price__c = 10000;  
        if(oppType == 'Expansion')
            newOpportunity.Expansion_Type__c = 'Upsell'; 
        if(stageName == 'Closed Lost') {
            newOpportunity.Lost_Reason__c = 'Other';
            newOpportunity.Lost_Reason_Details__c = 'Lost reason details must be at least 50 characters for lost opportunities.';
        }

        insert newOpportunity;
        return newOpportunity;
    } 
    
    public static Opportunity CreateOpportunity(Id accountId, Id recordTypeId, String stageName, Date closedDate) {
        
        Contact testContact = CreateContact();
        insert testContact;
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.RecordTypeId = recordTypeId;
        newOpportunity.StageName = stageName;
        newOpportunity.Name = 'Test Opportunity Name';
        newOpportunity.CloseDate = Date.newInstance(2019, 7, 11);
        newOpportunity.LeadSource = 'Signup Role';
        newOpportunity.Type = 'test type';
        newOpportunity.Project_Name__c = 'Project';
        newOpportunity.Amount = 1;
        newOpportunity.Primary_Contact__c = testContact.id;
        newOpportunity.CloseDate = closedDate;
        newOpportunity.ForecastCategoryName = 'Pipeline';
        return newOpportunity;
    } 
    
    public static Opportunity CreateOpportunity(Id accountId, String stageName, Date closedDate) {
        
        Contact testContact = CreateContact();
        insert testContact;
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.StageName = stageName;
        newOpportunity.Name = 'Test Opportunity Name';
        newOpportunity.CloseDate = Date.newInstance(2019, 7, 11);
        newOpportunity.LeadSource = 'Signup Role';
        newOpportunity.Type = 'Initial';
        newOpportunity.Project_Name__c = 'Project';
        newOpportunity.Amount = 1;
        newOpportunity.Primary_Contact__c = testContact.id;
        newOpportunity.CloseDate = closedDate;
        newOpportunity.ForecastCategoryName = 'Pipeline';
        return newOpportunity;
    } 
    
    public static Opportunity CreateOpportunityForStage(String username){
        
        User testUser = CreateUser(username);
        insert testUser;
        
        Contact testContact = CreateContact();
        insert testContact;
        Opportunity newOpportunity = new Opportunity();
       
        newOpportunity.StageName = 'Discovery';
        newOpportunity.Name = 'Test Opportunity Name';
        newOpportunity.CloseDate = Date.newInstance(2019, 7, 11);
        newOpportunity.LeadSource = 'Signup Role';
        newOpportunity.Type = 'Initial';
        newOpportunity.Project_Name__c = 'Project';
        newOpportunity.Amount = 1;
        newOpportunity.Primary_Contact__c = testContact.id;
        newOpportunity.How_Did_You_Hear_About_Contentful__c = 'Facebook';
        newOpportunity.Competitors__c = 'Acquia';
        newOpportunity.SLA_Name2__c = 'Platinum';
        newOpportunity.Effective_Date__c = Date.newInstance(2019, 11, 12);
        newOpportunity.Use_Case_New__c = 'Audio';
        newOpportunity.Closed_Won_Information__c = 'Necessary';
        newOpportunity.Prospecting_Manager__c = testUser.Id;
        newOpportunity.CF_Customer_Success_Manager_M__c = testUser.Id;
        newOpportunity.TA__c = testUser.Id;
        newOpportunity.SA__c = testUser.Id;
        
        return newOpportunity;
    } 
    
    public static Opportunity CreateOpportunityForStageClosedLost(){
        
        Contact testContact = CreateContact();
        insert testContact;
        Opportunity newOpportunity = new Opportunity();
        
        newOpportunity.StageName = 'Discovery';
        newOpportunity.Name = 'Test Opportunity Name';
        newOpportunity.CloseDate = Date.newInstance(2019, 7, 11);
        newOpportunity.LeadSource = 'Signup Role';
        newOpportunity.Type = 'Initial';
        newOpportunity.Project_Name__c = 'Project';
        newOpportunity.Amount = 1;
        newOpportunity.Primary_Contact__c = testContact.id;
        newOpportunity.How_Did_You_Hear_About_Contentful__c = 'Facebook';
        newOpportunity.Competitors__c = 'Acquia';
        newOpportunity.SLA_Name2__c = 'Platinum';
        newOpportunity.Effective_Date__c = Date.newInstance(2019, 11, 12);
        newOpportunity.Use_Case_New__c = 'Audio';
        newOpportunity.Closed_Won_Information__c = 'Necessary';
        newOpportunity.Prospecting_Manager__c = null;
        newOpportunity.CF_Customer_Success_Manager_M__c = null;
        newOpportunity.TA__c = null;
        newOpportunity.SA__c = null;
        
        return newOpportunity;
    } 
    
    public static List<Opportunity> CreateOpportunitiesWithAccounts(Account relatedAccount){
        List<Opportunity> listOfOpportunityForUpdate = new List<Opportunity>();
        
        //Opp 0 - Validition Rule - Type: Initial StageName: Discovery
        listOfOpportunityForUpdate.add(CreateOpportunity('Discovery','Initial'));
        //Opp 1 - Validition Rule - Type: Expansion StageName: Qualification
        listOfOpportunityForUpdate.add(CreateOpportunity('Qualification','Expansion'));
        //Opp 2 - Validition Rule - Type: Renewal StageName: Proposal/Negotiation
        listOfOpportunityForUpdate.add(CreateOpportunity('Proposal/Negotiation','Renewal'));
        //Opp 3 - Type: Else
        listOfOpportunityForUpdate.add(CreateOpportunity('Qualification','Open'));
        //Opp 4 - UpdateCloseDate
        listOfOpportunityForUpdate.add(CreateOpportunity());
        //Opp 5 - Opp With New Owner ID and UserRoleName = Account Executive And Account
        listOfOpportunityForUpdate.add(CreateOpportunity());
        
        for(Opportunity currentOpportunity : listOfOpportunityForUpdate){
            currentOpportunity.AccountId = relatedAccount.Id;
        }
        return listOfOpportunityForUpdate;
    }
    
    public static List<Opportunity> CreateOpportunitiesWithAccounts(){
        List<Account> listOfAccounts = TestDataFactory.CreateAccountsWithBillingAddress(5);
        insert listOfAccounts;
        
        List<Opportunity> listOfOpportunities = new List<Opportunity>();
        for(Account acc : listOfAccounts){
           	listOfOpportunities.Add(TestDataFactory.CreateOpportunity(acc.Id, 'Discovery', Date.newInstance(2099, 5, 5)));
        }        
        return listOfOpportunities;
    }
    
    //Opportunity - Change Stage Name
    public static void getClosedWonOrClosedLostOpportunity(Opportunity opp, Boolean isClosedWon, String budgetHolderId, String sapId){
         
        opp.StageName = 'Discovery';        
        // opp.Related_Service_Opportunity__c = 'No';
        update opp;
        //Required fields for Validation stage
        opp.StageName = 'Validation';
        opp.Use_Case_New__c = 'Knowledge base';
        opp.Current_Solution__c = 'Test Solution';
        opp.Opportunity_Pain__c = 'No Pain No Gain';
        opp.Business_Impact_Outcomes__c = 'No business impacts';
        opp.Decision_Process__c = 'No decision process';
        opp.Budget_Holder__c = budgetHolderId;
        update opp;
        //Required fields for Scoping & Alignment stage
        opp.StageName = 'Scoping & Alignment';
        opp.Is_this_opportunity_related_to_Trial__c = 'No';
        opp.Mutually_Agreed_Close_Date__c = Date.today();
        opp.Competitors__c = 'Adobe';
        opp.Sales_Account_Plan__c = sapId; 
        update opp;
        //Required fields for Procurement stage
        opp.StageName = 'Procurement';
        opp.Confirmed_Timeline__c = true;
        opp.Pro_Services_Presented__c = true;
        opp.What_are_the_PotentialOpportunityR_Risks__c = 'No risks';
        opp.Closing_Plan__c = 'No closing plan';
        opp.ARR_Low_End__c = 1;
        opp.ARR_High_End__c = 10;
        update opp;
        //Required fields for Signature stage
        opp.StageName = 'Signature';
        opp.MSA_Complete__c = true;
        opp.Legal_Completion_Date__c = Date.today();
        opp.Procurement_Completion_Date__c = Date.today();
        opp.Procurement_Contact__c = budgetHolderId;
        update opp;  

        Handover__c testHandover = TestDataFactory.CreateHandover(opp.Id, opp.AccountId);
 
        //Required fields for Submitted stage
        opp.Effective_Date__c = Date.today();
        opp.Closed_Won_Information__c = 'We won!!!!'; 
        opp.Competitors__c = 'Adobe';
        opp.SLA_Name2__c = 'Gold';
        opp.SLA_Price__c = 10000;
        opp.Irregular_Fee_Schedule__c = 'Yes';
        opp.Special_Pricing__c = 'Yes';
        opp.Special_Billing_Terms__c = 'Yes';
        opp.StageName = 'Submitted'; 
        update opp;
        opp.StageName = 'Closed Won';
        update opp;
        
        if(!isClosedWon) {
            opp.Lost_Reason__c = 'Legal';
            opp.Lost_Reason_Details__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Polycratem Samium felicem appellabant. Deinde disputat, quod cuiusque generis animantium statui deceat extremum. Sic enim censent, oportunitatis esse beate vivere. Duo enim genera quae erant, fecit tria.';
            opp.StageName = 'Closed Lost';
            update opp;
        } 
    } 
    
    //CREATE Product2//
    public static Product2 CreateProduct2(String name, String zquCategory, String internalName, String SKU, String currencyIsoCode){
        Product2 newProduct = new Product2();
        newProduct.Name = name;
        newProduct.CurrencyIsoCode = currencyIsoCode;
        newProduct.zqu__SKU__c = SKU;
        newProduct.zqu__Category__c = zquCategory; 
        newProduct.InternalName__c = internalName;
        newProduct.zqu__EffectiveStartDate__c = Date.today();
        newProduct.zqu__EffectiveStartDate__c = Date.today().addDays(15);
        insert newProduct;
        return newProduct;
    } 
    
    //CREATE ORDER//    
    public static Order CreateOrder(Id accountId, Id opportunityId, Date effDate, String status){
        Order newOrder = new Order();	
        newOrder.AccountId = accountId;
        newOrder.EffectiveDate = effDate;
        newOrder.Status = status;
        newOrder.Dhruvsoft__Opportunity__c = opportunityId;
        return newOrder;
    }
    
    //CREATE USER//
    public static User CreateUser(String firstName, String lastName, String email, String profileName, String title, String userRoleId){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];
        
        User newUser = new User();
        newUser.LastName = lastName;
        newUser.FirstName = firstName;
        newUser.Alias = firstName.left(2) + lastName.right(3);
        newUser.Title = title;
        newUser.Email = email;
        newUser.Username = email;
        newUser.ProfileId = profileId.Id;
        newUser.TimeZoneSidKey = 'GMT';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LocaleSidKey = 'en_US';
        newUser.IsActive = true;
        newUser.UserRoleId = userRoleId;
        
        insert newUser;
        return newUser;
    }
    
    public static User CreateUser(String username){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User newUser = new User();
        newUser.LastName = 'Test User Last Name';
        newUser.FirstName = 'Test User First Name';
        newUser.Alias = 'Alias';
        newUser.Email = 'usernames-email@test.com';
        newUser.Username = username;
        newUser.ProfileId = profileId.Id;
        newUser.TimeZoneSidKey = 'GMT';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LocaleSidKey = 'en_US';
        newUser.IsActive = true;
        
        return newUser;
    }
    
     public static User CreateUser(String username, Id profileId){
               
        User newUser = CreateUser(username);        
        newUser.ProfileId = profileId;        
        return newUser;
    }
    
    //CREATE USER WITH ROLE    
    public static UserRole CreateUserRole(String name,String devName){
        UserRole role = new UserRole();
        role.DeveloperName = devName;
        role.Name = name;        
        return role;
    }
    
    //CREATE MARKETING RESOURCE//    
    public static Marketing_Resource__c CreateMarketingResource(){
        
        Marketing_Resource__c newMarketingResource = new Marketing_Resource__c();
        newMarketingResource.Name = 'testtest';
        newMarketingResource.Short_name__c = 'test';
        
        return newMarketingResource;
    }
    
    //CREATE MARKETING RESOURCE LEAD//    
    public static Marketing_Resource_Lead__c CreateMarketingResourceLead(Id leadId, Id marketingResourceId){
        
        Marketing_Resource_Lead__c newMarketingResourceLead = new Marketing_Resource_Lead__c();  
        newMarketingResourceLead.Lead__c = leadId;
        newMarketingResourceLead.Marketing_Resource__c = marketingResourceId;
        
        return newMarketingResourceLead;
    }
    
    //FUNNEL BEAM INDUSTRY MAP
    public static FunnelBeamIndustryMap__c CreateFunnelBeamIndustryMap(){
        
        FunnelBeamIndustryMap__c industry = new FunnelBeamIndustryMap__c();
        industry.Name = 'Arts and Crafts';
        industry.FunnelBeam_Industry__c = 'Technology';
        industry.Salesforce_Industry__c = 'Technology';
        industry.IsAgency__c = true;
        
        return industry;
        
    }
    
    //CREATE CF ORGANIZATION

    public static CF_Organization__c CreateCF_Organization(Id accountId, String orgName, Integer gk_id, String gk_key){
        CF_Organization__c cfOrg = new CF_Organization__c();
        cfOrg.Account__c = accountId;
        cfOrg.gk_id__c = gk_id;
        cfOrg.Name = orgName;
        cfOrg.gk_name__c = orgName;
        cfOrg.gk_key__c = gk_key;
        insert cfOrg;
        return cfOrg;
    }
    
    public static CF_Organization__c CreateCF_Organization(Id accountId){
        CF_Organization__c organization = new CF_Organization__c();
        organization.Account__c = accountId;
        organization.gk_key__c = 'key';
        organization.Name = 'CF';
        
        return organization;
    }
    
    //CREATE CF USER
    public static CF_User__c CreateCF_User(){
        CF_User__c userCF = new CF_User__c();
        userCF.Name = 'User';
        userCF.gk_id__c = 123;
        userCF.gk_key__c = 'abc';
        userCF.gk_email__c = 'sa.sa@company.com';
        return userCF;
    }
    
    //CREATE EMAIL OPTED OUT DEFINITION    
    public static EmailOptOutDefinitions__c CreateEmailOptOutDefinitions(){
        EmailOptOutDefinitions__c newDefinition = new EmailOptOutDefinitions__c();
        newDefinition.Name = 'Test';
        newDefinition.Value__c = 'lilly';
        
        return newDefinition;   
    }
    
    //CREATE HANDOVER FOR OPPORTUNITY TEST
    
    public static Handover__c CreateHandover(Id oppId, Id accountId){
        return CreateHandover(oppId, accountId, null);
    }

    public static Handover__c CreateHandover(Id oppId, Id accountId, String recordType){
        
        recordType = recordType == null ? 'Sales-CS Handover' : recordType; 

        Handover__c newHandover = new Handover__c();
        newHandover.Opportunity_Name__c = oppId;
        newHandover.Account_Name__c = accountId;
        newHandover.RecordTypeId = Schema.SObjectType.Handover__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        insert newHandover;
        return newHandover;
    }
    
    // CREATE Partner_Deals__c FOR OPPORTUNITY TEST        
    public static Partner_Deals__c CreatePartnerDeal(Id opportunityId, Id accountId, Id clientAccountId, String customerRT){
        Partner_Deals__c newPartnerDeal = new Partner_Deals__c();
        newPartnerDeal.Opportunity_Name__c = opportunityId;
        newPartnerDeal.Partner_Account__c  = accountId;
        newPartnerDeal.Client_Account__c = clientAccountId;
        newPartnerDeal.Partner_Customer_Relationship_Type__c = customerRT;
        insert newPartnerDeal;
        return newPartnerDeal;
    } 
    
    //CREATE dsfs__DocuSign_Status__c
    
    public static dsfs__DocuSign_Status__c CreateDocuSignStatus(Id opportunityId){
        dsfs__DocuSign_Status__c newDocusignstatus = new dsfs__DocuSign_Status__c();
		newDocusignstatus.dsfs__Opportunity__c = opportunityId;
        return newDocusignstatus;
    }
    
    //CREATE Attachment    
    public static Attachment CreateAttachment(Id parentId){
        Attachment newAttachment = new Attachment();
		newAttachment.Name = 'test';
		newAttachment.Body = Blob.valueOf('test');
		newAttachment.ParentId = parentId;
        return newAttachment;
    }
    
    //CREATE ExecuteSetting
   	public static ExecuteSetting__c CreateExecuteSetting(String name, Boolean execute, Boolean active){
        ExecuteSetting__c executeSetting = new ExecuteSetting__c();
		executeSetting.Name = name; 
		executeSetting.Execute__c = execute;
        executeSetting.Active__c = active;
        insert executeSetting;
        return executeSetting;
    } 
   
    // CREATE ZProduct    
    public static zqu__ZProduct__c CreateZProduct(String name){
        zqu__ZProduct__c zproduct = new zqu__ZProduct__c();
        zproduct.Name = name;
        insert zproduct;
        return zproduct;
    } 

    // CREATE Zuora__CustomerAccount__c    
    public static Zuora__CustomerAccount__c CreateZuoraCustomerAccount(String accountId, String name){
        Zuora__CustomerAccount__c zCustomerAccount = new Zuora__CustomerAccount__c();
        zCustomerAccount.Zuora__Account__c = accountId;
        zCustomerAccount.Name = name;
        insert zCustomerAccount;
        return zCustomerAccount;
    }         
    
    //CREATE ZUORA SUBSCRIPTION FOR OPPORTUNITY TEST//    
    public static Zuora__Subscription__c CreateZouraSubscription(String productRatePlanId, String accountId, String status){
        Zuora__Subscription__c newSubscription = new Zuora__Subscription__c();
        newSubscription.Primary_Product_Rate_Plan__c = productRatePlanId;
        newSubscription.Zuora__Account__c = accountId;
        newSubscription.Zuora__Status__c = status;
        insert newSubscription;
        return newSubscription;
    }
    
    
    //CREATE zqu__ProductRatePlan__c FOR OPPORTUNITY TEST//    
    public static zqu__ProductRatePlan__c CreateProductRatePlan(String productId, String zquProductId, String planType, String internalName){
        zqu__ProductRatePlan__c newProductRatePlan = new zqu__ProductRatePlan__c();
        newProductRatePlan.zqu__ZProduct__c = zquProductId;
        newProductRatePlan.zqu__Product__c = productId; 
        newProductRatePlan.PlanType__c = planType;
        newProductRatePlan.InternalName__c = internalName;
        newProductRatePlan.zqu__EffectiveStartDate__c = Date.today();
        newProductRatePlan.zqu__EffectiveEndDate__c = Date.today().addDays(15);
        insert newProductRatePlan;
        return newProductRatePlan;
    } 

    // Create ZQuote
    public static zqu__Quote__c CreateZQuote(Id oppId){
        zqu__Quote__c newQuote = new zqu__Quote__c();
        newQuote.name = 'quote';
		newQuote.Acceptance_Status__c = 'Accepted';
		newQuote.zqu__Opportunity__c = oppId;
        return newQuote;
    }
    
    // Create Territory Maps
    public static List<Territory_Maps__c> CreateTerritoryMaps(){
              return new List<Territory_Maps__c> {
            new Territory_Maps__c(Name = 'Map 1', HQ_Country__c = 'Germany', Sales_Region__c = 'EMEA', Sales_Territory__c = 'DACH', State_Province__c = ''),
            new Territory_Maps__c(Name = 'Map 2', HQ_Country__c = 'Canada', Sales_Region__c = 'NA', Sales_Territory__c = 'Great Lakes', State_Province__c = 'Ontario'),
            new Territory_Maps__c(Name = 'Map 3', HQ_Country__c = 'Bosnia and Herzegovina', Sales_Region__c = 'EMEA', Sales_Territory__c = 'ROE', State_Province__c = ''),
            new Territory_Maps__c(Name = 'Map 4', HQ_Country__c = 'United States', Sales_Region__c = 'NA', Sales_Territory__c = 'California', State_Province__c = 'California'),
            new Territory_Maps__c(Name = 'Map 6', HQ_Country__c = 'Turkmenistan', Sales_Region__c = 'APAC', Sales_Territory__c = 'ROW', State_Province__c = ''),
            new Territory_Maps__c(Name = 'Map 7', HQ_Country__c = 'Australia', Sales_Region__c = 'OCEANIA', Sales_Territory__c = 'OCEANIA', State_Province__c = 'South Australia')
        }; 
    }

    //Pull data from Salesforce        
    public static List<Account> GetAccountsByIds(Set<Id> accountIds){
        return [SELECT Id, Classification__c, Tier__c,First_Class__c,Auto_classification_done__c 
                FROM Account WHERE Id in :accountIds ]; 
    }
    
    public static List<Account> GetAccountsWithBillingAddressByIds(Set<Id> accountIds){
        return [SELECT Id, BillingStreet, BillingCity,BillingState,BillingPostalCode,BillingCountry,
                DF_Company_Street__c,DF_City__c,DF_State__c,DF_Country_Postal_Code__c,DF_Company_Country__c
                FROM Account WHERE Id in :accountIds ]; 
    }
    
    public static List<Lead> GetLeadsById(Set<Id> leadsIds){
        return [SELECT Id, Classification__c, Tier__c, FunnelBeam_Classified__c, First_Class__c, DataFox_Classified__c,
                	Company_HQ_Country__c, Company_HQ_Sales_Region__c, Company_HQ_Sales_Territory__c
                FROM Lead WHERE Id in :leadsIds ]; 
    }
    
    public static List<zqu__Quote__c> GetQuotes(){
        return [SELECT Id, Payment__c, Additional_Users__c, Additional_Asset_Bandwidth__c, Additional_API_Calls__c, 
                Additional_API_Calls_Free__c, Additional_Asset_Bandwidth_Free__c, Included_Users__c,
                Bill_Cycle_Month__c, zqu__BillCycleDay__c, CF_Organization_Key__c, organization_key__c, Debitor_Number__c,
                zqu__Account__r.organization_key__c, zqu__Account__r.Billing_Entity__c, zqu__Account__r.Bill_Cycle_Month__c, zqu__Account__r.Debitor_Number__c
                FROM zqu__Quote__c
                ORDER BY Id]; 
    }
    
    public static zqu__Quote__c GetQuoteById(Id quoteId){
        return [SELECT Id, Payment__c, Additional_Users__c, Additional_Asset_Bandwidth__c, Additional_API_Calls__c, Bill_Cycle_Month__c,
                zqu__BillCycleDay__c, CF_Organization_Key__c, organization_key__c, Debitor_Number__c,
                zqu__Account__r.organization_key__c, zqu__Account__r.Billing_Entity__c, zqu__Account__r.Bill_Cycle_Month__c, zqu__Account__r.Debitor_Number__c
                FROM zqu__Quote__c
                WHERE Id = :quoteId LIMIT 1]; 
    }
    
    public static List<zqu__QuoteRatePLanCharge__c> GetDiscountQuoteRatePLanChargesByQuoteId(Id quoteId){
        return [SELECT Id, zqu__EffectivePrice__c, zqu__DiscountAmount__c, zqu__Discount__c 
                FROM zqu__QuoteRatePLanCharge__c 
                WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId AND zqu__ProductRatePlanCharge__r.InternalName__c = 'discount'];
    }
    
    public static List<zqu__QuoteRatePLanCharge__c> GetQuoteRatePLanChargesByQuoteId(Id quoteId){
        return [SELECT Id, zqu__Quantity__c, zqu__EffectivePrice__c, Name, InternalName__c, zqu__ProductRatePlanCharge__r.InternalName__c
                FROM zqu__QuoteRatePlanCharge__c 
                WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId AND 
                (zqu__ProductRatePlanCharge__r.InternalName__c = 'additional_api_calls' OR
                 zqu__ProductRatePlanCharge__r.InternalName__c = 'additional_users' OR
                 zqu__ProductRatePlanCharge__r.InternalName__c = 'additional_bandwidth' OR 
                 zqu__ProductRatePlanCharge__r.InternalName__c LIKE '%_sla%'
                )
                ORDER BY zqu__ProductRatePlanCharge__r.InternalName__c];
    }
    
    public static zqu__QuoteCharge_Tier__c GetQuoteChargeTierByInternalName(String internalName, Id quoteId){
        return [SELECT Id, zqu__Tier__c, zqu__RatePlanCharge__r.InternalName__c, zqu__StartingUnit__c, zqu__EndingUnit__c, zqu__QuoteRatePlanCharge__r.Name 
                FROM zqu__QuoteCharge_Tier__c 
                WHERE zqu__RatePlanCharge__r.InternalName__c = :internalName
                AND zqu__QuoteRatePlanCharge__r.zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId 
                AND zqu__EndingUnit__c = 750 LIMIT 1];          
    }
    
    // Static Resources Data 
    public static List<Account> LoadAccountsFromStaticResource(){
        List<Account> lstAccounts = Test.loadData(Account.sObjectType,'Zuora_Account');
        return lstAccounts;
    }
    
    public static List<Contact> LoadContactsFromStaticResource(){
        List<Contact> lstContacts = Test.loadData(Contact.sObjectType,'Zuora_Contact');
        return lstContacts;
    }
    
    public static List<Opportunity> LoadOpportunitiesFromStaticResource(){
        List<Opportunity> lstOpportunity = Test.loadData(Opportunity.sObjectType,'Zuora_Opportunity');
        return lstOpportunity;
    }
    
    public static List<zqu__BillingEntity__c> LoadBillingEntityFromStaticResource(){
        List<zqu__BillingEntity__c> lstBillingEntity = Test.loadData(zqu__BillingEntity__c.sObjectType,'Zuora_BillingEntity');
        return lstBillingEntity;
    }
    
    public static List<zqu__CommunicationProfile__c> LoadCommunicationProfileFromStaticResource(){
        List<zqu__CommunicationProfile__c> lstCommunicationProfile = Test.loadData(zqu__CommunicationProfile__c.sObjectType,'Zuora_CommuncationProfile');
        return lstCommunicationProfile;
    }
    
    public static List<zqu__ZUnitOfMeasure__c> LoadUnitsOfMeasureFromStaticResource(){
        List<zqu__ZUnitOfMeasure__c> lstUMO = Test.loadData(zqu__ZUnitOfMeasure__c.sObjectType,'Zuora_UMO');
        return lstUMO;
    }
    
    public static List<zqu__InvoiceTemplate__c> LoadInvoiceTemplatesFromStaticResource(){
        List<zqu__InvoiceTemplate__c> lstInvoiceTemplate = Test.loadData(zqu__InvoiceTemplate__c.sObjectType,'Zuora_InvoiceTemplate');
        return lstInvoiceTemplate;
    }
    
    public static List<Product2> LoadProducts2FromStaticResource(){
        List<Product2> lstProduct2 = Test.loadData(Product2.sObjectType,'Zuora_Product2');
        return lstProduct2;
    }
    
    public static List<zqu__ZProduct__c> LoadZProductsFromStaticResource(){
        List<zqu__ZProduct__c> lstZProduct = Test.loadData(zqu__ZProduct__c.sObjectType,'Zuora_Product');
        return lstZProduct;
    }
    
    public static List<zqu__ProductRatePlan__c> LoadProductRatePlansFromStaticResource(){
        List<zqu__ProductRatePlan__c> lstProductRatePlan = Test.loadData(zqu__ProductRatePlan__c.sObjectType,'Zuora_ProductRatePlan');
        return lstProductRatePlan;
    }
    
    public static List<zqu__ProductRatePlanCharge__c> LoadProductRatePlanChargesFromStaticResource(){
        List<zqu__ProductRatePlanCharge__c> lstProductRatePlanCharge = Test.loadData(zqu__ProductRatePlanCharge__c.sObjectType,'Zuora_ProductRatePlanCharge');
        return lstProductRatePlanCharge;
    }
    
    public static List<zqu__ProductRatePlanChargeTier__c> LoadProductRatePlanChargeTiersFromStaticResource(){
        List<zqu__ProductRatePlanChargeTier__c> lstProductRatePlanChargeTier = Test.loadData(zqu__ProductRatePlanChargeTier__c.sObjectType,'Zuora_ProductRatePlanChargeTier');
        return lstProductRatePlanChargeTier;
    }
    
    public static List<zqu__Quote__c> LoadQuotesFromStaticResource(){
        List<zqu__Quote__c> lstQuote = Test.loadData(zqu__Quote__c.sObjectType,'Zuora_Quote');
        return lstQuote;
    }
    
    public static List<zqu__QuoteAmendment__c> LoadQuoteAmendmentsFromStaticResource(){
        List<zqu__QuoteAmendment__c> lstQuoteAmendment = Test.loadData(zqu__QuoteAmendment__c.sObjectType,'Zuora_QuoteAmendment');
        return lstQuoteAmendment;
    }
    
    public static List<zqu__QuoteRatePlan__c> LoadQuoteRatePlansFromStaticResource(){
        List<zqu__QuoteRatePlan__c> lstQuoteRatePlan = Test.loadData(zqu__QuoteRatePlan__c.sObjectType,'Zuora_QuoteRatePlan');
        return lstQuoteRatePlan;
    }
    
    public static List<zqu__QuoteRatePlanCharge__c> LoadQuoteRatePlanChargesFromStaticResource(){
        List<zqu__QuoteRatePlanCharge__c> lstQuoteRatePlanCharge = Test.loadData(zqu__QuoteRatePlanCharge__c.sObjectType,'Zuora_QuoteRatePlanCharge');
        return lstQuoteRatePlanCharge;
    }
    
    public static List<zqu__QuoteCharge_Tier__c> LoadQuoteChargeTiersFromStaticResource(){
        List<zqu__QuoteCharge_Tier__c> lstQuoteRatePlanChargeTier = Test.loadData(zqu__QuoteCharge_Tier__c.sObjectType,'Zuora_QuoteRatePlanChargeTier');
        return lstQuoteRatePlanChargeTier;
    }
    
    public static void LoadTestData(){
        LoadAccountsFromStaticResource();
        LoadContactsFromStaticResource();
        LoadOpportunitiesFromStaticResource();
        LoadBillingEntityFromStaticResource();
        LoadCommunicationProfileFromStaticResource();
        LoadUnitsOfMeasureFromStaticResource();
        LoadInvoiceTemplatesFromStaticResource();
        LoadProducts2FromStaticResource();
        LoadZProductsFromStaticResource();
        LoadProductRatePlansFromStaticResource();        
        LoadProductRatePlanChargesFromStaticResource();
        LoadProductRatePlanChargeTiersFromStaticResource();
        LoadQuotesFromStaticResource();
        LoadQuoteAmendmentsFromStaticResource();
        LoadQuoteRatePlansFromStaticResource();
        LoadQuoteRatePlanChargesFromStaticResource();
        LoadQuoteChargeTiersFromStaticResource();
    }
}