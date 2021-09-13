trigger DocuSignStatusTrigger on dsfs__DocuSign_Status__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new DocuSignStatusTriggerHandler().run();
}