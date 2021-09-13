@isTest
public class ZuoraSubscriptionTriggerHandler_Test {

    public static testMethod void TestNotEnterpriseSubscription(){
        //Arrange 
        Account account = TestDataFactory.CreateAccount();

        Product2 product = TestDataFactory.CreateProduct2('Product 1',  'Add On Services', 'enterprise_properties', 'SKUNumber1', 'EUR');
        zqu__ZProduct__c zProduct = TestDataFactory.CreateZProduct('Zqu Product 1');
        zqu__ProductRatePlan__c productRatePlan = TestDataFactory.CreateProductRatePlan(product.Id, zProduct.Id, '', 'Test Product');

        Zuora__CustomerAccount__c zuoraCustomerAccount = TestDataFactory.CreateZuoraCustomerAccount(account.Id, 'Zuora Account Name');
        
        List<Zuora__Subscription__c> newSubscriptions = new List<Zuora__Subscription__c> {

            new Zuora__Subscription__c(Name = 'Subscription 1', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 10, CMRR_After_Discount__c = 5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today(), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 1, Zuora__NextRenewalDate__c = Date.today().addDays(4),
                                       CurrencyIsoCode = 'USD'),

            new Zuora__Subscription__c(Name = 'Subscription 2', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 1, CMRR_After_Discount__c = 0.5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today().addDays(5), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 200, Zuora__NextRenewalDate__c = Date.today().addDays(20),
                                       CurrencyIsoCode = 'EUR')
        };

        //Act
        insert newSubscriptions; 
        
        //Assert
        List<Account> listOfAccounts = [SELECT Id, Type FROM Account WHERE Id = :account.Id];
        System.assertEquals('Customer - Self Service', listOfAccounts[0].Type);
    }
 
    public static testMethod void TestEnterpriseSubscription(){
        //Arrange 
        Account account = TestDataFactory.CreateAccount();

        Product2 product = TestDataFactory.CreateProduct2('Product 1',  'Add On Services', 'enterprise_properties', 'SKUNumber1', 'EUR');
        zqu__ZProduct__c zProduct = TestDataFactory.CreateZProduct('Zqu Product 1');
        zqu__ProductRatePlan__c productRatePlan = TestDataFactory.CreateProductRatePlan(product.Id, zProduct.Id, 'Enterprise', 'Test Product');
        
        Zuora__CustomerAccount__c zuoraCustomerAccount = TestDataFactory.CreateZuoraCustomerAccount(account.Id, 'Zuora Account Name');

        List<Zuora__Subscription__c> newSubscriptions = new List<Zuora__Subscription__c> {

            new Zuora__Subscription__c(Name = 'Subscription 1', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 10, CMRR_After_Discount__c = 5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today(), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 1, Zuora__NextRenewalDate__c = Date.today().addDays(4),
                                       CurrencyIsoCode = 'USD'),

            new Zuora__Subscription__c(Name = 'Subscription 2', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 1, CMRR_After_Discount__c = 0.5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today().addDays(5), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 200, Zuora__NextRenewalDate__c = Date.today().addDays(20),
                                       CurrencyIsoCode = 'EUR')
        };

        //Act
        insert newSubscriptions; 

        //Assert
        List<Account> listOfAccounts = [SELECT Id, Type FROM Account WHERE Id = :account.Id]; 
        System.assertEquals('Customer - Enterprise', listOfAccounts[0].Type);
    }

    public static testMethod void TestAccountRollups_Insert(){

        //Arrange
        ExecuteSetting__c exSetting_1 = TestDataFactory.CreateExecuteSetting('Zuora Account Rollups', false, true);
        ExecuteSetting__c exSetting_2 = TestDataFactory.CreateExecuteSetting('Update Account Currency', false, true);
  
        Product2 product = TestDataFactory.CreateProduct2('Product 1',  'Add On Services', 'enterprise_properties', 'SKUNumber1', 'EUR');
        zqu__ZProduct__c zProduct = TestDataFactory.CreateZProduct('Zqu Product 1');
        zqu__ProductRatePlan__c productRatePlan = TestDataFactory.CreateProductRatePlan(product.Id, zProduct.Id, 'Enterprise', 'Test Product');
        
        Account account = TestDataFactory.CreateAccount();
        Zuora__CustomerAccount__c zuoraCustomerAccount = TestDataFactory.CreateZuoraCustomerAccount(account.Id, 'Zuora Account Name');
    
        List<Zuora__Subscription__c> newSubscriptions = new List<Zuora__Subscription__c> {

            new Zuora__Subscription__c(Name = 'Subscription 1', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 10, CMRR_After_Discount__c = 5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today(), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 1, Zuora__NextRenewalDate__c = Date.today().addDays(4),
                                       CurrencyIsoCode = 'USD'),

            new Zuora__Subscription__c(Name = 'Subscription 2', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 1, CMRR_After_Discount__c = 0.5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today().addDays(5), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 200, Zuora__NextRenewalDate__c = Date.today().addDays(20),
                                       CurrencyIsoCode = 'EUR')
        };

        //Act
        insert newSubscriptions;
        
        //Assert
        List<Account> listOfAccounts = [SELECT Id,
                                            Type,
                                            Zuora_Total_CMRR__c, 
                                            Zuora_Current_Contract_Start_Date__c, 
                                            Zuora_Active_Paying_Subscriptions__c, 
                                            Zuora_Cancelled_Subscriptions__c,
                                            Zuora_Subscriptions__c,
                                            Zuora_Total_TCV__c,
                                            Zuora_Next_Annual_Renewal_Date__c,
                                            Zuora_Active_Enterprise_Subscriptions__c,
                                            Zuora_Act_Partnership_Subscriptions__c,
                                            Zuora_Pro_Bono_Subscriptions__c,
                                            Zuora_Act_Enterprise_Trial_Sub__c,
                                            Add_to_Gainsight__c,
                                            Zuora_Customer_Type__c,
                                            Latest_Closed_Date_Expansion_Initial__c,
                                            CurrencyIsoCode
                                        FROM Account WHERE Id = :account.Id];

        System.assertEquals(Date.today(), listOfAccounts[0].Zuora_Current_Contract_Start_Date__c);
        System.assertEquals(5.5, listOfAccounts[0].Zuora_Total_CMRR__c);
        System.assertEquals(2, listOfAccounts[0].Zuora_Active_Paying_Subscriptions__c);
        System.assertEquals(2, listOfAccounts[0].Zuora_Subscriptions__c);
        System.assertEquals(Date.today().addDays(4), listOfAccounts[0].Zuora_Next_Annual_Renewal_Date__c);
        System.assertEquals(2, listOfAccounts[0].Zuora_Active_Enterprise_Subscriptions__c);
        System.assertEquals(0, listOfAccounts[0].Zuora_Act_Partnership_Subscriptions__c);
        System.assertEquals(0, listOfAccounts[0].Zuora_Pro_Bono_Subscriptions__c);
        System.assertEquals(0, listOfAccounts[0].Zuora_Act_Enterprise_Trial_Sub__c); 
        System.assertEquals('Customer - Enterprise', listOfAccounts[0].Type);
        System.assertEquals('USD', listOfAccounts[0].CurrencyIsoCode);        
    }

    public static testMethod void TestAccountRollups_UpdateAccountChange(){

        //Arrange
        ExecuteSetting__c exSetting_1 = TestDataFactory.CreateExecuteSetting('Zuora Account Rollups', false, true);
        ExecuteSetting__c exSetting_2 = TestDataFactory.CreateExecuteSetting('Update Account Currency', false, true);
  
        Product2 product = TestDataFactory.CreateProduct2('Product 1',  'Add On Services', 'enterprise_properties', 'SKUNumber1', 'EUR');
        zqu__ZProduct__c zProduct = TestDataFactory.CreateZProduct('Zqu Product 1');
        zqu__ProductRatePlan__c productRatePlan = TestDataFactory.CreateProductRatePlan(product.Id, zProduct.Id, 'Enterprise', 'Test Product');
        
        Account account = TestDataFactory.CreateAccount();
        Account account2 = TestDataFactory.CreateAccount();

        Zuora__CustomerAccount__c zuoraCustomerAccount = TestDataFactory.CreateZuoraCustomerAccount(account.Id, 'Zuora Account Name');
    
        List<Zuora__Subscription__c> newSubscriptions = new List<Zuora__Subscription__c> {

            new Zuora__Subscription__c(Name = 'Subscription 1', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 10, CMRR_After_Discount__c = 5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today(), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 1, Zuora__NextRenewalDate__c = Date.today().addDays(4),
                                       CurrencyIsoCode = 'USD'),

            new Zuora__Subscription__c(Name = 'Subscription 2', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 1, CMRR_After_Discount__c = 0.5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today().addDays(5), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 200, Zuora__NextRenewalDate__c = Date.today().addDays(20),
                                       CurrencyIsoCode = 'EUR')
        };

        insert newSubscriptions;       

        //Act
        List<Zuora__Subscription__c> listOfzuoraSubsriptions = [SELECT Id, Zuora__Account__c FROM Zuora__Subscription__c WHERE Name = 'Subscription 2'];

        Zuora__Subscription__c zuoraSubsription = listOfzuoraSubsriptions[0];
        zuoraSubsription.Zuora__Account__c = account2.Id;
        update zuoraSubsription;

        //Assert
        List<Account> listOfAccounts = [SELECT Id,
                                                Type,
                                                Zuora_Total_CMRR__c, 
                                                Zuora_Active_Paying_Subscriptions__c, 
                                                Zuora_Subscriptions__c
                                        FROM Account WHERE Id = :account.Id];

        System.assertEquals(5, listOfAccounts[0].Zuora_Total_CMRR__c);
        System.assertEquals(1, listOfAccounts[0].Zuora_Active_Paying_Subscriptions__c);
        System.assertEquals(1, listOfAccounts[0].Zuora_Subscriptions__c);
    }

    public static testMethod void TestAccountRollups_UpdateSubscriptionCancellation(){

        //Arrange
        ExecuteSetting__c exSetting_1 = TestDataFactory.CreateExecuteSetting('Zuora Account Rollups', false, true);
        ExecuteSetting__c exSetting_2 = TestDataFactory.CreateExecuteSetting('Update Account Currency', false, true);
  
        Product2 product = TestDataFactory.CreateProduct2('Product 1',  'Add On Services', 'enterprise_properties', 'SKUNumber1', 'EUR');
        zqu__ZProduct__c zProduct = TestDataFactory.CreateZProduct('Zqu Product 1');
        zqu__ProductRatePlan__c productRatePlan = TestDataFactory.CreateProductRatePlan(product.Id, zProduct.Id, 'Enterprise', 'Test Product');
        
        Account account = TestDataFactory.CreateAccount(); 

        Zuora__CustomerAccount__c zuoraCustomerAccount = TestDataFactory.CreateZuoraCustomerAccount(account.Id, 'Zuora Account Name');
    
        List<Zuora__Subscription__c> newSubscriptions = new List<Zuora__Subscription__c> {

            new Zuora__Subscription__c(Name = 'Subscription 1', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 10, CMRR_After_Discount__c = 5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today(), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 1, Zuora__NextRenewalDate__c = Date.today().addDays(4),
                                       CurrencyIsoCode = 'USD'),

            new Zuora__Subscription__c(Name = 'Subscription 2', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 1, CMRR_After_Discount__c = 0.5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today().addDays(5), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 200, Zuora__NextRenewalDate__c = Date.today().addDays(20),
                                       CurrencyIsoCode = 'EUR')
        };

        insert newSubscriptions;       

        //Act
        List<Zuora__Subscription__c> listOfzuoraSubsriptions = [SELECT Id, Zuora__Account__c FROM Zuora__Subscription__c WHERE Name = 'Subscription 2'];

        Zuora__Subscription__c zuoraSubsription = listOfzuoraSubsriptions[0];
        zuoraSubsription.Zuora__Status__c = 'cancelled';
        update zuoraSubsription;

        //Assert
        List<Account> listOfAccounts = [SELECT Id,
                                                Zuora_Active_Paying_Subscriptions__c, 
                                                Zuora_Cancelled_Subscriptions__c,
                                                Zuora_Subscriptions__c
                                        FROM Account WHERE Id = :account.Id];

        System.assertEquals(1, listOfAccounts[0].Zuora_Active_Paying_Subscriptions__c);
        System.assertEquals(1, listOfAccounts[0].Zuora_Cancelled_Subscriptions__c);
        System.assertEquals(2, listOfAccounts[0].Zuora_Subscriptions__c);
    }

    public static testMethod void TestAccountRollups_DeleteSubscription(){

        //Arrange
        ExecuteSetting__c exSetting_1 = TestDataFactory.CreateExecuteSetting('Zuora Account Rollups', false, true);
        ExecuteSetting__c exSetting_2 = TestDataFactory.CreateExecuteSetting('Update Account Currency', false, true);
  
        Product2 product = TestDataFactory.CreateProduct2('Product 1',  'Add On Services', 'enterprise_properties', 'SKUNumber1', 'EUR');
        zqu__ZProduct__c zProduct = TestDataFactory.CreateZProduct('Zqu Product 1');
        zqu__ProductRatePlan__c productRatePlan = TestDataFactory.CreateProductRatePlan(product.Id, zProduct.Id, 'Enterprise', 'Test Product');
        
        Account account = TestDataFactory.CreateAccount(); 

        Zuora__CustomerAccount__c zuoraCustomerAccount = TestDataFactory.CreateZuoraCustomerAccount(account.Id, 'Zuora Account Name');
    
        List<Zuora__Subscription__c> newSubscriptions = new List<Zuora__Subscription__c> {

            new Zuora__Subscription__c(Name = 'Subscription 1', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 10, CMRR_After_Discount__c = 5, Zuora__Status__c = 'cancelled', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today(), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 1, Zuora__NextRenewalDate__c = Date.today().addDays(4),
                                       CurrencyIsoCode = 'USD'),

            new Zuora__Subscription__c(Name = 'Subscription 2', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 1, CMRR_After_Discount__c = 0.5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today().addDays(5), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 200, Zuora__NextRenewalDate__c = Date.today().addDays(20),
                                       CurrencyIsoCode = 'EUR')
        };

        insert newSubscriptions;       

        //Act
        delete [SELECT Id, Zuora__Account__c FROM Zuora__Subscription__c WHERE Name = 'Subscription 2' LIMIT 1]; 
 
        //Assert
        List<Account> listOfAccounts = [SELECT  Id, 
                                                Zuora_Active_Paying_Subscriptions__c, 
                                                Zuora_Active_Enterprise_Subscriptions__c,
                                                Type
                                        FROM Account WHERE Id = :account.Id];
  
        System.assertEquals(0, listOfAccounts[0].Zuora_Active_Paying_Subscriptions__c);  
        System.assertEquals(0, listOfAccounts[0].Zuora_Active_Enterprise_Subscriptions__c);
        System.assertEquals('Former Customer', listOfAccounts[0].Type); 
    }

    public static testMethod void TestAccountRollups_UndeleteSubscription(){

        //Arrange
        ExecuteSetting__c exSetting_1 = TestDataFactory.CreateExecuteSetting('Zuora Account Rollups', false, true);
        ExecuteSetting__c exSetting_2 = TestDataFactory.CreateExecuteSetting('Update Account Currency', false, true);
  
        Product2 product = TestDataFactory.CreateProduct2('Product 1',  'Add On Services', 'enterprise_properties', 'SKUNumber1', 'EUR');
        zqu__ZProduct__c zProduct = TestDataFactory.CreateZProduct('Zqu Product 1');
        zqu__ProductRatePlan__c productRatePlan = TestDataFactory.CreateProductRatePlan(product.Id, zProduct.Id, 'Enterprise', 'Test Product');
        
        Account account = TestDataFactory.CreateAccount(); 

        Zuora__CustomerAccount__c zuoraCustomerAccount = TestDataFactory.CreateZuoraCustomerAccount(account.Id, 'Zuora Account Name');
    
        List<Zuora__Subscription__c> newSubscriptions = new List<Zuora__Subscription__c> {
            new Zuora__Subscription__c(Name = 'Subscription 1', Zuora__Account__c = account.Id, Primary_Product_Rate_Plan__c = productRatePlan.Id, 
                                       Zuora__MRR__c = 10, CMRR_After_Discount__c = 5, Zuora__Status__c = 'active', Zuora__CustomerAccount__c = zuoraCustomerAccount.Id, 
                                       Zuora__SubscriptionStartDate__c = Date.today(), Zuora__RenewalTerm__c = 'Test', Zuora__TCV__c = 1, Zuora__NextRenewalDate__c = Date.today().addDays(4),
                                       CurrencyIsoCode = 'USD')
        };

        insert newSubscriptions;       

        //Act 
        List<Zuora__Subscription__c> listOfzuoraSubsriptions = [SELECT Id, Zuora__Account__c FROM Zuora__Subscription__c WHERE Name = 'Subscription 1'];
        delete listOfzuoraSubsriptions[0];
        undelete listOfzuoraSubsriptions[0];

        //Assert
        List<Account> listOfAccounts = [SELECT  Id, 
                                                Zuora_Active_Paying_Subscriptions__c, 
                                                Zuora_Active_Enterprise_Subscriptions__c
                                        FROM Account WHERE Id = :account.Id];
  
        System.assertEquals(1, listOfAccounts[0].Zuora_Active_Paying_Subscriptions__c);  
        System.assertEquals(1, listOfAccounts[0].Zuora_Active_Enterprise_Subscriptions__c);       
    }
}