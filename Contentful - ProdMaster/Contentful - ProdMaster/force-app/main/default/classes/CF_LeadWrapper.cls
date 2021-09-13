public with sharing class CF_LeadWrapper {

    public Boolean checked{ get; set; }
    public Lead lead { get; set;}

    public CF_LeadWrapper(){
        lead = new Lead();
        checked = false;
    }

    public CF_LeadWrapper(Lead o){
        lead = o;
        checked = false;
    }

}