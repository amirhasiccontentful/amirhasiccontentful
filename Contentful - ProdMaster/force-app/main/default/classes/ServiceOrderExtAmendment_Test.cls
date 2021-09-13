@isTest(seeAllData=true)
public class ServiceOrderExtAmendment_Test {
    @isTest static void test_method_one() {
        Test.startTest();
        List<zqu__Quote__c> quotes = [SELECT Id, Payment__c, Additional_Users__c, Additional_Asset_Bandwidth__c, Additional_API_Calls__c FROM zqu__Quote__c LIMIT 1];
        for(zqu__Quote__c quote : quotes) {
            ApexPages.StandardController sc = new ApexPages.StandardController(quote);
            PageReference pageRef = Page.ServiceOrderAmendmentVF;
            Test.setCurrentPage(pageRef);
            ServiceOrderExtAmendment testAccPlan = new ServiceOrderExtAmendment(sc);
            testAccPlan.getQuote();
            testAccPlan.updateQuote();
            testAccPlan.calculateTotalPriceBasedOnPaymentTermForSLA(1.0);
        }
        Test.stopTest();
    }
}