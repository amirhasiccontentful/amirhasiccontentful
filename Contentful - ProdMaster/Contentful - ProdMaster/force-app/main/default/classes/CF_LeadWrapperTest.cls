@isTest
private class CF_LeadWrapperTest {

    public static testMethod void test() {

    	CF_LeadWrapper cw = new CF_LeadWrapper();
   		System.assertEquals(cw.checked,false);      

   		CF_LeadWrapper cw2 = new CF_LeadWrapper(new Lead(lastname='Test1'));
  		System.assertEquals(cw2.lead.lastname,'Test1');
  		System.assertEquals(cw2.checked,false);       

  	}    
}