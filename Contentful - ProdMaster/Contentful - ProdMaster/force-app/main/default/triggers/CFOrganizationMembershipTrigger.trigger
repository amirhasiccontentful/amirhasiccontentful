trigger CFOrganizationMembershipTrigger on CF_Organization_Membership__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new CFOrganizationMembershipTriggerHandler().run();
}