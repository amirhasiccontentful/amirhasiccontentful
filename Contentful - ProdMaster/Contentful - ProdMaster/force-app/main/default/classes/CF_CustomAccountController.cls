// Custom endpoint used by Gatekeeper to fetch a SF Account Id that can be passed on to Zuora 
// available via POST:
// staging: https://cs18.salesforce.com/services/apexrest/cf/CustomAccount
// production: https://eu3.salesforce.com/services/apexrest/cf/CustomAccount
// body: {"organizationKey": "2HBH5Hv6Golga4DKfUrKxc"}
// response: {"account": {"id": 00111000018ihZ3AAI}}

@RestResource(urlMapping='/cf/CustomAccount/*')
global with sharing class CF_CustomAccountController {
    public CF_CustomAccountController(ApexPages.StandardController controller) {
        
    }

   @HttpPost
    global static void post(String organizationKey) {
    	RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        String jsonResponse = '';
        CF_Organization__c org;
        id accountId;
        Account account;
        
        // error handling
        if (organizationKey == null) {
        	jsonResponse = '{"error": {"status": "Failure", "message": "MissingRequiredQueryParameter organizationKey"}}';
        	res.statusCode = 400;
        	res.responseBody = blob.valueOf(jsonResponse);
        	return;        	
        }
        
        // try to find an existing account for the CF Organization
        
        List<CF_Organization__c>orgs = [SELECT id, gk_name__c, account__c FROM CF_Organization__c WHERE gk_key__c = :organizationKey];
        
        if (orgs.size() > 0) {
        	org = orgs[0];
        }
        
        if (org == null) {
        	jsonResponse = '{"error": {"status": "Failure", "message": "MissingOrganization organizationKey"}}';
        	res.statusCode = 404;
        	res.responseBody = blob.valueOf(jsonResponse);
        	return;              	
        }
        
        if (org.account__c != null) { // org already has an account
        	accountId = org.account__c;
        }
        else { // create an account if it doesn't exist and associate org with account
        	List<Account> accounts = CF_Organization.createAccountsAndContactsForOrganizations(orgs, true);
        	
        	if (accounts.size() > 0) {
        		accountId = accounts[0].id;
        	}
        }
        
		// return the account id
		res.statusCode = 200;
		jsonResponse = '{"account": {"id": "'+ accountId +  '"}}';
		res.responseBody = blob.valueOf(jsonResponse);
    }

}