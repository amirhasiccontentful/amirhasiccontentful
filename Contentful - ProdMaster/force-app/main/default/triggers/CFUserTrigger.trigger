trigger CFUserTrigger on CF_User__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 
	Utility.IsExecutedFromCFUserOrOrg = true;
	new CFUserTriggerHandler().run();
}