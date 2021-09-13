@isTest
private class CF_OrganizationWrapperTest {

    public static testMethod void test() {

    	CF_OrganizationWrapper cw = new CF_OrganizationWrapper();
   		System.assertEquals(cw.checked,false);      

   		CF_OrganizationWrapper cw2 = new CF_OrganizationWrapper(new CF_Organization__c(name='Test1'));
  		System.assertEquals(cw2.org.name,'Test1');
  		System.assertEquals(cw2.checked,false);       

  	}    
}