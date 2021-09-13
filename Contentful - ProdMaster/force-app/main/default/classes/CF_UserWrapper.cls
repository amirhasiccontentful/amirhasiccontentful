public with sharing class CF_UserWrapper {

    public Boolean checked{ get; set; }
    public CF_User__c user { get; set;}

    public CF_UserWrapper(){
        user = new CF_User__c();
        checked = false;
    }

    public CF_UserWrapper(CF_User__c o){
        user = o;
        checked = false;
    }

}