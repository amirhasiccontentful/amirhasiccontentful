@isTest
public with sharing class CF_CustomAccountControllerTest {
    static testMethod void testController(){
    	CF_Organization__c org = CF_OrganizationTest.testObject();
    	insert org;
	
		
		Test.startTest();
		
  		RestRequest req = new RestRequest(); 
   		RestResponse res = new RestResponse();
         
   		req.requestURI = '/services/apexrest/cf/CustomAccount';  //Request URL
   		req.httpMethod = 'POST';//HTTP Request Type
   		req.requestBody = Blob.valueof('{"organizationKey": "' + org.gk_key__c + '"}');
   		RestContext.request = req;
   		RestContext.response= res;
		
		CF_CustomAccountController.post(org.gk_key__c);
		
		Test.stopTest();
    }

    static testMethod void testControllerMissingOrg(){		
		Test.startTest();
		
  		RestRequest req = new RestRequest(); 
   		RestResponse res = new RestResponse();
         
   		req.requestURI = '/services/apexrest/cf/CustomAccount';  //Request URL
   		req.httpMethod = 'POST';//HTTP Request Type
   		req.requestBody = Blob.valueof('{"organizationKey": "' + 123 + '"}');
   		RestContext.request = req;
   		RestContext.response= res;
		
		CF_CustomAccountController.post('123');
		
		Test.stopTest();
    }

}