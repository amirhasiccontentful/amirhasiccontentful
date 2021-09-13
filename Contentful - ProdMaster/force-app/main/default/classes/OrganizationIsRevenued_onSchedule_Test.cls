@isTest
public class OrganizationIsRevenued_onSchedule_Test {
    
    public static testMethod void testIsRevenuedFlag(){
        
        zqu__ZProduct__c  newZProduct = new zqu__ZProduct__c();
        newZProduct.Name = 'Test';
        insert newZProduct;
        
        zqu__ProductRatePlan__c  newProductRatePlan = new zqu__ProductRatePlan__c ();
        newProductRatePlan.Name = 'TEST';
        newProductRatePlan.zqu__ZProduct__c  = newZProduct.Id;
        newProductRatePlan.PlanType__c = '';
        insert newProductRatePlan;
        
        Account newAccount = new Account();
        newAccount.Name = 'TEST';
        insert newAccount;
        
        CF_Organization__c cfOrg = new CF_Organization__c(Name = 'test', gk_Name__c = 'test', gk_key__c = '123456789', gk_id__c = 123, Account__c = newAccount.Id);
		insert cfOrg;
        
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__Account__c = newAccount.Id, organization_key__c = '123456789');
		insert billingAccount;
        
        Zuora__Subscription__c newZuoraSubsription = new Zuora__Subscription__c ();
        newZuoraSubsription.Name = 'TEST';
        newZuoraSubsription.Zuora__Account__c = newAccount.Id;
        newZuoraSubsription.Zuora__MRR__c = 1000;
        newZuoraSubsription.Zuora__Status__c = 'Active';
        newZuoraSubsription.Zuora__CustomerAccount__c = billingAccount.Id;
        newZuoraSubsription.Primary_Product_Rate_Plan__c = newProductRatePlan.Id;
        insert newZuoraSubsription;
        
        
		Test.startTest();
        	new OrganizationIsRevenued_onSchedule().execute(null);
        Test.stopTest();
        
        List<CF_Organization__c> checkOrg = [SELECT Id, mrr_0__c FROM CF_Organization__c WHERE Id = :cfOrg.Id];
        System.assertEquals(true, checkOrg[0].mrr_0__c);
        
        
    }
}