trigger ZuoraQuoteTrigger on zqu__Quote__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ZuoraQuoteTriggerHandler().run();
}