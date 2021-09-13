@isTest
public class PartnerDealsTriggerHandler_Test {

    @isTest static void TEST_SetClientIdOnOpportunityChange_Insert() {
        //Arrange
        Account account = TestDataFactory.CreateAccount();
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);   
        Opportunity opportunity = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null, 'Inbound');

        //Act 
        Partner_Deals__c partnerDeal = TestDataFactory.CreatePartnerDeal(opportunity.Id, account.Id, null, 'Partner Sourced');

        //Assert   
        List<Partner_Deals__c> pdList = [SELECT Id, Client_Account__c, Opportunity_Name__r.AccountId FROM Partner_Deals__c];
        System.assertEquals(pdList[0].Client_Account__c, pdList[0].Opportunity_Name__r.AccountId);   
    }

    @isTest static void TEST_SetClientIdOnOpportunityChange_Update() {
        //Arrange
        Account account = TestDataFactory.CreateAccount();
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);   
        Opportunity opportunity = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null, 'Inbound');

        //Act 
        Partner_Deals__c partnerDeal = TestDataFactory.CreatePartnerDeal(opportunity.Id, account.Id, null, 'Partner Sourced');
        Partner_Deals__c partnerDeal2 = TestDataFactory.CreatePartnerDeal(null, account.Id, null, 'Partner Sourced');

        //Assert   
        List<Partner_Deals__c> pdList = [SELECT Id, Client_Account__c, Opportunity_Name__c, Opportunity_Name__r.AccountId FROM Partner_Deals__c];
        
        for(Partner_Deals__c dbPD : pdList) {
            if(dbPD.Opportunity_Name__c != null) {
                System.assertEquals(dbPD.Client_Account__c, dbPD.Opportunity_Name__r.AccountId);   
            }

            if(dbPD.Opportunity_Name__c == null) {
                System.assertEquals(null, dbPD.Client_Account__c);   
            }
        }

    }
    
    @isTest static void TEST_NewPartnerDealsCreation() {
        //Arrange
        Account account = TestDataFactory.CreateAccount();
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);   
        Opportunity opportunity = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null, 'Inbound');

        //Act 
        Partner_Deals__c partnerDeal = TestDataFactory.CreatePartnerDeal(opportunity.Id, account.Id, account.Id, 'Partner Sourced');

        //Assert   
        List<Opportunity> oppList = [SELECT Id, Pipeline_Source__c FROM Opportunity];
        System.assertEquals('Partnerships', oppList[0].Pipeline_Source__c);   
    }

    @isTest static void TEST_PartnerDealsUpdates_1() {
        //Arrange
        Account account = TestDataFactory.CreateAccount();
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);   
        Opportunity opportunity = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null, 'Inbound');
        Partner_Deals__c partnerDeal = TestDataFactory.CreatePartnerDeal(opportunity.Id, account.Id, account.Id, 'Partner Introduced');

        //Act 
        partnerDeal.Partner_Customer_Relationship_Type__c = 'Partner Sourced';
        update partnerDeal;

        //Assert   
        List<Opportunity> oppList = [SELECT Id, Pipeline_Source__c FROM Opportunity];
        System.assertEquals('Partnerships', oppList[0].Pipeline_Source__c);   
    }

    @isTest static void TEST_PartnerDealsUpdates_2() {
        //Arrange
        Account account = TestDataFactory.CreateAccount();
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);   
        Opportunity opportunity = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null, 'Inbound');
        Partner_Deals__c partnerDeal = TestDataFactory.CreatePartnerDeal(opportunity.Id, account.Id, account.Id, 'Partner Sourced');

        //Act 
        partnerDeal.Partner_Customer_Relationship_Type__c = 'Partner Introduced';
        update partnerDeal;

        //Assert   
        List<Opportunity> oppList = [SELECT Id, Pipeline_Source__c FROM Opportunity];
        System.assertEquals('Inbound', oppList[0].Pipeline_Source__c);   
    }

    @isTest static void TEST_PartnerDealsUpdates_3() {
        //Arrange
        Account account = TestDataFactory.CreateAccount();
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);   
        Opportunity opportunity = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null, 'Inbound');
        Opportunity opportunity2 = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null, 'Inbound');

        Partner_Deals__c partnerDeal = TestDataFactory.CreatePartnerDeal(opportunity.Id, account.Id, account.Id, 'Partner Sourced');

        //Act 
        partnerDeal.Opportunity_Name__c = opportunity2.Id;
        update partnerDeal;

        //Assert   

        List<Opportunity> oppList = [SELECT Id, Pipeline_Source__c FROM Opportunity WHERE Pipeline_Source__c = 'Partnerships'];
        System.assertEquals(1, oppList.size());   
    }

    @isTest static void TEST_PartnerDealsDeletion() {
        //Arrange
        Account account = TestDataFactory.CreateAccount();
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);   
        Opportunity opportunity = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null, 'Inbound');
        Partner_Deals__c partnerDeal = TestDataFactory.CreatePartnerDeal(opportunity.Id, account.Id, account.Id, 'Partner Sourced');

        //Act 
        delete partnerDeal;

        //Assert   
        List<Opportunity> oppList = [SELECT Id, Pipeline_Source__c FROM Opportunity];
        System.assertEquals('Inbound', oppList[0].Pipeline_Source__c);    
    } 

    @isTest static void TEST_PartnerDealsUndeletion() {
        //Arrange
        Account account = TestDataFactory.CreateAccount();
        Contact primaryContact = TestDataFactory.CreateContact(account.Id);   
        Opportunity opportunity = TestDataFactory.CreateOpportunity(account.Id, primaryContact.Id, null, 'Inbound');
        Partner_Deals__c partnerDeal = TestDataFactory.CreatePartnerDeal(opportunity.Id, account.Id, account.Id, 'Partner Sourced');

        //Act 
        delete partnerDeal;
        undelete partnerDeal;

        //Assert   
        List<Opportunity> oppList = [SELECT Id, Pipeline_Source__c FROM Opportunity];
        System.assertEquals('Partnerships', oppList[0].Pipeline_Source__c);   
    } 
}