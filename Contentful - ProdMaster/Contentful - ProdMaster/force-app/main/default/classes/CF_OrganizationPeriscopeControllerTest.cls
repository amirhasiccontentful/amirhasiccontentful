@isTest
private class CF_OrganizationPeriscopeControllerTest {

    static testMethod void testController(){
    	CF_Organization__c org = CF_OrganizationTest.testObject();
    	insert org;

	    ApexPages.StandardController sc = new ApexPages.standardController(org);
    	CF_OrganizationPeriscopeController e = new CF_OrganizationPeriscopeController(sc);
    	
    	System.assertEquals(e.organization, org); 

		e.getOrganizationPeriscopeDashboardUrl();
    }
}