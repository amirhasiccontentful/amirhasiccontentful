@isTest
private class CF_OpportunityStatsTriggerTest {

    static testMethod void test() {
		Contact c = new Contact();
		c.firstname = 'firstname';
		c.lastname = 'lastname';
		c.email = 'test@asdf.com';
		
		insert c;
		    	
    	
		Account a = new Account();
		a.name = 'testasdf';
		insert a;
		
		Opportunity opp=new Opportunity(Name='Doe', CloseDate=Date.today() + 1, StageName='Analysis');
		opp.RecordTypeId = [Select Id, SobjectType, Name From RecordType Where DeveloperName ='Enterprise_Expand' and SobjectType ='Opportunity'  limit 1].Id;
		opp.accountid = a.id;
		
		insert opp;  
		
		opp.description = 'Changed';
		opp.CloseDate=Date.today() + 2;
		opp.amount = 123.00;
		
		update opp;                   
    }
    
  /*  static testMethod void opportunityClose() {
        Profile p = [SELECT Id FROM Profile WHERE Name='CF - Account Management']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');

    	u.alias = 'alias';
    	u.profileid = p.id;
    	u.email = 'test@test.de';
    	u.username = 'test@tasdfest.de';
    	u.firstname = 'test';
    	u.lastname = 'test';
    	
    	insert u;
    	
    	
		Contact c = new Contact();
		c.firstname = 'firstname';
		c.lastname = 'lastname';
		c.email = 'test@asdf.com';
		
		insert c;
		    	
    	
		Account a = new Account();
		a.name = 'testasdf';
		a.CF_Customer_Success_Manager__c = u.id;
		insert a;
		
		Opportunity opp=new Opportunity(Name='Doe', CloseDate=Date.today() + 1, StageName='Analysis');
		opp.RecordTypeId = [Select Id, SobjectType, Name From RecordType Where Name ='Enterprise - Expand' and SobjectType ='Opportunity'  limit 1].Id;
		opp.accountid = a.id;
		
		insert opp;  
		
		zqu__Quote__c quote = new zqu__Quote__c();
		quote.name = 'quote';
		quote.Acceptance_Status__c = 'Accepted';
		quote.zqu__Opportunity__c = opp.id;
		
		insert quote;
		
		opp.Current_Quote__c = quote.id;
		opp.enterprise_product__c = 'Enterprise SMB';
		opp.se_technical_risk__c = 'Low';
		opp.stagename = 'Closed Won';
		opp.description = 'Changed Changed Changed Changed Changed Changed Changed Changed Changed Changed Changed Changed Changed Changed ';
		opp.CloseDate=Date.today() + 2;
		opp.amount = 123.00;
		opp.amount_services__c = 0;
		opp.Use_Case__c = 'Application Add-On';
		opp.Project_Significance__c = 'Core';
		
		
		update opp;          	
    }*/
}