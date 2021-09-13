global class PartnerScore_Batchable implements Database.Batchable<sObject> {

  global final String query;
    
  global PartnerScore_Batchable() {
      
      query = 'SELECT Id, Partner_Score_No__c, Had_Partner_Intro_Call__c, X1_Opp_or_Interest_in_Partnering__c, NDA_Partner_Doc_Signed__c, Delivered_Capabilities_Overview_w_3__c, Delivered_Content_Services_Prtnr_Prgm__c, Executed_Account_Mapping_Session__c, Executed_Tech_Team_Training_last_6_mo__c, Executed_Acct_Mngr_Training_last_6_mo__c, Used_Sandbox_to_trial_Contentful_tech__c, Determined_Contentful_Practice_Leader__c, Walked_through_Partner_Sales_Process__c, PR_Landing_Page_Marketing_Activity__c, Bi_weekly_or_Monthly_Pipeline_Call__c, Contentful_is_Preferred_Content_Solution__c, Selling_Contentful_is_Strat_Initiative__c, Developed_GTM_Business_Plan__c, of_Contentful_Certified_Devs__c, of_Onsite_Meetings_Past_Year__c, of_Opps_Worked_Together_in_Past_Year__c FROM Account WHERE LastModifiedDate = TODAY';
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext BC, List<Account> scope) {
      
      if(scope.isEmpty()) return;

      List<Account> accountsForUpdate = new List<Account>();

      for(Account account : scope){
        account.Partner_Score_No__c = 0;

			if(account.Had_Partner_Intro_Call__c == true){
				account.Partner_Score_No__c += 2;
			}

			if(account.X1_Opp_or_Interest_in_Partnering__c == true){
				account.Partner_Score_No__c += 2;
			}

			if(account.NDA_Partner_Doc_Signed__c == true){
				account.Partner_Score_No__c += 2;
			}

			if(account.Delivered_Capabilities_Overview_w_3__c == true){
				account.Partner_Score_No__c += 2;
			}

			if(account.Delivered_Content_Services_Prtnr_Prgm__c == true){
				account.Partner_Score_No__c += 2;
			}

			if(account.Executed_Account_Mapping_Session__c == true){
				account.Partner_Score_No__c += 4;
			}

			if(account.Executed_Tech_Team_Training_last_6_mo__c == true){
				account.Partner_Score_No__c += 4;
			}

			if(account.Executed_Acct_Mngr_Training_last_6_mo__c == true){
				account.Partner_Score_No__c += 5;
			}

			if(account.Used_Sandbox_to_trial_Contentful_tech__c == true){
				account.Partner_Score_No__c += 3;
			}

			if(account.Determined_Contentful_Practice_Leader__c == true){
				account.Partner_Score_No__c += 5;
			}

			if(account.Walked_through_Partner_Sales_Process__c == true){
				account.Partner_Score_No__c += 5;
			}

			if(account.PR_Landing_Page_Marketing_Activity__c == true){
				account.Partner_Score_No__c += 8;
			}

			if(account.Bi_weekly_or_Monthly_Pipeline_Call__c == true){
				account.Partner_Score_No__c += 6;
			}

			if(account.Contentful_is_Preferred_Content_Solution__c == true){
				account.Partner_Score_No__c += 5;
			}

			if(account.Selling_Contentful_is_Strat_Initiative__c == true){
				account.Partner_Score_No__c += 7;
			}

			if(account.Developed_GTM_Business_Plan__c == true){
				account.Partner_Score_No__c += 8;
			}

			if(account.of_Contentful_Certified_Devs__c != null){
				if(account.of_Contentful_Certified_Devs__c == '1 - 9'){
					account.Partner_Score_No__c += 2;
				} else if(account.of_Contentful_Certified_Devs__c == '10 - 29'){
					account.Partner_Score_No__c += 4;
				} else if(account.of_Contentful_Certified_Devs__c == '30 - 99'){
					account.Partner_Score_No__c += 8;
				} else if(account.of_Contentful_Certified_Devs__c == '100+'){
					account.Partner_Score_No__c += 10;
				}
			}

			if(account.of_Onsite_Meetings_Past_Year__c != null){
				if(account.of_Onsite_Meetings_Past_Year__c == '1 - 2'){
					account.Partner_Score_No__c += 4;
				} else if(account.of_Onsite_Meetings_Past_Year__c == '3 - 5'){
					account.Partner_Score_No__c += 6;
				} else if(account.of_Onsite_Meetings_Past_Year__c == '6+'){
					account.Partner_Score_No__c += 8;
				}
			}

			if(account.of_Opps_Worked_Together_in_Past_Year__c != null){
				if(account.of_Opps_Worked_Together_in_Past_Year__c == '0 - 1'){
					account.Partner_Score_No__c += 2;
				} else if(account.of_Opps_Worked_Together_in_Past_Year__c == '2 - 4'){
					account.Partner_Score_No__c += 6;
				} else if(account.of_Opps_Worked_Together_in_Past_Year__c == '5 - 9'){
					account.Partner_Score_No__c += 10;
				} else if(account.of_Opps_Worked_Together_in_Past_Year__c == '10+'){
					account.Partner_Score_No__c += 12;
				}
			}
        accountsForUpdate.add(account);
      }

      if(!accountsForUpdate.isEmpty()) update accountsForUpdate;
  }
    
  global void finish(Database.BatchableContext BC) {
    
  }
}