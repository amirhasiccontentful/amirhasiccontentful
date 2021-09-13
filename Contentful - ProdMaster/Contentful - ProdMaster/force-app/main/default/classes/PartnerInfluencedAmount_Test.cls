@isTest
public class PartnerInfluencedAmount_Test {
	
    public static testMethod void testPartnerInfluence(){
      
        Account acc = new Account();
        acc.Name = 'Test Partner';
        acc.Classification__c = 'Agency';
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'Test Client';
        insert acc2;
        
        Contact newContact = new Contact();
        newContact.AccountId = acc.Id;
        newContact.LastName = 'Test Contact Last Name';
        newContact.LeadSource = 'Referral';
        insert newContact;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.Stagename = 'Qualification';
        opp.AccountId = acc2.Id;
        opp.CloseDate = System.today();
        opp.Primary_Contact__c = newContact.Id;
        opp.Project_Name__c = 'Test';
        opp.LeadSource = 'Sales Generated';
        insert opp;
        
        Partner_Deals__c deal = new Partner_Deals__c();
        deal.Opportunity_Name__c = opp.Id;
        deal.Partner_Account__c  = acc.Id;
        deal.Client_Account__c  = acc2.Id;
        deal.Partner_Customer_Relationship_Type__c = 'Partner Sourced';
        insert deal;
        
        Test.startTest();
         	new PartnerInfluenceAmount_onSchedule().execute(null); 
        Test.stopTest();
    }
}