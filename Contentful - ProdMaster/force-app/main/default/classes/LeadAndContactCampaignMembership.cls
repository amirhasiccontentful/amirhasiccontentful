public class LeadAndContactCampaignMembership {
    
    /*
    public static void campaignMembershipList(List<CampaignMember> members) {

        Set<Id> leadIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        for(CampaignMember cm : [SELECT Id, LeadId, ContactId, Campaign.Name FROM CampaignMember WHERE Id IN :members]){

            if(cm.CampaignId != null){
                if(cm.LeadId != null){
                    leadIds.add(cm.LeadId);
                }

                if(cm.ContactId != null){
                    contactIds.add(cm.ContactId);
                }
            }
        }

        if(!leadIds.isEmpty()){

            List<Lead> leadsForUpdate = new List<Lead>();

            for(Lead l : [SELECT Id, (SELECT Campaign.Name FROM CampaignMembers) FROM Lead WHERE Id IN :leadIds]){

                l.Member_of_Campaign__c = '';

                if(l != null && l.CampaignMembers.size() > 0){

                    for(CampaignMember cm : l.CampaignMembers){
                        l.Member_of_Campaign__c += cm.Campaign.Name + '; ';
                    }

                    l.Member_of_Campaign__c = l.Member_of_Campaign__c.removeEnd('; ');
                }

                leadsForUpdate.add(l);
            }

            if(!leadsForUpdate.isEmpty()) update leadsForUpdate;
        }


        if(!contactIds.isEmpty()){

            List<Contact> contactsForUpdate = new List<Contact>();

            for(Contact c : [SELECT Id, (SELECT Campaign.Name FROM CampaignMembers) FROM Contact WHERE Id IN :contactIds]){

                c.Member_of_Campaign__c = '';

                if(c != null && c.CampaignMembers.size() > 0){

                    for(CampaignMember cm : c.CampaignMembers){
                        c.Member_of_Campaign__c += cm.Campaign.Name + '; ';
                    }

                    c.Member_of_Campaign__c = c.Member_of_Campaign__c.removeEnd('; ');
                }

                contactsForUpdate.add(c);
            }

            if(!contactsForUpdate.isEmpty()) update contactsForUpdate;
        }
        
        
    }
    */
}