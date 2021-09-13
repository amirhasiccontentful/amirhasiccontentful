@isTest
public with sharing class AccountTriggerHandler_Test {
    
    public static testMethod void Insert_Test(){
        //Arange 
        //
        Account testAcc = TestDataFactory.CreateAccount();
        testAcc.Tier__c = '1';
        testAcc.Classification__c = 'SMB';
        //Act
        //
        update testAcc;
        //Pull Data From Salesforce
        Account nullTierAccount = [SELECT id, Tier__c FROM Account WHERE Id =:testAcc.Id];
        //Assert
        //
        //Is Tier Null If Classification != Enterprise
        System.assertEquals(null, nullTierAccount.Tier__c);
    }
    
    public static testMethod void Update_Test(){
        //Arange
        //  
        List<Account> accountsWithParents = TestDataFactory.CreateAccountsWithParent();
        
        FunnelBeamIndustryMap__c industry = TestDataFactory.CreateFunnelBeamIndustryMap();
        insert industry;
        
        List<Account> listOfAccountsForUpdate = TestDataFactory.CreateAccounts();
        insert listOfAccountsForUpdate;
        
        listOfAccountsForUpdate = TestDataFactory.UpdateAccountRevenuesNumberOfEmployees(listOfAccountsForUpdate);
        
        //Act
        //
        update listOfAccountsForUpdate;
        update industry;
        
        //Pull Data From Salesforce
        Set<Id> idsOfUpdatedAccounts = new Set<Id>();
        for(Account updatedAccount : listOfAccountsForUpdate){
            idsOfUpdatedAccounts.add(updatedAccount.Id);
        }
        
        List<Account> updatedAccountsForAssert = TestDataFactory.GetAccountsByIds(idsOfUpdatedAccounts);
        List<Account> updatedBillingAddressForAssert = TestDataFactory.GetAccountsWithBillingAddressByIds(idsOfUpdatedAccounts);
        Account largeEnterpriseAccount = updatedAccountsForAssert[0];
        Account bigEnterpriseAccount = updatedAccountsForAssert[1];
        Account mediumEnterpriseAccount = updatedAccountsForAssert[2];
        Account largeAccountBlankClassification = updatedAccountsForAssert[3];
        Account bigAccountBlankClassification = updatedAccountsForAssert[4];
        Account mediumAccountBlankClassification = updatedAccountsForAssert[5];
        Account smbAccountBlankClassification = updatedAccountsForAssert[6];
        Account elseAccount = updatedAccountsForAssert[7];
        Account accountWithCompanyIndustry = updatedAccountsForAssert[8];
        Account accountWithBillingAddress = updatedBillingAddressForAssert[8];
       
        //Assert
        //
        //Enterprise Account With >= 10000 Employees
        System.assertEquals('Enterprise', largeEnterpriseAccount.Classification__c);
        System.assertEquals('1', largeEnterpriseAccount.Tier__c);
        System.assertEquals(false, largeEnterpriseAccount.First_Class__c);
        System.assertEquals(true, largeEnterpriseAccount.Auto_classification_done__c);
        //Enterprise Account With >= 1000 Employees
        System.assertEquals('Enterprise', bigEnterpriseAccount.Classification__c);
        System.assertEquals('2', bigEnterpriseAccount.Tier__c);
        //Enterprise Account With > 100 Employees
        System.assertEquals('Enterprise', mediumEnterpriseAccount.Classification__c);
        System.assertEquals('3', mediumEnterpriseAccount.Tier__c);
        //Blank Classification Account With >= 10000 Employees
        System.assertEquals('Enterprise', largeAccountBlankClassification.Classification__c);
        System.assertEquals('1', largeAccountBlankClassification.Tier__c);
        //Blank Classification Account With >= 1000 Employees
        System.assertEquals('Enterprise', bigAccountBlankClassification.Classification__c);
        System.assertEquals('2', bigAccountBlankClassification.Tier__c);
        //Blank Classification Account With >= 100 Employees
        System.assertEquals('Enterprise', mediumAccountBlankClassification.Classification__c);
        System.assertEquals('3', mediumAccountBlankClassification.Tier__c);
        //Blank Classification Account With > 0 Employees - SMB
        System.assertEquals('SMB', smbAccountBlankClassification.Classification__c);
        System.assertEquals(null, smbAccountBlankClassification.Tier__c);
        //Else Account
        System.assertEquals('Unknown', elseAccount.Classification__c);
        System.assertEquals(null, elseAccount.Tier__c);
        //Account with industry
        System.assertEquals('Agency', accountWithCompanyIndustry.Classification__c);
        System.assertEquals(null, accountWithCompanyIndustry.Tier__c);
        System.assertEquals(true, accountWithCompanyIndustry.Auto_classification_done__c);
        System.assertEquals(true, accountWithCompanyIndustry.First_Class__c);    
        //Account With Billing Address
        System.assertEquals(accountWithBillingAddress.DF_Company_Street__c, accountWithBillingAddress.BillingStreet);
        System.assertEquals(accountWithBillingAddress.DF_City__c, accountWithBillingAddress.BillingCity);
        System.assertEquals(accountWithBillingAddress.DF_State__c, accountWithBillingAddress.BillingState);
        System.assertEquals(accountWithBillingAddress.DF_Country_Postal_Code__c, accountWithBillingAddress.BillingPostalCode);
        System.assertEquals(accountWithBillingAddress.DF_Company_Country__c, accountWithBillingAddress.BillingCountry);
    }
    
    
    public static testMethod void Delete_Test(){
        //Arrange
        //
        Account test = TestDataFactory.CreateAccount(); 
        //Act
        //
        delete test;
        //Assert
        //
    }
    
    public static testMethod void SetZendeskFieldsTest(){
        //Arrange
        //        
        User zendeskCSMUser = TestDataFactory.CreateUser('zendeskCSMUser@testing.com');
        zendeskCSMUser.FirstName = 'Melinda';
        zendeskCSMUser.LastName = 'Marczali'; 
        zendeskCSMUser.CSM_Digital_Touch_Region__c = 'EMEA';
        
        User zendeskSAUser = TestDataFactory.CreateUser('zendeskSAUser@testing.com');
        zendeskSAUser.FirstName = 'Sia';
        zendeskSAUser.LastName = 'Rad';  
        
        List<User> testUsers = new List<User>{zendeskCSMUser, zendeskSAUser};
        insert testUsers;
        
        Account testAcc = TestDataFactory.CreateAccount();
        testAcc.CSM_Engagement_Level__c = 'Digital Touch';
        update testAcc;
        //Act
        
        testAcc.CF_Customer_Success_Manager__c = zendeskCSMUser.Id;
        testAcc.SA__c = zendeskSAUser.Id;
        testAcc.TA__c = zendeskSAUser.Id;
        
        update testAcc;
        
        //Assert
        List<Account> checkAccount = [SELECT Id, Zendesk_CSM__c, Zendesk_SA__c, Zendesk_TA__c FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals('csm_digital_emea', checkAccount[0].Zendesk_CSM__c);
        System.assertEquals('Sia Rad', checkAccount[0].Zendesk_SA__c);
        System.assertEquals('Sia Rad', checkAccount[0].Zendesk_TA__c);        
    }    

    //New Account created with no child and added childs later.
    @isTest static void test_NewAccountAddedChildsLater() {

        //Arrange
        Account ultimateAcc_1 = new Account(Name = 'BMW - Ultimate Level');
        insert ultimateAcc_1; 

        //Act 

        Test.startTest();

        Account child_1_a = new Account(Name = 'Third Level - Child 1 alfa', ParentId = ultimateAcc_1.Id);
        insert child_1_a;  

        List<Account> subChildAccounts = new List<Account> {
            new Account(Name = 'Fourth Level - Child 2 alfa', ParentId = child_1_a.Id),
            new Account(Name = 'Quarto Level - Child 3 adelta', ParentId = child_1_a.Id)
        };

        insert subChildAccounts;

        Test.stopTest(); 

        //Assert  
            
        List<Account> childAccounts = [SELECT Id, Ultimate_Parent__c FROM Account WHERE Id !=: ultimateAcc_1.Id];
        for(Account child : childAccounts){
            System.assertEquals(ultimateAcc_1.Id, child.Ultimate_Parent__c); 
        }
    }


    //New top level account added, (change ultimate parent for all chidls ) 
    @isTest static void test_NewTopLevelAccountAddedToHiearachy() {
    
        //Arrange
        Account ultimateAcc_1 = new Account(Name = 'BMW - Ultimate Level');
    	insert ultimateAcc_1;

        Account ultimateAcc_2 = new Account(Name = 'Second Level - Ultimate 2 - VW', ParentId = ultimateAcc_1.Id);
    	insert ultimateAcc_2;
    	
    	Account child_1_a = new Account(Name = 'Third Level - Child 1 alfa', ParentId = ultimateAcc_2.Id);
    	insert child_1_a; 

        Account child_1_b = new Account(Name = 'Treci - Child 1 beta', ParentId = ultimateAcc_2.Id);
    	insert child_1_b; 
    	
        Account child_1_c = new Account(Name = 'Terzo Level - Child 1 cdelta', ParentId = ultimateAcc_2.Id);
    	insert child_1_c;     	
    	
    	Account child_2_a = new Account(Name = 'Fourth Level - Child 2 alfa', ParentId = child_1_a.Id);
    	insert child_2_a; 
    	
    	Account child_2_b = new Account(Name = 'Cetvrti Level - Child 2 beta', ParentId = child_1_b.Id);
    	insert child_2_b;  

        Account child_3_a = new Account(Name = 'Quarto Level - Child 3 adelta', ParentId = child_1_a.Id);
    	insert child_3_a; 

        Set<Id> accountsIds = new Set<Id> { ultimateAcc_1.Id, ultimateAcc_2.Id, child_1_a.Id, child_1_b.Id, child_1_c.Id, child_2_a.Id, child_2_b.Id, child_3_a.Id };

        //Act 

        Test.startTest();

        Account newTopAccount = new Account(Name = 'BMW - Ultra Top Level');
    	insert newTopAccount;

        ultimateAcc_1.ParentId = newTopAccount.Id;
        update ultimateAcc_1;

        Test.stopTest(); 

        //Assert  
         
        List<Account> childAccounts = [SELECT Id, Ultimate_Parent__c FROM Account WHERE Id IN: accountsIds];
        for(Account child : childAccounts){
            System.assertEquals(newTopAccount.Id, child.Ultimate_Parent__c); 
        }
    }

    //Change account from 1 hierarchy to another
    @isTest static void test_TransferAccountToDifferentHieararchy() {
        
        //Arrange

        Account ultimateAcc_1 = new Account(Name = 'BMW - Ultimate Level');
    	insert ultimateAcc_1;

        Account ultimateAcc_2 = new Account(Name = 'Second Level - Ultimate 2 - VW', ParentId = ultimateAcc_1.Id);
    	insert ultimateAcc_2;

        Account ultimateAcc_3 = new Account(Name = 'Audi - Ultimate Level');
    	insert ultimateAcc_3;

        Account ultimateAcc_4 = new Account(Name = 'This is a car producing client - Seat', ParentId = ultimateAcc_3.Id);
    	insert ultimateAcc_4;
    	
    	Account child_1_a = new Account(Name = 'Third Level - Child 1 alfa', ParentId = ultimateAcc_2.Id);
    	insert child_1_a; 

        //Act 

        Test.startTest();

        //change parent Id to a completely different hierarchy
        child_1_a.ParentId = ultimateAcc_4.Id;
        update child_1_a; 

        Test.stopTest(); 

        //Assert   

        List<Account> childAccounts = [SELECT Id, Ultimate_Parent__c FROM Account WHERE Id =: child_1_a.Id];
        System.assertEquals(ultimateAcc_3.Id, childAccounts[0].Ultimate_Parent__c); 
    }

    //Remove parent from account
    @isTest static void test_ParentRemovalFromAccount() {
    
        //Arrange

        Account ultimateAcc_1 = new Account(Name = 'BMW - Ultimate Level');
        insert ultimateAcc_1;

        Account ultimateAcc_2 = new Account(Name = 'Second Level - Ultimate 2 - VW', ParentId = ultimateAcc_1.Id);
        insert ultimateAcc_2; 

        //Act 

        Test.startTest();

        //change parent Id to a completely different hierarchy
        ultimateAcc_2.ParentId = null;
        update ultimateAcc_2; 

        Test.stopTest(); 

        //Assert   

        List<Account> childAccounts = [SELECT Id, Ultimate_Parent__c FROM Account WHERE Id =: ultimateAcc_2.Id];
        System.assertEquals(null, childAccounts[0].Ultimate_Parent__c); 
    }

    //Change account with child accounts Parent Id / Same hiearchcy
    @isTest static void test_ParentUpdateWithinSameHiearachy() {
        
        //Arrange

        Account ultimateAcc_1 = new Account(Name = 'BMW - Ultimate Level');
    	insert ultimateAcc_1;

        Account ultimateAcc_2 = new Account(Name = 'Second Level - - VW', ParentId = ultimateAcc_1.Id);
    	insert ultimateAcc_2;

        Account ultimateAcc_3 = new Account(Name = 'Second Level - # Golf 4 #', ParentId = ultimateAcc_1.Id);
    	insert ultimateAcc_3;

        Account ultimateAcc_4 = new Account(Name = 'This is a car producing client - Seat', ParentId = ultimateAcc_3.Id);
    	insert ultimateAcc_4;
    	
    	Account child_1_a = new Account(Name = 'Third Level - Child 1 alfa', ParentId = ultimateAcc_2.Id);
    	insert child_1_a; 
    	
    	Account child_2_a = new Account(Name = 'Fourth Level - Child 2 alfa', ParentId = child_1_a.Id);
    	insert child_2_a; 

        Account child_3_a = new Account(Name = 'Quarto Level - Child 3 adelta', ParentId = child_1_a.Id);
    	insert child_3_a; 

        Set<Id> accountsIds = new Set<Id> { child_1_a.Id, child_2_a.Id, child_3_a.Id };

        //Act 

        Test.startTest();

        child_1_a.ParentId = ultimateAcc_3.Id; 
        update child_1_a;  

        Test.stopTest(); 

        //Assert   

        List<Account> childAccounts = [SELECT Id, Ultimate_Parent__c FROM Account WHERE Id IN: accountsIds];
        for(Account child : childAccounts){
            System.assertEquals(ultimateAcc_1.Id, child.Ultimate_Parent__c); 
        }

    }

    //Change account with child accounts Parent Id / Different hiearchcy
    @isTest static void test_ParentUpdateWithinDifferentHiearachy() {
        
        //Arrange

        Account ultimateAcc_1 = new Account(Name = 'BMW - Ultimate Level');
    	insert ultimateAcc_1;

        Account ultimateAcc_2 = new Account(Name = 'Second Level - Ultimate 2 - VW', ParentId = ultimateAcc_1.Id);
    	insert ultimateAcc_2;

        Account ultimateAcc_3 = new Account(Name = 'Audi - Ultimate Level');
    	insert ultimateAcc_3;

        Account ultimateAcc_4 = new Account(Name = 'This is a car producing client - Seat', ParentId = ultimateAcc_3.Id);
    	insert ultimateAcc_4;
    	
    	Account child_1_a = new Account(Name = 'Third Level - Child 1 alfa', ParentId = ultimateAcc_2.Id);
    	insert child_1_a;    	
    	
    	Account child_2_a = new Account(Name = 'Fourth Level - Child 2 alfa', ParentId = child_1_a.Id);
    	insert child_2_a; 

        Account child_3_a = new Account(Name = 'Quarto Level - Child 3 adelta', ParentId = child_1_a.Id);
    	insert child_3_a; 

        Set<Id> accountsIds = new Set<Id> { child_1_a.Id, child_2_a.Id, child_3_a.Id };

        //Act 

        Test.startTest();

        child_1_a.ParentId = ultimateAcc_4.Id; 
        update child_1_a;  

        Test.stopTest(); 

        //Assert   

        List<Account> childAccounts = [SELECT Id, Ultimate_Parent__c FROM Account WHERE Id IN: accountsIds];
        for(Account child : childAccounts){
            System.assertEquals(ultimateAcc_3.Id, child.Ultimate_Parent__c); 
        }

    }

    public static testMethod void Test_SalesSegmentOnOwnerChange(){

        //Arrange 

        Account newAccount = TestDataFactory.CreateAccount();
        User newUser = TestDataFactory.CreateUser('BMw', 'F30', 'bmwf30@test.test', 'System Administrator', 'Territory Account Executive', null);
     
        //Act 
        Test.startTest();

        newAccount.OwnerId = newUser.Id;
        update newAccount;

        Test.stopTest(); 
   
        //Assert 
       
        List<Account> allAccounts = [SELECT Id, Sales_Segment__c FROM Account];

        System.assertEquals('Territory', allAccounts[0].Sales_Segment__c); 
        
    }

    public static testMethod void Test_SalesSegmentOnOwnerNoTerritoryTitleChange(){

        //Arrange 

        Account newAccount = TestDataFactory.CreateAccount();
        User newUser = TestDataFactory.CreateUser('BMw', 'F30', 'bmwf30@test.test', 'System Administrator', 'Enterprise Account Executive', null);
     
        //Act 
        Test.startTest();

        newAccount.OwnerId = newUser.Id;
        update newAccount;

        Test.stopTest(); 
   
        //Assert 
       
        List<Account> allAccounts = [SELECT Id, Sales_Segment__c FROM Account];

        System.assertEquals(null, allAccounts[0].Sales_Segment__c); 
        
    }
    
}