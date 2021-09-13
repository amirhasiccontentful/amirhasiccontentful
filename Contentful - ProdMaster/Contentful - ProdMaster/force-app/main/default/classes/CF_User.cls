public with sharing class CF_User {	
	public static void updateOrganizationMemberships(CF_User__c user) {
		for (CF_Organization_Membership__c om : [SELECT Id, gk_user_id__c, gk_organization_id__c, gk_user__c, gk_organization__c FROM CF_Organization_Membership__c WHERE gk_user_id__c = :user.gk_id__c]) {
   			if (om.gk_user__c == null || om.gk_organization__c == null) {
   				CF_Organization_Membership.setRelationshipsFromId(om);
   				update om;	
	   		}
		}			
	}
	
	public static Contact contactFromUser(CF_User__c user) {
		Contact contact = new Contact();
		
       	contact.firstName = user.gk_first_name__c;
       	contact.lastName = user.gk_last_name__c;
       	contact.email = user.gk_email__c;
       	contact.CF_User__c = user.id;
       	
       	return contact;
	}
}