@isTest
public class ContentfulCertifiedProfessionals_Test {
	
    public static testMethod void testCertifiedPartnerCount(){
        
        Account acc = new Account(Name = 'Test Partner');
        insert acc;
        
        Contact con1 = new Contact(FirstName = 'Test1', LastName = 'Test1', Email = 'test1@partner.test', AccountId = acc.Id, Certified__c = true);
        insert con1;
        
        Contact con2 = new Contact(FirstName = 'Test2', LastName = 'Test2', Email = 'test2@partner.test', AccountId = acc.Id);
        insert con2;
        
        Test.startTest();
         	new ContCertifiedProfessional_onSchedule().execute(null); 
        Test.stopTest();
        
        List<Account> checkCertified = [SELECT Id, Contentful_Certified_Professionals_CCP__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1, checkCertified[0].Contentful_Certified_Professionals_CCP__c);
    }
}