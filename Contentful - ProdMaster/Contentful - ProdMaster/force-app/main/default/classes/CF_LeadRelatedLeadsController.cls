public with sharing class CF_LeadRelatedLeadsController {
    private List<Lead> leads;
    public Lead lead;
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}          
     
     
    public CF_LeadRelatedLeadsController(ApexPages.StandardController controller) {
        this.lead= (Lead)controller.getRecord();
    }
        
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {		            	
            	size = 10;
            	String domain = CF_Base.filterDomains(lead.email_domain__c); 
                con = new ApexPages.StandardSetController(Database.getQueryLocator([Select id, Name, Email_Domain__c, status, CF_Organization__c, CF_User__c, CF_Organization__r.name, CF_User__r.name, email, Idle_Reason__c, createdDate from Lead WHERE ( (CF_Organization__c != null AND CF_Organization__c = :lead.CF_Organization__c) OR (CF_User__c != null AND CF_User__c = :lead.CF_User__c) OR (email != null AND email = :lead.email) OR (Email_Domain__c != null AND Email_Domain__c = :domain) ) AND id != :lead.id ORDER BY createdDate DESC LIMIT 50]));
                con.setPageSize(size);
                noOfRecords = con.getResultSize();
            }
            return con;
        }
        set;
    }    
    
    public pageReference refresh() {
        con = null;
        getLeads();
        con.setPageNumber(1);
        return null;
    }    

    public List<Lead> getLeads() {
        List<Lead> leadList = new List<Lead>();
        for(Lead a : (List<Lead>)con.getRecords())
            leadList.add(a);
            
        return leadList;    	
    }


    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    // returns the first page of records
     public void first() {
         con.first();
     }

     // returns the last page of records
     public void last() {
         con.last();
     }

     // returns the previous page of records
     public void previous() {
         con.previous();
     }

     // returns the next page of records
     public void next() {
         con.next();
     }

     // returns the PageReference of the original page, if known, or the home page.
     public void cancel() {
         con.cancel();
     }    
}