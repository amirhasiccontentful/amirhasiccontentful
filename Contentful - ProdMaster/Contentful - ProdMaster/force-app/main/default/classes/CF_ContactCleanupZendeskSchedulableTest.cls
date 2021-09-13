@isTest
private class CF_ContactCleanupZendeskSchedulableTest {
    static testMethod void test() {
        Test.startTest();
        System.schedule('CF_ContactCleanupZendeskSchedulableTest', '0 0 0 * * ?', new CF_ContactCleanupZendeskSchedulable());
        Test.stopTest();
    }        
}