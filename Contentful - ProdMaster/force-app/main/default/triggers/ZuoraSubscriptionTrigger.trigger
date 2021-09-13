trigger ZuoraSubscriptionTrigger on Zuora__Subscription__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new ZuoraSubscriptionTriggerHandler().run();
}