@isTest
private class CF_PeriscopeTest {

    static testMethod void myUnitTest() {
    	CF_Organization__c org = CF_OrganizationTest.testObject();
		CF_Periscope.dashboardUrlForOrganization(org);
    }
}