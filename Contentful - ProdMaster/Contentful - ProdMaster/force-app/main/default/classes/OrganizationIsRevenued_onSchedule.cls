global class OrganizationIsRevenued_onSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        OrganizationIsRevenued_Batchable b = new OrganizationIsRevenued_Batchable();
        database.executebatch(b,50);
    }
   
}