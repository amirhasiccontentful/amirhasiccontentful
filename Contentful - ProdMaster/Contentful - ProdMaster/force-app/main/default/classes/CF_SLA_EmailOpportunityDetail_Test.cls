@isTest 
public class CF_SLA_EmailOpportunityDetail_Test {

    @isTest
    public static void Test_OppDetails(){

        //Arrange
        Account account = TestDataFactory.CreateAccount();
        Contact con = TestDataFactory.CreateContact(account.Id, 'Test LastName', 'test@contentful.com');
        Opportunity opp = TestDataFactory.CreateOpportunity(account.Id, con.Id);
        Handover__c handover = TestDataFactory.CreateHandover(opp.Id, account.Id, 'Sales-CS Handover');

        //Act 
        CF_SLA_EmailOpportunityDetail controller = new CF_SLA_EmailOpportunityDetail();
        controller.opportunityId = opp.Id;
        controller.handoverRecordType = 'Sales-CS Handover';

        //Assert   
        System.assertNotEquals(null, controller.getOpportunityDetails());  
    }
}