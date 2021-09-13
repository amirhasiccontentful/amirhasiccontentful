global class ContCertifiedProfessional_onSchedule implements Schedulable {
	
    global void execute(SchedulableContext sc)
    {
        ContentfulCertifiedProfessionals b = new ContentfulCertifiedProfessionals();
        database.executebatch(b,200);
    }
}