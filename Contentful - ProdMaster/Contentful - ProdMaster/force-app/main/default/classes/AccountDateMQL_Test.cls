@isTest
public class AccountDateMQL_Test {
	
    public static testMethod void testAccountMQLdate(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Test';
        ld.Company = 'Test';
        ld.LeadSource = 'App - Sign Up';
        ld.LeanData__Reporting_Matched_Account__c = acc.Id;
        ld.Date_MQL__c = system.today() - 1;
        insert ld;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        con.Date_MQL__c = system.today() - 2;
        
        insert con;
        
        Test.StartTest();
        	new AccountDateMQL_Lead_OnSchedule().execute(null);
        	new AccountDateMQL_Contact_OnSchedule().execute(null);
        Test.StopTest();
        
        List<Account> checkAccount = [SELECT Id, Date_Earliest_MQL__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(system.today() - 2, checkAccount[0].Date_Earliest_MQL__c);
    }
}