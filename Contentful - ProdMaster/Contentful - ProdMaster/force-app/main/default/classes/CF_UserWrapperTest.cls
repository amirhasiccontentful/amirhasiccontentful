@isTest
private class CF_UserWrapperTest {

    public static testMethod void test() {

    	CF_UserWrapper cw = new CF_UserWrapper();
   		System.assertEquals(cw.checked,false);      

   		CF_UserWrapper cw2 = new CF_UserWrapper(new CF_User__c(name='Test1'));
  		System.assertEquals(cw2.user.name,'Test1');
  		System.assertEquals(cw2.checked,false);       

  	}    
}