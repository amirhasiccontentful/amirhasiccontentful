public with sharing class CF_OrganizationWrapper {

    public Boolean checked{ get; set; }
    public CF_Organization__c org { get; set;}

    public CF_OrganizationWrapper(){
        org = new CF_Organization__c();
        checked = false;
    }

    public CF_OrganizationWrapper(CF_Organization__c o){
        org = o;
        checked = false;
    }

    //public static testMethod void testMe() {
//
    //    CF_OrganizationWrapper cw = new CF_OrganizationWrapper();
   //     System.assertEquals(cw.checked,false);      

   //     CF_OrganizationWrapper cw2 = new CF_OrganizationWrapper(new CF_Organization__c(name='Test1'));
  //      System.assertEquals(cw2.cat.name,'Test1');
  //      System.assertEquals(cw2.checked,false);       

  //  }

}