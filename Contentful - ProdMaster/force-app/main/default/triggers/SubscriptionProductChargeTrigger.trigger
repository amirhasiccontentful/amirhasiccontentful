trigger SubscriptionProductChargeTrigger on Zuora__SubscriptionProductCharge__c (before insert, before update, before delete, after insert, after update, after delete)  { 
	new SubscriptionProductChargeTriggerHandler().run();
}