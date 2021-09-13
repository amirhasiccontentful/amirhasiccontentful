trigger CFOrganizationTrigger on CF_Organization__c (before insert, before update, before delete, after insert, after update, after delete) {
	Utility.IsExecutedFromCFUserOrOrg = true;
	new CFORganizationTriggerHandler().run();
}