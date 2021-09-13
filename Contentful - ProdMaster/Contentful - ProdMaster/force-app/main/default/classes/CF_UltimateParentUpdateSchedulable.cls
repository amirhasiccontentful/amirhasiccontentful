global class CF_UltimateParentUpdateSchedulable implements Schedulable
{
    global void execute(SchedulableContext ctx) 
    {
        Database.executeBatch(new CF_UltimateParentUpdateBatchable(), 200);
    }
}