public with sharing class CF_Lead {
    public static void copyAttributesFromUserToLead(CF_User__c user, CF_Organization__c organization, Lead lead) {
               
        lead.CF_Organization__c = organization.id;
        lead.company = organization.gk_name__c;
        lead.DB_Marketing_Alias__c = organization.DB_Marketing_Alias__c;
        lead.DB_City__c = organization.DB_City__c;
        lead.DB_Country__c = organization.DB_Country_Name__c;
        lead.DB_User_Country__c = organization.DB_User_Country__c;
        //lead.DB_State__c = organization.DB_State__c; commented out since we aree only getting state code here
        lead.DB_Zip_Code__c = organization.DB_Zip__c;
        lead.DB_Country_Code__c = organization.DB_Country__c;
        lead.DB_Street__c = organization.DB_Street_Address__c;
        lead.DB_Phone__c = organization.DB_Phone__c;
        lead.DB_Demandbase_SID__c = organization.DB_Demandbase_SID__c;
        lead.DB_SIC__c = organization.DB_SIC__c;
        lead.DB_Industry__c = organization.DB_Industry__c;
        lead.DB_Sub_Industry__c = organization.DB_Sub_Industry__c;
        lead.DB_Employee_Count__c = organization.DB_Employee_Count__c;
        lead.DB_Employee_Range__c = organization.DB_Employee_Range__c;
        lead.DB_Revenue_Range__c = organization.DB_Revenue_Range__c;
        lead.DB_B2B__c = organization.DB_B2B__c;
        lead.DB_B2C__c = organization.DB_B2C__c;
        lead.DB_Web_Site__c = organization.DB_Web_Site__c;
                 
        lead.CF_User__c = user.id; 
        lead.FirstName = user.gk_first_name__c;
        lead.LastName = user.gk_last_name__c;
        lead.email = user.gk_email__c;
        lead.Title = user.DB_Job_Title__c;
        lead.Job_Function__c = user.DB_Job_Function__c;
        lead.utm_campaign__c = user.utm_campaign__c;
        lead.utm_medium__c = user.utm_medium__c;
        lead.utm_content__c = user.utm_content__c;
        lead.utm_source__c = user.utm_source__c;
        lead.utm_term__c = user.utm_term__c;
        lead.utm_orig_medium__c = user.utm_orig_medium__c;
        lead.utm_orig_source__c = user.utm_orig_source__c;
        lead.Platform__c = user.Platform__c;
        lead.DB_Data_Source__c = user.DB_Data_Source__c;

                  

        if (user.gk_invitation_created_at__c == null) {
            //lead.LeadSource = 'App - New User';
            //lead.LeadSource = 'Website Direct'; 
            lead.LeadSource = 'App - Sign Up';
            lead.Lead_Source_Detail__c = 'App - Sign Up';
        }
        else {
            //lead.LeadSource = 'App - Invited'; 
            //lead.LeadSource = 'Web App'; 
            lead.LeadSource = 'App - Invited';
            lead.Lead_Source_Detail__c = 'App - Invited';
        }
    }    
    
    /*public static String slackMessageForLead(Lead lead) {
        String name = lead.firstName + ' ' + lead.lastName;
        String message = name + ' (' + lead.email + ') from ' + lead.company + ' (' + lead.LeadSource + ') ';
        
        // Converted Status Change
        if (lead.status == 'Converted') {
            message = message + ' <auto-merged> ';
        }
        
        message = message + CF_Slack.objectLink(lead.id, 'Open');
        
        return message;     
    } */
    
    public static Boolean shouldAutoMergeLead(Lead lead) {
        /*if (lead.leadSource == 'App - Invited' && lead.CF_Organization__r.Account__c != null) {
            return true;
        }*/
        if (lead.Lead_Source_Detail__c == 'App - Invited' && lead.CF_Organization__r.Account__c != null && (lead.CF_Organization__r.gk_revenued_at__c != null || lead.CF_Organization__r.MRR_0__c == true)) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public static Boolean shouldMergeLeadWithContact(Lead lead, Contact contact) {
        if (contact.email == lead.email || (contact.lastname == lead.lastname && contact.firstname == lead.firstname) ) {
            return true;
        }
        else {
            return false;
        }
    }
}