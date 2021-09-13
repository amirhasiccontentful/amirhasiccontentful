global class AccountDateMQL_Contact_OnSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        AccountDateMQL_Contact_Batchable c = new AccountDateMQL_Contact_Batchable();
        database.executebatch(c,50);
    }
   
}