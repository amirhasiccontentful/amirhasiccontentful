public with sharing class CF_AccountUserSearchController {
    public Account account;
    public String pageUrl {set;}
    
    
    public CF_AccountUserSearchController(ApexPages.StandardController controller) {
        this.account = (Account)controller.getRecord();
    }
    

    // the results from the search. do not init the results or a blank rows show up initially on page load
    public List<CF_UserWrapper> searchResults {get;set;}
    // the categories that were checked/selected.
    public List<CF_UserWrapper> selectedUsers {
        get {
            if (selectedUsers == null) selectedUsers = new List<CF_UserWrapper>();
            return selectedUsers;
        }
        set;
    }      




    // fired when the search button is clicked
    public PageReference search() {

        if (searchResults == null) {
            searchResults = new List<CF_UserWrapper>(); // init the list if it is null
        } else {
            searchResults.clear(); // clear out the current results if they exist
        }
		
		Set<String> allEmails = new Set<String>();
		
    	List<CF_Organization__c> organizations = [Select id, gk_id__c FROM CF_Organization__c WHERE Account__c = :account.id];
    	Set<Decimal> organizationIds = new Set<Decimal>{};
    	
    	for (CF_Organization__c org : organizations) {
			organizationIds.add(org.gk_id__c);
    	}    	    	
    	
    	List<CF_Organization_Membership__c> memberships = [Select id, gk_user__r.gk_email__c FROM CF_Organization_Membership__c WHERE gk_organization_id__c IN :organizationIds];
    	
    	for (CF_Organization_Membership__c membership : memberships) {
    		if (membership.gk_user__r != null && membership.gk_user__r.gk_email__c != null) {
    			allEmails.add(membership.gk_user__r.gk_email__c);	
    		}
    	}   
    	
		List<Contact> contacts = [SELECT id, email FROM Contact WHERE AccountId = :account.id];
		
		
		for (Contact c : contacts) {
			allEmails.remove(c.email);
		}
		    	 			
        String qry = 'SELECT u.id, u.gk_first_name__c, u.gk_last_name__c, u.gk_email__c FROM CF_User__c u WHERE u.gk_first_name__c != null AND u.gk_last_name__c != null AND u.gk_email__c IN :allEmails ORDER By u.gk_first_name__c LIMIT 20';
                
        // may need to modify for governor limits??
        for(CF_User__c user : Database.query(qry)) {
            // create a new wrapper by passing it the category in the constructor
            CF_UserWrapper userWrapper = new CF_UserWrapper(user);
            // add the wrapper to the results
            searchResults.add(userWrapper);
        }
        return null;
    }   

    public String getPageUrl() {
        PageReference pr = new ApexPages.StandardController(account).view();
        return pr.getUrl();
    }


    public PageReference assign() {

        // clear out the currently selected categories
        selectedUsers.clear();

        // add the selected categories to a new List
        for (CF_UserWrapper ow : searchResults) {
            if (ow.checked)
                selectedUsers.add(new CF_UserWrapper(ow.user));
        }
		
		List<CF_User__c> users = new List<CF_User__c>();
		
        // ensure they selected at least one category or show an error message.
        if (selectedUsers.size() > 0) {
        	List<Contact> contactsToAdd = new List<Contact>();
        	
        	for (CF_UserWrapper ow : selectedUsers) {
        		Contact contact = CF_User.contactFromUser(ow.user);
        		contact.AccountId = account.id;
        		
        		contactsToAdd.add(contact);
        	}

        	insert contactsToAdd;
        	
			return new PageReference('/' + account.id);

        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select at least one User.'));
            return null;
        }       

    }       
}