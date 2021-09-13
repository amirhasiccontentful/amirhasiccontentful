global class DeleteSignUpLeads_Batchable implements Database.Batchable<sObject> {

  global final String query;
  /*global Set<String> existingSignupRoleEmails;
  global Integer scopedNumberOfDays;
  global Set<String> scopedEmails;
  global Date todayDate;
*/
    global DeleteSignUpLeads_Batchable() {

      /*scopedNumberOfDays = Integer.valueOf(Label.App_Sign_Up_Leads_batchable);

      Date d = System.today() - scopedNumberOfDays;

      existingSignupRoleEmails = new Set<String>();

      scopedEmails = new Set<String>();

      for(Lead l : [SELECT Id, Email FROM Lead WHERE (LeadSource = 'Signup Role' OR Lead_Source_Detail__c = 'Signup Role') AND Email != null]){
        if(l != null){
          existingSignupRoleEmails.add(l.Email);
        }
      }

      if(!existingSignupRoleEmails.isEmpty()){

        

        for(Lead appSignUp : [SELECT Id, Email, LeadSource, Lead_Source_Detail__c 
                                      FROM Lead 
                                      WHERE (LeadSource = 'App - Sign Up' OR Lead_Source_Detail__c = 'App - Sign Up') 
                                      AND Development_Platform__c != NULL 
                                      AND Email != NULL
                                      AND Email IN :existingSignupRoleEmails 
                                      AND CreatedDate > :d]){

          if(appSignUp != null){
            scopedEmails.add(appSignUp.Email);
          }

        }
      } 

      todayDate = System.today();
      query = 'SELECT Id FROM Lead WHERE IsConverted = false AND LeadSource = \'Signup Role\' AND (Email IN :scopedEmails OR CreatedDate < TODAY)';
      */

      query = 'SELECT ID FROM CASE WHERE ID = NULL';
  }
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
      //return null;
  }
  
  global void execute(Database.BatchableContext BC, List<Lead> scope) {
      
    }
    
  global void finish(Database.BatchableContext BC) {
    
  }
}