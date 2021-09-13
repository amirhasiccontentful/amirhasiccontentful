global class GainsightLeadUsageRollups_Batchable  implements Database.Batchable<sObject> {

  global final String query;
    
  global GainsightLeadUsageRollups_Batchable() {
      query = 'SELECT Id FROM CF_Organization__c WHERE LastModifiedDate = TODAY AND ID IN (SELECT CF_Organization__c FROM Lead)';
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext BC, List<CF_Organization__c> scope) {
      
      if(scope.isEmpty()) return;
	  
      Set<Id> scopedLeadIds = new Set<Id>();

      for(Lead ld : [SELECT Id FROM Lead WHERE CF_Organization__c IN :scope]){
          if(ld != null){
              scopedLeadIds.add(ld.Id);
          }
      }
      
      if(!scopedLeadIds.isEmpty()){
          LeadCFOrganizationRollups.calculateWeeklyRollups(scopedLeadIds);
      }
    }
    
  global void finish(Database.BatchableContext BC) {
    
  }
}