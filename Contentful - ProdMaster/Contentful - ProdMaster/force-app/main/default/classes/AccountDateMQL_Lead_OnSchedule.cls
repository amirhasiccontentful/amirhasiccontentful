global class AccountDateMQL_Lead_OnSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        AccountDateMQL_Lead_Batchable l = new AccountDateMQL_Lead_Batchable();
        database.executebatch(l,50);
    }
   
}