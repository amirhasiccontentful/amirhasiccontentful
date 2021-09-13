public with sharing class CF_OrganizationPeriscopeController {
    public CF_Organization__c organization; 
    public String getOrganizationPeriscopeDashboardUrl;
     
    public CF_OrganizationPeriscopeController(ApexPages.StandardController controller) {
        this.organization = (CF_Organization__c)controller.getRecord();
    }
    

    public String getOrganizationPeriscopeDashboardUrl() {
        return CF_Periscope.dashboardUrlForOrganization(organization);
    }

}