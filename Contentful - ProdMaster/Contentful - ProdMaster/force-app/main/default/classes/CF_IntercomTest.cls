@isTest
private class CF_IntercomTest {

    static testMethod void myUnitTest() {
    	Lead lead = new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry',Email='email@test.de',LeadSource='Other', Referrer_Commission__c=0);
		CF_Intercom.leadToString(lead);
    }
}