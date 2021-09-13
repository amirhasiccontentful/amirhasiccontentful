public with sharing class CF_AccountOrganizationSearchController {
    public Account account;
    public String pageUrl {set;}
    
    
    public CF_AccountOrganizationSearchController(ApexPages.StandardController controller) {
        this.account = (Account)controller.getRecord();
    }
    

    // the results from the search. do not init the results or a blank rows show up initially on page load
    public List<CF_OrganizationWrapper> searchResults {get;set;}
    // the categories that were checked/selected.
    public List<CF_OrganizationWrapper> selectedOrganizations {
        get {
            if (selectedOrganizations == null) selectedOrganizations = new List<CF_OrganizationWrapper>();
            return selectedOrganizations;
        }
        set;
    }      

    // the text in the search box
    public string searchText {
        get {
            if (searchText == null) searchText = account.Name; // prefill the serach box for ease of use
            return searchText;
        }
        set;
    } 



    // fired when the search button is clicked
    public PageReference search() {

        if (searchResults == null) {
            searchResults = new List<CF_OrganizationWrapper>(); // init the list if it is null
        } else {
            searchResults.clear(); // clear out the current results if they exist
        }

        String qry = 'SELECT o.Name, o.Account__r.Name, o.gk_key__c, o.gk_subscription_status__c, o.Totango_Account_Health_Icon__c, o.TotangoEngagement__c, o.gk_created_at__c FROM CF_Organization__c o WHERE o.Name LIKE \'%'+searchText+'%\' AND o.Account__c != \'' + account.id + '\' ORDER By o.Name LIMIT 20';
                
        // may need to modify for governor limits??
        for(CF_Organization__c org : Database.query(qry)) {
            // create a new wrapper by passing it the category in the constructor
            CF_OrganizationWrapper orgWrapper = new CF_OrganizationWrapper(org);
            // add the wrapper to the results
            searchResults.add(orgWrapper);
        }
        return null;
    }   

    public String getPageUrl() {
        PageReference pr = new ApexPages.StandardController(account).view();
        return pr.getUrl();
    }


    public PageReference assign() {

        // clear out the currently selected categories
        selectedOrganizations.clear();

        // add the selected categories to a new List
        for (CF_OrganizationWrapper ow : searchResults) {
            if (ow.checked)
                selectedOrganizations.add(new CF_OrganizationWrapper(ow.org));
        }
		
		List<CF_Organization__c> organizations = new List<CF_Organization__c>();
		
        // ensure they selected at least one category or show an error message.
        if (selectedOrganizations.size() > 0) {
        	for (CF_OrganizationWrapper ow : selectedOrganizations) {
        		organizations.add(ow.org);	
        	}

        	for (CF_Organization__c org : organizations) {
        		org.Account__c = account.id;	
        	}

        	update organizations;
        	
        	
			return new PageReference('/' + account.id);

        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select at least one Organization.'));
            return null;
        }       

    }       
}