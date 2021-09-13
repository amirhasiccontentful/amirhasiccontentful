public without sharing class ZuoraZInvoiceTriggerHandler extends TriggerHandler {
    
    /****************************************************/
    /* TRIGGER EXECUTION                                */
    /****************************************************/

    public override void beforeUpdate() {
    }

    public override void beforeInsert() {
    }

    public override void afterUpdate() {
        //accountZuoraInvoiceAmount(Trigger.new, (Map<Id, Zuora__ZInvoice__c>)trigger.oldMap);
    }

    public override void afterInsert() {
        //accountZuoraInvoiceAmount(Trigger.new, (Map<Id, Zuora__ZInvoice__c>)trigger.oldMap);
    }

    /****************************************************/
    /* HELPER FUNCTIONS                                 */
    /****************************************************/

    /*private void accountZuoraInvoiceAmount(List<Zuora__ZInvoice__c> newRecords, Map<Id, Zuora__ZInvoice__c> oldMapRecords){

        Set<Id> accountIds = new Set<Id>();

        Boolean executeFromCustomSetting = false;
        Boolean executeLogic = true;

        ExecuteSetting__c zuoraAccountRollupsSetting = new ExecuteCodeLogic().checkIfCodeLogicShouldBeExecuted('Zuora ZInvoice Account Rollup');

        if(zuoraAccountRollupsSetting != null){

            if(zuoraAccountRollupsSetting.Active__c == false){
                executeLogic = false;
            }

            if(zuoraAccountRollupsSetting.Execute__c == true){
                executeFromCustomSetting = true;
            }
        }

        if(executeLogic == false) return;


        for(Zuora__ZInvoice__c zI : newRecords){

            Zuora__ZInvoice__c oldRecord;

            if(oldMapRecords != null){
                oldRecord = oldMapRecords.get(zI.Id);
            }

            if(oldRecord == null){
                accountIds.add(zI.Zuora__Account__c);
            } else if(oldRecord != null && 
                (zI.Zuora__AmountWithoutTax__c != oldRecord.get('Zuora__AmountWithoutTax__c') || 
                 zI.Zuora__Account__c != oldRecord.get('Zuora__Account__c') || 
                 executeFromCustomSetting
                )){

                accountIds.add(zI.Zuora__Account__c);

                if((Id)oldRecord.get('Zuora__Account__c') != null){
                    accountIds.add((Id)oldRecord.get('Zuora__Account__c'));
                }
            }
        }

        if(accountIds.isEmpty()) return;

        List<Account> accountsForUpdate = new List<Account>();

        for(Account acc : [SELECT Id, Name, Zuora_Total_Invoice_Amount__c, 
                            (SELECT Id, Zuora__Account__c, Zuora__AmountWithoutTax__c FROM Zuora__Invoices__r)
                            FROM Account WHERE Id IN :accountIds]){

            acc.Zuora_Total_Invoice_Amount__c = 0.00;

            if(!acc.Zuora__Invoices__r.isEmpty()){

                for(Zuora__ZInvoice__c zInvoice : acc.Zuora__Invoices__r){
                    if(zInvoice.Zuora__AmountWithoutTax__c > 0){
                        acc.Zuora_Total_Invoice_Amount__c += zInvoice.Zuora__AmountWithoutTax__c;
                    }
                }
            }

            accountsForUpdate.add(acc);
        }

        /*for(AggregateResult ag : [SELECT Zuora__Account__c acc, sum(Zuora__AmountWithoutTax__c) total 
                                    FROM Zuora__ZInvoice__c WHERE Zuora__Account__c IN :accountIds AND Zuora__AmountWithoutTax__c > 0 
                                    GROUP BY Zuora__Account__c]){

            if(ag.get('acc') != null){
                Account acc = new Account(Id = (Id)ag.get('acc'));
                acc.Zuora_Total_Invoice_Amount__c = (Decimal)ag.get('total');
                accountsForUpdate.add(acc);
            }
        }

        if(!accountsForUpdate.isEmpty()){

            try{
                update accountsForUpdate;
            } catch (Exception e){

                System.debug('ZuoraZInvoiceTriggerHandler.accountZuoraInvoiceAmount:exception:--- ' + e);

                //Set Header values of the file

                String csvHeader = 'Record Id, Name \n';

                String mainContent = csvHeader;

                for (Account acc : accountsForUpdate)

                {
                      //Adding records in a string
                       String recordString = acc.Id+','+acc.Name +'\n';
                       mainContent += recordString;
                }

                Messaging.EmailFileAttachment csvAttcmnt = new Messaging.EmailFileAttachment ();

                //Create CSV file using Blob

                Blob csvBlob = Blob.valueOf(mainContent);

                String csvname = 'Zuora Account Total Invoice Amount Rollup Failed.csv';

                csvAttcmnt.setFileName(csvname);

                csvAttcmnt.setBody(csvBlob);

                Messaging.SingleEmailMessage singEmail = new Messaging.SingleEmailMessage ();

                List<String> toAddresses = new list<string> {'salesforce-admin@contentful.com'};

                //Set recipient list

                singEmail.setToAddresses(toAddresses);

                String subject = 'Zuora Account Total Invoice Amount Rollup Failed CSV';

                singEmail.setSubject (subject);

                singEmail.setPlainTextBody ('Zuora Account Total Invoice Amount Rollup Failed CSV - ' + e);

                //Set blob as CSV file attachment

                singEmail.setFileAttachments (new Messaging.EmailFileAttachment []{csvAttcmnt});

                try{
                    Messaging.SendEmailResult [] r = Messaging.sendEmail (new Messaging.SingleEmailMessage [] {singEmail});
                } catch (Exception ex){
                    System.debug('ZuoraZInvoiceTriggerHandler.accountZuoraInvoiceAmount:exception:email:ex:---- ' + ex);
                }
                
            }

        }
    }*/
}