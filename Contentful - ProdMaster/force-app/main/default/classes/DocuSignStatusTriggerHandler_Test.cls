@isTest
public with sharing class DocuSignStatusTriggerHandler_Test {
	@testSetup static void loadTestData() {
		//Load CSV file saved in static resource  
		List<SObject> lstImportSetting = Test.loadData(ImportSetting__c.sObjectType,'testImportSetting');
        List<SObject> lstAcc = Test.loadData(Account.sObjectType,'testAccounts');
        List<sObject> lstOpportunities = Test.loadData(Opportunity.sObjectType, 'testOpportunities');
	}

	@isTest static void TEST_SaveDocuSignDocumentToOpportunity() {
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

		// check number of attachments before
		List<Attachment> existingAtt = [SELECT Id FROM Attachment WHERE ParentId = :opp.Id];
		System.assertEquals(0, existingAtt.size());

		// create docusign status
		dsfs__DocuSign_Status__c docusignstatus = new dsfs__DocuSign_Status__c();
		docusignstatus.dsfs__Opportunity__c = opp.Id;
		insert docusignstatus;

		// add attachment to docusign status
		Attachment newDocusignAtt = new Attachment();
		newDocusignAtt.Name = 'test';
		newDocusignAtt.Body = Blob.valueOf('test');
		newDocusignAtt.ParentId = docusignstatus.Id;
		insert newDocusignAtt;

		// update docusign to complete
		dsfs__DocuSign_Status__c docuSignStatusUpdate = [SELECT dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c LIMIT 1];
		docuSignStatusUpdate.dsfs__Envelope_Status__c = 'Completed';
		update docuSignStatusUpdate;

		// check number of documents on opportunity
		List<Attachment> existingAttAfter = [SELECT Id FROM Attachment WHERE ParentId = :opp.Id];
		System.assertEquals(1, existingAttAfter.size());
	}

}