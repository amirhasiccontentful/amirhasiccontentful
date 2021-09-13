public without sharing class TaskTriggerHandler extends TriggerHandler {

	/****************************************************/
	/* TRIGGER EXECUTION								*/
	/****************************************************/

	public override void beforeUpdate() {
		populateActivityDateProxyField(trigger.new);
		UpdateLeadStatusBasedOnLoggedEmails(trigger.new);
	}

	public override void beforeInsert() {
		populateActivityDateProxyField(trigger.new);
		UpdateLeadStatusBasedOnLoggedEmails(trigger.new);
	}

	public override void afterUpdate() {
		new TaskAndEventRollups().updateTaskRollupFields(trigger.new);
		rollupActivityDatesToAccount(trigger.new, (Map<Id, Task>)trigger.oldMap);
		AddPhoneToAccount(trigger.new);
	}

	public override void afterInsert() {
		new TaskAndEventRollups().updateTaskRollupFields(trigger.new);
		rollupActivityDatesToAccount(trigger.new, null);
		SendEmailNotification(trigger.new);
	}

	/****************************************************/
	/* HELPER FUNCTIONS									*/
	/****************************************************/

	//The expected value of the standard Task.ActivityDate field, copied here to facilitate SOQL aggregate functions
	public void populateActivityDateProxyField(List<Task> newTasks){
		for (Task eachTask : newTasks) {
            eachTask.Activity_Date_Proxy__c = eachTask.ActivityDate;
        }
	}

	private void AddPhoneToAccount(List<Task> tasks){
		List<Account> updateAccounts = new List<Account>();
		for(Task t : tasks) {
			if(t.WhatId != null) {
				String objectType = String.valueOf(t.WhatId.getSObjectType());
				if(objectType == 'Account') {
					if(t.CC__Task_outcome_c__c != null) {
						if(t.CC__Task_outcome_c__c.CONTAINS('R:') || t.CC__Task_outcome_c__c.CONTAINS('C:')) {
							
							Account acc = new Account(Id =t.WhatId); 
							if(t.CC__Task_outcome_c__c.CONTAINS('C:'))
								acc.Critical_Phone_Number__c = t.CC__Task_outcome_c__c.substringAfter('C:').substringBetween('<', '>');
							if(t.CC__Task_outcome_c__c.CONTAINS('R:'))
								acc.Regular_Phone_Number__c = t.CC__Task_outcome_c__c.substringAfter('R:').substringBetween('<', '>');
							updateAccounts.add(acc);
						}
					}
				}
			}
		}
		try {
			if(!updateAccounts.isEmpty())
				update updateAccounts;
		} catch (Exception e) {}
	}

	private void UpdateLeadStatusBasedOnLoggedEmails(List<Task> tasks) {
		Set<Id> leadIdsWithOutgoingEmails = new Set<Id>();
		Set<Id> leadIdsWithIncomingEmails = new Set<Id>();
		Set<Id> leadIdsWithActivities = new Set<Id>();
	   	List<Lead> leadsToUpdate = new List<Lead>();
	   		
	 	for (Task task : tasks) {

	 		// workaround for dooly to update activity with task, 
	 		//but usually we use activity as value since type can't have default value
	      	if(task.type != null) {
	          	if(task.type.contains('-'))
	      		  	task.Activity__c = task.type;
	          	else
	          		task.type = task.Activity__c;
	        }
	      	else
	      	 	task.type = task.Activity__c;
	      	
	      	// update lead status on activity
	      
	       	if (task.whoId != null && task.status == 'Completed' && task.type != null) { 
	       	   //check if the task is associated with a lead
	           	if (String.valueOf(task.whoId).startsWith('00Q') == true) {
	           	  	if (task.type.startsWith('Email -')) {
		           	  	if (task.Subject.startsWith('← Email:')) { // cirrus insight syntax
		           	  		leadIdsWithIncomingEmails.add(task.whoId);	
		           	  	} else if (task.Subject.startsWith('→ Email:')) {
		           	  		leadIdsWithOutgoingEmails.add(task.whoId);
		           	  	}	  	
	           	  	} else if (task.type.startsWith('Call - ') || task.type.startsWith('In-person - ')) {
	           	  		leadIdsWithActivities.add(task.whoId);
	           	  	}
	           	}
	       	}
	 	}

	 	List<Lead> allLeads = [SELECT Id FROM Lead WHERE (Id IN :leadIdsWithOutgoingEmails AND Status IN ('Open')) 
			 					OR (Id IN :leadIdsWithIncomingEmails AND status IN ('Open', 'Contacted')) 
			 					OR (Id IN :leadIdsWithActivities AND status IN ('Open', 'Contacted'))];

	 	for(Lead lead : allLeads) {
	 		if (leadIdsWithOutgoingEmails.contains(lead.Id)) {
	 			lead.Status = 'Contacted';
	 		} else if (leadIdsWithIncomingEmails.contains(lead.Id)) {
	 			lead.Status = 'Conversation';
	 		} else if (leadIdsWithActivities.contains(lead.Id)) {
	 			lead.Status = 'Conversation';
	 		}
	 		leadsToUpdate.add(lead);
	 	}

	 	if(!leadsToUpdate.isEmpty()) {
	 		update leadsToUpdate;
	 	}
	}

	// LEGACY needs refactoring
	private void SendEmailNotification(List<Task> tasks) {
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
	
		//Contact recipient = [SELECT id, firstname FROM Contact LIMIT 1];
		//EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'CF_Task_Product_Input'];	
		
		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'salesforce@contentful.com'];
		String contactPrefix = Schema.SObjectType.Contact.getKeyPrefix();
		String leadPrefix = Schema.SObjectType.Lead.getKeyPrefix();
		
		Set<id> accountIds = new Set<id>();
		Set<id> contactIds = new Set<id>();
		Set<id> leadIds = new Set<id>();
		
		for (Task task : tasks) {
			if (task.accountId != null) {
				accountIds.add(task.accountId); 
			}
			
			if (task.whoId != null) {
	      		String stringId = task.whoid;
	      		if (stringId.startsWith(contactPrefix)) {
	      			contactIds.add(task.whoid);			
	      		}
	      		else if (stringId.startsWith(leadPrefix)) {
	      			leadIds.add(task.whoid);
	      		}
			}
		}
		
		List<Account> accounts = [SELECT Name, OwnerId, Owner.Email FROM Account WHERE id IN :accountIds];
		List<Contact> contacts = [SELECT Name FROM Contact WHERE id IN :contactIds];
		List<Lead> leads = [SELECT Name, Company, OwnerId, Owner.email FROM Lead WHERE id IN :leadIds AND isConverted = false];
		
		Map<Id, Account> idToAccount = new Map<Id, Account>();
		   
		for (Account a : accounts) {
			idToAccount.put(a.id, a); 
		}
		
		Map<Id, Contact> idToContact = new Map<Id, Contact>();
		   
		for (Contact c : contacts) {
			idToContact.put(c.id, c); 
		}
		
		Map<Id, Lead> idToLead = new Map<Id, Lead>();
		   
		for (Lead l : leads) {
			idToLead.put(l.id, l); 
		}	
		
	 	for (Task task : tasks) {
	      	
	      	Account account = null;
	      	Contact contact = null;
	      	Lead lead = null;
	      	
	      	Id originalOwnerId = null;
	      	String originalOwnerEmail = null;
	      	
	      	if (task.accountId != null) {
	      		account = idToAccount.get(task.accountId);
	      		originalOwnerId = account.ownerid;
	      		originalOwnerEmail = account.owner.email;
	      	}
	      	
	      	if (task.whoId != null) {
	      		String stringId = task.whoid;
	      		if (stringId.startsWith(contactPrefix)) {
	      			contact = idToContact.get(task.whoid);
	      		}
	      		else if (stringId.startsWith(leadPrefix)) {
	      			lead = idToLead.get(task.whoid);
	      			
	      			if (lead != null) {
		      			originalOwnerId = lead.ownerid;
		      			String leadOwnerId = lead.ownerid;
		      			
		      			if (!leadOwnerId.startsWith('00G')) { // do not send when in queue
		      				originalOwnerEmail = lead.owner.email;	
		      			}      				
	      			}

	      		}
	      	}
			
			if (task.Product_Relevant_Input__c == true) {
		      	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		
		        // create email content
		        String subject = 'Task logged with Product Input: ' + task.Subject;
				
				email.setOrgWideEmailAddressId(owea.get(0).id);
				
		        String body = '** TASK LOGGED WITH RELEVANT PRODUCT INPUT **\n\n';
		        
		        body += 'Subject: ' + task.subject + '\n';
		        body += 'Status: ' + task.status + '\n';
		        body += 'Activity Type: ' + task.activity__c + '\n';
		        body += 'Owner: ' + [SELECT Name from User WHERE id = :task.ownerid][0].name + '\n';
		        
		        if (account != null) {
		        	body += 'Account: ' + account.name + '\n';
		        }
		        
				if (lead != null) {
					body += 'Lead: ' + lead.name + ' (' + lead.company + ')\n';
					subject += ' (' + lead.name + ')';
				}
				
				if (contact != null) {
					body += 'Contact: ' + contact.name + '\n';
					subject += ' (' + contact.name + ')';
				}			
		        
		        body += 'Description:\n';
		        body += '---\n';
		        body += task.description;
		        body += '\n---\n';
		        
		        body += 'https://' + URL.getSalesforceBaseUrl().getHost() + '/' + task.id;
		        
		        email.setPlainTextBody(body);
		
		        // add recipients
		        List<String> toAddresses = new List<String>();
		        
		        toAddresses.add('product-feedback@contentful.com');
		        toAddresses.add('email-bcc-receiver@contentful.com');
		        
		        email.setSubject(subject);
		        email.setToAddresses(toAddresses);
		        
		        emails.add(email); 			
			}
			
			if (originalOwnerId != task.OwnerId) {
		      	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		
		        // create email content
		        String subject = 'Task logged on object you own: ' + task.Subject;
				
				email.setOrgWideEmailAddressId(owea.get(0).id);
				
		        String body = '** TASK LOGGED ON OBJECT YOU OWN **\n\n';
		        
		        body += 'Subject: ' + task.subject + '\n';
		        body += 'Status: ' + task.status + '\n';
		        body += 'Activity Type: ' + task.activity__c + '\n';
		        body += 'Owner: ' + [SELECT Name from User WHERE id = :task.ownerid][0].name + '\n';
		        
		        if (account != null) {
		        	body += 'Account: ' + account.name + '\n';
		        }
		        
				if (lead != null) {
					body += 'Lead: ' + lead.name + ' (' + lead.company + ')\n';
					subject += ' (' + lead.name + ')';
				}
				
				if (contact != null) {
					body += 'Contact: ' + contact.name + '\n';
					subject += ' (' + contact.name + ')';
				}			
		        
		        body += 'Description:\n';
		        body += '---\n';
		        body += task.description;
		        body += '\n---\n';
		        
		        body += 'https://' + URL.getSalesforceBaseUrl().getHost() + '/' + task.id;
		        
		        email.setPlainTextBody(body);
		
		        // add recipients
		        List<String> toAddresses = new List<String>();
		        
		        if (originalOwnerEmail != null) {
		        	toAddresses.add(originalOwnerEmail);	
		        }
		        
		        toAddresses.add('email-bcc-receiver@contentful.com');
		        
		        email.setSubject(subject);
		        email.setToAddresses(toAddresses);
		        
		        emails.add(email); 				
			}

	 	}
	 	
	    if(!emails.isEmpty()){
	    	try {
	        	Messaging.sendEmail(emails);
	        } catch (Exception e) {
	        }
	    } 	
	}

    
	private void rollupActivityDatesToAccount(List<Task> newTasksList, Map<Id, Task> oldTasksMap){
        
        Boolean executeFromCustomSetting = false;
        Boolean executeLogic = true;

        ExecuteSetting__c zuoraAccountRollupsSetting = new ExecuteCodeLogic().checkIfCodeLogicShouldBeExecuted('Rollup Activity Dates To Account');

        if(zuoraAccountRollupsSetting != null){

            if(zuoraAccountRollupsSetting.Active__c == false){
                executeLogic = false;
            }

            if(zuoraAccountRollupsSetting.Execute__c == true){
                executeFromCustomSetting = true;
            }
        }

        if(executeLogic == false) return;

        Set<Id> scopedAccountIds = new Set<Id>();
        
        for(Task tsk : newTasksList){
            
            Task oldRecord;

            if(oldTasksMap != null){
                oldRecord = oldTasksMap.get(tsk.Id);
            }

            if(oldRecord == null && tsk.AccountId != null && tsk.Status == 'Completed' && tsk.Activity_Date_Proxy__c != null){
                scopedAccountIds.add(tsk.AccountId);
            } else if(oldRecord != null && 
                (tsk.AccountId != oldRecord.get('AccountId') || 
                 tsk.Status != oldRecord.get('Status') || 
                 tsk.Type != oldRecord.get('Type') || 
                 tsk.Activity_Date_Proxy__c != oldRecord.get('Activity_Date_Proxy__c') || 
                 executeFromCustomSetting
                )){

                scopedAccountIds.add(tsk.AccountId);

                if((Id)oldRecord.get('AccountId') != null){
                    scopedAccountIds.add((Id)oldRecord.get('AccountId'));
                }
            }
        }
        
        if(scopedAccountIds.isEmpty()) return;

        List<Account> listOfaccountsForUpdate = new List<Account>();

        for(Account acc : [SELECT Id, 
                                  Most_Recent_Email_From_Customer__c,
                                  Most_Recent_Email_From_Customer_to_CSM__c,
                                  Most_Recent_Email_Outreach__c,
                                  Most_Recent_Email_Outreach_by_CSM__c,
                                  Most_Recent_In_Person_Meeting__c,
                                  Most_Recent_In_Person_Meeting_with_CSM__c,
                                  Most_Recent_Phone_Call__c,
                                  Most_Recent_Phone_Call_with_CSM__c,
                                  (SELECT Id, Activity_Date_Proxy__c, Description, Type, AccountId, CreatedBy.Title FROM Tasks 
                                  	WHERE Activity_Date_Proxy__c != null AND Status = 'Completed' AND ActivityDate != null AND Type != null) 
                                  FROM Account WHERE Id IN :scopedAccountIds]){

        	//if(acc.Tasks.isEmpty()){
        		acc.Most_Recent_Email_From_Customer__c = null;
        		acc.Most_Recent_Email_Outreach__c = null;
        		acc.Most_Recent_In_Person_Meeting__c = null;
        		acc.Most_Recent_Phone_Call__c = null;
        		acc.Most_Recent_Email_From_Customer_to_CSM__c = null;
        		acc.Most_Recent_Email_Outreach_by_CSM__c = null;
        		acc.Most_Recent_In_Person_Meeting_with_CSM__c = null;
        		acc.Most_Recent_Phone_Call_with_CSM__c = null;
        	//} else {

        		if(!acc.Tasks.isEmpty()){
        			for(Task task : acc.Tasks){

	        			if(task.Activity_Date_Proxy__c != null){
	        				if((acc.Most_Recent_Email_From_Customer__c == null || acc.Most_Recent_Email_From_Customer__c < task.Activity_Date_Proxy__c) && task.Type.startsWith('Email')){
			                    acc.Most_Recent_Email_From_Customer__c = Date.valueof(task.Activity_Date_Proxy__c);
			                }

			                if((acc.Most_Recent_Email_Outreach__c == null || acc.Most_Recent_Email_Outreach__c < task.Activity_Date_Proxy__c) && task.Type.startsWith('Email')){
			                    acc.Most_Recent_Email_Outreach__c = Date.valueof(task.Activity_Date_Proxy__c);
			                }

			                if((acc.Most_Recent_In_Person_Meeting__c == null || acc.Most_Recent_In_Person_Meeting__c < task.Activity_Date_Proxy__c) && task.Type.startsWith('In-person')){
			                    acc.Most_Recent_In_Person_Meeting__c = Date.valueof(task.Activity_Date_Proxy__c);
			                }

			                if((acc.Most_Recent_Phone_Call__c == null || acc.Most_Recent_Phone_Call__c < task.Activity_Date_Proxy__c) && task.Type.startsWith('Call')){
			                    acc.Most_Recent_Phone_Call__c = Date.valueof(task.Activity_Date_Proxy__c);
			                }

			                if(task.CreatedBy.Title == 'CSM'){

			                    if((acc.Most_Recent_Email_From_Customer_to_CSM__c == null || acc.Most_Recent_Email_From_Customer_to_CSM__c < task.Activity_Date_Proxy__c) && task.Type.startsWith('Email')){
			                        acc.Most_Recent_Email_From_Customer_to_CSM__c = Date.valueof(task.Activity_Date_Proxy__c);
			                    }

			                    if((acc.Most_Recent_Email_Outreach_by_CSM__c == null || acc.Most_Recent_Email_Outreach_by_CSM__c < task.Activity_Date_Proxy__c) && task.Type.startsWith('Email')){
			                        acc.Most_Recent_Email_Outreach_by_CSM__c = Date.valueof(task.Activity_Date_Proxy__c);
			                    }

			                    if((acc.Most_Recent_In_Person_Meeting_with_CSM__c == null || acc.Most_Recent_In_Person_Meeting_with_CSM__c < task.Activity_Date_Proxy__c) && task.Type.startsWith('In-person')){
			                        acc.Most_Recent_In_Person_Meeting_with_CSM__c = Date.valueof(task.Activity_Date_Proxy__c);
			                    }

			                    if((acc.Most_Recent_Phone_Call_with_CSM__c == null || acc.Most_Recent_Phone_Call_with_CSM__c < task.Activity_Date_Proxy__c) && task.Type.startsWith('Call')){
			                        acc.Most_Recent_Phone_Call_with_CSM__c = Date.valueof(task.Activity_Date_Proxy__c);
			                    }
			                }
	        			}
		                
	            	}
        		}
	        		
        		//}

            listOfaccountsForUpdate.add(acc);
            
        }

        System.debug('rollupActivityDatesToAccount:listOfaccountsForUpdate:---' + listOfaccountsForUpdate);

        if(!listOfaccountsForUpdate.isEmpty()) update listOfaccountsForUpdate;


    }
}