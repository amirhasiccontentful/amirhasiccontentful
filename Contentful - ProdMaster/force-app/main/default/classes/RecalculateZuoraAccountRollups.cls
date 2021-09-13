public class RecalculateZuoraAccountRollups {
    //Apex properties or variables
    public Id accId { get; set; }
    
    //constructor to get the Account record Id
    public RecalculateZuoraAccountRollups(ApexPages.StandardController controller) {
        accId =  (Id)controller.getRecord().Id;
    }

    //Method that is called from the Visual Force page action attribute
    public PageReference zuoraAccountRollups() {
       
        if(!String.isBlank(accId)){
            Set<Id> scopedAccId = new Set<Id>();
            scopedAccId.add(accId);
            ZuoraSubscriptionTriggerHandler.accountZuoraRollupsExecute(scopedAccId);
        }
       PageReference pageRef = new PageReference('/' + accId);
       pageRef.setRedirect(true);
       return pageRef; //Returns to the account page
    }
}