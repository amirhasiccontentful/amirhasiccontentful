@isTest
public class RelaculateZuoraAccountRollups_Test {
    
    public static testMethod void test_zuoraAccountRollups(){
        
        zqu__ZProduct__c  newZProduct = new zqu__ZProduct__c();
        newZProduct.Name = 'Test';
        insert newZProduct;
        
        zqu__ProductRatePlan__c  newProductRatePlan = new zqu__ProductRatePlan__c ();
        newProductRatePlan.Name = 'TEST';
        newProductRatePlan.zqu__ZProduct__c  = newZProduct.Id;
        newProductRatePlan.PlanType__c = 'Enterprise';
        insert newProductRatePlan;
        
        Account newAccount = new Account();
        newAccount.Name = 'TEST';
        insert newAccount;

        Zuora__CustomerAccount__c newZuoraCustomerAccount = new Zuora__CustomerAccount__c();
        newZuoraCustomerAccount.Name = 'Test';
        newZuoraCustomerAccount.Zuora__Account__c = newAccount.Id;
        insert newZuoraCustomerAccount;

        List<Zuora__Subscription__c> newSubscriptions = new List<Zuora__Subscription__c>();
        
        Zuora__Subscription__c newZuoraSubsription = new Zuora__Subscription__c ();
        newZuoraSubsription.Name = 'TEST';
        newZuoraSubsription.Zuora__Account__c = newAccount.Id;
        newZuoraSubsription.Primary_Product_Rate_Plan__c = newProductRatePlan.Id;
        newZuoraSubsription.Zuora__MRR__c = 10;
        newZuoraSubsription.CMRR_After_Discount__c = 5;
        newZuoraSubsription.Zuora__Status__c = 'active';
        newZuoraSubsription.Zuora__CustomerAccount__c = newZuoraCustomerAccount.Id;
        newZuoraSubsription.Zuora__SubscriptionStartDate__c = system.today();
        newZuoraSubsription.Zuora__RenewalTerm__c = 'test';
        newZuoraSubsription.Zuora__TCV__c = 1;
        newZuoraSubsription.Zuora__NextRenewalDate__c = system.today() + 4;
        newSubscriptions.add(newZuoraSubsription);

        Zuora__Subscription__c newZuoraSubsription2 = new Zuora__Subscription__c ();
        newZuoraSubsription2.Name = 'TEST 2';
        newZuoraSubsription2.Zuora__Account__c = newAccount.Id;
        newZuoraSubsription2.Primary_Product_Rate_Plan__c = newProductRatePlan.Id;
        newZuoraSubsription2.Zuora__MRR__c = 1;
        newZuoraSubsription2.CMRR_After_Discount__c = 0.5;
        newZuoraSubsription2.Zuora__Status__c = 'active';
        newZuoraSubsription2.Zuora__CustomerAccount__c = newZuoraCustomerAccount.Id;
        newZuoraSubsription2.Zuora__SubscriptionStartDate__c = system.today() + 5;
        newZuoraSubsription2.Zuora__RenewalTerm__c = 'test';
        newZuoraSubsription2.Zuora__NextRenewalDate__c = system.today() + 20;
        newZuoraSubsription2.Zuora__TCV__c = 200;
        newSubscriptions.add(newZuoraSubsription2);

        Zuora__Subscription__c newZuoraSubsription3 = new Zuora__Subscription__c ();
        newZuoraSubsription3.Name = 'TEST 3';
        newZuoraSubsription3.Zuora__Account__c = newAccount.Id;
        newZuoraSubsription3.Primary_Product_Rate_Plan__c = newProductRatePlan.Id;
        newZuoraSubsription3.Zuora__MRR__c = 1;
        newZuoraSubsription3.CMRR_After_Discount__c = 0.5;
        newZuoraSubsription3.Zuora__Status__c = 'cancelled';
        newZuoraSubsription3.Zuora__CustomerAccount__c = newZuoraCustomerAccount.Id;
        newZuoraSubsription3.Zuora__SubscriptionStartDate__c = system.today();
        newZuoraSubsription3.Zuora__RenewalTerm__c = 'test';
        newZuoraSubsription3.Zuora__TCV__c = 4;
        newSubscriptions.add(newZuoraSubsription3);

        insert newSubscriptions;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newAccount);
        RecalculateZuoraAccountRollups testAccZuoraRollup = new RecalculateZuoraAccountRollups(sc);
        
        PageReference pageRef = Page.RecalculateZuoraAccountRollups;
        pageRef.getParameters().put('id', String.valueOf(newAccount.Id));
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        testAccZuoraRollup.zuoraAccountRollups();
        Test.stopTest();
        
        List<Account> checkAccount1 = [SELECT Id, 
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
                                            Add_to_Gainsight__c
                                        FROM Account WHERE Id = :newAccount.Id];

        /*System.assertEquals(system.today(), checkAccount1[0].Zuora_Current_Contract_Start_Date__c);
        System.assertEquals(5.5, checkAccount1[0].Zuora_Total_CMRR__c);
        System.assertEquals(2, checkAccount1[0].Zuora_Active_Paying_Subscriptions__c);
        System.assertEquals(1, checkAccount1[0].Zuora_Cancelled_Subscriptions__c);
        System.assertEquals(3, checkAccount1[0].Zuora_Subscriptions__c);
        System.assertEquals(system.today() + 4, checkAccount1[0].Zuora_Next_Annual_Renewal_Date__c);
        System.assertEquals(2, checkAccount1[0].Zuora_Active_Enterprise_Subscriptions__c);
        System.assertEquals(0, checkAccount1[0].Zuora_Act_Partnership_Subscriptions__c);
        System.assertEquals(0, checkAccount1[0].Zuora_Pro_Bono_Subscriptions__c);
        System.assertEquals(0, checkAccount1[0].Zuora_Act_Enterprise_Trial_Sub__c);
        System.assertEquals(true, checkAccount1[0].Add_to_Gainsight__c);
        */
        
    }
}