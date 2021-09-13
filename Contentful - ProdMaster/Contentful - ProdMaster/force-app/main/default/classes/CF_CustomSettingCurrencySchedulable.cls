/*
Use this to schedule the automatic job to save currency rates to custom settings to be used in formulas

System.schedule('CF_CustomSettingCurrencySchedulable', '0 0 * * * ?', new CF_CustomSettingCurrencySchedulable());

*/

global class CF_CustomSettingCurrencySchedulable implements Schedulable 
{
    global void execute(SchedulableContext ctx) 
    {   	
		CF_CustomSettingCurrencySchedulable.updateExchangeRates();
    }
    
    global static void updateExchangeRates() {
        List<CurrencyType> conversionRates = [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE];
        
        CF_Currency_Rate__c customSetting = CF_Currency_Rate__c.getOrgDefaults();
        
        for (CurrencyType rate : conversionRates) {
        	String key = rate.ISOCode + 'toUSD__c';
        	customSetting.put(key, 1.0 / rate.ConversionRate);
        }
        
        if (Test.isRunningTest() == false) { // cannot update settings in test
        	update customSetting;	
        }
            	
    }
}