public without sharing class ContentfulSetupForm {

	public Contentful_Setup_Form__c setupForm {get; set;}
	public List<Contentful_Setup_Form__c> existingSetupForm {get; set;}
	public Id setupFormAccountId {get; set;}
	public Boolean isNewForm {get; set;}
	public Boolean showInputForm {get; set;}
	public Boolean formLocked {get; set;}
	public Contact con {get; set;}
	
	public ContentfulSetupForm(){

		setupFormAccountId = apexpages.currentpage().getparameters().get('id');
		showInputForm = true;
		formLocked = false;

		con = new Contact();

		if(setupFormAccountId != null){
			existingSetupForm = [SELECT Id, 
										Name, 
										Upgrade_a_new_or_a_pre_existing_account__c,
										Account_s_organization_ID__c,
										Spaces_to_upgrade_to_the_Enterprise_plan__c,
										Organization_owners_email_addresses__c,
										Email_domains__c,
										Company_name__c,
										Mailing_address__c,
										Invoicing_contact_name__c,
										Invoicing_contact_email_address__c,
										Phone_number_for_billing_inquiries__c,
										PO_number__c,
										VAT_ID__c,
										Primary_contact_name__c,
										Primary_contact_email__c,
										Billing_contact_name__c,
										Billing_contact_email__c,
										Technical_contact_name__c,
										Technical_contact_email__c,
										Editorial_contact_name__c,
										Editorial_contact_email__c,
										Account_name__c,
										Account__c,
										Account__r.billing_entity__c,
										Mailling_Street__c,
										Mailling_City__c,
										Mailling_State__c,
										Mailing_Postal_Code__c,
										Mailling_Country__c,
										Form_Locked__c
										FROM Contentful_Setup_Form__c WHERE Id = :setupFormAccountId LIMIT 1];
		}
		
		if(existingSetupForm.isEmpty()){
			setupForm = new Contentful_Setup_Form__c();
		} else{
			setupForm = existingSetupForm[0];

			con.MailingStateCode = existingSetupForm[0].Mailling_State__c;
			con.MailingCountryCode = existingSetupForm[0].Mailling_Country__c;

			if(setupForm.Form_Locked__c == true){
				formLocked = true;
			}
		}
		
	}
	
	public void save(){

		try{
			if(setupFormAccountId != null && setupForm.Form_Locked__c == false){
				setupForm.Id = setupFormAccountId;
				setupForm.Form_Locked__c = true;
				setupForm.Mailling_State__c = con.MailingStateCode;
				setupForm.Mailling_Country__c = con.MailingCountryCode;
			}

			update setupForm; // upsert by Account_s_organization_ID__c???
			showInputForm = false;
			formLocked = true;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Thank you. Your form was successfully submitted!'));
		} catch (Exception e){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'There was a issue with the form submission. Please try again.'));
		}
		
	}
}