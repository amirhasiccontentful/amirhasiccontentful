public with sharing class OrderTriggerHandler extends TriggerHandler {
/*	public override void afterInsert() {
		CreateTasks(trigger.new);
	}

	// LEGACY we can remove it and refactor it
	private void CreateTasks(List<Order> orders) {
		List<Task> tasks = new List<Task>();

		for (Order ord : orders) {

			//Id ownerId = ord.Dhruvsoft__Opportunity__r.OwnerId;
			Id ownerId = ord.OwnerId; //'005w0000004GQZS';
			
			Date dueDate = Date.today().addDays(7);
			
			// general - account mgmt
			
			id oppId = ord.Dhruvsoft__Opportunity__c;
			
			Opportunity opp = [SELECT id, Category__c, Type, Has_Guaranteed_Upgrades__c, Referring_Account__c, Referrer_Commission__c, Marketing_Case_Study__c, Marketing_Badge_on_Website__c, Product_On_site_Research_Observation__c, Product_Remote_Usabillity_Interview__c, Product_Beta_Testing_Feedback__c, Current_Quote__c  FROM Opportunity WHERE id = :oppId LIMIT 1][0];
			Boolean newCustomer = opp.Category__c == 'Enterprise' && opp.Type == 'Initial';
			
			
			if (newCustomer == true) {
	        	tasks.add( CF_Base.taskForOrder('Create and archive contract', 'Create a Contract in Salesforce and save a PDF of the counter-signed contract as an attached file.', 'Account Management', ord, ownerId, dueDate) );
	        	tasks.add( CF_Base.taskForOrder('Introduce Account Management', 'After a deal is closed Sales has to intro our account management team as the official primary point of contact for enterprise customers.', 'Account Management', ord, ownerId, dueDate) );
	        	tasks.add( CF_Base.taskForOrder('Fill out Enterprise Setup Form', 'Send them our Enterprise Setup Form to give us the necessary details to set up their account.', 'Account Management', ord, ownerId, dueDate) );
			}
	        
	        tasks.add( CF_Base.taskForOrder('Set up subscription in Zuora', 'Sent the primary quote to Z-Billing with the correct contract effective and contract activation dates', 'Account Management', ord, ownerId, dueDate) );
	        
	        if (opp.Has_Guaranteed_Upgrades__c == true) {
				tasks.add( CF_Base.taskForOrder('Set up Zuora subscription amendments for included upgrades', 'In Zuora add future amendments that change the MRR and the included features/limits', 'Account Management', ord, ownerId, dueDate) );        	
	        }
	             
	        tasks.add( CF_Base.taskForOrder('Tidy up Salesforce account', 'Merge leads, update contacts and tidy up the whole account. They are now enterprise level and deserve special treatment.', 'Account Management', ord, ownerId, dueDate) );
	        
	        // general - operations
	        
	        if (newCustomer == true) {
		        tasks.add( CF_Base.taskForOrder('Introduce Operations for vendor registration', 'Our Account management team introduces operations to fill out any required vendor forms and surveys.', 'Account Management', ord, ownerId, dueDate) );
		        
		        tasks.add( CF_Base.taskForOrder('Collect first invoice', 'Our Account management works with the customer to get the first invoice paid.', 'Operations', ord, ownerId, dueDate) );        	
	        }

			if (opp.Referring_Account__c != null && opp.Referrer_Commission__c > 0) {
				tasks.add( CF_Base.taskForOrder('Pay commissions to the refering account', 'A partner refered the opportunity and commissions need to be paid.', 'Operations', ord, ownerId, dueDate) );	
			}        
	        
	        
	        // check quote for items that require setup (custom field)
	        
	        List<zqu__Quote__c> quotes = [SELECT id FROM zqu__Quote__c WHERE id = :opp.Current_Quote__c LIMIT 1];
	        
	        if (quotes.size () > 0) {
	        	zqu__Quote__c quote = quotes[0];
	        	
		        List<zqu__QuoteRatePlan__c> quoteRatePlans = [SELECT id FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c = :quote.id];
		        
		        Set<Id> quoteRatePlanIds = new Set<Id>();
		        
		        for (zqu__QuoteRatePlan__c qrp : quoteRatePlans) {
		        	quoteRatePlanIds.add(qrp.id);
		        }
		        
		        List<zqu__QuoteRatePlanCharge__c> quoteRatePlanCharges = [SELECT id, zqu__ProductRatePlanCharge__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__c IN :quoteRatePlanIds]; 
				
				Set<Id> productRatePlanChargeIds = new Set<Id>();
				
				for (zqu__QuoteRatePlanCharge__c c : quoteRatePlanCharges) {
					productRatePlanChargeIds.add(c.zqu__ProductRatePlanCharge__c);
				}
				
				List<zqu__ProductRatePlanCharge__c> productRatePlanCharges = [SELECT id, Name, InternalName__c, RequiresManualSetup__c FROM zqu__ProductRatePlanCharge__c WHERE id IN :productRatePlanChargeIds];
				
				for (zqu__ProductRatePlanCharge__c charge : productRatePlanCharges) {
					if (charge.RequiresManualSetup__c == 'Yes') {
						// product add-ons
						
						if (charge.InternalName__c == 'silver_support' || charge.InternalName__c == 'gold_support' || charge.InternalName__c == 'platinum_support' || charge.InternalName__c == 'custom_support') {
							tasks.add( CF_Base.taskForOrder('Feature setup: ' + charge.name, 'The account needs to be set up in Zendesk for the SLA.', 'Account Management', ord, ownerId, dueDate) );	
						}

						if (charge.InternalName__c == 'offsite_backup') {
							tasks.add( CF_Base.taskForOrder('Feature setup: ' + charge.name, 'Offsite backup configuration needs to be set up with the customer in the app.', 'Account Management', ord, ownerId, dueDate) );	
						}

						if (charge.InternalName__c == 'custom_api_domain') {
							tasks.add( CF_Base.taskForOrder('Feature setup: ' + charge.name, 'The custom API domain needs to be set up together with our DevOps team.', 'Account Management', ord, ownerId, dueDate) );	
						}					
						
						if (charge.InternalName__c == 'custom_asset_domain') {
							tasks.add( CF_Base.taskForOrder('Feature setup: ' + charge.name, 'The custom Asset domain needs to be set up together with our DevOps team.', 'Account Management', ord, ownerId, dueDate) );	
						}	
						
						if (charge.InternalName__c == 'getty_images') {
							tasks.add( CF_Base.taskForOrder('Feature setup: ' + charge.name, 'Getty Image credentials need to be set up by the Gatekeeper team.', 'Account Management', ord, ownerId, dueDate) );	
						}						

						if (charge.InternalName__c == 'business_continuity') {
							tasks.add( CF_Base.taskForOrder('Feature setup: ' + charge.name, 'Business Continuity needs to be set up with operations (source code escrow) and our Dev Ops team (training).', 'Account Management', ord, ownerId, dueDate) );	
						}

						if (charge.InternalName__c == 'dedicated_database') {
							tasks.add( CF_Base.taskForOrder('Feature setup: ' + charge.name, 'Our Dev Ops team has to set up a dedicated database shard for this customer.', 'Account Management', ord, ownerId, dueDate) );	
						}					

						if (charge.InternalName__c == 'dedicated_app_servers') {
							tasks.add( CF_Base.taskForOrder('Feature setup: ' + charge.name, 'Our Dev Ops team has to set up dedicated app servers for this customer.', 'Account Management', ord, ownerId, dueDate) );	
						}	
						
						// professional services						
						
						if (charge.InternalName__c == 'custom_development') {
							tasks.add( CF_Base.taskForOrder('Professional Services: ' + charge.name, 'Plan and finalize custom development work.', 'Account Management', ord, ownerId, dueDate) );	
						}	

						if (charge.InternalName__c == 'consulting') {
							tasks.add( CF_Base.taskForOrder('Professional Services: ' + charge.name, 'Plan, conduct and invoice one-time consulting work.', 'Account Management', ord, ownerId, dueDate) );	
						}	
						
						if (charge.InternalName__c == 'training') {
							tasks.add( CF_Base.taskForOrder('Professional Services: ' + charge.name, 'Plan, conduct and invoice one-time training.', 'Account Management', ord, ownerId, dueDate) );	
						}						
						
						if (charge.InternalName__c == 'training_subscription') {
							tasks.add( CF_Base.taskForOrder('Professional Services: ' + charge.name, 'Plan and conduct regular trainings.', 'Account Management', ord, ownerId, dueDate) );	
						}	
						
						if (charge.InternalName__c == 'training_subscription') {
							tasks.add( CF_Base.taskForOrder('Professional Services: ' + charge.name, 'Plan and conduct regular trainings.', 'Account Management', ord, ownerId, dueDate) );	
						}																						
					}
				}        	
	        }
	        
	        // guarantees - marketing
	        
	        if (opp.Marketing_Case_Study__c == true) {
	        	tasks.add( CF_Base.taskForOrder('Create marketing case study', 'We received a guaranteed case study and need to interview the customer and write it.', 'Marketing', ord, ownerId, null) );
	        }
	        
	        if (opp.Marketing_Badge_on_Website__c == true) {
	        	tasks.add( CF_Base.taskForOrder('Provide and check CF badge installation', 'Customer agreed to put a Contentful logo on their website/app. We have to provide them the logo andn check that this is done.', 'Account Management', ord, ownerId, null) );
	        }
	        
	        // guarantees - product
	        
	        if (opp.Product_On_site_Research_Observation__c == true) {
	        	tasks.add( CF_Base.taskForOrder('Conduct on-site usability study', 'We received a guaranteed on-site usability study and need to organize this with the customer.', 'Product', ord, ownerId, null) );
	        }
	        
	        if (opp.Product_Remote_Usabillity_Interview__c == true) {
	        	tasks.add( CF_Base.taskForOrder('Conduct remote usability study', 'We received a guaranteed remote usability study and need to organize this with the customer.', 'Product', ord, ownerId, null) ); 
	        }
	        
	        if (opp.Product_Beta_Testing_Feedback__c == true) {
	        	tasks.add( CF_Base.taskForOrder('Invite to beta testing', 'We received a guarantee to receive feedback for beta functionality in our product.', 'Product', ord, ownerId, null) );
	        }    	
		}
		
		insert tasks;
		}*/
}