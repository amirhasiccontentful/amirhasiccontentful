/*
Use this to schedule the cleanup job:

System.schedule('Lead Idle Cleanup', '0 0 * * * ?', new CF_LeadIdleSchedulable());

*/

global class CF_LeadIdleSchedulable implements Schedulable
{
    global void execute(SchedulableContext ctx) 
    {   	
        Database.executeBatch(new CF_LeadIdleBatchable(), 200);
    } 
}