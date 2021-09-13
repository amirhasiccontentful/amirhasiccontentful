public with sharing class CF_UserDetailButtonController {
    private ApexPages.StandardController standardController;
 
    public CF_UserDetailButtonController(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        if (!Test.isRunningTest()) { 
        	standardController.addFields(new List<String>{'gk_first_name__c', 'gk_last_name__c', 'gk_email__c', 'gk_id__c', 'gk_invitation_created_at__c'});
        }
    }
 
    public PageReference createLeadFromCF_User() {  
        Id recordId = standardController.getId();
        CF_User__c user = (CF_User__c) standardController.getRecord();
        //Lead lead = CF_Lead.leadFromCF_User(user);
        //user.gk_lead_created_at__c = DateTime.now();

		//insert lead;        
        
        //PageReference pRef = new PageReference('/' + lead.id);
        //pRef.setRedirect(true); 
        //return pRef;
        return null;        
    }
}