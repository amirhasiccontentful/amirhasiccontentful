@isTest
private class CF_LeadIdleSchedulableTest {

    static testMethod void myUnitTest() {
        Test.startTest();
        System.schedule('CF_LeadIdleSchedulable', '0 0 0 * * ?', new CF_LeadIdleSchedulable());
        Test.stopTest();
    }
}