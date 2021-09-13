global class ZuoraInvoice_Batchable implements Database.Batchable<sObject> {
	
    global final String query; 
    global final Date modifiedSince;
	
   	global ZuoraInvoice_Batchable() {
        modifiedSince = System.today().addDays(- Integer.valueof(Label.ZInvoice_Modified_Since));
    	query = 'SELECT Id, Zuora_Total_Invoice_Amount__c FROM Account WHERE ID IN (SELECT Zuora__Account__c FROM Zuora__ZInvoice__c WHERE LastModifiedDate > :modifiedSince)'; 
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
        //Get all zuoura invoice related account
        Map<Id, Account> accountsMap = new Map<Id, Account>((List<Account>)Database.query(query));
        List<String> accountIds = new List<String>();
        for(Id accoundId : accountsMap.keySet()) {
            accountIds.add(accoundId);
        } 

        //Execute main query to get all accounts that need to be updates
        String soql = 'SELECT Id, Name, Zuora_Total_Invoice_Amount__c FROM Account WHERE ';
        soql += 'Id IN (\'' + String.join(accountIds, '\',\'') + '\') OR (Zuora_Total_Invoice_Amount__c != null AND Zuora_Total_Invoice_Amount__c != 0) ';
            
        return Database.getQueryLocator(soql);
	}
	
	global void execute(Database.BatchableContext BC, List<Account> scope) {

        //Get related account Ids
        Set<Id> accountIds = new Set<Id>();
        for(Account account : scope) {
            accountIds.add(account.Id);
        } 
           
        //Get related Zuora Invoices
        List<Zuora__ZInvoice__c> zuoraInvoices = [SELECT Id, Zuora__Account__c, Zuora__AmountWithoutTax__c FROM Zuora__ZInvoice__c WHERE Zuora__Account__c IN :accountIds];

        //Map zoura invoices to their related accounts within a new map
        Map<Id, List<Zuora__ZInvoice__c>> zuoraInvoicesMap = new Map<Id, List<Zuora__ZInvoice__c>>();
        for(Zuora__ZInvoice__c zInvoice : zuoraInvoices) {
            if(zuoraInvoicesMap.containsKey(zInvoice.Zuora__Account__c)) {
                List<Zuora__ZInvoice__c> relatedZuoraInvoices = zuoraInvoicesMap.get(zInvoice.Zuora__Account__c);
                relatedZuoraInvoices.add(zInvoice);
                zuoraInvoicesMap.put(zInvoice.Zuora__Account__c, relatedZuoraInvoices);
            } else {
                zuoraInvoicesMap.put(zInvoice.Zuora__Account__c, new List<Zuora__ZInvoice__c> { zInvoice });
            }
        } 
        
        //Get accounts to update 
        List<Account> accountsForUpdate = new List<Account>();

        for(Account acc : scope){
            
            acc.Zuora_Total_Invoice_Amount__c = 0.00;

            List<Zuora__ZInvoice__c> zInvoicesList = zuoraInvoicesMap.get(acc.Id);

            if(zInvoicesList != null && zInvoicesList.size() > 0) {
                for(Zuora__ZInvoice__c zInvoice : zInvoicesList){ 
                    acc.Zuora_Total_Invoice_Amount__c += zInvoice.Zuora__AmountWithoutTax__c;
                }
            }

            accountsForUpdate.add(acc);
        }
         
        if(!accountsForUpdate.isEmpty()) update accountsForUpdate;
        
   	}
   	
	global void finish(Database.BatchableContext BC) {
    	
	}
}