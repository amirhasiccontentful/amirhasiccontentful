@isTest
private class CF_ZendeskTicketEmailTriggerTest {

    static testMethod void myUnitTest() {
    	Contact contact = new Contact(Lastname = 'Lastname', Email = 'test@email.com');
    	insert contact;
    	
        Zendesk__Zendesk_Ticket__c ticket = new Zendesk__Zendesk_Ticket__c(Zendesk__Requester__c = contact.id);
        insert ticket;
        
    }
}