@isTest
public class ContentfulSetupFormLink_Test {
	
    private static testMethod void testSetupFormLink(){
        Account acc = new Account(Name = 'Test Acc', Billing_Entity__c = 'gmbh');
        insert acc;
        
        Contentful_Setup_Form__c cf = new Contentful_Setup_Form__c();
        cf.Account__c = acc.Id;
        insert cf;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cf);
        ContentfulSetupFormLink testLink = new ContentfulSetupFormLink(sc);
        
        PageReference pageRef = Page.CopyToClipboardSetupForm;
        pageRef.getParameters().put('id', String.valueOf(cf.Id));
        Test.setCurrentPage(pageRef);
 
    }
}