@isTest
private class CF_LeadConvertTriggerTest {

    static testMethod void test() {
		Contact c = new Contact();
		c.firstname = 'firstname';
		c.lastname = 'lastname';
		c.email = 'test@asdf.com';
		
		insert c;
		
		// create a Lead
		//Id RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('General').getRecordTypeId();
		String description = 'This is a description. This is a description. This is a description. This is a description. This is a description. This is a description. This is a description. ';
		
		Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry',Email='email@test.de',Country = 'Germany',LeadSource='Other',Project_Description__c=description, HQ_Country__c = 'Germany', Referrer_Commission__c=0);
		
		insert lead;                
		
		Database.LeadConvert lc = new database.LeadConvert();
		lc.setLeadId(lead.id);
		lc.setDoNotCreateOpportunity(false);
		// Converted Status Change
		lc.setConvertedStatus('Converted');
		
		Database.LeadConvertResult lcr = Database.convertLead(lc);
		System.assert(lcr.isSuccess());        
    }
}