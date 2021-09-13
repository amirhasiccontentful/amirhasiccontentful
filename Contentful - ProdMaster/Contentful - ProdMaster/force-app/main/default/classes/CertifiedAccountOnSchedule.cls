global class CertifiedAccountOnSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        CertifiedAccount_Batchable b = new CertifiedAccount_Batchable();
        database.executebatch(b,100);
    }
   
}