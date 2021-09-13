trigger PartnerDeals on Partner_Deals__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new PartnerDealsTriggerHandler().run();
}