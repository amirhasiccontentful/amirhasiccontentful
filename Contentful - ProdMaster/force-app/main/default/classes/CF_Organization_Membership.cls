public with sharing class CF_Organization_Membership {
	public static void setUserFromId(CF_Organization_Membership__c om) {
		try {
			if (om.gk_user__c == null) {
				Id id = [SELECT Id FROM CF_User__c WHERE gk_id__c=:om.gk_user_id__c].Id;
			  	om.gk_user__c = id;				
			}
	   	} 
	   	catch(QueryException e) {
       		System.debug('Failed finding user for CF_Organization_Membership: ' + om.gk_user_id__c + ', ' + om.id);
       	}
	}
	
	public static void setOrganizationFromId(CF_Organization_Membership__c om) {
		try {
			if (om.gk_organization__c == null) {
				Id id = [SELECT Id FROM CF_Organization__c WHERE gk_id__c=:om.gk_organization_id__c].Id;
				om.gk_organization__c = id;				
			}
		}
	   	catch(QueryException e) {
       		System.debug('Failed finding organization for CF_Organization_Membership: ' + om.gk_organization_id__c + ', ' + om.id);
       	}			
	}
	
	public static void setRelationshipsFromId(CF_Organization_Membership__c om) {
		setUserFromId(om);
		setOrganizationFromId(om);
	}	
	
	public static void updateName(CF_Organization_Membership__c om) {  
		CF_Organization__c org = null; 
		CF_User__c user = null;
		String name = '';
		
		try {
			org = [SELECT Name FROM CF_Organization__c WHERE gk_id__c = :om.gk_organization_id__c];
			if (org != null && org.Name != null) {
				name = name + org.Name;	
			}
		}
		catch(Exception e) {
			System.debug('Could not find organization for Organization Membership: ' + om.id);
		}

		try {
			user = [SELECT Name FROM CF_User__c WHERE gk_id__c = :om.gk_user_id__c];
			if (user != null && user.Name != null) {
				name = name + ' / ' + user.Name;	
			}
		}
		catch(Exception e) {
			System.debug('Could not find user for Organization Membership: ' + om.id);
		}
		
		if (om != null && om.gk_role__c != null) {
			name = name + ' (' + om.gk_role__c + ')';
		}
		
		if (name.length() == 0) {
			name = 'Unkown';
		}
		
		if (name.length() > 70) { // threw errors otherwise
			name = name.substring(0, 70) + '...';
		}
		
		om.Name = name;
	}		

}