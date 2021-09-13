@isTest
public class ServiceOrderExtApril2020Test {
    static testMethod void getQuote_updateQuote() {
        // Arrange
        // Load test data from static resources
        TestDataFactory.LoadTestData();    
        List<zqu__Quote__c> lstQuote_Test = TestDataFactory.GetQuotes(); 
        
        //Act
        //
        Test.startTest();
        
        ApexPages.StandardController standardTestController = new ApexPages.StandardController(lstQuote_Test[0]);
        ServiceOrderExt_April2020 serviceOrderExtTestInstance = new ServiceOrderExt_April2020(standardTestController);
        serviceOrderExtTestInstance.getQuote();
        serviceOrderExtTestInstance.getAggregatedCharges();
        serviceOrderExtTestInstance.paymentBasedOnSelectedBasePlan('Test'); 
        serviceOrderExtTestInstance.updateQuote();
        
        
        Test.stopTest();
        
        //Pull data from Salesforce
        //
        zqu__Quote__c updatedQuote_1 = TestDataFactory.GetQuoteById(lstQuote_Test[0].Id);
        List<zqu__QuoteRatePLanCharge__c> discount = TestDataFactory.GetDiscountQuoteRatePlanChargesByQuoteId(updatedQuote_1.Id);   
        List<zqu__QuoteRatePlanCharge__c> quoteRatePlans = TestDataFactory.GetQuoteRatePLanChargesByQuoteId(updatedQuote_1.Id);         
        //zqu__QuoteCharge_Tier__c assetBandwidthQuoteChargeTier = TestDataFactory.GetQuoteChargeTierByInternalName('asset_bandwidth', updatedQuote_1.Id); 
		
        
        
        // Assert
        //
        System.assertEquals('2', updatedQuote_1.Bill_Cycle_Month__c, 'Start date is 2/18/2019, Bill Cycle Month expected to be 2');
        System.assertEquals('18', updatedQuote_1.zqu__BillCycleDay__c, 'Start date is 2/18/2019, Bill Cycle Day expected to be 18');
        System.assertEquals(updatedQuote_1.Bill_Cycle_Month__c, updatedQuote_1.zqu__Account__r.Bill_Cycle_Month__c);
        System.assertEquals(updatedQuote_1.zqu__Account__r.Debitor_Number__c, updatedQuote_1.Debitor_Number__c);
        System.assertEquals('gmbh', updatedQuote_1.zqu__Account__r.Billing_Entity__c);
        System.assertEquals(0, quoteRatePlans[0].zqu__Quantity__c, 'Expecting that value of Additional API Calls from Quote is assigned to Quanity field of Quote Rate Plan with internal name additional_api_calls');
        System.assertEquals(0, quoteRatePlans[1].zqu__Quantity__c, 'Expecting that value of Additional Users from Quote is assigned to Quanity field of Quote Rate Plan with internal name additional_users');
        System.assertEquals(1.00000, quoteRatePlans[2].zqu__Quantity__c, 'Expecting that value of Additional Asset Bandwith from Quote is assigned to Quanity field of Quote Rate Plan with internal name additional_bandwidth');
        //System.assertEquals(750, assetBandwidthQuoteChargeTier.zqu__EndingUnit__c);
    }
    
    static testMethod void getQuote_updateQuote_2() {
        // Arrange
        // Load test data from static resources
        TestDataFactory.LoadTestData();     
        List<zqu__Quote__c> lstQuote_Test = TestDataFactory.GetQuotes(); 
        // Act
        // 
        Test.startTest();
        
        ApexPages.StandardController standardTestController = new ApexPages.StandardController(lstQuote_Test[1]);
        ServiceOrderExt_April2020 serviceOrderExtTestInstance = new ServiceOrderExt_April2020(standardTestController);
        serviceOrderExtTestInstance.getQuote();
        serviceOrderExtTestInstance.updateQuote();
        Test.stopTest();
        
        // Assert
        // 
        System.assertEquals(2, lstQuote_Test.size());
    }
}