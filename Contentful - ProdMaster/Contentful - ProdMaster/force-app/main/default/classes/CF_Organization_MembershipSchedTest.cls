@isTest
private class CF_Organization_MembershipSchedTest {
    static testMethod void test() {
        Test.startTest();
        CF_Organization_Membership__c om = new CF_Organization_Membership__c();
        om.gk_user_id__c = 123;
        om.gk_organization_id__c = 456;
        om.gk_key__c = 'key';
        om.gk_id__c = 1;
        insert om;
        
        System.schedule('CF_Organization_MembershipSchedulable', '0 0 0 * * ?', new CF_Organization_MembershipSchedulable());
        Test.stopTest();
    }        
}