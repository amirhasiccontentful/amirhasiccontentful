// http://salesforcesource.blogspot.de/2008/10/how-to-create-custom-related-list-on.html
public with sharing class CF_AccountDetailZendeskController {
    private List<Zendesk__Zendesk_Ticket__c> tickets;
    public Account account;
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}     
     
    public CF_AccountDetailZendeskController(ApexPages.StandardController controller) {
        this.account = (Account)controller.getRecord();
    }
    
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
		    	Set<String> emails = new Set<String>{}; 
		    	
		    	AccountHierarchy hierarchy = new AccountHierarchy(account.id);
		    	List<Id> accountIds = hierarchy.toIdList();
		    	
		    	List<CF_Organization__c> organizations = [Select id, gk_id__c FROM CF_Organization__c WHERE Account__c IN :accountIds];
		    	Set<Decimal> organizationIds = new Set<Decimal>{};
		    	
		    	for (CF_Organization__c org : organizations) {
					organizationIds.add(org.gk_id__c);
		    	}    	    	
		    	
		    	List<CF_Organization_Membership__c> memberships = [Select id, gk_user__r.gk_email__c FROM CF_Organization_Membership__c WHERE gk_organization_id__c IN :organizationIds];
		    	
		    	for (CF_Organization_Membership__c membership : memberships) {
		    		if (membership.gk_user__r != null && membership.gk_user__r.gk_email__c != null) {
		    			emails.add(membership.gk_user__r.gk_email__c);	
		    		}
		    	}    	            	
		            	
            	size = 5;
                con = new ApexPages.StandardSetController(Database.getQueryLocator([Select id, Email__c, Zendesk__Status__c, Zendesk__Subject__c, Zendesk__Date_Time_created__c, Zendesk__Date_Time_solved__c, Zendesk__Priority__c, Zendesk__Tags__c from Zendesk__Zendesk_Ticket__c WHERE email__c IN :emails ORDER BY Zendesk__Date_Time_created__c DESC]));
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