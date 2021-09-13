public class LeadTriggerHandler extends TriggerHandler{

    /****************************************************/
    /* TRIGGER EXECUTION                                */
    /****************************************************/

    public override void beforeInsert() {
        partnerSubmittedLeadOwner(trigger.new);
        AssignSDRtoCustomField(trigger.new);
        AutoClassifyLeads(trigger.new);
        checkIfAddressIsUPdatedByInternalUser(trigger.new, (Map<Id, Lead>)trigger.oldMap);
        populateFirstLastTouchDates(Trigger.new);
        new PersonaTitleMapping().assignPersonaTitleMapping('Lead', Trigger.new, Trigger.oldMap);
        emailOptOutField((Map<Id, Lead>)trigger.oldMap, Trigger.new);
        removeTierIfQualificationIsNotEnterprise(trigger.new);
        //leadToAccountMatching(trigger.new, (Map<Id, Lead>)trigger.oldMap); 
        setAddressInfofromDemandBaseIfMissing(trigger.new);
        assignLeadSDROrOwnerifMatchedAccountDetailsExists(trigger.new, (Map<Id, Lead>)trigger.oldMap); 
        setLatestMQLInfo(trigger.new, (Map<Id, Lead>)trigger.oldMap);
    }

    public override void beforeUpdate() {
        resetLeanDataDuplicateLeadField(trigger.new);
        checkIfAddressIsUPdatedByInternalUser(trigger.new, (Map<Id, Lead>)trigger.oldMap);
        DataFoxEnrichment(trigger.new, (Map<Id, Lead>)trigger.oldMap);
        AssignSDRtoCustomField(trigger.new);
        new PersonaTitleMapping().assignPersonaTitleMapping('Lead', Trigger.new, Trigger.oldMap);
        emailOptOutField((Map<Id, Lead>)trigger.oldMap, Trigger.new);
        removeTierIfQualificationIsNotEnterprise(trigger.new);
        //leadToAccountMatching(trigger.new, (Map<Id, Lead>)trigger.oldMap); 
        setAddressInfofromDemandBaseIfMissing(trigger.new);
        AssignSalesRegionAndTerritory(trigger.new, (Map<Id, Lead>)trigger.oldMap);
        assignLeadSDROrOwnerifMatchedAccountDetailsExists(trigger.new, (Map<Id, Lead>)trigger.oldMap);
        setLatestMQLInfo(trigger.new, (Map<Id, Lead>)trigger.oldMap);
        assignLeadReportingFields(trigger.new); 
    }

    //to uncomment when needed
    // public override void beforeDelete() {   
        
    // }

    public override void afterInsert() {

        if(!Utility.IsExecutedFromCFUserOrOrg) {
            CFUserUtility.RelationshipBetweenCFUserAndLeadOrContact(trigger.new);
            CFOrganizationUtility.RelationshipBetweenCFOrgAndLeadOrAccount(trigger.new);
        }

        AssignMarketingResourceWhenDownloadedFromWebsite(trigger.new);
 
    }

    public override void afterUpdate() {
        if(!Utility.IsExecutedFromCFUserOrOrg) {
            CFUserUtility.RelationshipBetweenCFUserAndLeadOrContact(trigger.new);
            CFUserUtility.RelationshipBetweenCFUserAndContactAfterLeadConversion(trigger.new);
            CFOrganizationUtility.RelationshipBetweenCFOrgAndLeadOrAccount(trigger.new);
            CFOrganizationUtility.RelationshipBetweenCFOrgAndAccountAfterLeadConversion(trigger.new);
        }
        MarketingResourceLeadConvertedToContact(trigger.new);
        CreateRelationshipBetweenAccountAndOrganization(trigger.new);

        if (!System.isBatch() && !System.isFuture()) {
            AssignSalesRegionAndTerritoryOnCountryChange(trigger.new, (Map<Id, Lead>)trigger.oldMap);
        }

        //setContactStatusUponLeadConversion((Map<Id, Lead>)trigger.oldMap, trigger.new);
    }

    public override void afterDelete() {
        if(!Utility.IsExecutedFromCFUserOrOrg) {
            CFUserUtility.RelationshipBetweenCFUserAndLeadOrContact(trigger.old);
            CFOrganizationUtility.RelationshipBetweenCFOrgAndLeadOrAccount(trigger.old);
        }

        if (!System.isBatch() && !System.isFuture()) {
            setLeadSourceAfterLeadMerging(trigger.old);
        }
    }

    /****************************************************/
    /* HELPER FUNCTIONS                                 */
    /****************************************************/

    // Name: assignLeadReportingFields
	// Description: Sets check box fields on the Lead object that previously were displayed in formula fields. 
    // Transferred to checkbox fields due to hitting limits with object references in formula fields
	private void assignLeadReportingFields(List<Lead> newLeads) {
	
        Set<Id> matchedAccountsIds = new Set<Id>();

        for(Lead lead : newLeads) {
            if(lead.LeanData__Reporting_Matched_Account__c != null) {
                matchedAccountsIds.add(lead.LeanData__Reporting_Matched_Account__c);
            } 
        }         

        Map<Id, Account> matchedAccountsMap = new Map<Id, Account>([SELECT Id, Prospecting_Manager__c, OwnerId, Owner.UserRole.Name, RecordType.Name
                                                                    FROM Account 
                                                                    WHERE Id IN: matchedAccountsIds]); 
        
        if(matchedAccountsMap.size() > 0) { 
            for(Lead lead : newLeads) { 

                Account matchedAccount = matchedAccountsMap.get(lead.LeanData__Reporting_Matched_Account__c);

                if(matchedAccount != null && matchedAccount.Id == lead.LeanData__Reporting_Matched_Account__c && matchedAccount.Owner.UserRoleId != null) {
                    lead.Known_Account__c = matchedAccount.Owner.UserRole.Name.contains('Account Executive') || 
                                            matchedAccount.Owner.UserRole.Name.contains('Director of Sales') ||
                                            matchedAccount.Owner.UserRole.Name.contains('Partner') ? true : false;                
                    lead.Known_Partner_Account__c = matchedAccount.Owner.UserRole.Name.contains('Partner') ||
                                                    matchedAccount.Owner.UserRole.Name.contains('PDR') ||
                                                    matchedAccount.Owner.UserRole.Name.contains('PM') ? true : false;                 
                } else if (matchedAccount != null && matchedAccount.Id == lead.LeanData__Reporting_Matched_Account__c && matchedAccount.Owner.UserRoleId == null){
                    lead.Known_Account__c =  false;                
                    lead.Known_Partner_Account__c = false; 
                }                   
            }
        }        
	}

    // Name: setLatestMQLInfo
	// Description: Sets latest MQL priority field when Date Latest MQL is changed.  
    private void setLatestMQLInfo(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        
        for(Lead lead : newLeads) {
                 
            if(oldLeadsMap != null) {
                Lead oldLead = oldLeadsMap.get(lead.Id); 

                if(lead.Date_Latest_MQL__c != null && lead.Date_Latest_MQL__c != oldLead.Date_Latest_MQL__c){
                    lead.Latest_MQL_Priority__c = lead.MQL_Priority_Level__c;
                }
            } 
            
        }          
    } 

    // Name: assignLeadSDROrOwnerifMatchedAccountDetailsExists
	// Description: Assigns SDR or Lead Owners based on the Matched account with certain criterias
    private void assignLeadSDROrOwnerifMatchedAccountDetailsExists(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        
        Set<Id> matchedAccountsIds = new Set<Id>();

        for(Lead lead : newLeads) {
                
            //Pre-MQL routing. Check if Lead Status is open and Matched account set for the first time. 
            //MQL Routing. Check if Revenue Cycle Stage is MQL and Matched account set
            if(Trigger.isUpdate) {
                Lead oldLead = oldLeadsMap.get(lead.Id); 

                //Additional check added for lead owner changes. This will enable manual ownership changes. 
                if( (oldLead.LeanData__Reporting_Matched_Account__c != lead.LeanData__Reporting_Matched_Account__c != null && lead.Status == 'Open' && oldLead.OwnerId == lead.OwnerId) || 
                    (lead.LeanData__Reporting_Matched_Account__c != null && lead.Revenue_Cycle_Stage__c == 'MQL' && oldLead.Revenue_Cycle_Stage__c != 'MQL') ){
                    matchedAccountsIds.add(lead.LeanData__Reporting_Matched_Account__c);
                }
            } 

            //Pre-MQL routing. No check for Revenue Cycle Stage if MQL
            if(Trigger.isInsert && lead.LeanData__Reporting_Matched_Account__c != null){
                matchedAccountsIds.add(lead.LeanData__Reporting_Matched_Account__c);
            } 
        }         

        Map<Id, Account> matchedAccountsMap = new Map<Id, Account>([SELECT Id, Prospecting_Manager__c, OwnerId, Owner.UserRole.Name
                                                                    FROM Account 
                                                                    WHERE Id IN: matchedAccountsIds AND
                                                                    (
                                                                    (Prospecting_Manager__c != null AND Prospecting_Manager__r.IsActive = true) OR
                                                                    (Owner.UserRole.Name LIKE '%Partner%' AND Owner.IsActive = true)
                                                                )]); 

        if(matchedAccountsMap.size() > 0) { 
            for(Lead lead : newLeads) { 

                Account matchedAccount = matchedAccountsMap.get(lead.LeanData__Reporting_Matched_Account__c);

                if(matchedAccount != null && matchedAccount.Id == lead.LeanData__Reporting_Matched_Account__c) {
                    if(matchedAccount.Prospecting_Manager__c != null) {
                        lead.Prospecting_Manager__c = matchedAccount.Prospecting_Manager__c; 
                    }

                    if(matchedAccount.Owner.UserRoleId != null && matchedAccount.Owner.UserRole.Name.contains('Partner')) {
                        lead.OwnerId = matchedAccount.OwnerId; 
                    }
                }                   
            }
        }
    } 

    private void setAddressInfofromDemandBaseIfMissing(List<Lead> newLeads) {
        for(Lead lead : newLeads) {
            if(lead.Country == null && lead.DB_Country__c != null){
                lead.Country = lead.DB_Country__c;                
                //lead.State = lead.DB_State__c; // DB state names abbreviations instead of full names. Dependent picklist          
                lead.Street = lead.DB_Street__c;                
                lead.City = lead.DB_City__c;                
                lead.PostalCode = lead.DB_Zip_Code__c;                
            }
        }         
    }

    //Disable validation rule executions for specific fields on leads
    //In this case enable Lead Source updates
    private void setLeadSourceAfterLeadMerging(List<Lead> oldLeads) {

        Set<Id> leadIds = new Set<Id>();
        Map<Id, List<Lead>> oldLeadsMap = new Map<Id, List<Lead>>();

        //Set set of lead Ids 
        //Set map of all MasterRecordId (lead ids) and groupd all deleted/merged leads into a list
        for(Lead deletedLead : oldLeads) { 

            if(String.isNotEmpty(deletedLead.MasterRecordId)) {
                leadIds.add(deletedLead.MasterRecordId);

                if(oldLeadsMap.containsKey(deletedLead.MasterRecordId)) {
                    List<Lead> relatedLeads = oldLeadsMap.get(deletedLead.MasterRecordId);
                    relatedLeads.add(deletedLead);
                    oldLeadsMap.put(deletedLead.MasterRecordId, relatedLeads);
                } else {
                    oldLeadsMap.put(deletedLead.MasterRecordId, new List<Lead> { deletedLead });
                }
            }
        } 

        if(leadIds.size() > 0) {

            //Map of lead Ids and new LeadSource values
            Map<Id, String> mapOfLeadsToUpdate = new Map<Id, String>();

            List<Lead> leadsList = [SELECT Id, CreatedDate, LeadSource 
                                    FROM Lead 
                                    WHERE Id IN :leadIds]; 
            
            for(Lead lead : leadsList) {

                //get all deleted leads (if multiple leads were merged to 1 lead) 
                List<Lead> deletedLeadsList = oldLeadsMap.get(lead.Id);

                if(deletedLeadsList.size() > 0) {

                    String latestLeadSource = '';

                    for(Lead oldLead : deletedLeadsList) { 
                        //If different LeadSources, set latest created Lead Source to the Merged master lead
                        if(lead.LeadSource != oldLead.LeadSource) {
                            latestLeadSource = oldLead.CreatedDate > lead.CreatedDate ? oldLead.LeadSource : lead.LeadSource;
                        }
                    }

                    if(String.isNotEmpty(latestLeadSource)) {
                        mapOfLeadsToUpdate.put(lead.Id, latestLeadSource);
                    }

                }
            }

            if(mapOfLeadsToUpdate.size() > 0) {
                setNewLeadSources(mapOfLeadsToUpdate);
            }  
        }
    }

    @future
    private static void setNewLeadSources(Map<Id, String> leadsMap){

        List<Lead> leadsToUpdate = [SELECT Id, LeadSource
                                   FROM Lead
                                   WHERE Id IN :leadsMap.keySet()];

        for(Lead lead : leadsToUpdate) { 
            lead.LeadSource = leadsMap.get(lead.Id);
        }

        update leadsToUpdate;
    }

    /*
    private void setContactStatusUponLeadConversion(Map<Id, Lead> oldLeadsMap, List<Lead> newLeads) {


        Set<Id> contactIds = new Set<Id>();
        Map<Id, String> contactLeadStatusMap = new Map<Id, String>();

        for(Lead lead : newLeads) {
            Lead oldLead = oldLeadsMap.get(lead.Id);

            if(lead.IsConverted && !oldLead.IsConverted && String.isNotEmpty(lead.ConvertedContactId)){
                contactIds.add(lead.ConvertedContactId);
                contactLeadStatusMap.put(lead.ConvertedContactId, lead.Status);
            }
        } 

        if(contactIds.size() > 0) { 

            List<Contact> contactsToUpdate = new List<Contact>();

            //Get all lead related contacts
            List<Contact> contactsList = [SELECT Id, Contact_Status__c 
                                          FROM Contact 
                                          WHERE Id IN :contactIds];

            //Loop trough contats to update list and assign lead status to the corresponding contact
            for(Contact con : contactsList) {

                String contactStatus = contactLeadStatusMap.get(con.Id);

                if(String.isNotEmpty(contactStatus)) {
                    con.Contact_Status__c = contactStatus;
                    contactsToUpdate.add(con);
                }
            } 

            if(contactsToUpdate.size() > 0) update contactsToUpdate;
        }
    }
    */

    private void partnerSubmittedLeadOwner(List<Lead> newLeads){

        Set<Id> scopedAccountIds = new Set<Id>();
        List<Lead> scopedLeads = new List<Lead>();

        for(Lead l : newLeads){
            if(l.Allbound_ID__c != null && l.Referring_Account__c != null){
                scopedAccountIds.add(l.Referring_Account__c);
                scopedLeads.add(l);
            }
        }

        if(!scopedAccountIds.isEmpty()){

            Map<Id, Account> mapOfAcccountAndOwnerIds = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :scopedAccountIds]);

            for(Lead ld : scopedLeads){

               if(mapOfAcccountAndOwnerIds.get(ld.Referring_Account__c) != null){
                  Account matchedAccount = mapOfAcccountAndOwnerIds.get(ld.Referring_Account__c);
                  ld.OwnerId = matchedAccount.OwnerId;
            	}
            }
        }
    }

    //Logic replaced with LeanData matching 
    /*
    //Match Leads to Account  based on the email domain
    private void leadToAccountMatching(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap){

        Set<String> leadDomains = new Set<String>();
        List<Lead> scopedLeads = new List<Lead>();

        for(Lead ld : newLeads){
            if(Trigger.isUpdate && ((ld.dfox__Company_DataFox_Id__c != oldLeadsMap.get(ld.Id).get('dfox__Company_DataFox_Id__c') || ld.Website != oldLeadsMap.get(ld.Id).get('Website') || ld.Company != oldLeadsMap.get(ld.Id).get('Company')) || (ld.Rerun_Apex_logic__c = true && ld.Rerun_Apex_logic__c != oldLeadsMap.get(ld.Id).get('Rerun_Apex_logic__c')))){
                if(ld.dfox__Company_DataFox_Id__c != null){
                    leadDomains.add(ld.dfox__Company_DataFox_Id__c);
                } else if(ld.Website != null){
                    leadDomains.add(ld.Domain__c);
                } else if(ld.Company != null){
                    leadDomains.add(ld.Company);
                }
            }
            else if(Trigger.isInsert){
                if(ld.dfox__Company_DataFox_Id__c != null){
                    leadDomains.add(ld.dfox__Company_DataFox_Id__c);
                } else if(ld.Website != null){
                    leadDomains.add(ld.Domain__c);
                } else if(ld.Company != null){
                    leadDomains.add(ld.Company);
                }
            }
        }

        if(!leadDomains.isEmpty()){

            Map<String,Id> mapOfAccountIdsAndDomain = new Map<String,Id>();

            for(Account acc : [SELECT Id, dfox__Id__c, Domain__c, Website, Name FROM Account WHERE dfox__Id__c IN :leadDomains OR Website IN :leadDomains OR Name IN :leadDomains]){
                if(acc != null){
                    mapOfAccountIdsAndDomain.put(acc.Name, acc.Id);
                    if(acc.Website != null){
                        mapOfAccountIdsAndDomain.put(acc.Domain__c, acc.Id);
                    }
                    if(acc.dfox__Id__c != null){
                        mapOfAccountIdsAndDomain.put(acc.dfox__Id__c, acc.Id);
                    }
                }
            }

            if(mapOfAccountIdsAndDomain != null){

                for(Lead ld : newLeads){

                    Id accountId;

                    if(mapOfAccountIdsAndDomain.get(ld.dfox__Company_DataFox_Id__c) != null){
                        accountId = mapOfAccountIdsAndDomain.get(ld.dfox__Company_DataFox_Id__c);
                    } else if(mapOfAccountIdsAndDomain.get(ld.Domain__c) != null){
                        accountId = mapOfAccountIdsAndDomain.get(ld.Domain__c);
                    } else if(mapOfAccountIdsAndDomain.get(ld.Company) != null){
                        accountId = mapOfAccountIdsAndDomain.get(ld.Company);
                    }

                    if(accountId != null){
                        ld.Matched_Account__c = accountId;
                    }

                    ld.Rerun_Apex_logic__c = false;
                }
            }
        }
    }
    */

    private void AssignMarketingResourceWhenDownloadedFromWebsite(List<Lead> leads) {
        List<Marketing_Resource_Lead__c> insertMarketingResourceLeads = new List<Marketing_Resource_Lead__c>();
        Set<String> marketinResourceShortNames = new Set<String>();
        List<Lead> marketingResourceLeads = new List<Lead>();
        for(Lead lead : leads) {
            if(lead.Marketing_Resource_Short_Name__c != null) {
                marketinResourceShortNames.add(lead.Marketing_Resource_Short_Name__c);
                marketingResourceLeads.add(lead);
            }
        }

        if(!marketinResourceShortNames.isEmpty()) {
            List<Marketing_Resource__c> resources = [SELECT Name, Short_Name__c FROM Marketing_Resource__c WHERE Short_Name__c IN :marketinResourceShortNames];
            Map<String, Marketing_Resource__c> resourceIdsByShortName = new Map<String, Marketing_Resource__c>();
            for(Marketing_Resource__c res : resources) {
                resourceIdsByShortName.put(res.Short_Name__c, res);
            }

            for(Lead l : marketingResourceLeads) {
                Marketing_Resource__c resource = resourceIdsByShortName.get(l.Marketing_Resource_Short_Name__c);
                if(resource != null) {
                    Marketing_Resource_Lead__c mrl = new Marketing_Resource_Lead__c();
                    mrl.Lead__c = l.Id;
                    mrl.Marketing_Resource__c = resource.Id;
                    insertMarketingResourceLeads.add(mrl);
                }
            }

            if(!insertMarketingResourceLeads.isEmpty()) {
                insert insertMarketingResourceLeads;
            }
        }
    }

    private void MarketingResourceLeadConvertedToContact(List<Lead> leads) {
        Set<Id> leadIds = new Set<Id>();
        Map<Id, Id> contactIdByLeadId = new Map<Id, Id>();
        List<Marketing_Resource_Lead__c> updateMarketingResources = new List<Marketing_Resource_Lead__c>();
        for(Lead lead : leads) {
            if(lead.IsConverted) {
                leadIds.add(lead.Id);
                contactIdByLeadId.put(lead.Id, lead.ConvertedContactId);
            }
        }

        List<Marketing_Resource_Lead__c> marketingResourceLeads = [SELECT Lead__c FROM Marketing_Resource_Lead__c WHERE Lead__c IN :leadIds];
        if(!marketingResourceLeads.isEmpty()){
            for(Marketing_Resource_Lead__c mr :marketingResourceLeads) {
                mr.Contact__c = contactIdByLeadId.get(mr.Lead__c);
                mr.Lead__c = null;
                updateMarketingResources.add(mr);
            }
        }
        if(!updateMarketingResources.isEmpty()) {
            update updateMarketingResources;
        }
    }

    private void resetLeanDataDuplicateLeadField(List<Lead> newLeads){

        for(Lead l : newLeads){
            if(l.Duplicate_Lead__c == l.Id){
                l.Duplicate_Lead__c = null;
            }
        }
    }

    private void AutoClassifyLeads(List<lead> leads) {
        // matching leads
        Set<String> leadsClassified = new Set<String>();
        Set<String> companies = new Set<String>();

        for(Lead lead : leads) {
            if(!CF_Base.isPublicDomain(lead.Email_Domain__c)) {
                if(lead.Company != null && lead.Email_Domain__c != null) {
                    Boolean comapnyContainsLetter = Pattern.matches('\\w*[a-zA-Z]\\w*', lead.Company);
                    if(comapnyContainsLetter) { // check if company contains letters
                        leadsClassified.add(lead.Company + lead.Email_Domain__c);
                        companies.add(lead.Company);
                    }
                }
            }
        }
        if(!leadsClassified.isEmpty()) {
            List<Lead> allLeads = new List<Lead>();
            for(Lead l : [SELECT Company_And_Email_Domain__c, Classification__c, Company, Email_Domain__c, Tier__c, First_Class__c
            FROM Lead WHERE Company IN :companies]) {
                if(leadsClassified.contains(l.Company_And_Email_Domain__c))
                    allLeads.add(l);
            }

            Map<String, List<Lead>> leadsByCompanyName = new Map<String, List<Lead>>();

            for(Lead lead : allLeads) {
                if(leadsByCompanyName.containsKey(lead.Company)) {
                    List<Lead> existingLeads = leadsByCompanyName.get(lead.Company);
                    existingLeads.add(lead);
                    leadsByCompanyName.put(lead.Company, existingLeads);
                } else {
                    leadsByCompanyName.put(lead.Company, new List<Lead>{lead});
                }
            }

            for(Lead lead : leads) {
                List<Lead> relatedLeads = new List<Lead>(leadsByCompanyName.get(lead.Company));
                if(!relatedLeads.isEmpty()) {
                    String classification = '';
                    Boolean firstCLassification = true;
                    for(Lead l : relatedLeads) {
                        if(l.Classification__c != null) {
                            if(firstCLassification) {
                                classification = l.Classification__c;
                                firstCLassification = false;
                            }
                            if(l.Classification__c != classification) {
                                lead.Auto_Classified_Multiple_Match__c = true;
                            }
                        }
                    }
                }
            }

            for(Lead lead : leads) {
                if(!lead.Auto_Classified_Multiple_Match__c) {
                    List<Lead> relatedLeads = new List<Lead>(leadsByCompanyName.get(lead.Company));
                    if(!relatedLeads.isEmpty()) {
                        for(Lead l : relatedLeads) {
                            if(l.Classification__c != null) {
                                if(l.Classification__c == 'Agency') {
                                    lead.First_Class__c = l.First_Class__c;
                                }
                                lead.Classification__c = l.Classification__c;
                                lead.Tier__c = l.Tier__c;
                                lead.Auto_Classified__c = true;
                            }
                        }
                    }
                }
            }
        }

    }

    public void AssignSDRtoCustomField(List<Lead> leads) {
        Set<Id> ownerIds = new Set<Id>();

        for (Lead lead : leads) {
            ownerIds.add(lead.OwnerId);
        }

        Map<Id, User> usersMap = new Map<Id, User>([SELECT UserRole.Name FROM User WHERE Id IN :ownerIds AND UserRoleId != null]);

        if(usersMap != null){
            for (Lead lead : leads) {
                if(usersMap.get(lead.OwnerId) != null){
                    User owner = usersMap.get(lead.OwnerId);
                    if(owner != null) { // If Owner is Queue
                        if (owner.UserRole.Name == 'SDR') {
                            lead.Prospecting_Manager__c = lead.OwnerId;
                        }
                    }
                }
            }
        }
    }

    public void CreateRelationshipBetweenAccountAndOrganization(List<Lead> leads) {
        Set<Id> orgIds = new Set<Id>();

        for (Lead lead : leads) {
            orgIds.add(lead.CF_Organization__c);
        }

        Map<Id, CF_Organization__c> organizationsMap = new Map<Id, CF_Organization__c>([SELECT Account__c From CF_Organization__c WHERE Id IN :orgIds]);
        Map<Id, CF_Organization__c> updateOrganizations = new Map<Id, CF_Organization__c>();

        for (Lead lead : leads) {
            if (Lead.IsConverted && lead.ConvertedAccountId != null && lead.CF_Organization__c != null && lead.Status != 'Converted - Self-service upgrade') {
                CF_Organization__c organization = organizationsMap.get(lead.CF_Organization__c);
                if (organization != null) {
                    //potentially causing the issue where cf org account__c is being changed
                    if(organization.Account__c == null){
                        organization.Account__c = lead.ConvertedAccountId;
                        updateOrganizations.put(organization.Id, organization);
                    }
                }
            }
        }
        if (!updateOrganizations.values().isEmpty()) {
            update updateOrganizations.values();
        }
    }

    private void checkIfAddressIsUPdatedByInternalUser(List<Lead> leads, Map<Id, Lead> oldLeads){

        List<User> checkForGenericUser = [SELECT Id, Generic_User__c FROM User WHERE Id = :UserInfo.getUserId()];

        if(!checkForGenericUser.isEmpty()){
            if((checkForGenericUser[0].Generic_User__c == FALSE && !Label.Datafox_User_Id.contains(checkForGenericUser[0].Id)) || Label.Non_generic_user_Id_list.contains(checkForGenericUser[0].Id)){

                for(Lead ld : leads){

                    if(Trigger.isUpdate && ld.Country != oldLeads.get(ld.Id).get('Country')){
                        ld.Address_set_by_internal_user__c = true;
                    } else if(Trigger.isInsert && ld.Country != null) {
                        ld.Address_set_by_internal_user__c = true;
                    }

                }
            }
        }
    }

    private void DataFoxEnrichment(List<Lead> leads, Map<Id, Lead> oldLeads) {

        Set<String> setOfCountries = new Set<String>();
        Set<String> setOfStates = new Set<String>();

        //all the country codes in the ORG
        Schema.DescribeFieldResult fieldResultCountryCode = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> countries = fieldResultCountryCode.getPicklistValues();

        for(Schema.PicklistEntry c : countries){
            setOfCountries.add(c.getLabel());
        }

        //all the state codes in the ORG
        Schema.DescribeFieldResult fieldResultStateCode = User.statecode.getDescribe();
        List<Schema.PicklistEntry> states = fieldResultStateCode.getPicklistValues();

        for(Schema.PicklistEntry s : states){
            setOfStates.add(s.getLabel());
        }

        for (Lead lead : leads) {
            Lead oldLead = oldLeads.get(lead.Id);
            if(lead.DataFox_Classified__c == false && (lead.dfox__Company_Revenue_Estimate_Amt__c != oldLead.dfox__Company_Revenue_Estimate_Amt__c || lead.dfox__Company_Number_of_Employees__c != oldLead.dfox__Company_Number_of_Employees__c || lead.DataFox_Classified__c != oldLead.DataFox_Classified__c)) {
                if(lead.Classification__c == 'Enterprise' && lead.Tier__c != null && !lead.DataFox_Classified__c) {
                    if(lead.dfox__Company_Revenue_Estimate_Amt__c >= 1000000000 || lead.dfox__Company_Number_of_Employees__c >= 10000) {
                        lead.Classification__c = 'Enterprise';
                        lead.Tier__c = '1';
                        lead.DataFox_Classified__c = true;
                        lead.First_Class__c = false;
                    } else if ((lead.dfox__Company_Revenue_Estimate_Amt__c >= 100000000 && lead.dfox__Company_Revenue_Estimate_Amt__c < 1000000000) || (lead.dfox__Company_Number_of_Employees__c >= 1000 && lead.dfox__Company_Number_of_Employees__c <= 10000)) {
                        lead.Classification__c = 'Enterprise';
                        lead.Tier__c = '2';
                        lead.DataFox_Classified__c = true;
                        lead.First_Class__c = false;
                    } else if ((lead.dfox__Company_Revenue_Estimate_Amt__c >= 10000000 && lead.dfox__Company_Revenue_Estimate_Amt__c < 100000000) || (lead.dfox__Company_Number_of_Employees__c >= 100 && lead.dfox__Company_Number_of_Employees__c <= 1000)) {
                        lead.Classification__c = 'Enterprise';
                        lead.Tier__c = '3';
                        lead.DataFox_Classified__c = true;
                        lead.First_Class__c = false;
                    }
                }
                else if((lead.Classification__c == null || (lead.Classification__c == 'Enterprise' && lead.Tier__c == null) || lead.Classification__c == 'SMB' || lead.Classification__c =='Unknown')) {
                    if(lead.dfox__Company_Revenue_Estimate_Amt__c >= 1000000000 || lead.dfox__Company_Number_of_Employees__c >= 10000) {
                        lead.Classification__c = 'Enterprise';
                        lead.Tier__c = '1';
                        lead.DataFox_Classified__c = true;
                        lead.First_Class__c = false;
                    } else if ((lead.dfox__Company_Revenue_Estimate_Amt__c >= 100000000 && lead.dfox__Company_Revenue_Estimate_Amt__c < 1000000000) || (lead.dfox__Company_Number_of_Employees__c >= 1000 && lead.dfox__Company_Number_of_Employees__c <= 10000)) {
                        lead.Classification__c = 'Enterprise';
                        lead.Tier__c = '2';
                        lead.DataFox_Classified__c = true;
                        lead.First_Class__c = false;
                    } else if ((lead.dfox__Company_Revenue_Estimate_Amt__c >= 10000000 && lead.dfox__Company_Revenue_Estimate_Amt__c < 100000000) || (lead.dfox__Company_Number_of_Employees__c >= 100 && lead.dfox__Company_Number_of_Employees__c <= 1000)) {
                        lead.Classification__c = 'Enterprise';
                        lead.Tier__c = '3';
                        lead.DataFox_Classified__c = true;
                        lead.First_Class__c = false;
                    } else if (lead.dfox__Company_Revenue_Estimate_Amt__c > 0 || lead.dfox__Company_Number_of_Employees__c > 0 || lead.Company != null) {
                        lead.Classification__c = 'SMB';
                        lead.Tier__c = '';
                        lead.DataFox_Classified__c = true;
                        lead.First_Class__c = false;
                    } else {
                        lead.Classification__c = 'Unknown';
                        lead.Tier__c = '';
                        lead.DataFox_Classified__c = true;
                        lead.First_Class__c = false;
                    }
                }

                if(String.isNotBlank(lead.dfox__Company_Website__c) && String.isBlank(lead.Website)) {
                    lead.Website = lead.dfox__Company_Website__c;
                }
                if (String.isNotBlank(lead.dfox__Company_Phone_Number__c) && String.isBlank(lead.Phone)) {
                    lead.Phone = lead.dfox__Company_Phone_Number__c;
                }
                if (String.isNotBlank(lead.dfox__Company_LinkedIn_URL__c) && String.isBlank(lead.LinkedIn__c)) {
                    lead.LinkedIn__c = lead.dfox__Company_LinkedIn_URL__c;
                }
                if (lead.dfox__Company_Revenue_Estimate_Amt__c != null && lead.AnnualRevenue == null) {
                    lead.AnnualRevenue = lead.dfox__Company_Revenue_Estimate_Amt__c;
                }
                if (lead.dfox__Company_Number_of_Employees__c != null && lead.NumberOfEmployees == null) {
                    lead.NumberOfEmployees = lead.dfox__Company_Number_of_Employees__c.intValue();
                }
            }

            // Address
            if(lead.DF_Enriched_Address__c == false){
                try {
                    if (String.isNotBlank(lead.dfox__Company_Country__c) && lead.dfox__Company_Country__c != oldLead.dfox__Company_Country__c && setOfCountries.contains(lead.dfox__Company_Country__c) && lead.Address_set_by_internal_user__c == FALSE) {

                        lead.Country = lead.dfox__Company_Country__c;
                        lead.State = lead.dfox__Company_State__c;

                        if (String.isNotBlank(lead.dfox__Company_Street_Address__c)) {
                            lead.Street = lead.dfox__Company_Street_Address__c;
                        }
                        if(String.isNotBlank(lead.dfox__Company_Zip_Code__c)) {
                            lead.PostalCode = lead.dfox__Company_Zip_Code__c;
                        }
                        if(String.isNotBlank(lead.dfox__Company_City__c)) {
                            lead.City = lead.dfox__Company_City__c.left(40);
                        }

                        lead.DF_Enriched_Address__c = true;

                    }
                } catch (Exception e) {

                }
            }
        }
    }

    private void populateFirstLastTouchDates(List<Lead> newLeads){

        for(Lead ld : newLeads){
            if(ld.First_Touch_Created_Date__c == null){
                ld.First_Touch_Created_Date__c = System.now();
            }
            if(ld.Last_Touch_Created_Date__c == null){
                ld.Last_Touch_Created_Date__c = System.now();
            }
            if(ld.First_Touch_Asset__c == null){
                ld.First_Touch_Asset__c = ld.Asset__c;
            }
            if(ld.Last_Touch_Asset__c == null){
                ld.Last_Touch_Asset__c = ld.Asset__c;
            }
            if(ld.First_Touch_Asset_Detail__c == null){
                ld.First_Touch_Asset_Detail__c = ld.Asset_Detail__c;
            }
            if(ld.Last_Touch_Asset_Detail__c == null){
                ld.Last_Touch_Asset_Detail__c = ld.Asset_Detail__c;
            }
            if(ld.First_Touch_Lead_Source_Detail__c == null){
                ld.First_Touch_Lead_Source_Detail__c = ld.Lead_Source_Detail__c;
            }
            if(ld.Last_Touch_Lead_Source_Detail__c == null){
                ld.Last_Touch_Lead_Source_Detail__c = ld.Lead_Source_Detail__c;
            }
        }
    }

    private void removeTierIfQualificationIsNotEnterprise(List<Lead> newLeadList) {

        for(Lead ld : newLeadList){
            if(ld.Classification__c != 'Enterprise'){
                ld.Tier__c = null;
            }
        }
    }  

    private void AssignSalesRegionAndTerritory(List<Lead> leadList, Map<Id, Lead> oldLeadsMap){
  
        Map<String, String> salesRegionsMap = new Map<String, String>();
        Map<String, String> salesTerritoriesMap = new Map<String, String>();  

        List<Territory_Maps__c> territoryMaps = Territory_Maps__c.getall().values();

        for(Territory_Maps__c tmap : territoryMaps) {

            String territoryKey = (tmap.HQ_Country__c == 'United States' || tmap.HQ_Country__c == 'Canada') && tmap.State_Province__c != null ? tmap.State_Province__c : tmap.HQ_Country__c;

            salesRegionsMap.put(tmap.HQ_Country__c, tmap.Sales_Region__c);
            salesTerritoriesMap.put(territoryKey, tmap.Sales_Territory__c);
        }         

        for(Lead lead : leadList){   

            Lead oldLead = oldLeadsMap.get(lead.Id);   

            if( (!String.isEmpty(lead.Company_HQ_Country__c) && oldLead.Company_HQ_Country__c != lead.Company_HQ_Country__c) ||
                ((!String.isEmpty(lead.Company_HQ_State__c) && oldLead.Company_HQ_State__c != lead.Company_HQ_State__c))
            ) {

                String territoryKey = (lead.Company_HQ_Country__c == 'United States' || lead.Company_HQ_Country__c == 'Canada') && lead.Company_HQ_State__c != null ? lead.Company_HQ_State__c : lead.Company_HQ_Country__c;

                lead.Company_HQ_Sales_Region__c = salesRegionsMap.get(String.escapeSingleQuotes(lead.Company_HQ_Country__c));
                lead.Company_HQ_Sales_Territory__c = salesTerritoriesMap.get(String.escapeSingleQuotes(territoryKey));
            } 
            else if((String.isEmpty(lead.Company_HQ_Country__c) && String.isNotEmpty(lead.Country)) ||
                (!String.isEmpty(lead.Company_HQ_Country__c) && String.isEmpty(lead.Company_HQ_State__c) && !String.isEmpty(lead.State))) {
            
                lead.Company_HQ_Country__c = lead.Country;
                lead.Company_HQ_State__c = lead.Company_HQ_Country__c == 'United States' || lead.Company_HQ_Country__c == 'Canada' ? lead.State : null; 

                String territoryKey = (lead.Company_HQ_Country__c == 'United States' || lead.Company_HQ_Country__c == 'Canada') && lead.Company_HQ_State__c != null ? lead.Company_HQ_State__c : lead.Company_HQ_Country__c;

                lead.Company_HQ_Sales_Region__c = salesRegionsMap.get(String.escapeSingleQuotes(lead.Company_HQ_Country__c));
                lead.Company_HQ_Sales_Territory__c = salesTerritoriesMap.get(String.escapeSingleQuotes(territoryKey));
            }   
        }
    }

    private void AssignSalesRegionAndTerritoryOnCountryChange(List<Lead> leadList, Map<Id, Lead> oldLeadsMap){

        Set<Id> leadIds = new Set<Id>();

        for(Lead lead : leadList){  

            Lead oldLead = oldLeadsMap.get(lead.Id);   

            if(!String.isEmpty(lead.Country) && oldLead.Country != lead.Country && String.isEmpty(lead.Company_HQ_Country__c)) {
                leadIds.add(lead.Id);
            }
        }

        if(leadIds.size() > 0) AssignCompanyHQCountryAndState(leadIds);

    }

    @future
    private static void AssignCompanyHQCountryAndState(Set<Id> leadIds){

        List<Lead> leadsToUpdate = [SELECT Id, Country, State, Company_HQ_Country__c, Company_HQ_State__c, Company_HQ_Sales_Region__c, Company_HQ_Sales_Territory__c
                                    FROM Lead
                                    WHERE Id IN : leadIds];  

        Map<String, String> salesRegionsMap = new Map<String, String>();
        Map<String, String> salesTerritoriesMap = new Map<String, String>();  

        List<Territory_Maps__c> territoryMaps = Territory_Maps__c.getall().values();

        for(Territory_Maps__c tmap : territoryMaps) {
            salesRegionsMap.put(tmap.HQ_Country__c, tmap.Sales_Region__c);
            salesTerritoriesMap.put(tmap.State_Province__c, tmap.Sales_Territory__c);
        }    

        for(Lead lead : leadsToUpdate){ 
            lead.Company_HQ_Country__c = lead.Country;
            lead.Company_HQ_State__c = lead.Company_HQ_Country__c == 'United States' || lead.Company_HQ_Country__c == 'Canada' ? lead.State : null;
 
            String territoryKey = (lead.Company_HQ_Country__c == 'United States' || lead.Company_HQ_Country__c == 'Canada') && lead.Company_HQ_State__c != null ? lead.Company_HQ_State__c : lead.Company_HQ_Country__c;
            
            lead.Company_HQ_Sales_Region__c = salesRegionsMap.get(String.escapeSingleQuotes(lead.Company_HQ_Country__c));
            lead.Company_HQ_Sales_Territory__c = salesTerritoriesMap.get(String.escapeSingleQuotes(territoryKey));
        }

        if(leadsToUpdate.size() > 0)
            Database.update(leadsToUpdate, false);
    }

    private void emailOptOutField(Map<Id, Lead> oldLeadValues, List<Lead> newLeads){

        List<EmailOptOutDefinitions__c> lstOfDefinedValuesForOptOut = [SELECT Id, Name, Value__c FROM EmailOptOutDefinitions__c];

        if(lstOfDefinedValuesForOptOut.size() == 0) return;

        List<Lead> scopedRecordsForProcessing = new List<Lead>();

        for(Lead l : newLeads){
            if ((Trigger.isUpdate && l.Email != oldLeadValues.get(l.Id).get('Email'))) {
                scopedRecordsForProcessing.add(l);
            } else if (Trigger.isInsert){
                scopedRecordsForProcessing.add(l);
            }
        }

        for(Lead ld : scopedRecordsForProcessing){
            if(String.isNotBlank(ld.Email)){
                for(EmailOptOutDefinitions__c definition : lstOfDefinedValuesForOptOut){
                    if(ld.Email.containsIgnoreCase(definition.Value__c)){
                        ld.HasOptedOutOfEmail = true;
                    }
                }
            }
        }
    }
}