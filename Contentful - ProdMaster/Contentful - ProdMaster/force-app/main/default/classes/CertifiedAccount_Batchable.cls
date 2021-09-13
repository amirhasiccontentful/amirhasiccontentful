global class CertifiedAccount_Batchable implements Database.Batchable<sObject> {

  global final String query;
  global Date scopedDate;
  public List<Account> certifiedAccounts;
  
  global CertifiedAccount_Batchable() {
      certifiedAccounts = new List<Account>([SELECT Id, Certified__c FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Certified__c = true)]);
      query = 'SELECT Id, Certified__c FROM Account WHERE Certified__c = true OR Id IN :certifiedAccounts';
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext BC, List<Account> scope) {
      
      if(scope.isEmpty()) return;

      List<Account> resetTheCertifiedFieldValue = new List<Account>();

      for(Account acc : scope){
          if(acc.Certified__c == true){
            acc.Certified__c = FALSE;
            resetTheCertifiedFieldValue.add(acc);
          }
      }
	
      if(!resetTheCertifiedFieldValue.isEmpty()){
          update resetTheCertifiedFieldValue;
      }
      
      
      List<Account> setTheCertifiedFieldValue = new List<Account>();
      for(Account certifiedAcc : [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Certified__c = true)]){
          certifiedAcc.Certified__c = TRUE;
          setTheCertifiedFieldValue.add(certifiedAcc);
      }
      
      if(!setTheCertifiedFieldValue.isEmpty()){
          update setTheCertifiedFieldValue;
      } 
  }
    
  global void finish(Database.BatchableContext BC) {
    
  }
}