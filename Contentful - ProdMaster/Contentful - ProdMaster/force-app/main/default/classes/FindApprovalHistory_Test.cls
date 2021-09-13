@isTest
public class FindApprovalHistory_Test {
    
    private static testMethod void test_method_one() {
		
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test Contact';
		insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Discovery';
        opp.Amount = 1000;
        opp.LeadSource = 'App - Sign Up';
        opp.Primary_Contact__c = con.Id;
        insert opp;
        
		FindApprovalHistory apHistory = new FindApprovalHistory();
        apHistory.opportunityId = opp.Id;
        apHistory.getGeneratedApprovalHistory();
        
        system.assertEquals(new List<ProcessInstance>(), apHistory.generatedApprovalHistory);
	}
}