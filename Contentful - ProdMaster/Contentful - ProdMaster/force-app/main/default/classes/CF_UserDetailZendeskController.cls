// http://salesforcesource.blogspot.de/2008/10/how-to-create-custom-related-list-on.html
public with sharing class CF_UserDetailZendeskController {
    private List<Zendesk__Zendesk_Ticket__c> tickets;
    public CF_User__c user;
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}     
     
    public CF_UserDetailZendeskController(ApexPages.StandardController controller) {
        this.user = (CF_User__c)controller.getRecord();
    }
    
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
            	size = 5;
     	            	
                con = new ApexPages.StandardSetController(Database.getQueryLocator([Select id, Zendesk__Status__c, Zendesk__Subject__c, Zendesk__Date_Time_created__c, Zendesk__Date_Time_solved__c, Zendesk__Priority__c, Zendesk__Tags__c from Zendesk__Zendesk_Ticket__c WHERE email__c = :user.gk_email__c ORDER BY Zendesk__Date_Time_created__c DESC]));
                con.setPageSize(size);
                noOfRecords = con.getResultSize();
            }
            return con;
        }
        set;
    }    
    
    public pageReference refresh() {
        con = null;
        getTickets();
        con.setPageNumber(1);
        return null;
    }    

    public List<Zendesk__Zendesk_Ticket__c> getTickets() {
        List<Zendesk__Zendesk_Ticket__c> ticketList = new List<Zendesk__Zendesk_Ticket__c>();
        for(Zendesk__Zendesk_Ticket__c a : (List<Zendesk__Zendesk_Ticket__c>)con.getRecords())
            ticketList.add(a);
            
        return ticketList;    	
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