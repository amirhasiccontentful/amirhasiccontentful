global class ZuoraDefaultFieldValues extends zqu.CreateQuoteController.PopulateDefaultFieldValuePlugin{  
   global override void populateDefaultFieldValue(SObject record, zqu.PropertyComponentController.ParentController pcc)
   {  
      if(record != null && pcc != null){
        super.populateDefaultFieldValue(record, pcc);  
      }
      
      //Populate default values in the quote header  
      if(record != null && (Id) record.get('zqu__Opportunity__c') != null){
        // Retrieve the account ID from the quote   
        if((Id) record.get('zqu__Account__c') != null) {
          Id accId = (Id) record.get('zqu__Account__c');
          List<Account> acc = [SELECT Id, Billing_Entity__c FROM Account WHERE Id = :accId];
          
          if(acc[0].Billing_Entity__c == 'gmbh'){
               //record.put('zqu__InvoiceTemplate__c', String.valueof(Label.Zuora_Invoice_Id_Contenful_GmbH));
               record.put('Bill_From__c', 'Contentful GmbH');
               record.put('Master_Agreement_URL__c', String.valueOf(Label.Zuora_Master_Agreement_URL_GmbH));
          } else if(acc[0].Billing_Entity__c == 'inc'){
               //record.put('zqu__InvoiceTemplate__c', String.valueof(Label.Zuora_Invoice_Id_Contenful_Inc));
               record.put('Bill_From__c', 'Contentful Inc.');
               record.put('Master_Agreement_URL__c', String.valueOf(Label.Zuora_Master_Agreement_URL_Inc));
          }
        }      
          
        //record.put('zqu__CommunicationProfile__c', String.valueOf(Label.Zuora_Communication_Profile));
        //record.put('zqu__BillingMethod__c', 'Email');    
      }         
      
      /*
      // Find the contacts associated with the account         
      List<Contact>contacts = [SELECT Id, Name FROM Contact WHERE Account.Id = :accountId];         
      
      // Assuming the contacts are present set the billTo and soldTo to the first contact         
      if  (contacts.size() > 0) {             
         // System.debug('mp: about to add ' + contacts[0].Id + ' as a contact ID');             
         record.put('zqu__BillToContact__c', contacts[0].Id);             
         record.put('zqu__SoldToContact__c', contacts[0].Id);             
      
         // Beforeretrieving  the lookup  options, needs to populate the map first             
         super.setLookupOptions(pcc);             
      
         // Now retrieve the lookup component options             
         zqu.LookupComponentOptions billToOptions = super.getLookupOption('zqu__BillToContact__c');             
         billToOptions.targetId = contacts[0].Id;             
         billToOptions.targetName = contacts[0].Name;             
         zqu.LookupComponentOptions soldToOptions  = super.getLookupOption('zqu__SoldToContact__c');             
         soldToOptions.targetId = contacts[0].Id;             
         soldToOptions.targetName = contacts[0].Name;         
      }*/
   }
}