public class UpdatePartnerDealsController {
    public Id OppId {get;set;}
    
    public UpdatePartnerDealsController() {
        OppId = ApexPages.currentPage().getParameters().get('Id');
    }
   
    public List<Partner_Deals__c> getNewPartnerDeals() {
        return [SELECT Id,Name,Partner_Account__r.Name,Partner_Owner__r.Name,Partner_Customer_Relationship_Type__c,Influenced_Field__c
		FROM Partner_Deals__c WHERE Opportunity_Name__c =:OppId];

    }
    
     @RemoteAction
    public static List<Partner_Deals__c> updateInfluencedDeals(String OppId, Decimal Influenced, String PartnerName){
        List<AggregateResult> result = [SELECT SUM(Influenced_Field__c) InfluenceSum  
                                  FROM Partner_Deals__c 
                                  WHERE Opportunity_Name__c = :OppId AND Name != :PartnerName
                                  GROUP BY Opportunity_Name__c];
        
        Decimal sum = 100 ;
        if(result.size() > 0){
            sum = (Decimal)result[0].get('InfluenceSum');
        }
            
        
        List<Partner_Deals__c> partner = [SELECT Id,Name,Partner_Account__r.Name,Partner_Owner__r.Name,Partner_Customer_Relationship_Type__c,Influenced_Field__c
                                    FROM Partner_Deals__c WHERE Opportunity_Name__c = :OppId AND Name = :PartnerName];
        for(Partner_Deals__c prt : partner){
            prt.Influenced_Field__c = Influenced;
        }
        
         update partner;
         
        return partner;
    }
    
    public void save(){
      ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Influenced Record updated Successfully.!'));
    }

}