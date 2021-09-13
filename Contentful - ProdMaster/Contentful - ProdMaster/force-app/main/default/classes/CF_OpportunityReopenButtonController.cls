public with sharing class CF_OpportunityReopenButtonController {
    private ApexPages.StandardController standardController;
 
    public CF_OpportunityReopenButtonController(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        if (!Test.isRunningTest()) { 
        	standardController.addFields(new List<String>{'id', 'name', 'stagename', 'accountId', 'ownerId', 'description', 'use_case__c', 'project_significance__c', 'enterprise_product__c', 'previous_opportunity__c', 'se_documentation_url__c'});
        }
    }
 
    public PageReference reopenOpportunity() {  
        Id recordId = standardController.getId();
        Opportunity opportunity = (Opportunity) standardController.getRecord();
		
		if (opportunity.stagename == 'Closed Lost') {
			Opportunity newOpp = CF_Opportunity.reopenOpportunity(opportunity);    
	        
	        PageReference pRef = new PageReference('/' + newOpp.id);
	        pRef.setRedirect(true); 
	        return pRef;			
		}
		else {
			// todo: show an error
			return null;
		}        
    }
}