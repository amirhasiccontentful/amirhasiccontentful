global class GainsightLeadUsageRollups_Scheduled implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        GainsightLeadUsageRollups_Batchable b = new GainsightLeadUsageRollups_Batchable();
        database.executebatch(b,100);
    }
}