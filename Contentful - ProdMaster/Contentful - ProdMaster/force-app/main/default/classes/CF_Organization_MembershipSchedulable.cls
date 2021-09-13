// Regularly check that there's no null relationships 
/*
Use this to schedule the cleanup job of contacts created by Zendesk every 15 minutes

System.schedule('CF_Organization_MembershipSchedulable', '0 0 * * * ?', new CF_Organization_MembershipSchedulable());

*/ 

global class CF_Organization_MembershipSchedulable implements Schedulable {
    global void execute(SchedulableContext ctx)  {   	 
        Database.executeBatch(new CF_Organization_MembershipBatchable(), 200);
    } 
}