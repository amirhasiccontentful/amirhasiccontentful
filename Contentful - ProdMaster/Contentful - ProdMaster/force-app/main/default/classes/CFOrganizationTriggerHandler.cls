public with sharing class CFOrganizationTriggerHandler extends TriggerHandler {
	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/

	public override void beforeUpdate() {
		//CalculatePQA(trigger.new);
		CreateAccountAndContactForPayingOrganization(trigger.new, (Map<Id, CF_Organization__c>)trigger.OldMap);
	}

	public override void beforeInsert() {
		//CalculatePQA(trigger.new);
		if(Utility.runOnce()) {
			CreateOrUpdateIPLookup(trigger.new);
		}

	}

	public override void afterUpdate() {
		CalculateFieldsOnAccount(trigger.new);

	}

	public override void afterInsert() {
		CalculateFieldsOnAccount(trigger.new);
	}


	// Name: RollupValuesToAccount
	// Description: Update calculated fields on Account every time CF Organization is updated 
	// Update: make this future update as it sometimes run into unable_to_lock_row error
	private void CalculateFieldsOnAccount(List<CF_Organization__c> cfOrgs) {
		System.SavePoint sp = Database.setSavePoint();
		Set<Id> accountIds = new Set<Id>();
		Map<Id, Account> accountsToUpdate = new Map<Id, Account>();

		for(CF_Organization__c cfOrg : cfOrgs) {
			accountIds.add(cfOrg.Account__c);
		}

		Map<Id, Account> accounts = new Map<Id, Account>([SELECT CF_Users__c, (SELECT Id, CF_User_Count__c, TotangoActive_users_last_14_days__c, TotangoEngagement__c FROM CF_Organizations__r) FROM Account WHERE Id IN :accountIds]);

		if(!accounts.isEmpty()) {
			for(CF_Organization__c cfOrg : cfOrgs) {
				Account account = new Account();

				// Check if account already exists in the map (multiple assignments on one account in trigger context)
				if(accountsToUpdate.containsKey(cfOrg.Account__c))
					account = null;
				else
					account = accounts.get(cfOrg.Account__c);

				if(account != null) {
					account.CF_Organization_Count__c = account.CF_Organizations__r.size();
					Decimal users = 0;
					for(CF_Organization__c org : account.CF_Organizations__r) {
						users += org.CF_User_Count__c != null ? org.CF_User_Count__c : 0;
						/*if(account.Maximum_Totango_Active_Users__c < org.TotangoActive_users_last_14_days__c || account.Maximum_Totango_Active_Users__c == null)
							account.Maximum_Totango_Active_Users__c = org.TotangoActive_users_last_14_days__c;
						if(account.Maximum_Totango_Engagement__c < org.TotangoEngagement__c || account.Maximum_Totango_Engagement__c == null)
							account.Maximum_Totango_Engagement__c = org.TotangoEngagement__c;	*/		
					}
					account.CF_Users__c = users;
					accountsToUpdate.put(account.Id, account);
				}
			}
			if(!accountsToUpdate.values().isEmpty()) {
				try {
					update accountsToUpdate.values();
				} catch (Exception e) {
					// future
					Database.rollback(sp);

				}
			}
		}
	}

	

	// Name: CalclatePQA
	// Description: Calculates the PQA based on these three parameters:
	//				- Number of Users > 3
	//				- Total CDA Requests > 500
	// 				- Lead Infer Score == A (infer is out)
	// Update: not working propertly as data sync between gk and salesforce is not live
	/*private void CalculatePQA(List<CF_Organization__c> cfOrgs) {
		Set<Id> cfOrgIds = new Set<Id>();
		Map<Id, List<Lead>> allLeadsByCFOrganization = new Map<Id, List<Lead>>();

		for(CF_Organization__c cfOrg : cfOrgs) {
			cfOrgIds.add(cfOrg.Id);
		}

		System.debug('Riki cfOrgIds size: ' + cfOrgIds.size());

		List<Lead> leads = [SELECT CF_Organization__c FROM Lead WHERE CF_Organization__c IN :cfOrgIds LIMIT 2500];

		System.debug('Riki leads size: ' + leads.size());

		if(!leads.isEmpty()) {
			for(Lead l : leads) {
				if(allLeadsByCFOrganization.containsKey(l.CF_Organization__c)) {
					List<Lead> addLeads = new List<Lead>(allLeadsByCFOrganization.get(l.CF_Organization__c));
					addLeads.add(l);
					allLeadsByCFOrganization.put(l.CF_Organization__c, addLeads);
				} else {
					allLeadsByCFOrganization.put(l.CF_Organization__c, new List<Lead> { l });
				}
			}
		
			for(CF_Organization__c cfOrg : cfOrgs) {
				if(!cfOrg.PQA__c) {
					if(cfOrg.cf_user_count__c >= 3 && cfOrg.gk_total_cda_requests__c >= 500) {
						List<Lead> getLeads = new List<Lead>(allLeadsByCFOrganization.get(cfOrg.Id));
						if(!getLeads.isEmpty()) {
							for(Lead lead : getLeads) {
								
									cfOrg.PQA__c = true;
									cfOrg.PQA_Date__c = System.today();
									break;
								
							}
						} else {
							cfOrg.PQA__c = true;
							cfOrg.PQA_Date__c = System.today();
						}
					}
				}
			}
		}
	}*/

	// Name: CreateAccountAndContactForPayingOrganization
	// Description: If CF Organization is created on paying self-service or paying enterprise then create an account and contact for that
	//				organization to tide up Zuora Billing infromation 
	// UPDATE: Refactor createAccountAndCOntactsForORganizations method
	private void CreateAccountAndContactForPayingOrganization(List<CF_Organization__c> cfOrgs, Map<Id, CF_Organization__c> oldCFOrgs) {
		List<CF_Organization__c> payingCForgs = new List<CF_Organization__c>();
		for (CF_Organization__c cfOrg : cfOrgs) {
			CF_Organization__c oldCFOrg = oldCFOrgs != null ? oldCFOrgs.get(cfOrg.Id) : null;
			if(oldCFOrg != null) {
				if(((oldCFOrg.gk_revenued_at__c == null && cfOrg.gk_revenued_at__c != null) || (cfOrg.MRR_0__c == true && oldCFOrg.MRR_0__c == false)) && cfOrg.Account__c == null) {
					payingCForgs.add(cfOrg);
				}
			}
		}

		CF_Organization.createAccountsAndContactsForOrganizations(payingCForgs, false);
	}

	// Name: InsertLookups
	// Description: generates lookup urls on cf organization
	private void CreateOrUpdateIPLookup(List<CF_Organization__c> cfOrgs) {
		List<String> urlFields = new List<String>{'gk_first_visit_url__c', 'gk_first_visit_referer__c', 'gk_last_visit_url__c', 'gk_last_visit_referer__c'};
	
		List<CF_UrlLookup__c> lookupsToInsert = new List<CF_UrlLookup__c>();
		Map<String, CF_UrlLookup__c> lookupsToInsertMap = new Map<String, CF_UrlLookup__c>();
		
		Set<String> urlChecksums = new Set<String>();
		
	 	for (CF_Organization__c org : cfOrgs) {      	
	   		for (String field : urlFields) {
	   			String value = (String)org.get(field);
	   			if (value != null && string.isBlank(value) != true) {
	   				urlChecksums.add(CF_UrlLookup.checksumForUrl(value));	
	   			}
	   		}    
	 	}  	
	   		
	    List<CF_UrlLookup__c> lookups = [SELECT id, name, url__c, url_checksum__c FROM CF_UrlLookup__c WHERE url_checksum__c IN :urlChecksums];	
	       
	  	Map<String, CF_UrlLookup__c> urlChecksumToLookup = new Map<String, CF_UrlLookup__c>();
		   
		for (CF_UrlLookup__c l : lookups) {
			urlChecksumToLookup.put(l.url_checksum__c, l); 
		}
		
		Set<String>lookedUpUrls = new Set<String>();
		//Set<String>duplicatechecksum = new Set<String>(); // duplicate value
	
	        		
		for (CF_Organization__c org : cfOrgs) {       	
	   		for (String field : urlFields) {
	       		String url = (String)org.get(field);
	       		
	       		if (url != null && string.isBlank(url) != true && 
	       			(url.startsWith('http:') || url.startsWith('https:')) // only http(s), avoid app urls 
	       		   ) { 
		       		CF_UrlLookup__c lu = urlChecksumToLookup.get(url);
		       		
		       		if (lu == null && lookedUpUrls.contains(url) == false) {
		       			lu = new CF_UrlLookup__c();
		       			
		       			CF_UrlLookup.initLookup(lu, url);
			    		CF_UrlLookup.loadAndUpdateLookupFuture(url);
			    		
				    	lookupsToInsertMap.put(lu.url_checksum__c, lu);
				    	lookedUpUrls.add(url);
			    		//duplicatechecksum.add(lu.url_checksum__c);
		       		}	       			
	       		}	       		       			
	   		}   	
	 	}

	 	lookupsToInsert.addAll(lookupsToInsertMap.values());
	 	
	 	upsert lookupsToInsert url_checksum__c; 
	 	
	    for (CF_UrlLookup__c  l : lookupsToInsert) {
	    	urlChecksumToLookup.put(l.url_checksum__c, l); 
	    }          
	   
	   
	    for (CF_Organization__c org : cfOrgs) {
	   		for (String field : urlFields) {
	   			String value = (String)org.get(field);
	   			if (value != null && string.isBlank(value) != true) {
	       			String checksum = CF_UrlLookup.checksumForUrl(value);
	       			CF_UrlLookup__c l = urlChecksumToLookup.get(checksum);
	       			
	       			if (l != null) {
	       				String key = field.remove('gk_').remove('__c') + '_lookup__c';
	       				org.put(key, l.id);  
	       			}       				
	   			}
	   		}   		
	    } 	
	}
}