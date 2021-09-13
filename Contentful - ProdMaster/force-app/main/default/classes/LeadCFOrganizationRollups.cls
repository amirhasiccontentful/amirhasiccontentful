public class LeadCFOrganizationRollups {
	
    public static void calculateWeeklyRollups(Set<Id> scopedLeadIds){

		List<Lead> leadsForUpdate = new List<Lead>();

		for(Lead ld : [SELECT 
							Id, 
							CF_Organization__c,
							User_count_last_week__c, 
							User_count_week_before__c, 
							CDA_last_week__c, 
							CDA_week_before__c, 
							CPA_last_week__c, 
							CPA_week_before__c, 
							CMA_last_week__c, 
							CMA_week_before__c,
							CF_Organization__r.Gainsight__c, 
							CF_Organization__r.Gainsight_Seven_Day_Sliding_Cda_Calls__c, 
							CF_Organization__r.Gainsight_Seven_Day_Sliding_Cma_Calls__c, 
							CF_Organization__r.Gainsight_Seven_Day_Sliding_Cpa_Calls__c
							FROM Lead WHERE Id IN :scopedLeadIds]){

			ld.User_count_week_before__c = ld.User_count_last_week__c;
			ld.User_count_last_week__c = ld.CF_Organization__r.Gainsight__c;

			ld.CDA_week_before__c = ld.CDA_last_week__c;
			ld.CDA_last_week__c = ld.CF_Organization__r.Gainsight_Seven_Day_Sliding_Cda_Calls__c;

			ld.CPA_week_before__c = ld.CPA_last_week__c;
			ld.CPA_last_week__c = ld.CF_Organization__r.Gainsight_Seven_Day_Sliding_Cpa_Calls__c;

			ld.CMA_week_before__c = ld.CMA_last_week__c;
			ld.CMA_last_week__c = ld.CF_Organization__r.Gainsight_Seven_Day_Sliding_Cma_Calls__c;

			leadsForUpdate.add(ld);

		}

		if(!leadsForUpdate.isEmpty()) update leadsForUpdate;
	}
}