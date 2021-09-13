@isTest(seeAllData=true)
private class ServiceOrderExtTest {
	
	@isTest static void test_method_one() {
		Test.startTest();
		List<zqu__Quote__c> quotes = [SELECT Id, Payment__c, Additional_Users__c, zqu__BillToContact__c, zqu__BillToContact__r.MailingStreet, zqu__SoldToContact__c, Additional_Asset_Bandwidth__c, Additional_API_Calls__c FROM zqu__Quote__c order by CreatedDate desc LIMIT 1];
		//insert obj;x
		for(zqu__Quote__c quote : quotes) {
			ApexPages.StandardController sc = new ApexPages.StandardController(quote);
			ServiceOrderExt testAccPlan = new ServiceOrderExt(sc);
			testAccPlan.getQuote();
            //testAccPlan.saveAttachment();
            testAccPlan.updateQuote();
            testAccPlan.calculateTotalPriceBasedOnPaymentTermForSLA(1.0);
		}
		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}