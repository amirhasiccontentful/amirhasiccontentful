@isTest
public class ZuoraZInvoiceTriggerHandler_Test {
    
    private static testMethod void zInvoiceAccountRollup_test(){

        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Zuora__ZInvoice__c newInvoice = new Zuora__ZInvoice__c();
        newInvoice.Name = 'Test Invoice';
        newInvoice.Zuora__AmountWithoutTax__c = 100;
        newInvoice.Zuora__Account__c = acc.Id;
        insert newInvoice;
        
        Test.startTest();
			new ZInvoice_onSchedule().execute(null);
        Test.stopTest();
        
        List<Account> checkAccount = [SELECT Id, Zuora_Total_Invoice_Amount__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(100, checkAccount[0].Zuora_Total_Invoice_Amount__c);
    }


    private static testMethod void zInvoiceAccountRollupAccountChanged_test(){

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Account acc2 = new Account(Name = 'Test Account2');
        insert acc2;
        
        Zuora__ZInvoice__c newInvoice = new Zuora__ZInvoice__c();
        newInvoice.Name = 'Test Invoice';
        newInvoice.Zuora__AmountWithoutTax__c = 100;
        newInvoice.Zuora__Account__c = acc.Id;
        insert newInvoice;

        /*List<Account> checkAccount = [SELECT Id, Zuora_Total_Invoice_Amount__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(100, checkAccount[0].Zuora_Total_Invoice_Amount__c);
		*/
        newInvoice.Zuora__Account__c = acc2.Id;
        update newInvoice;
        
        Test.startTest();
			new ZInvoice_onSchedule().execute(null);
        Test.stopTest();

        List<Account> checkAccount2 = [SELECT Id, Name, Zuora_Total_Invoice_Amount__c FROM Account];
        System.assertEquals('Test Account', checkAccount2[0].Name);
        System.assertEquals(null, checkAccount2[0].Zuora_Total_Invoice_Amount__c);

        System.assertEquals('Test Account2', checkAccount2[1].Name);
        System.assertEquals(100, checkAccount2[1].Zuora_Total_Invoice_Amount__c);

    }
}