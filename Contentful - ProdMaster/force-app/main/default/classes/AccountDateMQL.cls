public class AccountDateMQL {

    public void earliestAccountMQLdate(Set<Id> scopedAccountIds, List<AggregateResult> scopedMQLRecords){
        
        Map<Id, Account> listOfMatchedAccounts = new Map<Id, Account>([SELECT Id, Date_Earliest_MQL__c FROM Account WHERE Id IN :scopedAccountIds]);
        
        List<Account> accMQL = new List<Account>();
		
        for(AggregateResult ld : scopedMQLRecords){
            
            Account matchedAccount = listOfMatchedAccounts.get(String.valueof(ld.get('acc')));
            
            if(matchedAccount != null){
                if(matchedAccount.Date_Earliest_MQL__c == null || matchedAccount.Date_Earliest_MQL__c > Date.valueOf(ld.get('minmql'))){
                    Account acc = new Account(Id = matchedAccount.Id);
            		acc.Date_Earliest_MQL__c = Date.valueOf(ld.get('minmql'));
            		accMQL.add(acc);
                }
            }
        }
        
        update accMQL;
    }
}