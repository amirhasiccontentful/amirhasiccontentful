@isTest
public with sharing class CF_Base_Test {

    static testMethod void testController(){
    	CF_Base.filterDomains('test');
    	CF_Base.filterCompanyName('test');
    	CF_Base.isGenericCompanyName('test');
    	CF_Base.isPublicDomain('test');
    	
    	
    }
    
    static testMethod void testFormatCurrency() {
    	CF_Base.formatCurrency('USD', 1.00);
    }

    static testMethod void testTaskForOrder() {
     
		Account account = TestDataFactory.CreateAccount(true);
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);  
        Opportunity opp = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null); 
    
    	Order ord = new Order();	
    	ord.AccountId = account.Id;
        ord.EffectiveDate = system.today();
        ord.Status = 'Draft';
		ord.Dhruvsoft__Opportunity__c = opp.id;

    	insert ord;
    	
    	Id ownerId = UserInfo.getUserId();
    
    	Task t = CF_Base.taskForOrder('subject', 'description', 'Account Management', ord, ownerId, null);
    }
 
	//Commented out due to Ticket BIZSYS-112
	/*
     static testMethod void testEmails() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      	User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
      		EmailEncodingKey='UTF-8', LastName='SalesForce Bot', LanguageLocaleKey='en_US', 
      		LocaleSidKey='en_US', ProfileId = p.Id, 
      		TimeZoneSidKey='America/Los_Angeles', UserName='standardasdfuser1234@testorg4.com'); 
      	insert u;
      	    	
      	System.runAs(u) {
  			Account a = new Account();
    		a.name = 'Account';
    		a.ownerid = u.id;
    		insert a;
        
        	List<sObject> newObj = new List<sObject>();
        	newObj.add(a);
        	
        	List<String> fieldNames = new List<String>{'OwnerId', 'CF_Customer_Success_Manager__c', 'Sales_Manager__c', 'Product_Expert__c', 'Prospecting_Manager__c'};
        	
			CF_Base.sendOwnerChangeEmails('Account', null, newObj, fieldNames);
      	
      	}   
     }   
	 */
    
}