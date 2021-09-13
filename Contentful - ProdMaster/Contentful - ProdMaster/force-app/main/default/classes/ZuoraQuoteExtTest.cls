@isTest(seeAllData=true)
private class ZuoraQuoteExtTest {
	
	@isTest static void test_method_one() {
		Test.startTest();
		List<zqu__Quote__c> quotes = [SELECT Id, Payment__c FROM zqu__Quote__c LIMIT 1];
		//insert obj;x
		for(zqu__Quote__c quote : quotes) {
			ApexPages.StandardController sc = new ApexPages.StandardController(quote);
			ZuoraQuoteExt testAccPlan = new ZuoraQuoteExt(sc);
			testAccPlan.getQuote();
		}
		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}