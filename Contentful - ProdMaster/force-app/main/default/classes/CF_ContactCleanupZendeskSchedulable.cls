/*
Use this to schedule the cleanup job of contacts created by Zendesk every 15 minutes

System.schedule('Zendesk Contact Cleanup: *:00', '0 0 * * * ?', new CF_ContactCleanupZendeskSchedulable());
System.schedule('Zendesk Contact Cleanup: *:15', '0 15 * * * ?', new CF_ContactCleanupZendeskSchedulable());
System.schedule('Zendesk Contact Cleanup: *:30', '0 30 * * * ?', new CF_ContactCleanupZendeskSchedulable());
System.schedule('Zendesk Contact Cleanup: *:45', '0 45 * * * ?', new CF_ContactCleanupZendeskSchedulable());

*/

global class CF_ContactCleanupZendeskSchedulable implements Schedulable
{
    global void execute(SchedulableContext ctx) 
    {   	
        Database.executeBatch(new CF_ContactCleanupZendeskBatchable(), 200);
    }
}