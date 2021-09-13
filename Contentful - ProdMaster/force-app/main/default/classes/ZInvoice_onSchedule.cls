global class ZInvoice_onSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        ZuoraInvoice_Batchable c = new ZuoraInvoice_Batchable();
        database.executebatch(c,Integer.valueOf(Label.ZInvoiceBatchSize));
    }
}