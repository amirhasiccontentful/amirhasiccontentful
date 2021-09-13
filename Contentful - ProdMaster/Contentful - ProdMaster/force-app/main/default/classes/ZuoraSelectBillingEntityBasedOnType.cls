global without sharing class ZuoraSelectBillingEntityBasedOnType  implements zqu.SelectEntityComponentOptions.ISelectEntityPlugin {
      global zqu.SelectEntityComponentOptions.SelectEntityPluginResponse selectEntityForNewQuote(String accountId, String opportunityId) {
          zqu.SelectEntityComponentOptions.SelectEntityPluginResponse resp = new zqu.SelectEntityComponentOptions.SelectEntityPluginResponse();
           
          if(opportunityId != null){
              List<Opportunity> opp = [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id =: opportunityId];
              
              if(opp.isEmpty() && opp[0].RecordType.DeveloperName == 'Enterprise_Initial'){
                  resp.selectedId = null;
              } else {
                  
                    Account acc = [SELECT Id, Enterprise_Subscription__c, Enterprise_Subscription__r.Zuora__CustomerAccount__c FROM Account WHERE Id=:accountId LIMIT 1];
                    if(acc.Enterprise_Subscription__c != null && acc.Enterprise_Subscription__r.Zuora__CustomerAccount__c != null) {        
                       resp.selectedId = acc.Enterprise_Subscription__r.Zuora__CustomerAccount__c;
                       //resp.autoSubmit = true;
                    }
              }
          }
           
          return resp;
      }
}