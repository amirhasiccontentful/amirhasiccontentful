@isTest
private class CF_SetUltimateParentUpdateSchedulTest {
    static testMethod void test() {
        Test.startTest();
        System.schedule('CF_UltimateParentUpdateSchedulable', '0 0 0 * * ?', new CF_UltimateParentUpdateSchedulable());
        Test.stopTest();
    }        
}