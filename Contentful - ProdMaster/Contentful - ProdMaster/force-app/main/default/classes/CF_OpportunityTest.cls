@isTest 
public with sharing class CF_OpportunityTest {
	public static Opportunity testObject() {
	   Account acc = new Account();
	   acc.name = 'Account';
	   insert acc;
		
	   Opportunity opp = new Opportunity();
		opp.name = 'name';
		opp.stagename = 'Discovery';
		opp.accountId = acc.id;
		//opp.ownerId = oldOpp.ownerId;
		opp.description = 'description';
		opp.closedate = system.today().addDays(30);
       
       return opp; 
	}
		
/*    static testMethod void testReopenOpportunity() {      
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
    	    	 
       Opportunity opp = CF_OpportunityTest.testObject();
       opp.ownerid = u.id;
       insert opp;
       
       Opportunity newOpp = CF_Opportunity.reopenOpportunity(opp);
       
       System.assertNotEquals(newOpp.id, opp.id) ;
       System.assertEquals(opp.id, newOpp.previous_opportunity__c);
    }*/
}