global class AddToGainsight_Batchable implements Database.Batchable<sObject> {

  global final String query;
  global Date scopedDate;

  global AddToGainsight_Batchable() {
      scopedDate = System.today() - 7;
      query = 'SELECT Id, Add_To_Gainsight__c, Zuora_Customer_Type__c, Latest_Closed_Date_Expansion_Initial__c FROM Account WHERE Add_To_Gainsight__c = TRUE OR (Zuora_Customer_Type__c = \'Enterprise\' OR Latest_Closed_Date_Expansion_Initial__c >= :scopedDate)';
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext BC, List<Account> scope) {
      
      if(scope.isEmpty()) return;

      List<Account> accountsForUpdate = new List<Account>();

      for(Account acc : scope){
        acc.Add_To_Gainsight__c = FALSE;

        if(acc.Zuora_Customer_Type__c == 'Enterprise' || acc.Latest_Closed_Date_Expansion_Initial__c >= scopedDate){
           acc.Add_To_Gainsight__c = true;
        }

        accountsForUpdate.add(acc);
      }

      if(!accountsForUpdate.isEmpty()) update accountsForUpdate;
  }
    
  global void finish(Database.BatchableContext BC) {
    
  }
}