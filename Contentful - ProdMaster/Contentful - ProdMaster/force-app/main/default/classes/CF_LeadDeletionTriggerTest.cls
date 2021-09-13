@isTest
private class CF_LeadDeletionTriggerTest {

    static testMethod void test() {
		// create a Lead
		//Id RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('App').getRecordTypeId();
		
		//Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry',Email='email@test.de',LeadSource='App - Invited');
		Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry',Email='email@test.de',LeadSource = 'Web App', Lead_Source_Detail__c = 'App - Invited');
		
		insert lead;                
		
		try {
			delete lead;
		} 
		catch(Exception e) {

    	}
    }
}