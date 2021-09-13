public with sharing class CF_Opportunity {
	public static Opportunity reopenOpportunity(Opportunity oldOpp) {
		Opportunity opp = new Opportunity();
		
		// TODO: only allow closed lost
		
		opp.name = oldOpp.name + '(Reopened: ' +  datetime.now().format('yyyy-MM-dd')+ ')';
		opp.stagename = 'Discovery';
		opp.accountId = oldOpp.accountId;
		opp.ownerId = oldOpp.ownerId;
		opp.description = oldOpp.description + '\n\nReopened previous opportunity';
		opp.use_case__c = oldOpp.use_case__c;
		opp.project_significance__c = oldOpp.project_significance__c;
		//opp.enterprise_product__c = oldOpp.enterprise_product__c;
		//opp.previous_opportunity__c = oldOpp.id;
		opp.se_documentation_url__c = oldOpp.se_documentation_url__c; 
		opp.closedate = system.today().addDays(30);
		
		insert opp;
		
		return opp;
	}
}