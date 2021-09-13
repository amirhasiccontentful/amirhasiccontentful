global class PartnerInfluencedAmount implements Database.Batchable<sObject> {
	global final String query;
	global List<Account> lstAccounts;
    global Integer scopedNumberOfDays;
   	global PartnerInfluencedAmount() {
        scopedNumberOfDays = Integer.valueOf(Label.Partner_Influence_Range);
        query = 'SELECT Id, Partner_Account__c FROM Partner_Deals__c WHERE LastModifiedDate = LAST_N_DAYS:' + scopedNumberOfDays + ' ORDER BY Partner_Account__c';
	}
	
   	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Partner_Deals__c> scope) {
        
        lstAccounts = new List<Account>();
        Set<Id> scopedAccounts = new Set<Id>();
        
        for(Partner_Deals__c p : scope){
            scopedAccounts.add(p.Partner_Account__c);
        }
        
        for(Account acc : [SELECT Id, (SELECT Id, Opportunity_Stage__c, Opportunity_Type__c, Referral_Fee__c, MDF__c, Commission_MDF_Status__c, Influenced_Amount__c, Partner_Customer_Relationship_Type__c FROM Partner_Deals1__r WHERE Opportunity_Type__c = 'Initial' OR Opportunity_Type__c = 'Expansion') 
                           FROM Account WHERE Id IN :scopedAccounts OR (Partner_Deal_Count__c > 0 AND (Partner_Influenced_Amount__c > 0 OR Partner_Open_Pipeline__c > 0 OR Partner_Referral_Fees__c > 0 OR Partner_MDF__c > 0))]){
           	
            acc.Partner_Influenced_Amount__c = 0;
            acc.Partner_Influenced_Amount_Direct__c = 0;
            acc.Partner_Influenced_Amount_Indirect__c = 0;
            acc.Partner_Open_Pipeline__c = 0;
            acc.Partner_Open_Pipeline_Direct__c = 0;
            acc.Partner_Open_Pipeline_Indirect__c = 0;
            acc.Partner_Referral_Fees__c = 0;
            acc.Partner_MDF__c = 0;
            
            
            if(!acc.Partner_Deals1__r.isEmpty()){
                
                Decimal influencedAmount = 0;
                Decimal influencedAmountDirect = 0;
                Decimal influencedAmountIndirect = 0;
                
                Decimal partnerOpenPipeline = 0;
                Decimal partnerOpenPipelineDirect = 0;
                Decimal partnerOpenPipelineIndirect = 0;
                
                Decimal partnerReferralFees = 0;
                Decimal partnerMDF = 0;
                
                for (Partner_Deals__c pd : acc.Partner_Deals1__r) {
                    
                    if(pd.Opportunity_Stage__c == 'Closed Won'){
                        influencedAmount += pd.Influenced_Amount__c;
                        if(pd.Commission_MDF_Status__c == 'Approved'){
                            partnerReferralFees += pd.Referral_Fee__c;
                        	partnerMDF += pd.MDF__c;
                        }
                    } else if(pd.Opportunity_Stage__c != 'Closed Won' && pd.Opportunity_Stage__c != 'Closed Lost'){
                        partnerOpenPipeline += pd.Influenced_Amount__c;
                    }
                    
                    
                    if(pd.Partner_Customer_Relationship_Type__c == 'Partner Sourced'){
                        if(pd.Opportunity_Stage__c == 'Closed Won'){
                            influencedAmountDirect += pd.Influenced_Amount__c;
                        } else if(pd.Opportunity_Stage__c != 'Closed Won' && pd.Opportunity_Stage__c != 'Closed Lost'){
                            partnerOpenPipelineDirect += pd.Influenced_Amount__c;
                        }
                        
                    } else {
                        if(pd.Opportunity_Stage__c == 'Closed Won'){
                        	influencedAmountIndirect += pd.Influenced_Amount__c;
                        } else if(pd.Opportunity_Stage__c != 'Closed Won' && pd.Opportunity_Stage__c != 'Closed Lost'){
                            partnerOpenPipelineIndirect += pd.Influenced_Amount__c;
                        }
                    }
                }
                acc.Partner_Influenced_Amount__c = influencedAmount;
            	acc.Partner_Influenced_Amount_Direct__c = influencedAmountDirect;
            	acc.Partner_Influenced_Amount_Indirect__c = influencedAmountIndirect;
                acc.Partner_Open_Pipeline__c = partnerOpenPipeline;
                acc.Partner_Open_Pipeline_Direct__c = partnerOpenPipelineDirect;
                acc.Partner_Open_Pipeline_Indirect__c = partnerOpenPipelineIndirect;
                acc.Partner_Referral_Fees__c = partnerReferralFees;
                acc.Partner_MDF__c = partnerMDF;
                    
                lstAccounts.add(acc);
            }
        }
        
        System.debug('PartnerInfluence:lstAccounts:--- ' + lstAccounts);
        
        if(!lstAccounts.isEmpty()) Database.update(lstAccounts,false);
        
   	}
   	
	global void finish(Database.BatchableContext BC) {
    	
	}
}