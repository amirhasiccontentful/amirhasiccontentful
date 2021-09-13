global class CF_Organization_MembershipBatchable implements Database.Batchable<sObject> {
	global final String query; 
	
	
   	global CF_Organization_MembershipBatchable() {
    	query = 'SELECT Id, gk_user_id__c, gk_organization_id__c, gk_user__c, gk_organization__c FROM CF_Organization_Membership__c WHERE gk_user__c = null OR gk_organization__c = null';
    	
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	   List<CF_Organization_Membership__c> organizationMemberships = new List<CF_Organization_Membership__c>();
       Set<Integer> allOrgIds  = new Set<Integer>();
  	   Set<Integer> allUserIds = new Set<Integer>();
      
       for(sObject s : scope) {
       		CF_Organization_Membership__c om = (CF_Organization_Membership__c)s;
       		allOrgIds.add(om.gk_organization_id__c.intvalue());    
      		allUserIds.add(om.gk_user_id__c.intvalue());    
      		organizationMemberships.add(om);
       }      
      
  	  List<CF_Organization__c> potentialOrganizations = [SELECT Name, gk_id__c FROM CF_Organization__c WHERE gk_id__c IN :allOrgIds];
	  List<CF_User__c> potentialUsers = [SELECT Name, gk_id__c FROM CF_User__c WHERE gk_id__c = :allUserIds];
	
  
  	  Map<Decimal, CF_Organization__c> idToOrgMap = new Map<Decimal, CF_Organization__c>();
  	  for (CF_Organization__c u : potentialOrganizations) {
    	idToOrgMap.put(u.gk_id__c.intvalue(), u); 
	  }
	
  	  Map<Integer, CF_User__c> idToUserMap = new Map<Integer, CF_User__c>();
  	  for (CF_User__c u : potentialUsers) {
    	idToUserMap.put(u.gk_id__c.intvalue(), u);
	  }	  	  
      
      for (CF_Organization_Membership__c om : organizationMemberships) {
  		CF_User__c user = idToUserMap.get(om.gk_user_id__c.intvalue());
  		CF_Organization__c org = idToOrgMap.get(om.gk_organization_id__c.intvalue());
  		
  		if (user != null) {
  			om.gk_user__c = user.id;	
  		}
  		else {
  			System.debug('No user found for: ' + om.gk_user_id__c);
  		}
  		
  		if (org != null) {
  			om.gk_organization__c = org.id;	
  		}
  		else {
  			System.debug('No org found for: ' + om.gk_organization_id__c);
  		}
  		
  		
      }
      
      update organizationMemberships;
	}	
	
	global void finish(Database.BatchableContext BC) {
    	AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];

	}	
}