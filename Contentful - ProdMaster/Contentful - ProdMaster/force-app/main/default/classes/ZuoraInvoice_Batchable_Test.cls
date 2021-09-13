@isTest
public with sharing class ZuoraInvoice_Batchable_Test {
    
    @isTest
    public static void TEST_ZuoraInvoiceBatchable() {

        //Arrange
        Account account_1 = TestDataFactory.CreateAccount();
        Account account_2 = TestDataFactory.CreateAccount();

        Zuora__ZInvoice__c zInvoice_1 = TestDataFactory.CreateZuoraZInvoice(account_1.Id, 250, 'USD');
        Zuora__ZInvoice__c zInvoice_2 = TestDataFactory.CreateZuoraZInvoice(account_1.Id, 350, 'USD');
        Zuora__ZInvoice__c zInvoice_3 = TestDataFactory.CreateZuoraZInvoice(account_2.Id, 500, 'USD');

        List<String> accountsIds = new List<String> { account_1.Id, account_2.Id };
        
        //Act

        Test.startTest();

        ZuoraInvoice_Batchable c = new ZuoraInvoice_Batchable();
        database.executebatch(c, Integer.valueOf(Label.ZInvoiceBatchSize));

        Test.stopTest();

        //Assert
        List<Account> accountsList = [SELECT Id, Zuora_Total_Invoice_Amount__c FROM Account WHERE Id IN :accountsIds];
        for (Account account : accountsList) {
            if(account_1.Id == account.Id) {
                System.assertEquals(600, account.Zuora_Total_Invoice_Amount__c);
            }

            if(account_2.Id == account.Id) {
                System.assertEquals(500, account.Zuora_Total_Invoice_Amount__c);
            }
        }

    }

}