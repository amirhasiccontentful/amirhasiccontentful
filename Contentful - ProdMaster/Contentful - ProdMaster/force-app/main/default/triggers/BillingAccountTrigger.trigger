trigger BillingAccountTrigger on Zuora__CustomerAccount__c (before insert, before update, before delete, after insert, after update, after delete) {
	new BillingAccountTriggerHandler().run();
}