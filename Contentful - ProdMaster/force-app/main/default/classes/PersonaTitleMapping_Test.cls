@isTest
public with sharing class PersonaTitleMapping_Test {

	// Lead Persona Mapping Test Cases
    
    public static testMethod void testLeadProjectManagerAssignment(){

    	Persona_Title_Mapping__c ptm = new Persona_Title_Mapping__c();

    	ptm.Positive__c= 'Manager';
    	ptm.Negative__c= 'CEO';
    	ptm.Equals__c = 'CFO';
    	ptm.Persona__c = 'Project Manager';
    	ptm.Priority_Level__c = 2;
        ptm.Job_Function__c = 'test1';
        ptm.Job_Title__c = 'Manager';

    	insert ptm;

    	Persona_Title_Mapping__c ptm2 = new Persona_Title_Mapping__c();

    	ptm2.Positive__c= 'Designer';
    	ptm2.Negative__c= 'CEO';
    	ptm2.Equals__c = 'CFO';
    	ptm2.Persona__c = 'Developer';
    	ptm2.Priority_Level__c = 1;

    	insert ptm2;

        Lead g = new Lead();
		g.Company = 'M Lead';
		g.LastName = 'M Lead';
		g.LeadSource = 'Website Direct';
		g.Email = 'test@test.com';
		g.Title = 'Manager';
        g.Job_Function__c = 'test1';
		insert g;

		List<Lead> lstOfLeads = [SELECT Id, Persona__c FROM Lead WHERE Id =: g.Id];
		System.assertEquals('Project Manager', lstOfLeads[0].Persona__c);

    }

    public static testMethod void testLeadProjectManagerAssignmentCommaSeparated(){

    	Persona_Title_Mapping__c ptm = new Persona_Title_Mapping__c();

    	ptm.Positive__c= 'Manager;\r\nTechnical Director;\r\nHead of Technology';
    	ptm.Negative__c= 'CEO;\r\nHead of eCommerce';
    	ptm.Equals__c = 'CFO';
    	ptm.Persona__c = 'Project Manager';
    	ptm.Priority_Level__c = 1;

    	insert ptm;

    	Persona_Title_Mapping__c ptm2 = new Persona_Title_Mapping__c();

    	ptm2.Positive__c= 'Designer;\r\nHead of Frontend;\r\nHead of Technology';
    	ptm2.Negative__c= 'CEO';
    	ptm2.Equals__c = 'CFO';
    	ptm2.Not_Equals__c = 'Manager';
    	ptm2.Persona__c = 'Developer';
    	ptm2.Priority_Level__c = 2;

    	insert ptm2;

        Lead g = new Lead();
		g.Company = 'M Lead';
		g.LastName = 'M Lead';
		g.LeadSource = 'Website Direct';
		g.Email = 'test@test.com';
		g.Title = 'Manager, Designer, Head of eCommerce';
        g.Job_Function__c = 'Manager, Designer, Head of eCommerce';
		insert g;

		List<Lead> lstOfLeads = [SELECT Id, Persona__c FROM Lead WHERE Id =: g.Id];
		System.assertEquals('Developer', lstOfLeads[0].Persona__c);

    }

    public static testMethod void testLeadProjectManagerAssignmentOneCommaSeparated(){

    	Persona_Title_Mapping__c ptm = new Persona_Title_Mapping__c();

    	ptm.Positive__c= 'Manager;\r\nTechnical Director;\r\nHead of Technology';
    	ptm.Negative__c= 'CEO, Head of eCommerce';
    	ptm.Equals__c = 'CFO';
    	ptm.Persona__c = 'Project Manager';
    	ptm.Priority_Level__c = 2;

    	insert ptm;

    	Persona_Title_Mapping__c ptm2 = new Persona_Title_Mapping__c();

    	ptm2.Positive__c= 'Designer';
    	ptm2.Negative__c= 'CEO';
    	ptm2.Equals__c = 'CFO';
    	ptm2.Persona__c = 'Developer';
    	ptm2.Priority_Level__c = 1;

    	insert ptm2;

        Lead g = new Lead();
		g.Company = 'M Lead';
		g.LastName = 'M Lead';
		g.LeadSource = 'Website Direct';
		g.Email = 'test@test.com';
		g.Title = 'Manager, Designer';
        g.Job_Function__c = 'Manager, Designer';
		insert g;

		List<Lead> lstOfLeads = [SELECT Id, Persona__c FROM Lead WHERE Id =: g.Id];
		System.assertEquals('Project Manager', lstOfLeads[0].Persona__c);

    }


    public static testMethod void testLeadProjectManagerAssignmentTitleEmpty(){

    	Persona_Title_Mapping__c ptm = new Persona_Title_Mapping__c();

    	ptm.Positive__c= 'Manager;\r\nTechnical Director;\r\nHead of Technology';
    	ptm.Negative__c= 'CEO; Head of eCommerce';
    	ptm.Equals__c = 'CFO';
    	ptm.Persona__c = 'Project Manager';
    	ptm.Priority_Level__c = 2;

    	insert ptm;

    	Persona_Title_Mapping__c ptm2 = new Persona_Title_Mapping__c();

    	ptm2.Positive__c= 'Designer';
    	ptm2.Negative__c= 'CEO';
    	ptm2.Equals__c = 'CFO';
    	ptm2.Persona__c = 'Developer';
    	ptm2.Priority_Level__c = 1;

    	insert ptm2;

        Lead g = new Lead();
		g.Company = 'M Lead';
		g.LastName = 'M Lead';
		g.LeadSource = 'Website Direct';
		g.Email = 'test@test.com';
		g.Title = '';
        g.Job_Function__c = '';
		insert g;

		List<Lead> lstOfLeads = [SELECT Id, Persona__c FROM Lead WHERE Id =: g.Id];
		System.assertEquals(null, lstOfLeads[0].Persona__c);

    }

    public static testMethod void testLeadProjectManagerAssignmentTitleDefinitionMissing(){

    	Persona_Title_Mapping__c ptm = new Persona_Title_Mapping__c();

    	ptm.Positive__c= 'Manager;\r\nTechnical Director;\r\nHead of Technology';
    	ptm.Negative__c= 'CEO; Head of eCommerce';
    	ptm.Equals__c = 'CFO';
    	ptm.Persona__c = 'Project Manager';
    	ptm.Priority_Level__c = 2;

    	insert ptm;

    	Persona_Title_Mapping__c ptm2 = new Persona_Title_Mapping__c();

    	ptm2.Positive__c= 'Designer';
    	ptm2.Negative__c= 'CEO';
    	ptm2.Equals__c = 'CFO';
    	ptm2.Persona__c = 'Developer';
    	ptm2.Priority_Level__c = 1;

    	insert ptm2;

        Lead g = new Lead();
		g.Company = 'M Lead';
		g.LastName = 'M Lead';
		g.LeadSource = 'Website Direct';
		g.Email = 'test@test.com';
		g.Title = 'Content';
        g.Job_Function__c = 'Content';
		insert g;

		List<Lead> lstOfLeads = [SELECT Id, Persona__c FROM Lead WHERE Id =: g.Id];
		System.assertEquals('Other', lstOfLeads[0].Persona__c);

    }



    // Contact Persona Mapping Test Cases
    
    public static testMethod void testContactProjectManagerAssignment(){

    	Persona_Title_Mapping__c ptm = new Persona_Title_Mapping__c();

    	ptm.Positive__c= 'Manager';
    	ptm.Negative__c= 'CEO';
    	ptm.Equals__c = 'CFO';
    	ptm.Persona__c = 'Project Manager';
    	ptm.Priority_Level__c = 2;

    	insert ptm;

    	Persona_Title_Mapping__c ptm2 = new Persona_Title_Mapping__c();

    	ptm2.Positive__c= 'Designer';
    	ptm2.Negative__c= 'CEO';
    	ptm2.Equals__c = 'CFO';
    	ptm2.Persona__c = 'Developer';
    	ptm2.Priority_Level__c = 1;

    	insert ptm2;

        Account acc = new Account(	Name = 'sForceTest1', 
        							Website = 'http://www.sforcetest1.com', 
        							Phone = '(415) 901-7000)', 
        							BillingStreet =  'The Landmark @ One Market',
        							BillingCity = 'San Francisco',
        							BillingState = 'California',
        							BillingPostalCode = '94105',
        							BillingCountry = 'United States'
        							);
       	 insert acc;

		Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Title = 'Manager, Designer', Job_Function__c = 'Manager, Designer');
		insert con;

		List<Contact> lstOfContacts = [SELECT Id, Persona__c FROM Contact WHERE Id =: con.Id];
		System.assertEquals('Project Manager', lstOfContacts[0].Persona__c);

    }

    public static testMethod void testContactProjectManagerAssignmentCommaSeparated(){

    	Persona_Title_Mapping__c ptm = new Persona_Title_Mapping__c();

    	ptm.Positive__c= 'Manager;\r\nTechnical Director;\r\nHead of Technology';
    	ptm.Negative__c= 'CEO;\r\nHead of eCommerce';
    	ptm.Equals__c = 'CFO';
    	ptm.Persona__c = 'Project Manager';
    	ptm.Priority_Level__c = 1;

    	insert ptm;

    	Persona_Title_Mapping__c ptm2 = new Persona_Title_Mapping__c();

    	ptm2.Positive__c= 'Designer;\r\nHead of Frontend;\r\nHead of Technology';
    	ptm2.Negative__c= 'CEO';
    	ptm2.Equals__c = 'CFO';
    	ptm2.Persona__c = 'Developer';
    	ptm2.Priority_Level__c = 2;

    	insert ptm2;

        Account acc = new Account(	Name = 'sForceTest1', 
        							Website = 'http://www.sforcetest1.com', 
        							Phone = '(415) 901-7000)', 
        							BillingStreet =  'The Landmark @ One Market',
        							BillingCity = 'San Francisco',
        							BillingState = 'California',
        							BillingPostalCode = '94105',
        							BillingCountry = 'United States'
        							);
       	insert acc;

		Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Title = 'Manager, Designer', Job_Function__c = 'Manager, Designer');
		insert con;

		List<Contact> lstOfContacts = [SELECT Id, Persona__c FROM Contact WHERE Id =: con.Id];
		System.assertEquals('Developer', lstOfContacts[0].Persona__c);

    }

    public static testMethod void testContactProjectManagerAssignmentOneCommaSeparated(){

    	Persona_Title_Mapping__c ptm = new Persona_Title_Mapping__c();

    	ptm.Positive__c= 'Manager;\r\nTechnical Director;\r\nHead of Technology';
    	ptm.Negative__c= 'CEO;\r\nHead of eCommerce';
    	ptm.Equals__c = 'CFO';
    	ptm.Persona__c = 'Project Manager';
    	ptm.Priority_Level__c = 2;

    	insert ptm;

    	Persona_Title_Mapping__c ptm2 = new Persona_Title_Mapping__c();

    	ptm2.Positive__c= 'Designer';
    	ptm2.Negative__c= 'CEO';
    	ptm2.Equals__c = 'CFO';
    	ptm2.Persona__c = 'Developer';
    	ptm2.Priority_Level__c = 1;

    	insert ptm2;

        Account acc = new Account(	Name = 'sForceTest1', 
        							Website = 'http://www.sforcetest1.com', 
        							Phone = '(415) 901-7000)', 
        							BillingStreet =  'The Landmark @ One Market',
        							BillingCity = 'San Francisco',
        							BillingState = 'California',
        							BillingPostalCode = '94105',
        							BillingCountry = 'United States'
        							);
       	insert acc;

		Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Title = 'Manager, Designer', Job_Function__c = 'Manager, Designer');
		insert con;

		List<Contact> lstOfContacts = [SELECT Id, Persona__c FROM Contact WHERE Id =: con.Id];
		System.assertEquals('Project Manager', lstOfContacts[0].Persona__c);

    }


    public static testMethod void testContactProjectManagerAssignmentTitleEmpty(){

    	Persona_Title_Mapping__c ptm = new Persona_Title_Mapping__c();

    	ptm.Positive__c= 'Manager;\r\nTechnical Director;\r\nHead of Technology';
    	ptm.Negative__c= 'CEO;\r\nHead of eCommerce';
    	ptm.Equals__c = 'CFO';
    	ptm.Persona__c = 'Project Manager';
    	ptm.Priority_Level__c = 2;

    	insert ptm;

    	Persona_Title_Mapping__c ptm2 = new Persona_Title_Mapping__c();

    	ptm2.Positive__c= 'Designer';
    	ptm2.Negative__c= 'CEO';
    	ptm2.Equals__c = 'CFO';
    	ptm2.Persona__c = 'Developer';
    	ptm2.Priority_Level__c = 1;

    	insert ptm2;

        Account acc = new Account(	Name = 'sForceTest1', 
        							Website = 'http://www.sforcetest1.com', 
        							Phone = '(415) 901-7000)', 
        							BillingStreet =  'The Landmark @ One Market',
        							BillingCity = 'San Francisco',
        							BillingState = 'California',
        							BillingPostalCode = '94105',
        							BillingCountry = 'United States'
        							);
       	insert acc;

		Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Title = '', Job_Function__c = '');
		insert con;

		List<Contact> lstOfContacts = [SELECT Id, Persona__c FROM Contact WHERE Id =: con.Id];
		System.assertEquals(null, lstOfContacts[0].Persona__c);

    }

    public static testMethod void testContactProjectManagerAssignmentTitleDefinitionMissing(){

    	Persona_Title_Mapping__c ptm = new Persona_Title_Mapping__c();

    	ptm.Positive__c= 'Manager;\r\nTechnical Director;\r\nHead of Technology';
    	ptm.Negative__c= 'CEO;\r\nHead of eCommerce';
    	ptm.Equals__c = 'CFO';
    	ptm.Persona__c = 'Project Manager';
    	ptm.Priority_Level__c = 2;

    	insert ptm;

    	Persona_Title_Mapping__c ptm2 = new Persona_Title_Mapping__c();

    	ptm2.Positive__c= 'Designer';
    	ptm2.Negative__c= 'CEO';
    	ptm2.Equals__c = 'CFO';
    	ptm2.Persona__c = 'Developer';
    	ptm2.Priority_Level__c = 1;

    	insert ptm2;

        Account acc = new Account(	Name = 'sForceTest1', 
        							Website = 'http://www.sforcetest1.com', 
        							Phone = '(415) 901-7000)', 
        							BillingStreet =  'The Landmark @ One Market',
        							BillingCity = 'San Francisco',
        							BillingState = 'California',
        							BillingPostalCode = '94105',
        							BillingCountry = 'United States'
        							);
       	insert acc;

		Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Title = 'Content', Job_Function__c = 'Content');
		insert con;

		List<Contact> lstOfContacts = [SELECT Id, Persona__c FROM Contact WHERE Id =: con.Id];
		System.assertEquals('Other', lstOfContacts[0].Persona__c);

    }

    public static testMethod void testContactProjectManagerAssignmentTitleDefinitionWithComma(){

    	Persona_Title_Mapping__c ptm = new Persona_Title_Mapping__c();

    	ptm.Positive__c= 'Manager;\r\nTechnical, Director;\r\nHead of Technology';
    	ptm.Negative__c= 'CEO;\r\nHead of eCommerce';
    	ptm.Equals__c = 'CFO';
    	ptm.Persona__c = 'Project Manager';
    	ptm.Priority_Level__c = 2;

    	insert ptm;

    	Persona_Title_Mapping__c ptm2 = new Persona_Title_Mapping__c();

    	ptm2.Positive__c= 'Designer; Technical';
    	ptm2.Negative__c= 'CEO';
    	ptm2.Equals__c = 'CFO';
    	ptm2.Persona__c = 'Developer';
    	ptm2.Priority_Level__c = 1;

    	insert ptm2;

        Account acc = new Account(	Name = 'sForceTest1', 
        							Website = 'http://www.sforcetest1.com', 
        							Phone = '(415) 901-7000)', 
        							BillingStreet =  'The Landmark @ One Market',
        							BillingCity = 'San Francisco',
        							BillingState = 'California',
        							BillingPostalCode = '94105',
        							BillingCountry = 'United States'
        							);
       	insert acc;

		Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Title = 'Technical, Director', Job_Function__c = 'Technical, Director');
		insert con;

		List<Contact> lstOfContacts = [SELECT Id, Persona__c FROM Contact WHERE Id =: con.Id];
		System.assertEquals('Project Manager', lstOfContacts[0].Persona__c);

    }
}