global class CF_UserCreateLeadBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful  {
  public class applicationException extends Exception {}
  
  global final String query;
  global Boolean isImport;
  global List<Lead> allCreatedLeads;
  
  global CF_UserCreateLeadBatchable() {
    this(false);
  }
  
    global CF_UserCreateLeadBatchable(Boolean i) {
      isImport = i;
      
      // Importing was only used in the beginning when all CF objects were added to salesforce
      
      if (isImport) {
        query = 'SELECT id, Platform__c, utm_orig_source__c, utm_orig_medium__c, utm_term__c, utm_source__c, utm_content__c, utm_medium__c, utm_campaign__c, DB_Job_Function__c, DB_Job_Title__c, gk_last_name__c, gk_first_name__c, gk_lead_created_at__c, gk_invitation_created_at__c, gk_email__c, gk_id__c, DB_Data_Source__c FROM CF_User__c WHERE gk_lead_created_at__c = null AND gk_first_name__c != null AND gk_last_name__c != null';
      }
      else {
        query = 'SELECT id, Platform__c, utm_orig_source__c, utm_orig_medium__c, utm_term__c, utm_source__c, utm_content__c, utm_medium__c, utm_campaign__c, DB_Job_Function__c, DB_Job_Title__c, gk_last_name__c, gk_first_name__c, gk_lead_created_at__c, gk_invitation_created_at__c, gk_email__c, gk_id__c, DB_Data_Source__c FROM CF_User__c WHERE gk_imported_at__c = null AND gk_lead_created_at__c = null AND gk_first_name__c != null AND gk_last_name__c != null'; 
      }
      
        allCreatedLeads = new List<Lead>();
  }
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext BC, List<sObject> scope) {

        List<Lead> leadsToCreate = new List<Lead>();
        List<CF_User__c> usersToUpdate = new List<CF_User__c>();
        Set<Id> insertedLeadIds = new Set<Id>();
       
        // PART 1: Create the leads
        
        // query for lead record name to later create the lead
        
    //String recordTypeName = 'App';

    /*Refactor: replace by a single line:

     Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

    */

      //Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByName();
      //Schema.RecordTypeInfo rtInfo =  rtMapByName.get(recordTypeName);
     // Id recordTypeId = rtInfo.getRecordTypeId();   
    
    // query for queue id to later create the lead
    Id leadOwnerId = [SELECT Id FROM Group WHERE Name = 'Default' AND Type = 'Queue'][0].Id;
        
        // iterate through all users and get their gk_user_ids, to find related organization memberships
        Set<Integer> allUserIds = new Set<Integer>();
      
        for(sObject s : scope) {
          CF_User__c u = (CF_User__c)s;
          allUserIds.add(u.gk_id__c.intvalue());
        }         
        
        // load all organization memberships for the users from above based on the gk user id
                
        List<CF_Organization_Membership__c> organizationsMemberships = [SELECT Id, 
                                  gk_organization__c, 
                                  gk_user__c, 
                                  gk_organization__r.Id, 
                                  gk_organization__r.account__c, 
                                  gk_organization__r.gk_name__c, 
                                  gk_created_at__c, 
                                  gk_user_id__c, 
                                  gk_organization_id__c,
                                  gk_organization__r.DB_Marketing_Alias__c,
                                  gk_organization__r.DB_City__c,
                                  gk_organization__r.DB_Country_Name__c,
                                  gk_organization__r.DB_User_Country__c,                                      
                                  gk_organization__r.DB_State__c,
                                  gk_organization__r.DB_Zip__c,
                                  gk_organization__r.DB_Country__c,
                                  gk_organization__r.DB_Street_Address__c,
                                  gk_organization__r.DB_Phone__c,
                                  gk_organization__r.DB_Demandbase_SID__c,
                                  gk_organization__r.DB_SIC__c,
                                  gk_organization__r.DB_Industry__c,
                                  gk_organization__r.DB_Sub_Industry__c,
                                  gk_organization__r.DB_Employee_Count__c,
                                  gk_organization__r.DB_Employee_Range__c,
                                  gk_organization__r.DB_Revenue_Range__c,
                                  gk_organization__r.DB_B2B__c,
                                  gk_organization__r.DB_B2C__c,
                                  gk_organization__r.DB_Web_Site__c,
                                  gk_organization__r.gk_revenued_at__c,
                                  gk_organization__r.MRR_0__c                                      
                                  FROM CF_Organization_Membership__c 
                                  WHERE gk_user_id__c IN :allUserIds FOR UPDATE];
        
        if (isImport == false) { // coming from a trigger
          // create the relationships if necessary 
        for (CF_Organization_Membership__c om : organizationsMemberships) {
            CF_Organization_Membership.setRelationshipsFromId(om);
          }   
          
          update organizationsMemberships;
          
          // reload the memberships so that all relationships are set that setRelationships created
          organizationsMemberships = [SELECT 
                      gk_organization__c, 
                      gk_user__c, 
                      gk_organization__r.Id, 
                      gk_organization__r.account__c, 
                      gk_organization__r.gk_name__c, 
                      gk_created_at__c, 
                      gk_user_id__c,
                      gk_organization__r.DB_Marketing_Alias__c,
                      gk_organization__r.DB_City__c,
                      gk_organization__r.DB_Country_Name__c,
                      gk_organization__r.DB_State__c,
                      gk_organization__r.DB_Zip__c,
                      gk_organization__r.DB_Country__c,
                      gk_organization__r.DB_Street_Address__c,
                      gk_organization__r.DB_Phone__c,
                      gk_organization__r.DB_User_Country__c,                
                      gk_organization__r.DB_Demandbase_SID__c,
                      gk_organization__r.DB_SIC__c,
                      gk_organization__r.DB_Industry__c,
                      gk_organization__r.DB_Sub_Industry__c,
                      gk_organization__r.DB_Employee_Count__c,
                      gk_organization__r.DB_Employee_Range__c,
                      gk_organization__r.DB_Revenue_Range__c,
                      gk_organization__r.DB_B2B__c,
                      gk_organization__r.DB_B2C__c,
                      gk_organization__r.DB_Web_Site__c,
                      gk_organization__r.gk_revenued_at__c,
                      gk_organization__r.MRR_0__c
                       
                      FROM CF_Organization_Membership__c 
                      WHERE gk_user_id__c IN :allUserIds];
        }
    
    // create a lookup hash from user ids to organizations
        Map<Id, CF_Organization_Membership__c> orgMembershipToOrgMap = new Map<Id, CF_Organization_Membership__c>();
        
      
      for (CF_Organization_Membership__c om : organizationsMemberships) {

        CF_Organization_Membership__c existing = orgMembershipToOrgMap.get(om.gk_user__c);

        /* Use the first organization membership or the newest one (user could be in multiple organizations, but we need to pick one for the lead 
           we create later)
        */

        if (existing == null || existing.gk_created_at__c > om.gk_created_at__c) {
          orgMembershipToOrgMap.put(om.gk_user__c, om); 
        }
    }
    
        // iterate again through all objects that changed
        for(sObject s : scope) {

          CF_User__c user = (CF_User__c)s;
          CF_Organization_Membership__c om = orgMembershipToOrgMap.get(user.Id); // fetch the latest organization belonging to the user
          
          if (om != null) { // only proceed if we found an organization membership for the user
            CF_Organization__c organization = om.gk_organization__r; // load the organization for the membership
            
            if (user != null & organization != null) { // assure we have all 3 objects in place before we create the lead
              
              // create the lead
              Lead lead = new Lead();
              //lead.RecordTypeId = recordTypeId;
              lead.ownerId = leadOwnerId;
              
              CF_Lead.copyAttributesFromUserToLead(user, organization, lead);
              
              //if (isImport) {
              //  lead.status = 'Idle'; 
              //}
              
              // tag the user so that we know we created the lead
              user.gk_lead_created_at__c = DateTime.now(); 
              
              // only add it to an array, update later, to not run into governor limits
              leadsToCreate.add(lead);
              usersToUpdate.add(user);                
            }         
          }

       }
       
      // There are duplicate rules for e.g. emails, this is more important for real users, not so much for automations
      // we want to allow duplicates in this batch and just ignore duplicate warnings
          Database.DMLOptions dml = new Database.DMLOptions(); 
          dml.DuplicateRuleHeader.AllowSave = true;
        
          // Batch insert the leads and update the users
          // TODO: check if this is in a transaction
          Database.insert(leadsToCreate, dml);
          Database.update(usersToUpdate, dml);  
        
        
        // PART 2: 
        // If a user has been invited and the organization is already paying us, automatically convert the lead to a contact and the corresponding account
        
        // collect all the lead ids we just created
        for(Lead lead : leadsToCreate) {
          insertedLeadIds.add(lead.id);
        }        
        
          List<Lead> leadsForAutoMerge = new List<Lead>();
          List<Contact> contacts = new List<Contact>();
          List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        
          // load all the leads we just created with additional related objects
          leadsForAutoMerge = [SELECT Id, 
                      Firstname, 
                      Lastname, 
                      LeadSource,
                      Lead_Source_Detail__c, 
                      Email, 
                      CF_Organization__c, 
                      CF_Organization__r.Account__c, 
                      CF_Organization__r.Account__r.OwnerId,
                      CF_Organization__r.gk_revenued_at__c,
                      CF_Organization__r.MRR_0__c
                      FROM Lead 
                      WHERE Id IN :insertedLeadIds];
        
          // go through all leads and save the account ids, so we can later query for all contacts in these accounts so we can merge the lead with the contact
        Set<Id> allAccountIds = new Set<Id>();
      
    for(Lead lead : leadsForAutoMerge) {
          if (lead.CF_Organization__c != null && lead.CF_Organization__r.Account__c != null && (lead.CF_Organization__r.gk_revenued_at__c != null || lead.CF_Organization__r.MRR_0__c == true)) {
            allAccountIds.add(lead.CF_Organization__r.Account__c);  
          } 
        }            
        
          contacts = [SELECT Id, Name, Firstname, Lastname, Email, AccountId FROM Contact WHERE AccountId IN :allAccountIds];
        
          // iterate through all leads that we might want to auto-merge into contacts
          for (Lead lead : leadsForAutoMerge) {
          // check if we should merge
            if (CF_Lead.shouldAutoMergeLead(lead) == true) {
            // merge into account
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.Id);
            lc.setDoNotCreateOpportunity(True); // we do not create a sales opportunity, they already are paying us
            lc.setAccountId(lead.CF_Organization__r.Account__c);
            
        // do not only merge into the account, merge into an existing contact if it exists (same name, email etc)
        for (Contact contact : contacts) { 
          if (contact.AccountId == lead.CF_Organization__r.Account__c && CF_Lead.shouldMergeLeadWithContact(lead, contact) ) {
            lc.setContactId(contact.Id);  
          }
        }
        // Converted Status Change
        String convertedStatus = 'Converted';
        
        for (Lead l : leadsToCreate) {
          if (l.Id == lead.Id) {
            l.status = convertedStatus; // for slack message later, not reloaded from db  
          }
        }
        
        lc.setConvertedStatus(convertedStatus);
        lc.setSendNotificationEmail(false);
        lc.setOwnerId(lead.CF_Organization__r.Account__r.ownerid);
        
        leadsToConvert.add(lc); 
            }
          }
        
          // Use apex functions to convert leads
    List<Database.LeadConvertResult> r = Database.convertLead(leadsToConvert, dml);
      
        // If there's duplicate errors, at least log them for debugging
        for (Database.LeadConvertResult sr : r) {
          if(!sr.isSuccess()){
          for(Database.Error duplicateError : sr.getErrors()){
              System.debug('Error when auto-merging lead: ' + duplicateError.getMessage());
          }
          }           
        }
        
       // create an array of all leads so we can send message to slack in finish job
       /*Commented Out On 15th of May so that it does not send messages anymore to Slack START
       for (Lead lead : leadsToCreate) {
          allCreatedLeads.add(lead);
       } Commented Out On 15th of May so that it does not send messages anymore to Slack END*/  
  } 
  
  global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        
        // only notifications to slack at the end as cannot be between DML operations
        /* Commented Out On 15th of May so that it does not send messages anymore to Slack START
        if (isImport == false && allCreatedLeads.size() > 0) {
          String message = '';
          
          if (allCreatedLeads.size() > 1) {
            message = ' \\n ';
          }
          
          for (Lead lead : allCreatedLeads) {
            message = message + 'Lead / new: ' + CF_Lead.slackMessageForLead(lead) + ' \\n ';
          }
          
          CF_Slack.postMessage('#biz-bot-leads', message);        
        } Commented Out On 15th of May so that it does not send messages anymore to Slack END*/
  } 
}