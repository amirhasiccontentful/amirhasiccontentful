@isTest(SeeAllData=true)
public class SubscriptionProductChargeTriggerH_Test { 
	// Code coverage
	@isTest static void TEST_PopulateSubscriptionCustomFields_CodeCoverage() {
		List<Zuora__SubscriptionProductCharge__c> subPCList = [SELECT id FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__UOM__c = null AND Zuora__Type__c = 'Recurring' LIMIT 20];
		if(!subPCList.isEmpty())
			update subPCList;
        
        Zuora__SubscriptionProductCharge__c testInsert = new Zuora__SubscriptionProductCharge__c();
        insert testInsert;

	}
}