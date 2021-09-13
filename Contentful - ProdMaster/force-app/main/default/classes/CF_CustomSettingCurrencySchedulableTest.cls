@isTest
private class CF_CustomSettingCurrencySchedulableTest {
    static testMethod void test() {
        Test.startTest();
        
        //System.schedule('CF_CustomSettingCurrencySchedulable', '0 0 0 * * ?', new CF_CustomSettingCurrencySchedulable());
        CF_CustomSettingCurrencySchedulable.updateExchangeRates();
        Test.stopTest();
    }        
}