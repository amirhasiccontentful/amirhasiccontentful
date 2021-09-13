public with sharing class CF_AccountLeadSearchController {
    public Account account;
    public String pageUrl {set;}
    
    
    public CF_AccountLeadSearchController(ApexPages.StandardController controller) {
        this.account = (Account)controller.getRecord();
    }
    

    // the results from the search. do not init the results or a blank rows show up initially on page load
    public List<CF_LeadWrapper> searchResults {get;set;}
    // the categories that were checked/selected.
    public List<CF_LeadWrapper> selectedLeads {
        get {
            if (selectedLeads == null) selectedLeads = new List<CF_LeadWrapper>();
            return selectedLeads;
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
            searchResults = new List<CF_LeadWrapper>(); // init the list if it is null
        } else {
            searchResults.clear(); // clear out the current results if they exist
        }
		
		// find leads by text (name, company, email)
        String qry = 'SELECT o.Name, o.Firstname, o.Lastname, o.Company, o.Email, o.Title, o.Status, o.age__c, o.Owner.Name, o.Classification__c, o.first_class__c, o.CF_Organization__r.id, o.CF_Organization__r.gk_name__c, o.CF_Organization__r.Account__c, o.LeadSource FROM Lead o ' + 
        			 'WHERE o.IsConverted = false AND ( o.Name LIKE \'%'+searchText+'%\' OR o.Company LIKE \'%'+searchText+'%\' OR o.email LIKE \'%'+searchText+'%\') ' +  
        			 'ORDER By o.Name LIMIT 50';
                
                
        // may need to modify for governor limits??
        for(Lead org : Database.query(qry)) {
            // create a new wrapper by passing it the category in the constructor
            CF_LeadWrapper leadWrapper = new CF_LeadWrapper(org);
            // add the wrapper to the results
            searchResults.add(leadWrapper);
        }
        return null;
    }  
    
    public PageReference related() {

        if (searchResults == null) {
            searchResults = new List<CF_LeadWrapper>(); // init the list if it is null
        } else {
            searchResults.clear(); // clear out the current results if they exist
        }
		
    	List<CF_Organization__c> organizations = [Select id, gk_id__c FROM CF_Organization__c WHERE Account__c = :account.id];
    	Set<id> organizationIds = new Set<id>{};		
		
    	for (CF_Organization__c org : organizations) {
			organizationIds.add(org.id);
    	}    			
		
		// find leads by organization, text (name, company, email)
        String qry = 'SELECT o.Name, o.Firstname, o.Lastname, o.Company, o.Email, o.Title, o.Status, o.age__c, o.Owner.Name, o.Classification__c, o.first_class__c, o.CF_Organization__r.id, o.CF_Organization__r.gk_name__c, o.CF_Organization__r.Account__c, o.LeadSource FROM Lead o ' + 
        			 'WHERE o.IsConverted = false AND o.CF_Organization__c IN :organizationIds ' +  
        			 'ORDER By o.Name LIMIT 50';
                
                
        // may need to modify for governor limits??
        for(Lead org : Database.query(qry)) {
            // create a new wrapper by passing it the category in the constructor
            CF_LeadWrapper leadWrapper = new CF_LeadWrapper(org);
            // add the wrapper to the results
            searchResults.add(leadWrapper);
        }
        return null;
    }   

    public String getPageUrl() {
        PageReference pr = new ApexPages.StandardController(account).view();
        return pr.getUrl();
    }


    public PageReference assign() {
		Database.DMLOptions dml = new Database.DMLOptions(); 
	    dml.DuplicateRuleHeader.AllowSave = true;
	    		
        // clear out the currently selected categories
        selectedLeads.clear();

        // add the selected categories to a new List
        for (CF_LeadWrapper ow : searchResults) {
            if (ow.checked)
                selectedLeads.add(new CF_LeadWrapper(ow.lead));
        }
		
		List<Lead> leads = new List<Lead>();
		List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
		
		List<Contact> contacts = [SELECT name, firstname, lastname, email FROM Contact WHERE AccountId = :account.id];
		
        // ensure they selected at least one category or show an error message.
        if (selectedLeads.size() > 0) {
        	for (CF_LeadWrapper ow : selectedLeads) {
        		leads.add(ow.lead);	
        	}

        	for (Lead lead : leads) {        		
				Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(lead.id);
				lc.setDoNotCreateOpportunity(True);
				lc.setAccountId(account.id);
				
				for (Contact contact : contacts) {
					if (CF_Lead.shouldMergeLeadWithContact(lead, contact)) {
						lc.setContactId(contact.id);	
					}
				}
				// Converted Status Change					
				lc.setConvertedStatus('Converted');
				lc.setSendNotificationEmail(false);
				lc.setOwnerId(UserInfo.getUserId());
				
				leadsToConvert.add(lc); 
        	}
			
			List<Database.LeadConvertResult> r = Database.convertLead(leadsToConvert, dml);
			
        	Boolean hasError = false;
        	
        	for (Database.LeadConvertResult sr : r) {
		    	if(!sr.isSuccess()){
					for(Database.Error duplicateError : sr.getErrors()){
		  				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, duplicateError.getMessage() ));
					}
					
					hasError = true;
		    	}        		
        	}

			if (hasError == true) {
				return null;
			}
			else {
				return new PageReference('/' + account.id);
			}
					
			
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select at least one Lead.'));
            return null;
        }       

    }       
}