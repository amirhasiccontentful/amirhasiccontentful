@isTest
public class ContentfulSetupForm_Test {
    
    private static testMethod void testSetupForm(){
        Account acc = new Account(Name = 'Test Acc');
        insert acc;
        
        Contentful_Setup_Form__c cf = new Contentful_Setup_Form__c();
        cf.Account__c = acc.Id;
        insert cf;
        
        
        PageReference pageRef = Page.ContentfulSetupForm ;
        pageRef.getParameters().put('id', String.valueOf(cf.Id));
        Test.setCurrentPage(pageRef);

        ContentfulSetupForm testForm = new ContentfulSetupForm();
        
        testForm.save();
    }

}