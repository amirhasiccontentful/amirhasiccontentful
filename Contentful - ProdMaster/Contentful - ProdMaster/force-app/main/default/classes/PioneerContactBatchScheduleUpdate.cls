global class PioneerContactBatchScheduleUpdate implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        PioneerContact_Batchable b = new PioneerContact_Batchable();
        database.executebatch(b,50);
    }
   
}