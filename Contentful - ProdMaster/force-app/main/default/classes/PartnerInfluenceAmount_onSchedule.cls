global class PartnerInfluenceAmount_onSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        PartnerInfluencedAmount b = new PartnerInfluencedAmount();
        database.executebatch(b,200);
    }
   
}