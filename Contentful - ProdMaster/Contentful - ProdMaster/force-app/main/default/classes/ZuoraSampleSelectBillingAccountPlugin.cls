global class ZuoraSampleSelectBillingAccountPlugin implements zqu.SelectBillingAccountComponentOptions.ICustomizeBillingAccountPlugin {
    
    global zqu.JSRemoteController.BillingAccountObjects getAvailableBillingAccounts(zqu.JSRemoteController.BillingAccountObjects accountObjs){

        //'accountObjs.billingAccountTypes' contains 
        // a list of billing account types : 'new', 'existing'
        
        //get the opp type
        if(accountObjs.opportunityId != NULL){
            
            List<Opportunity> opp = [SELECT Id, RecordType.DeveloperName, Account.Enterprise_Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Account.Enterprise_Subscription__r.Zuora__CustomerAccount__c FROM Opportunity WHERE Id = :accountObjs.opportunityId];
            if(!opp.isEmpty()){
                if(opp[0].RecordType.DeveloperName != 'Enterprise_Initial'){ 
                    // Remove the 'new' account type 
                    // to disallow new account creation
                    
                    if(opp[0].RecordType.DeveloperName == 'Enterprise_Renewal'){
                        accountObjs.billingAccountTypes.remove(0);
                    }
                    
                    // Set the default selected billing account type
                    accountObjs.defaultBillingAccountType = 'existing';
                    if(opp[0].Account.Enterprise_Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c != null){
                        accountObjs.defaultBillingAccountId = opp[0].Account.Enterprise_Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c;
                    }
                } else {
                    accountObjs.defaultBillingAccountType = 'new';
                    accountObjs.billingAccountTypes.remove(1);
                }
            }
        }
      
        return accountObjs;
    }

    global zqu.JSRemoteController.QuoteTypeObjects getAvailableQuoteTypes(zqu.JSRemoteController.QuoteTypeObjects quoteTypeObjs){
        
        System.debug('quoteTypeObjs:---- ' + quoteTypeObjs);
        if(quoteTypeObjs.opportunityId != NULL){
            List<Opportunity> opp = [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id = :quoteTypeObjs.opportunityId];
            if(!opp.isEmpty()){
                if(opp[0].RecordType.DeveloperName == 'Enterprise_Initial'){ 
                    quoteTypeObjs.defaultQuoteType = 'new';
                } else if(opp[0].RecordType.DeveloperName == 'Enterprise_Renewal'){ 
                    quoteTypeObjs.defaultQuoteType = 'renew';
                } else if(opp[0].RecordType.DeveloperName == 'Enterprise_Expand'){ 
                    quoteTypeObjs.defaultQuoteType = 'amend';
                }
            }
        }
        return quoteTypeObjs;
    }
    
    global zqu.JSRemoteController.SubscriptionObjects getAvailableSubscriptions(zqu.JSRemoteController.SubscriptionObjects subscriptionObjs){
        return subscriptionObjs;
    }
}