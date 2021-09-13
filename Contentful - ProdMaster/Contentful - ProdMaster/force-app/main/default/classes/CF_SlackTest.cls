@isTest
private class CF_SlackTest {

    static testMethod void testObjectUrl() {
    	Account account = new Account(Name = 'Company');
    	insert account;
    	
        CF_Slack.objectUrl(account.id);
    }
    
    static testMethod void testObjectLink() {
    	Account account = new Account(Name = 'Company');
    	insert account;
    	
        CF_Slack.objectLink(account.id, 'Text');
    }    
    
    static testMethod void testIsSandbox() {
        CF_Slack.isSandbox();
    }        
}