global class AccountsWithMultipleCurrencies implements Schedulable 
{
    global void execute(SchedulableContext SC) 
    {
        sendEmailWithTheListOfAccountsWithMultipleCurrencies();
    }
    public void sendEmailWithTheListOfAccountsWithMultipleCurrencies()
    {
        List<Account> accountsWithMultipleCurrencies = new List<Account>();

        for(Account acc : [SELECT Id, Name, CurrencyISOCode, 
                            (SELECT Id, CurrencyISOCode FROM Zuora__Subscriptions__r 
                                                        WHERE CurrencyISOCode != null AND 
                                                        Zuora__Status__c = 'active' 
                                                        ORDER BY CreatedDate DESC) 
                            FROM Account WHERE LastModifiedDate = TODAY]){

            String subscriptionCurrency = '';
            Integer currencyCount = 0;

            for(Zuora__Subscription__c subCurrency : acc.Zuora__Subscriptions__r){
                
                if(subscriptionCurrency != subCurrency.CurrencyISOCode){
                    currencyCount += 1;
                }
            }

            if(currencyCount > 1){
                accountsWithMultipleCurrencies.add(acc);
            }
        }

        if(!accountsWithMultipleCurrencies.isEmpty()){

            //Send email with the list of Accounts that have multiple currencies
            String csvHeader = 'Record Id, Name \n';

            String mainContent = csvHeader;

            for (Account acc : accountsWithMultipleCurrencies)

            {
                //Adding records in a string
                String recordString = acc.Id+','+acc.Name +'\n';
                mainContent += recordString;
            }

            Messaging.EmailFileAttachment csvAttcmnt = new Messaging.EmailFileAttachment ();

            //Create CSV file using Blob

            Blob csvBlob = Blob.valueOf(mainContent);

            String csvname = 'Accounts With Multiple Currencies.csv';

            csvAttcmnt.setFileName(csvname);

            csvAttcmnt.setBody(csvBlob);

            Messaging.SingleEmailMessage singEmail = new Messaging.SingleEmailMessage ();

            List<String> toAddresses = new list<string> {String.valueOf(Label.MultipleCurrenciesRecipient)};

            //Set recipient list

            singEmail.setToAddresses(toAddresses);

            String subject = 'Accounts With Multiple Currencies';

            singEmail.setSubject (subject);

            singEmail.setPlainTextBody ('Attached is the list of Account records that have active subscriptions in different currencies');

            //Set blob as CSV file attachment

            singEmail.setFileAttachments (new Messaging.EmailFileAttachment []{csvAttcmnt});

            try{
                Messaging.SendEmailResult [] r = Messaging.sendEmail (new Messaging.SingleEmailMessage [] {singEmail});
            } catch (Exception ex){
                System.debug('ZuoraSubscriptionTriggerHandler:accountCurrencies:ex:---- ' + ex);
            }
        }
    }
}