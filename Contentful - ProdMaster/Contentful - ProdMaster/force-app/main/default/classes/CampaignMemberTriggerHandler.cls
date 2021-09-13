public class CampaignMemberTriggerHandler extends TriggerHandler {

	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/

	public override void afterInsert() {
		campaignMembershipList(Trigger.new);
	}

	public override void afterUpdate() {
		campaignMembershipList(Trigger.new);
	}

	/****************************************************/
	/* HELPER METHODS									*/
	/****************************************************/

	private void campaignMembershipList(List<CampaignMember> newCampaignMembers) {

		Set<Id> leadIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();

		for(CampaignMember cm : newCampaignMembers){

			if(cm.CampaignId != null){

				if(cm.LeadId != null){
					leadIds.add(cm.LeadId);
				}

				if(cm.ContactId != null){
					contactIds.add(cm.ContactId);
				}
			}
		}

		//Add Campaign member details to Lead
		//Add details about MQL being engaged in campaign
		if(leadIds.size() > 0){

			List<Lead> leadsForUpdate = new List<Lead>();  
			Map<Id, List<CampaignMember>> campaignMembersMap = new Map<Id, List<CampaignMember>>();

			List<CampaignMember> listOfDBcampaignMembers = [SELECT LeadId, Campaign.Name, Campaign.Department__c, HasResponded 
													   	    FROM CampaignMember
													   	    WHERE LeadId IN :leadIds]; 

			for(CampaignMember campaignMember : listOfDBcampaignMembers) { 
				if(campaignMembersMap.containsKey(campaignMember.LeadId)) {
					List<CampaignMember> relatedCampaignMembers = campaignMembersMap.get(campaignMember.LeadId);
					relatedCampaignMembers.add(campaignMember);
					campaignMembersMap.put(campaignMember.LeadId, relatedCampaignMembers);
				} else {
					campaignMembersMap.put(campaignMember.LeadId, new List<CampaignMember> { campaignMember });
				} 
			} 

			for(Lead lead : [SELECT Id, Member_of_Campaign__c, MQL_Engaged_in_Campaign__c FROM Lead WHERE Id IN :leadIds]){

				lead.Member_of_Campaign__c = false;
				lead.MQL_Engaged_in_Campaign__c = false;				

				List<CampaignMember> listOfcampaignMembers = campaignMembersMap.get(lead.Id);

				if(listOfcampaignMembers.size() > 0){

					for(CampaignMember cm : listOfcampaignMembers){
						lead.Member_of_Campaign__c = true;

						if(cm.Campaign.Department__c != null && cm.Campaign.Department__c.contains('Partner') && cm.HasResponded){
							lead.MQL_Engaged_in_Campaign__c = true; 
						}
					} 
				}

				leadsForUpdate.add(lead);
			}

			if(leadsForUpdate.size() > 0)
				update leadsForUpdate;
		}

		//Add Campaign member details to Contact
		//Add details about MQL being engaged in campaign
		if(contactIds.size() > 0){

			List<Contact> contactsForUpdate = new List<Contact>();
			Map<Id, List<CampaignMember>> campaignMembersMap = new Map<Id, List<CampaignMember>>();

			List<CampaignMember> listOfDBcampaignMembers = [SELECT ContactId, Campaign.Name, Campaign.Department__c, HasResponded 
													   	    FROM CampaignMember
													   	    WHERE ContactId IN :contactIds]; 

			for(CampaignMember campaignMember : listOfDBcampaignMembers) { 
				if(campaignMembersMap.containsKey(campaignMember.ContactId)) {
					List<CampaignMember> relatedCampaignMembers = campaignMembersMap.get(campaignMember.ContactId);
					relatedCampaignMembers.add(campaignMember);
					campaignMembersMap.put(campaignMember.ContactId, relatedCampaignMembers);
				} else {
					campaignMembersMap.put(campaignMember.ContactId, new List<CampaignMember> { campaignMember });
				} 
			} 

			for(Contact contact : [SELECT Id, Member_of_Campaign__c, MQL_Engaged_in_Campaign__c FROM Contact WHERE Id IN :contactIds]){

				contact.Member_of_Campaign__c = false;
				contact.MQL_Engaged_in_Campaign__c = false;

				List<CampaignMember> listOfcampaignMembers = campaignMembersMap.get(contact.Id);

				if(listOfcampaignMembers.size() > 0){

					for(CampaignMember cm : listOfcampaignMembers){
						contact.Member_of_Campaign__c = true;

						if(cm.Campaign.Department__c != null && cm.Campaign.Department__c.contains('Partner') && cm.HasResponded){
							contact.MQL_Engaged_in_Campaign__c = true;
						}
					} 
				}

				contactsForUpdate.add(contact);
			}

			if(contactsForUpdate.size() > 0)
				update contactsForUpdate;
		}	
	}
}