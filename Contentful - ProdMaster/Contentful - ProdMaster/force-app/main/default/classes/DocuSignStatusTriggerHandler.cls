public class DocuSignStatusTriggerHandler extends TriggerHandler { 
	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/

	public override void beforeUpdate() {

	}

	public override void beforeInsert() {
	}

	public override void afterUpdate() {
		SaveDocumentToOpportunity(trigger.new, (Map<Id, dsfs__DocuSign_Status__c>) trigger.oldMap);
	}

	public override void afterInsert() {
	}
	/****************************************************/
	/* HELPER FUNCTIONS									*/
	/****************************************************/

	// Name: SaveDocumentToOpportunity
	// Description: Once document is signed by all parties it should be stored to Opportunity
	private void SaveDocumentToOpportunity(List<dsfs__DocuSign_Status__c> docuSignStatuses, Map<Id, dsfs__DocuSign_Status__c> oldDocuSignStatuses) {
		List<Attachment> insertOppAttachments = new List<Attachment>();

		for(dsfs__DocuSign_Status__c docuSignStatus : docuSignStatuses) {
			dsfs__DocuSign_Status__c oldDocuSignStatus = oldDocuSignStatuses.get(docuSignStatus.Id);
			if(docuSignStatus.dsfs__Envelope_Status__c == 'Completed' && oldDocuSignStatus.dsfs__Envelope_Status__c != 'Completed') {
				for(Attachment docuSignStatusAttachment : [SELECT ParentId, Name, IsPrivate, ContentType, BodyLength, Body, OwnerId, Description FROM Attachment WHERE ParentId = :docuSignStatus.Id]) {
					if( docuSignStatus.dsfs__Opportunity__c != null ) {
						Attachment att = new Attachment();
						att.ParentId = docuSignStatus.dsfs__Opportunity__c;
						att.Name = docuSignStatusAttachment.Name;
						att.IsPrivate = docuSignStatusAttachment.IsPrivate;
						att.ContentType = docuSignStatusAttachment.ContentType;
						att.Body = docuSignStatusAttachment.Body;
						att.OwnerId = docuSignStatusAttachment.OwnerId;
						att.Description = docuSignStatusAttachment.Description;
						insertOppAttachments.add(att);
					}
				}
 			}
		}
		if(!insertOppAttachments.isEmpty()) {
			insert insertOppAttachments;
		}
	}
}