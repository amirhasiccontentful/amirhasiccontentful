@isTest
private class CF_CurrencyConverterTest {

    static testMethod void testConvertToOrgCurrency() {
    	Decimal input = 1.0;
    	String inputCurrency = 'EUR';
    	Date dayOfConversion = Date.today();
    	
        Decimal result = CF_CurrencyConverter.convertToOrgCurrency(inputCurrency, input, dayOfConversion);
        System.assertNotEquals(result, input);
    }
    
    static testMethod void testConvertFromOrgCurrency() {
    	Decimal input = 1.0;
    	String inputCurrency = 'EUR';
    	Date dayOfConversion = Date.today();
    	
        Decimal result = CF_CurrencyConverter.convertFromOrgCurrency(inputCurrency, input, dayOfConversion);
        System.assertNotEquals(result, input);    	
    }
}