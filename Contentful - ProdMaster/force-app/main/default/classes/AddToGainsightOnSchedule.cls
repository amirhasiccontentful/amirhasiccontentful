global class AddToGainsightOnSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        AddToGainsight_Batchable b = new AddToGainsight_Batchable();
        database.executebatch(b,50);
    }
   
}