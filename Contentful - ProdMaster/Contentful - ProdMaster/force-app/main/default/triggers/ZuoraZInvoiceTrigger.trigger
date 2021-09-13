trigger ZuoraZInvoiceTrigger on Zuora__ZInvoice__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ZuoraZInvoiceTriggerHandler().run();
}