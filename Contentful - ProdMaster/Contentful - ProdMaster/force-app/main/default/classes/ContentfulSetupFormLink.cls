public class ContentfulSetupFormLink {
	
    private final Contentful_Setup_Form__c acct;
    public String urlLink {get; set;}
    public Boolean billingEntitySelected {get; set;}

    public ContentfulSetupFormLink(ApexPages.StandardController controller){

        this.acct = (Contentful_Setup_Form__c)controller.getRecord();
        billingEntitySelected = false;
        urlLink = Label.Contentful_Setup_Form_SIte_URL + '/ContentfulSetupForm?id=' + this.acct.Id;
        Contentful_Setup_Form__c currentAcc = [SELECT Id, Account__r.billing_entity__c FROM Contentful_Setup_Form__c WHERE Id = :this.acct.Id];
        if(currentAcc.Account__r.billing_entity__c != null){
        	billingEntitySelected = true;
        }
    }
}