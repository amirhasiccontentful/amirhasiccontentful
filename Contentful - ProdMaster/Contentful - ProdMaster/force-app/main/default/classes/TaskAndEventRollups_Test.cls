@isTest
public class TaskAndEventRollups_Test {
    
    public static testMethod void testTaskRollups(){

        List<ExecuteSetting__c> newSettingsForInsert = new List<ExecuteSetting__c>();

        ExecuteSetting__c newSetting = new ExecuteSetting__c();
        newSetting.Name = 'Task Rollups';
        newSetting.Active__c = true;
        newSetting.Execute__c = false;
        newSettingsForInsert.add(newSetting);

        ExecuteSetting__c newSetting2 = new ExecuteSetting__c();
        newSetting2.Name = 'Rollup Activity Dates To Account';
        newSetting2.Active__c = true;
        newSetting2.Execute__c = true;
        newSettingsForInsert.add(newSetting2);

        insert newSettingsForInsert;
        
        User u;

        List<User> otherAdmin = [SELECT Id, Name FROM User WHERE Profile.Name = 'System Administrator' AND isActive = TRUE AND Id != :UserInfo.getUserId()];

        System.runAs(otherAdmin[0]){

            UserRole rl = [SELECT Id FROM UserRole WHERE Name = 'SDR'];

            u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales'].Id,
             LastName = 'last',
             Email = 'conttentful@bbbb.com',
             Username = 'conttentful@bbbbb.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'CSM',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             UserRoleId = rl.Id
            );

            insert u;

        }
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        //acc.Most_Recent_In_Person_Meeting__c = System.now().addDays(-3);
        insert acc;

        Lead newLead = new Lead();
        newLead.LastName = 'Test';
        newLead.Company = 'Test';
        newLead.LeadSource = 'Other';
        newLead.Status = 'Open';
        insert newLead;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'Discovery';
        opp.CloseDate = system.today();
        opp.Amount = 1;
        opp.Description = 'Testing closed won';
        insert opp;

        List<Task> lstOfTasks = new List<Task>();
        
        Task tsk = new Task();
        tsk.Subject = 'Test 1';
        tsk.WhoId = newLead.Id;
        tsk.ActivityDate = system.today().addDays(6);
        tsk.CreatedDate = system.today() - 3;
        tsk.Type = 'In-person - Discovery';
        tsk.Status = 'Completed';
        tsk.CC__Task_outcome_c__c = 'C:11111111111';
        tsk.Product_Relevant_Input__c = true;
        lstOfTasks.add(tsk);

        Task tsk2 = new Task();
        tsk2.Subject = 'Test 2';
        //tsk2.WhoId = newLead.Id;
        tsk2.WhatId = opp.Id;
        tsk2.ActivityDate = system.today().addDays(1);
        tsk2.CreatedDate = system.today();
        tsk2.Type = 'In-person - Discovery';
        tsk2.Status = 'Completed';
        tsk2.CC__Task_outcome_c__c = 'C:11111111111';
        lstOfTasks.add(tsk2);

        Task tsk3 = new Task();
        tsk3.Subject = 'Test 3';
        tsk3.WhatId = acc.Id;
        tsk3.ActivityDate = system.today().addDays(4);
        tsk3.CreatedDate = system.today();
        tsk3.Type = 'Email - Other';
        tsk3.Status = 'Completed';
        tsk3.CC__Task_outcome_c__c = 'C:11111111111';
        tsk3.Description =    'From: ewelina@contentful.com\n' 
                            + 'To: marcel.pinnow@deutschebahn.com\n'
                            + 'Cc: kai.weber@deutschebahn.com, sven.sv.hesse@deutschebahn.com, thomas.t.vollmer@deutschebahn.com, thomas.pustelnik@fi2q.com\n'
                            + 'Bcc: \n'
                            + 'Subject: Re: Contentful: account set up, final step\n'
                            + 'Body:\n'
                            + 'Hi everyone, \n'
                            + 'apologies for back and forth, but to ensure everything is correct, would you let me know which of the following spaces (from Org 0ts4yn5qlrLTezwnVx93Q2) is to be upgraded to LARGE space? \n\n'
                            + 'Dev Space: yhjl2hfcsp6uIAT Space: s04rvhbiwa4jProd. Space: u650fhji7tve \n'
                            + 'The other two will be turned into micro spaces. You can also export them, or spin of dev environments from production space. \n'
                            + 'Looking forward to your feedback and thank you in advance,Ewe \n'
                            + 'On Thu, Jun 21, 2018 at 7:51 AM, Ewelina Grajko < ewelina@contentful.com <mailto:ewelina@contentful.com>> wrote:\n'
                            + 'Good morning everyone, \n'
                            + 'the move has been done - please let me know if you encounter any issues, I will be happy to help! \n'
                            + 'Looking forward to seeing you tomorrow. \n'
                            + 'Best,Ewe \n'
                            + 'On Wed, Jun 20, 2018 at 6:12 PM, Ewelina Grajko < ewelina@contentful.com <mailto:ewelina@contentful.com>> wrote: \n'
                            + 'Hi Marcel, \n'
                            + 'thank you for the permissions! I will perform the move tomorrow morning, allowing you to immediately see if any problems occurred - I am assuming the day is almost over for you? \n'
                            + 'he organisation name can be changed by the Owner of the Organisation, in that case Thomas P. --> if you encounter troubles, I can help :) \n'
                            + 'Best, \n'
                            + 'Ewe \n '

                            + 'From: fb@test.ba \n' 
                            + 'To: marcel.pinnow@deutschebahn.com\n'
                            + 'Cc: kai.weber@deutschebahn.com, sven.sv.hesse@deutschebahn.com, thomas.t.vollmer@deutschebahn.com, thomas.pustelnik@fi2q.com\n'
                            + 'Bcc: \n'
                            + 'Subject: Re: Contentful: account set up, final step\n'
                            + 'Body:\n'
                            + 'Hi everyone, \n'
                            + 'apologies for back and forth, but to ensure everything is correct, would you let me know which of the following spaces (from Org 0ts4yn5qlrLTezwnVx93Q2) is to be upgraded to LARGE space? \n'
                            + 'Dev Space: yhjl2hfcsp6uIAT Space: s04rvhbiwa4jProd. Space: u650fhji7tve \n'
                            + 'The other two will be turned into micro spaces. You can also export them, or spin of dev environments from production space. \n\n'
                            + 'Looking forward to your feedback and thank you in advance,Ewe \n'
                            + 'On Thu, Jun 21, 2018 at 7:51 AM, Ewelina Grajko < ewelina@contentful.com <mailto:ewelina@contentful.com>> wrote:\n'
                            + 'Good morning everyone, \n'
                            + 'the move has been done - please let me know if you encounter any issues, I will be happy to help! \n'
                            + 'Looking forward to seeing you tomorrow. \n'
                            + 'Best,Ewe \n'
                            + 'On Wed, Jun 20, 2018 at 6:12 PM, Ewelina Grajko < ewelina@contentful.com <mailto:ewelina@contentful.com>> wrote: \n'
                            + 'Hi Marcel, \n\n'
                            + 'thank you for the permissions! I will perform the move tomorrow morning, allowing you to immediately see if any problems occurred - I am assuming the day is almost over for you? \n'
                            + 'he organisation name can be changed by the Owner of the Organisation, in that case Thomas P. --> if you encounter troubles, I can help :) \n'
                            + 'Best, \n'
                            + 'Ewe ';
        lstOfTasks.add(tsk3);

        

        System.runAs(u){
            insert lstOfTasks;
        }

        List<Lead> checkLeads = [SELECT Id, Last_Task_Creation_Date__c, Task_Count__c, Last_Task_Date__c FROM Lead WHERE Id = :newLead.Id];

        System.assertEquals(system.today() - 3, checkLeads[0].Last_Task_Creation_Date__c);
        System.assertEquals(1, checkLeads[0].Task_Count__c);
        System.assertEquals(system.today().addDays(6), checkLeads[0].Last_Task_Date__c);

        /*List<Opportunity> checkOpp = [SELECT Id, Last_Task_Creation_Date__c, Task_Count__c, Last_Task_Date__c FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals(system.today(), checkOpp[0].Last_Task_Creation_Date__c);
        System.assertEquals(1, checkOpp[0].Task_Count__c);
        System.assertEquals(system.today() + 1, checkOpp[0].Last_Task_Date__c);
		*/
        update lstOfTasks;
        List<Account> checkAccounts = [SELECT Id, 
                                              Most_Recent_Email_From_Customer__c,
                                              Most_Recent_Email_From_Customer_to_CSM__c,
                                              Most_Recent_Email_Outreach__c,
                                              Most_Recent_Email_Outreach_by_CSM__c,
                                              Most_Recent_In_Person_Meeting__c,
                                              Most_Recent_In_Person_Meeting_with_CSM__c,
                                              Most_Recent_Phone_Call__c,
                                              Most_Recent_Phone_Call_with_CSM__c FROM Account];
        
        //System.assertEquals(system.today().addDays(1), checkAccounts[0].Most_Recent_In_Person_Meeting__c);
        //System.assertEquals(system.today().addDays(1), checkAccounts[0].Most_Recent_In_Person_Meeting_with_CSM__c);
        System.assertEquals(system.today().addDays(4), checkAccounts[0].Most_Recent_Email_Outreach__c);
        System.assertEquals(system.today().addDays(4), checkAccounts[0].Most_Recent_Email_From_Customer__c);
    }


    public static testMethod void testEventRollups(){

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Lead newLead = new Lead();
        newLead.LastName = 'Test';
        newLead.Company = 'Test';
        newLead.LeadSource = 'Other';
        newLead.Status = 'Open';
        insert newLead;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'Discovery';
        opp.CloseDate = system.today();
        opp.Amount = 1;
        opp.Description = 'Testing closed won';
        insert opp;
        
        Event event = new Event();
        event.Subject = 'Test 1';
        event.WhoId = newLead.Id;
        event.ActivityDateTime = system.now().addDays(6);
        event.CreatedDate = system.today() - 3;
        event.DurationInMinutes = 45;
        insert event;

        Event event2 = new Event();
        event2.Subject = 'Test 2';
        //event2.WhoId = newLead.Id;
        event2.WhatId = opp.Id;
        event2.ActivityDateTime = system.now().addDays(1);
        event2.CreatedDate = system.today();
        event2.DurationInMinutes = 45;
        insert event2;

        List<Lead> checkLeads = [SELECT Id, Last_Event_Creation_Date__c, Event_Count__c, Last_Event_Date__c FROM Lead WHERE Id = :newLead.Id];

        System.assertEquals(system.today() - 3, checkLeads[0].Last_Event_Creation_Date__c);
        System.assertEquals(1, checkLeads[0].Event_Count__c);
        //System.assertEquals(system.today().addDays(6), Date.valueof(checkLeads[0].Last_Event_Date__c));

        /*List<Opportunity> checkOpp = [SELECT Id, Last_Event_Creation_Date__c, Event_Count__c, Last_Event_Date__c FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals(system.today(), checkOpp[0].Last_Event_Creation_Date__c);
        System.assertEquals(1, checkOpp[0].Event_Count__c);
        //System.assertEquals(system.today() + 1, checkOpp[0].Last_Event_Date__c);*/
    }


    public static testMethod void testTaskAndEventOrderRollups(){

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'Discovery';
        opp.CloseDate = system.today();
        opp.Amount = 1;
        opp.Description = 'Testing closed won';
        insert opp;

        List<Order> lstOfOrdersForInsert = new List<Order>();

        Order o = new Order();
        o.AccountId = acc.Id;
        o.Dhruvsoft__Opportunity__c = opp.Id;
        o.EffectiveDate = System.today();
        o.Status = 'Draft';
        lstOfOrdersForInsert.add(o);

        Order o2 = new Order();
        o2.AccountId = acc.Id;
        o2.Dhruvsoft__Opportunity__c = opp.Id;
        o2.EffectiveDate = System.today();
        o2.Status = 'Draft';
        lstOfOrdersForInsert.add(o2);

        insert lstOfOrdersForInsert;

        List<Task> lstOfTasks = new List<Task>();
        
        Task tsk = new Task();
        tsk.Subject = 'Test 1';
        tsk.WhatId = o.Id;
        tsk.ActivityDate = system.today().addDays(6);
        tsk.CreatedDate = system.today() - 3;
        tsk.Status = 'Open';
        lstOfTasks.add(tsk);

        Task tsk2 = new Task();
        tsk2.Subject = 'Test 2';
        tsk2.WhatId = o.Id;
        //tsk2.ActivityDate = system.today().addDays(1);
        tsk2.CreatedDate = system.today();
        tsk2.Status = 'Open';
        lstOfTasks.add(tsk2);

        Task tsk3 = new Task();
        tsk3.Subject = 'Test 2';
        tsk3.WhatId = o.Id;
        tsk3.ActivityDate = system.today().addDays(1);
        tsk3.CreatedDate = system.today();
        tsk3.Status = 'Open';
        lstOfTasks.add(tsk3);

        Task tsk4 = new Task();
        tsk4.Subject = 'Test 2';
        tsk4.WhatId = o2.Id;
        tsk4.ActivityDate = system.today().addDays(1);
        tsk4.CreatedDate = system.today();
        tsk4.Status = 'Open';
        lstOfTasks.add(tsk4);

        insert lstOfTasks;

        /*List<Order> checkOrder = [SELECT Id, Open_Task_With_Due_Date_Count__c, Task_Count__c, Open_Task_Count__c FROM Order WHERE Id = :o.Id];

        System.assertEquals(2, checkOrder[0].Open_Task_With_Due_Date_Count__c);
        System.assertEquals(3, checkOrder[0].Task_Count__c);
        System.assertEquals(3, checkOrder[0].Open_Task_Count__c);*/
    }
}