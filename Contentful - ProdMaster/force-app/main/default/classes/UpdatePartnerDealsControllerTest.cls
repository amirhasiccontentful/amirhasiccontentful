@isTest
public class UpdatePartnerDealsControllerTest {

    static testMethod void testMultipleMethod() {
        Account newAccount = new Account();
        newAccount.Name = 'Test Name';
        newAccount.Website = 'www.test.com';
        
        insert newAccount;
        
        Contact newContact = new Contact();
        newContact.AccountId = newAccount.Id;
        newContact.LastName = 'Test Contact Last Name';
        newContact.LeadSource = 'Referral';
        insert newContact;
        
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.StageName = 'Discovery';
        newOpportunity.Name = 'Test Opportunity Name';
        newOpportunity.CloseDate = Date.newInstance(2019, 7, 11);
        newOpportunity.LeadSource = 'Signup Role';
        newOpportunity.Type = 'Initial';
        newOpportunity.Amount = 1;
        newOpportunity.Primary_Contact__c = newContact.Id;
        newOpportunity.Project_Name__c = 'Test';
        newOpportunity.LeadSource = 'Sales Generated';
        
        
        insert newOpportunity;
        
        Partner_Deals__c newPartnerDeals = new Partner_Deals__c();
        newPartnerDeals.Partner_Customer_Relationship_Type__c = 'Partner Sourced';
        newPartnerDeals.Opportunity_Name__c = newOpportunity.id;
        newPartnerDeals.Partner_Account__c = newAccount.Id;
        
		newPartnerDeals.Influenced_Field__c = 1;        
        insert newPartnerDeals;
        
        UpdatePartnerDealsController muscoController = new UpdatePartnerDealsController();
        
        muscoController.getNewPartnerDeals();
        muscoController.save();
        UpdatePartnerDealsController.updateInfluencedDeals(newOpportunity.Id, -50, 'Test Test');
        UpdatePartnerDealsController.updateInfluencedDeals(newOpportunity.Id, 101, 'Test Test');
    }

}