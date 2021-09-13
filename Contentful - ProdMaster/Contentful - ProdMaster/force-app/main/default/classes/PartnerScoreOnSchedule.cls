global class PartnerScoreOnSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        PartnerScore_Batchable b = new PartnerScore_Batchable();
        database.executebatch(b,50);
    }
   
}