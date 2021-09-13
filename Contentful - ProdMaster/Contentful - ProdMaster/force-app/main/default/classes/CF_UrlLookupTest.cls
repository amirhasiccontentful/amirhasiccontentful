@isTest
private class CF_UrlLookupTest {
    static testMethod void testUpdateLookupWithJson() {
    	Map<String, Object> j = (Map<String, Object>)JSON.deserializeUntyped('{"value": 1}');
    	CF_UrlLookup__c l = new CF_UrlLookup__c();
    	CF_UrlLookup.updateLookupWithJson(j, l);
    }
    
    static testMethod void testInit() {
    	String url = 'http://test.com';
    	CF_UrlLookup__c l = new CF_UrlLookup__c();
    	CF_UrlLookup.initLookup(l, url);
    }       
}