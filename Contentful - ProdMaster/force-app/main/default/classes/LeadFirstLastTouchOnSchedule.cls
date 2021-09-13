global class LeadFirstLastTouchOnSchedule implements Schedulable 
{
	global void execute(SchedulableContext SC) 
  	{
		leadSourcesMerge();
  	}
	public void leadSourcesMerge()
   	{
      Date numberOfDaysSinceMerge = System.today().addDays(-Integer.valueOf(Label.LeadMergeScope));
        
      List<AggregateResult> mergedLeadsOrdered = [SELECT 
													min(First_Touch_Created_Date__c) ftDate, 
													max(Last_Touch_Created_Date__c) ltDate, 
													MasterRecordId mr,
													LeadSource ls, 
													First_Touch_Lead_Source_Detail__c firstSourceDetails,
													First_Touch_Asset__c firstTouchAsset,
													First_Touch_Asset_Detail__c firstTouchAssetDetails,
													Last_Touch_Lead_Source_Detail__c lastSourceDetails,
													Last_Touch_Asset__c lastTouchAsset,
													Last_Touch_Asset_Detail__c lastTouchAssetDetails
													FROM Lead WHERE MasterRecordId != null AND LastModifiedDate >= :numberOfDaysSinceMerge
													GROUP BY MasterRecordId, LeadSource, First_Touch_Lead_Source_Detail__c, First_Touch_Asset__c,
													First_Touch_Asset_Detail__c, Last_Touch_Lead_Source_Detail__c, Last_Touch_Asset__c, Last_Touch_Asset_Detail__c
													ALL ROWS];
        
       	if(mergedLeadsOrdered.size() == 0) return;
        
        Set<Id> mergeLeadIds = new Set<Id>();
        
        for(AggregateResult l : mergedLeadsOrdered){
            mergeLeadIds.add((String)l.get('mr'));
        }

		List<Lead> listOfMasters = [SELECT Id, 
									CreatedDate, 
									First_Touch_Created_Date__c, 
									Last_Touch_Created_Date__c, 
									LeadSource, 
									First_Touch_Lead_Source__c, 
									Last_Touch_Lead_Source__c 
									FROM Lead WHERE Id IN :mergeLeadIds];

		if(listOfMasters.size() == 0) return;

		Map<Id, Lead> lstOfMasterLeadsForUpdate = new Map<Id, Lead>();

		for(Lead l : listOfMasters){
			
			l.First_Touch_Lead_Source__c = l.LeadSource;
			l.Last_Touch_Lead_Source__c = l.LeadSource;

			for(AggregateResult agr : mergedLeadsOrdered){

				if(l.Id == (String)agr.get('mr')){

					if(l.First_Touch_Created_Date__c > (DateTime)agr.get('ftDate')){
						l.First_Touch_Created_Date__c = (DateTime)agr.get('ftDate');
						l.First_Touch_Lead_Source__c = (String)agr.get('ls');
						l.First_Touch_Lead_Source_Detail__c = (String)agr.get('firstSourceDetails');
						l.First_Touch_Asset__c = (String)agr.get('firstTouchAsset');
						l.First_Touch_Asset_Detail__c = (String)agr.get('firstTouchAssetDetails');
					}

					if(l.Last_Touch_Created_Date__c < (DateTime)agr.get('ltDate')){
						l.Last_Touch_Created_Date__c = (DateTime)agr.get('ltDate');
						l.Last_Touch_Lead_Source__c = (String)agr.get('ls');
						l.Last_Touch_Lead_Source_Detail__c = (String)agr.get('lastSourceDetails');
						l.Last_Touch_Asset__c = (String)agr.get('lastTouchAsset');
						l.Last_Touch_Asset_Detail__c = (String)agr.get('lastTouchAssetDetails');
					}
					lstOfMasterLeadsForUpdate.put(l.Id, l);
				}
			}
		}

		if(lstOfMasterLeadsForUpdate.values().size()>0) update lstOfMasterLeadsForUpdate.values();
   	}
}