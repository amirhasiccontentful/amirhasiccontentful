public with sharing class CF_LeadRelatedAccountsController {
    private List<Account> accounts;
    public Lead lead;
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}          
     
    public CF_LeadRelatedAccountsController(ApexPages.StandardController controller) {
        this.lead= (Lead)controller.getRecord();
    }
        
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {		            	
            	size = 20;
            	String domain = CF_Base.filterDomains(lead.email_domain__c); 
            	String company = CF_Base.filterCompanyName(lead.company);
                con = new ApexPages.StandardSetController(Database.getQueryLocator('Select id, Name, Owner.Name, CF_Customer_Success_Manager__r.Name from Account WHERE Domain__c = :domain OR Name LIKE \'%'+company+'%\' ORDER BY name'));
                con.setPageSize(size);
                noOfRecords = con.getResultSize();
            }
            return con;
        }
        set;
    }    
    
    public pageReference refresh() {
        con = null;
        getAccounts();
        con.setPageNumber(1);
        return null;
    }    

    public List<Account> getAccounts() {
        List<Account> accountList = new List<Account>();
        for(Account a : (List<Account>)con.getRecords())
            accountList.add(a);
            
        return accountList;    	
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