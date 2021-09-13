@isTest
public class CampaignMemberTriggerHandler_Test {
	
    @isTest static void TEST_LeadAndContactMemberOfCampaign(){

        //Arrange
        Campaign newCampaign = new Campaign(Name = 'Test MK Campaign', Department__c = 'Partnership');
        insert newCampaign;
        
        Lead newLead = new Lead(Company = 'Test Company', LastName = 'LastName', LeadSource = 'Website Direct', Email = 'test@test.test');
        insert newLead;

        Account acc = new Account(Name = 'Test Acc'); 
        insert acc;
        
        Contact newCon = new Contact(LastName = 'Test last', AccountId = acc.Id);
        insert newCon;

        //Act
        CampaignMember cm = new CampaignMember(LeadId = newLead.Id, CampaignId = newCampaign.Id);
       	insert cm;

        CampaignMember cm2 = new CampaignMember(ContactId = newCon.Id, CampaignId = newCampaign.Id);
        insert cm2;

        //Assert
        List<Contact> allContacts = [SELECT Id, Member_of_Campaign__c FROM Contact];
        List<Lead> allLeads = [SELECT Id, Member_of_Campaign__c FROM Lead];

        System.assertEquals(true, allContacts[0].Member_of_Campaign__c);
        System.assertEquals(true, allLeads[0].Member_of_Campaign__c);
	}
    
}