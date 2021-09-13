public with sharing class CF_SLA_EmailOpportunityDetail {

    public Id opportunityId {get;set;} 
    public String handoverRecordType {get;set;} 

    public Opportunity getOpportunityDetails()
    { 
        List<Opportunity> oppList = [SELECT Id, AccountId, Account.Name, Owner.Name, Account.CF_Customer_Success_Manager__c, Type, SLA_Name2__c,
                                            SLA_Sev_1_Response_Time__c, SLA_Sev_2_Response_Time__c, SLA_Sev_3_Response_Time__c, 
                                            Account.Zendesk_Organization__c, Account.Zendesk_SLA_Support_Plan__c,
                                            (SELECT Email_domains__c, Additional_email_domains__c
                                             FROM Handovers__r 
                                             WHERE RecordType.Name = :handoverRecordType)
                                     FROM Opportunity 
                                     WHERE Id =: opportunityId];
        return oppList.size() > 0 ? oppList[0] : null;
    }

}