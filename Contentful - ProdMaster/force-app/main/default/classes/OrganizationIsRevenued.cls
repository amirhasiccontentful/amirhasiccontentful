public class OrganizationIsRevenued {
	
    public void setOfRevenuedOrgKeys(Set<String> revenuedOrgKeys){
        
        List<CF_Organization__c> cfOrgsForUpdate = new List<CF_Organization__c>();
        
        for(CF_Organization__c cfOrg : [SELECT Id, gk_key__c, gk_revenued_at__c, mrr_0__c
                                        FROM CF_Organization__c 
                                        WHERE gk_key__c IN :revenuedOrgKeys AND mrr_0__c = false]){
                     
      		cfOrg.mrr_0__c = true;
            cfOrgsForUpdate.add(cfOrg);
      	}
        
        if(!cfOrgsForUpdate.isEmpty()) update cfOrgsForUpdate;
    }
}