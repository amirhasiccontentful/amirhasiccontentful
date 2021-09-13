public without sharing class PartnerDealsTriggerHandler extends TriggerHandler {
   	
    public override void beforeInsert(){
        PartnerDealsRollupSummary(trigger.new, (Map<Id, Partner_Deals__c>)trigger.newMap);
        SetClientIdOnOpportunityChange(trigger.new, null);
    }

    public override void beforeUpdate() {
        PartnerDealsRollupSummary(trigger.new, (Map<Id, Partner_Deals__c>)trigger.oldMap);
        SetClientIdOnOpportunityChange(trigger.new, (Map<Id, Partner_Deals__c>)trigger.oldMap);
    }

    public override void beforeDelete() {
        
	}

	public override void afterInsert() {
		updateOpportunityPipelineSource(trigger.new, (Map<Id, Partner_Deals__c>)trigger.oldMap);
	}
    
	public override void afterUpdate() {
		updateOpportunityPipelineSource(trigger.new, (Map<Id, Partner_Deals__c>)trigger.oldMap);
	}

	public override void afterDelete() {
        PartnerDealsRollupSummaryDelete(trigger.old);
        updateOpportunityPipelineSource(trigger.old, null);
    }

    public override void afterUndelete() {
		updateOpportunityPipelineSource(trigger.new, null);
	}

	private void SetClientIdOnOpportunityChange(List<Partner_Deals__c> partnerDeals, Map<Id, Partner_Deals__c> oldPartnerDealsMap){

        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> partnerDealIdsForClientIdRemoval = new Set<Id>(); 

        for(Partner_Deals__c pd : partnerDeals) {
            
            if(Trigger.isInsert && pd.Opportunity_Name__c != null) {
                opportunityIds.add(pd.Opportunity_Name__c);
            }
 
            if(oldPartnerDealsMap == null) continue;

            Partner_Deals__c oldPD = oldPartnerDealsMap.get(pd.Id); 

            if(Trigger.isUpdate && oldPD != null && pd.Opportunity_Name__c != null && pd.Opportunity_Name__c != oldPD.Opportunity_Name__c) {
                opportunityIds.add(pd.Opportunity_Name__c);
            }  

            if(Trigger.isUpdate && oldPD != null && pd.Opportunity_Name__c == null && pd.Opportunity_Name__c != oldPD.Opportunity_Name__c) {
                partnerDealIdsForClientIdRemoval.add(pd.Id);
            }  
        }

        if(opportunityIds.size() > 0) { 

            List<Opportunity> opportunitiesList = [SELECT Id, AccountId 
                                                   FROM Opportunity 
                                                   WHERE Id IN :opportunityIds];
                                        
            Map<Id, Id> opportunityToAccountMapIds = new Map<Id, Id>();

            for(Opportunity dbOpp : opportunitiesList) {
                opportunityToAccountMapIds.put(dbOpp.Id, dbOpp.AccountId);
            } 

            for(Partner_Deals__c pd : partnerDeals) {
                Id accountId = opportunityToAccountMapIds.get(pd.Opportunity_Name__c);
                if(accountId != null) {
                    pd.Client_Account__c = accountId;
                }
            }
        }

        if(partnerDealIdsForClientIdRemoval.size() > 0) { 
            for(Partner_Deals__c pd : partnerDeals) {
                if(partnerDealIdsForClientIdRemoval.contains(pd.Id)){
                    pd.Client_Account__c = null;
                }
            }
        }
    }

	private void updateOpportunityPipelineSource(List<Partner_Deals__c> partnerDeals, Map<Id, Partner_Deals__c> oldPartnerDealsMap){

        Map<Id, Opportunity> mapOffOppsToUpdate = new Map<Id, Opportunity>();

		ExecuteSetting__c executeSetting = ExecuteSetting__c.getValues('Partner Sourced - Pipeline Source');
        
		Boolean executeRerun = executeSetting != null && executeSetting.Execute__c ? true : false;

		for(Partner_Deals__c pd : partnerDeals){

            //Add opportunity Id for all operations different then update
            if( !Trigger.isUpdate && pd.Opportunity_Name__c != null && pd.Partner_Customer_Relationship_Type__c == 'Partner Sourced'){
                mapOffOppsToUpdate.put(pd.Opportunity_Name__c, new Opportunity(Id = pd.Opportunity_Name__c));
            }

            if(oldPartnerDealsMap == null) continue; 
            
            Partner_Deals__c oldDeal = oldPartnerDealsMap.get(pd.Id);
            
            //If partner deal details have been updated
			if( executeRerun == true ||
                ( Trigger.isUpdate && (pd.Opportunity_Name__c != oldDeal.Opportunity_Name__c || 
                    pd.Partner_Customer_Relationship_Type__c != oldDeal.Partner_Customer_Relationship_Type__c) )
               ){

                if(pd.Opportunity_Name__c != null)
                    mapOffOppsToUpdate.put(pd.Opportunity_Name__c, new Opportunity(Id = pd.Opportunity_Name__c)); 

                if(oldDeal.Opportunity_Name__c != null)
                    mapOffOppsToUpdate.put(oldDeal.Opportunity_Name__c, new Opportunity(Id = oldDeal.Opportunity_Name__c)); 
			}
        }

		if(!mapOffOppsToUpdate.isEmpty()){ 
            update mapOffOppsToUpdate.values();
		}

	}

    private void PartnerDealsRollupSummary(List<Partner_Deals__c> partnerDeals, Map<Id, Partner_Deals__c> oldPartnerDeals){
        
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> partnerDealsIds = new Set<Id>();
        Map<Id,Opportunity> opportunitiesMap = new Map<Id,Opportunity>();
        Map<Id,List<Partner_Deals__c>> allPartnerDealsMap = new Map<Id,List<Partner_Deals__c>>();
        Map<Id,Set<Partner_Deals__c>> opportunityPartnerDealsMap = new Map<Id,Set<Partner_Deals__c>>();
        
        ExecuteSetting__c executeSetting = ExecuteSetting__c.getValues('Partner Influence');

        Boolean executeRerun = executeSetting != null && executeSetting.Execute__c ? true : false;
            
        for(Partner_Deals__c pd : partnerDeals){
            partnerDealsIds.Add(pd.Id);
            if(Trigger.IsUpdate || Trigger.IsDelete){
                if((pd.Opportunity_Name__c != null && oldPartnerDeals.get(pd.Id).Opportunity_Name__c != pd.Opportunity_Name__c) || executeRerun)
                    opportunityIds.add(pd.Opportunity_Name__c); 
            }
            else if(pd.Opportunity_Name__c != null) {
                opportunityIds.add(pd.Opportunity_Name__c); 
            }
        } 

        if(opportunityIds.size() == 0) return;
        
        opportunitiesMap = new Map<Id,Opportunity>([
            SELECT Id,Partner_Deal_Count__c
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ]);
        
        List<Partner_Deals__c> listOfPartnerDeals = new List<Partner_Deals__c>([SELECT Id, Opportunity_Name__c, Influenced_Field__c
                                                                                FROM Partner_Deals__c
                                                                                WHERE Opportunity_Name__c IN :opportunityIds]);
        for(Partner_Deals__c pd : listOfPartnerDeals){
            if(!partnerDealsIds.Contains(pd.Id)){
                if(allPartnerDealsMap.get(pd.Opportunity_Name__c) != NULL){
                    allPartnerDealsMap.get(pd.Opportunity_Name__c).Add(pd);
                } 
                else {
                    allPartnerDealsMap.put(pd.Opportunity_Name__c, new List<Partner_Deals__c>{pd});
                }
            }
        }
            
        Map<Id, Integer> pdCounts = new Map<Id, Integer>();
        for(Id oppId : opportunityIds){
            Integer count = 0;
            for(Partner_Deals__c pd : partnerDeals){
                if(pd.Opportunity_Name__c == oppId)
                    count++;
            }
            count += allPartnerDealsMap.get(oppId) != NULL ? allPartnerDealsMap.get(oppId).size() : 0;
            pdCounts.put(oppId, count);
        }  
            
            
        for(Id oppId : pdCounts.keySet()){
            Decimal influencedFieldValue =( 100.00 / pdCounts.get(oppId)).setScale(2, RoundingMode.HALF_UP);
            
            if(allPartnerDealsMap.size() > 0) {
                for(Partner_Deals__c pd : allPartnerDealsMap.get(oppId)){
                    pd.Influenced_Field__c = influencedFieldValue;
                }
            }                   
            
            for(Partner_Deals__c existingPD : partnerDeals){
                if(existingPD.Opportunity_Name__c == oppId)
                existingPD.Influenced_Field__c = influencedFieldValue;
            }
        }

        List<Partner_Deals__c> pdsForUpdate = new List<Partner_Deals__c>();

        for(Id key : allPartnerDealsMap.Keyset()){
            pdsForUpdate.addAll(allPartnerDealsMap.get(key));
        }        

        update pdsForUpdate;
        
        for(Id key : pdCounts.keySet()){
            if(!pdCounts.containsKey(key)){
                opportunitiesMap.get(key).Partner_Deal_Count__c = 0;
            } else {
                Integer partnerDealsCount = pdCounts.get(key);
                opportunitiesMap.get(key).Partner_Deal_Count__c = partnerDealsCount;
            }
        }

        update opportunitiesMap.values();		
    }
    
    private void PartnerDealsRollupSummaryDelete(List<Partner_Deals__c> partnerDeals){

		Set<Id> opportunityIds = new Set<Id>();
		Map<Id,Opportunity> opportunitiesMap = new Map<Id,Opportunity>();
		List<Partner_Deals__c> allPartnerDeals = new List<Partner_Deals__c>();
		Map<Id,Set<Partner_Deals__c>> opportunityPartnerDealsMap = new Map<Id,Set<Partner_Deals__c>>();

		for(Partner_Deals__c pd : partnerDeals){
			opportunityIds.add(pd.Opportunity_Name__c);
		}

		opportunitiesMap = new Map<Id,Opportunity>([
			SELECT Id,Partner_Deal_Count__c
			FROM Opportunity
			WHERE Id IN :opportunityIds
		]);

		allPartnerDeals = [
			SELECT Id, Opportunity_Name__c, Influenced_Field__c
			FROM Partner_Deals__c
			WHERE Opportunity_Name__r.Id IN :opportunityIds
		];

		for(Partner_Deals__c partnerDeal : allPartnerDeals){
			if(!opportunityPartnerDealsMap.containsKey(partnerDeal.Opportunity_Name__c)){
				opportunityPartnerDealsMap.put(partnerDeal.Opportunity_Name__c, new Set<Partner_Deals__c>{partnerDeal});
			} else {
				Set<Partner_Deals__c> existingPartnerDeals = opportunityPartnerDealsMap.get(partnerDeal.Opportunity_Name__c);
				existingPartnerDeals.add(partnerDeal);
				opportunityPartnerDealsMap.put(partnerDeal.Opportunity_Name__c,existingPartnerDeals);
			}
		}

		for(Id key : opportunitiesMap.keySet()){
			if(!opportunityPartnerDealsMap.containsKey(key)){
				opportunitiesMap.get(key).Partner_Deal_Count__c = 0;
			} else {
				Integer partnerDealsCount = opportunityPartnerDealsMap.get(key).size();
				opportunitiesMap.get(key).Partner_Deal_Count__c = partnerDealsCount;
				
				Set<Partner_Deals__c> newPartnerDeals = opportunityPartnerDealsMap.get(key);
				for(Partner_Deals__c partnerDeal : newPartnerDeals){
					partnerDeal.Influenced_Field__c =( 100.00 / partnerDealsCount).setScale(2, RoundingMode.HALF_UP);
				}
			}
        }
        
		update allPartnerDeals;
		update opportunitiesMap.values();		
	}
    
    
}