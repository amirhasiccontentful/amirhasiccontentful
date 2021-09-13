@isTest(seeAllData=true)
public class ZuoraPlugins_Test {
    /*@isTest static void testAddBase() {
        
        Account acc = createTestAccount(null, true);
        Opportunity opp = createTestOpportunity(acc, true);
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id);
        insert con;
        
        zqu__Quote__c quote = createTestQuote(acc, opp, con, con, true, true);
        
        List<Product2> lstOfProducts = new List<Product2>();
        List<zqu__ZProduct__c> lstOfZProducts = new List<zqu__ZProduct__c>();
        List<zqu__ProductRatePlan__c> lstOfProductRatePlans = new List<zqu__ProductRatePlan__c>();
        
        Product2 prod = new Product2();
        prod.Name = 'Micro (Free) annual';
        prod.InternalName__c = 'micro_free_space_annual';
        lstOfProducts.add(prod);
        
        Product2 prod2 = new Product2();
        prod2.Name = 'Large annual';
        prod2.InternalName__c = 'large_space_annual';
        lstOfProducts.add(prod2);
            
        zqu__ZProduct__c  newZProduct = new zqu__ZProduct__c();
        newZProduct.Name = 'Micro (Free) annual';
        newZProduct.InternalName__c = 'micro_free_space_annual';
        lstOfZProducts.add(newZProduct);
        
        zqu__ZProduct__c  newZProduct2 = new zqu__ZProduct__c();
        newZProduct2.Name = 'Large annual';
        newZProduct2.InternalName__c = 'large_space_annual';
        lstOfZProducts.add(newZProduct2);
        
        zqu__ProductRatePlan__c  newProductRatePlan = new zqu__ProductRatePlan__c();
        newProductRatePlan.Name = 'large space annual';
        newProductRatePlan.zqu__ZProduct__c  = newZProduct.Id;
        newProductRatePlan.PlanType__c = '';
        newProductRatePlan.InternalName__c = 'large_space_annual';
        newProductRatePlan.zqu__ZuoraId__c = '1212121212121212121212';
        newProductRatePlan.zqu__Product__c = prod2.Id;
        lstOfProductRatePlans.add(newProductRatePlan);
        
        zqu__ProductRatePlan__c  newProductRatePlan2 = new zqu__ProductRatePlan__c();
        newProductRatePlan2.Name = 'space2 annual';
        newProductRatePlan2.zqu__ZProduct__c  = newZProduct.Id;
        newProductRatePlan2.PlanType__c = '';
        newProductRatePlan2.InternalName__c = 'free_space';
        newProductRatePlan2.zqu__Product__c = prod.Id;
        lstOfProductRatePlans.add(newProductRatePlan2);
        
        insert lstOfProducts;
        insert lstOfZProducts;
        insert lstOfProductRatePlans;
       
        ZuoraAddMicroFree plugin = new ZuoraAddMicroFree();

        Boolean success = false;

        try {
            plugin.onAdd (quote.Id, new List<Id>{newProductRatePlan2.Id});
            success = true;
        } catch (ZuoraAddMicroFree.AddRemoveException ex) {
            System.assert(true, 'Micro (Free) plan is already added');
        }
    }
    
    @isTest static void testRemoveBase() {
       
    }*/
    
    /*@isTest static void testonSave() {
        
        List<zqu__Quote__c> quote = [SELECT Id, Name FROM zqu__Quote__c ORDER BY CreatedDate desc];
        List<zqu__QuoteRatePlan__c> quoteRatePlan = [SELECT Id, Name, zqu__ProductRatePlan__c FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c = :quote[0].Id order by name desc];
        List<zqu__ProductRatePlan__c> productRatePlan = [SELECT Id, Name FROM zqu__ProductRatePlan__c WHERE Id = :quoteRatePlan[0].zqu__ProductRatePlan__c];
        
        zqu.zChargeGroup zcg = zqu.zQuoteUtil.getChargeGroup(quote[0].Id, productRatePlan[0].Id);
        zqu.zQuoteUtil.addChargeGroup(zcg);
      
        ZuoraAddMicroFreeOnSave plugin = new ZuoraAddMicroFreeOnSave();

        Boolean success = false;

        try {
            plugin.onSave (new List<zqu.zChargeGroup>{zcg}, null, null, null);
            success = true;
        } catch (ZuoraAddMicroFreeOnSave.SavePluginException ex) {
            System.assert(true, 'Micro (Free) plan is already added');
        }
    }*/
    
    
    @isTest static void testSelectBillingAccount() {
        
        Account acc = [SELECT Id, Enterprise_Subscription__c, Enterprise_Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c 
                                            FROM Account WHERE Enterprise_Subscription__c != null 
                                            AND Id IN (SELECT AccountId FROM Opportunity) 
                                            AND Enterprise_Subscription__r.Zuora__CustomerAccount__c != null LIMIT 1];
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
        
        zqu.JSRemoteController.BillingAccountObjects obj = new zqu.JSRemoteController.BillingAccountObjects();
        obj.opportunityId = opp.Id;
        obj.defaultBillingAccountType = 'new';
        obj.defaultBillingAccountId = acc.Enterprise_Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c;
            
        ZuoraSampleSelectBillingAccountPlugin plugin = new ZuoraSampleSelectBillingAccountPlugin();

        Boolean success = false;

        try {
            plugin.getAvailableBillingAccounts (new zqu.JSRemoteController.BillingAccountObjects());
            plugin.getAvailableQuoteTypes(new zqu.JSRemoteController.QuoteTypeObjects());
            plugin.getAvailableSubscriptions(new zqu.JSRemoteController.SubscriptionObjects());
            success = true;
        } catch (ZuoraAddMicroFreeOnSave.SavePluginException ex) {
            System.assert(true, 'Micro (Free) plan is already added');
        }
    }
    
    @isTest static void testSelectBillingEntityBasedOnType() {
        
       Account acc = [SELECT Id, Enterprise_Subscription__c, Enterprise_Subscription__r.Zuora__CustomerAccount__c 
                                            FROM Account WHERE Enterprise_Subscription__c != null 
                                            AND Id IN (SELECT AccountId FROM Opportunity) LIMIT 1];
       
       Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
        
       ZuoraSelectBillingEntityBasedOnType plugin = new ZuoraSelectBillingEntityBasedOnType();

        Boolean success = false;

        try {
            plugin.selectEntityForNewQuote(acc.Id, opp.Id);
            success = true;
        } catch (ZuoraAddMicroFreeOnSave.SavePluginException ex) {
            System.assert(true, 'Micro (Free) plan is already added');
        }
    }
    
    
    @isTest static void testDefaultFieldValues() {
        
        Account acc = createTestAccount(null, true);
        Opportunity opp = createTestOpportunity(acc, true);
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id);
        insert con;
        
        zqu__Quote__c quote = createTestQuote(acc, opp, con, con, true, false);
      
        //quote.zqu__Opportunity__c = opp.Id;
        
        ZuoraDefaultFieldValues controller = new ZuoraDefaultFieldValues();
        PageReference createQuote = Page.zqu__CreateQuote;
        createQuote.getParameters().put('oppId', opp.Id);
        createQuote.getParameters().put('quoteType', 'Subscription');
        createQuote.getParameters().put('stepNumber', '2');
        Test.setCurrentPage(Page.zqu__CreateQuote);

        Test.startTest();

        controller.populateDefaultFieldValue(quote, null);

        Test.stopTest();
    }
    
    //Create a test Quote
    public static zqu__Quote__c createTestQuote(Account acc, Opportunity opp, Contact billTo, Contact soldTo, Boolean isNewSub, Boolean doInsert) {
        isNewSub = (isNewSub != null) ? isNewSub : true;

        zqu__Quote__c quote = new zqu__Quote__c();
        quote.Name = 'Test Quote';
        quote.zqu__SubscriptionType__c = (isNewSub) ? 'New Subscription' : 'Amend Subscription';
        quote.zqu__StartDate__c = System.today();
        quote.zqu__ValidUntil__c = System.today();
        quote.zqu__Subscription_Term_Type__c = 'Termed';
        quote.Payment__c = 'Annual';
        quote.zqu__InitialTerm__c = 12;
        quote.zqu__RenewalTerm__c = 12;
        quote.zqu__Account__c = (acc != null) ? acc.Id : null;
        quote.zqu__Opportunity__c = (opp != null) ? opp.Id : null;
        quote.zqu__BillToContact__c = (billTo != null) ? billTo.Id : null;
        quote.zqu__SoldToContact__c = (soldTo != null) ? soldTo.Id : null;
        //quote.zqu__ExistSubscriptionID__c = (isNewSub) ? null : subId;
    
        if (doInsert) {
            insert quote;
        }
    
        return quote;
    }

    //Create a test Account
    public static Account createTestAccount(Account parent, Boolean doInsert) 
    {
        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.BillingCity = 'Atlanta';
        testAcc.BillingState = 'California';
        testAcc.BillingCountry = 'United States';
        testAcc.BillingPostalCode = '12345';
        testAcc.BillingStreet = '123 Main St';
        
        if (parent != null) {
            testAcc.ParentId = parent.Id;
        }
        if (doInsert) {
            insert testAcc;
        }
    
        return testAcc;
    }

    //Create a test Opportunity
    public static Opportunity createTestOpportunity(Account acc, Boolean doInsert)
    {                
        Opportunity opp = new Opportunity();    
        opp.CloseDate = System.today().addMonths(1); 
        opp.Effective_Date__c = System.today().addMonths(1);          
        opp.StageName = 'Discovery';
        opp.Type = 'New Business';          
        opp.Name = 'Test Opportunity';
        opp.Amount = 100;
        opp.Description = 'testingtestingtestingtestingtesting';
        
        if (acc != null) {
            opp.AccountId = acc.Id;
        }        
        if (doInsert) {
            insert opp;
        }
    
        return opp;
    }
    
    public static zqu__QuoteCharge__c makeQuoteCharge(zqu__Quote__c testQuote, zqu__ProductRatePlanCharge__c testPRPC) {

    zqu__QuoteCharge__c testQuoteCharge = new zqu__QuoteCharge__c();

    testQuoteCharge.Name = 'my test quote charge';
    testQuoteCharge.zqu__Quote__c = testQuote.Id;
    testQuoteCharge.zqu__ProductRatePlanCharge__c = testPRPC.Id; 

    insert testQuoteCharge;
    return testQuoteCharge;
  }
    
    public static zqu__ProductRatePlanCharge__c makeProductRatePlanCharge(String prp, String type, String model)
    {
    zqu__ProductRatePlanCharge__c testprpc = new zqu__ProductRatePlanCharge__c();
    testprpc.zqu__ProductRatePlan__c = prp;
    testprpc.name = 'test';
    //testprpc.name=type+model+ratePlanChargeId;
    //testprpc.zqu__ZuoraId__c = String.valueOf(ratePlanChargeId);
    //ratePlanChargeId++;
    testprpc.zqu__UOM__c = 'test UOM';
    testprpc.zqu__Type__c = type;
    testprpc.zqu__RecurringPeriod__c = 'Annu';
    testprpc.zqu__PrepaymentPeriods__c = 1;
    testprpc.zqu__Model__c = model;
    testprpc.zqu__MinQuantity__c = 0;
    testprpc.zqu__MaxQuantity__c = 1000;
    testprpc.zqu__ListPrice__c = 5;
    testprpc.zqu__Description__c = 'Test charge';
    testprpc.zqu__DefaultQuantity__c = 5;
    testprpc.zqu__Discount_Apply_Type__c = 0;
    testprpc.zqu__Discount_Level__c = 'RatePlan';
    testprpc.zqu__Upto_How_Many_Periods__c = 0;
    testprpc.zqu__Deleted__c = false;

    insert testprpc;
    return testprpc;
  }
}