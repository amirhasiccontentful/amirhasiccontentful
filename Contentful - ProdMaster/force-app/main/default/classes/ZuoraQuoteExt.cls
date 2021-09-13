public class ZuoraQuoteExt {
	// Public Properties
	public Id zQuoteId { get; set; }
	public zqu__Quote__c quote { get; set; }
	public String payment { get; set; }

	public Boolean isSilverSLA { get; set; }
	public Boolean isGoldSLA { get; set; }
	public Boolean isPlatinumSLA { get; set; }
	public Boolean isDiamondSLA { get; set; }

	public Boolean showUsage { get; set; }
	public Boolean showSLA { get; set; }
	public Boolean showBase { get; set; }
	public Boolean showAddon { get; set; }
	public Boolean showDiscount { get; set; }
	public Boolean showProjects { get; set; }
	public Boolean showProperties { get; set; }

	public List<Charge> charges { get; set; }
	public List<Project__c> projects { get; set; }

	public Integer numberOfProjects { get; set; }
	public Decimal projectsPrice { get; set; }
	public Boolean projectsValueValidation { get; set; }

	public Decimal platformTotalReccuring { get; set; }
	public Decimal addonsTotalReccuring { get; set; }
	public Decimal slaTotalReccuring { get; set; }
	public Decimal discountTotalReccuring { get; set;}
	public Decimal propertiesTotalReccuring { get; set; }

	public Decimal platformTotalOneTime { get; set; }
	public Decimal addonsTotalOneTime { get; set; }
	public Decimal slaTotalOneTime { get; set; }
	public Decimal discountTotalOneTime { get; set;}

	public Boolean showTotalReccuring { get; set; }
	public Boolean showTotalOneTime { get; set; }

	public Decimal setupFee { get; set; }


	public class Charge {
		public String name { get; set; }
		public String description { get; set; }
		public Decimal price { get; set; }
		public Decimal included { get; set; } 
		public String additionalInformation { get; set; } 
		public String chargeType { get; set; } 
		public Decimal quantity { get; set; }
	}

	public ZuoraQuoteExt(){}
	public ZuoraQuoteExt(ApexPages.StandardController controller) {
		this.zQuoteId = controller.getId();
		this.quote = (zqu__Quote__c)controller.getRecord();

		this.showTotalReccuring = false;
		this.showTotalOneTime = false;
		this.projectsValueValidation = true;

		this.platformTotalReccuring = 0;
		this.addonsTotalReccuring = 0;
		this.slaTotalReccuring = 0;
		this.discountTotalReccuring = 0;
		this.propertiesTotalReccuring = 0;

		this.platformTotalOneTime = 0;
		this.addonsTotalOneTime = 0;
		this.slaTotalOneTime = 0;
		this.discountTotalOneTime = 0;

		this.isSilverSLA = false;
		this.isGoldSLA = false;
		this.isPlatinumSLA = false;
		this.isDiamondSLA = false;
	
		this.showSLA = false;
		this.showBase = false;
		this.showAddon = false;
		this.showDiscount = false;

		this.setupFee = 0;

		this.charges = new List<Charge>();

		getQuote();
	}

	public void getQuote() {

		List<zqu__QuoteRatePlan__c> selectedRatePlanssFromZuora = [SELECT Id, Name, zqu__QuoteProductName__c, zqu__Product__r.Description, 
									zqu__ProductRatePlan__r.zqu__Product__r.zqu__Category__c, zqu__ProductRatePlan__r.zqu__Product__r.InternalName__c, (SELECT Name, zqu__Description__c, zqu__Quantity__c, zqu__EffectivePrice__c, 
									zqu__QuoteRatePlan__r.Name, zqu__ChargeType__c, zqu__ProductRatePlanCharge__r.InternalName__c, zqu__ProductRatePlanCharge__r.zqu__Description__c,
									zqu__ProductRatePlanCharge__r.zqu__Type__c, zqu__ProductRatePlanCharge__r.unit_type__c FROM zqu__Quote_Rate_Plan_Charges__r) FROM zqu__QuoteRatePlan__c 
									WHERE zqu__Quote__c = :zQuoteId];

		Set<Id> quoteRatePlanChargeIds = new Set<Id>();
		for(zqu__QuoteRatePlan__c qrp : selectedRatePlanssFromZuora) {
			for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {
				quoteRatePlanChargeIds.add(qrpc.Id);
			}
		}

		List<zqu__QuoteCharge_Tier__c> usagePlanTiers = [SELECT Id, zqu__EndingUnit__c, zqu__Price__c, zqu__RatePlanCharge__r.InternalName__c, zqu__Tier__c  FROM zqu__QuoteCharge_Tier__c	 WHERE zqu__QuoteRatePlanCharge__c IN: quoteRatePlanChargeIds];
		
	

		if(!selectedRatePlanssFromZuora.isEmpty()) {
			loadQuoteData(selectedRatePlanssFromZuora, usagePlanTiers);
		}
	}

	public void loadQuoteData(List<zqu__QuoteRatePlan__c> quoteRatePlans, List<zqu__QuoteCharge_Tier__c> usagePlanTiers) {
		for(zqu__QuoteRatePlan__c qrp : quoteRatePlans) {
				// Add On Service
			if(qrp.zqu__ProductRatePlan__r.zqu__Product__r.zqu__Category__c == 'Add On Services') {
				for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {
					if(qrpc.zqu__ProductRatePLanCharge__r.InternalName__c != null) {
						if (Label.Zuora_Quote_Base_Features_Only_Total.contains(qrpc.zqu__ProductRatePLanCharge__r.InternalName__c)){
							setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'setupfee', null);
						}
						else if(Label.Zuora_Quote_SLA.contains(qrpc.zqu__ProductRatePLanCharge__r.InternalName__c)) {
							checkSLA(qrpc.zqu__ProductRatePlanCharge__r.InternalName__c);
							this.showSLA = true;

							addCharge(cleanPlanName(qrpc.Name), qrpc.zqu__Description__c, calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'sla', null, null);
							setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'sla',null);
						} /*else {
							this.showAddon = true;
							addCharge(cleanPlanName(qrpc.Name), qrpc.zqu__Description__c, calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'addons', null, null);
							setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'addons',null);
						}*/
				
					} /*else {
						this.showAddon = true;
						addCharge(cleanPlanName(qrpc.Name), qrpc.zqu__Description__c, calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'addons', null, null);
						setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'addons',null);
					}*/
				}

				if(qrp.zqu__ProductRatePlan__r.zqu__Product__r.InternalName__c == 'enterprise_properties') {
					for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {
							this.showProjects = true;
							addCharge(cleanPlanName(qrpc.Name), qrpc.zqu__Description__c, calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'properties', null, qrpc.zqu__Quantity__c);
							setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'properties', qrpc.zqu__Quantity__c);
					}

				}
			} 
		
		}

			

		for(zqu__QuoteRatePlan__c qrp : quoteRatePlans) {
			// Base Plan
			if(qrp.zqu__ProductRatePlan__r.zqu__Product__r.zqu__Category__c == 'Base Products') {
				// Charges
				for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {
					if(qrpc.zqu__ProductRatePlanCharge__r.InternalName__c != null) {
					System.debug('riki id = ' + qrpc.Id);
						System.debug('RIKI = ' + qrpc.zqu__ProductRatePlanCharge__r.InternalName__c);
						if(Label.Zuora_Quote_Platform.contains(qrpc.zqu__ProductRatePlanCharge__r.InternalName__c)) {
							this.showBase = true;
							//this.payment = paymentBasedOnSelectedBasePlan(qrpc.zqu__QuoteRatePlan__r.Name);
							addCharge(cleanPlanName(qrpc.zqu__QuoteRatePlan__r.Name), qrpc.zqu__Description__c, 
											calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'platform', null, null);
							setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'platform', null);
						} else if(Label.Zuora_Quote_Limits.contains(qrpc.zqu__ProductRatePlanCharge__r.InternalName__c)) {
							Decimal price = 0;
							Decimal included = null;
							for(zqu__QuoteCharge_Tier__c tier : usagePlanTiers) {
								if(tier.zqu__RatePlanCharge__r.InternalName__c == qrpc.zqu__ProductRatePlanCharge__r.InternalName__c) {
									if(usagePlanTiers.size() == 1) {
										included = tier.zqu__EndingUnit__c;
										price = qrpc.zqu__EffectivePrice__c;
									} else {
										if(tier.zqu__Tier__c == 1)
											included = tier.zqu__EndingUnit__c;
										if(tier.zqu__Tier__c == 2)
											price = tier.zqu__Price__c;
										else 
											price = qrpc.zqu__EffectivePrice__c;
									}
								}
							}
							if(qrpc.Name.contains('GB')) {
								addCharge(qrpc.Name, qrpc.zqu__Description__c, price, 'limit', included, null);
							} else {
								addCharge(cleanPlanName(qrpc.Name), qrpc.zqu__Description__c, price, 'limit', included, null);
							}
						} else if(Label.Zuora_Quote_Base_Features.contains(qrpc.zqu__ProductRatePLanCharge__r.InternalName__c) && !qrpc.Name.startsWith('_')) {
							this.showAddon = true;			
							if(qrpc.Name.contains('SSO')) {
								addCharge(qrpc.Name, qrpc.zqu__Description__c, calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'addons', null, null);
							} else {
								addCharge(cleanPlanName(qrpc.Name), qrpc.zqu__Description__c, calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'addons', null, null);
							}
							setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'addons',null);
						} else if (Label.Zuora_Quote_Base_Features_Only_Total.contains(qrpc.zqu__ProductRatePLanCharge__r.InternalName__c)){
							setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'setupfee',null);
						} else if(Label.Zuora_Quote_Base_SLA.contains(qrpc.zqu__ProductRatePLanCharge__r.InternalName__c)) {
							if(!this.showSLA) {
								this.showSLA = true;
								checkSLA(qrpc.zqu__ProductRatePlanCharge__r.InternalName__c);
								addCharge(cleanPlanName(qrpc.Name), qrpc.zqu__Description__c, calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'sla', null, null);
								setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'sla',null);
							}
						} else if(Label.Zuora_Quote_Base_Discount.contains(qrpc.zqu__ProductRatePLanCharge__r.InternalName__c)) {
							System.debug('RIKI DISCOUNT');
							this.showDiscount = true;
							addCharge(cleanPlanName(qrpc.Name), qrpc.zqu__Description__c, qrpc.zqu__EffectivePrice__c, 'disount', null, null);
							setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'disount',null);
						} 
					}
				}
			}
		}
       	//updateQuote(this.zQuoteId);
       
	}

	public void saveAttachment(){
		// Delete all attachments
		List<Attachment> attachments = new List<Attachment>([SELECT id FROM Attachment WHERE ParentId = :zQuoteId]);
		if(!attachments.IsEmpty()) {
			try{
				delete attachments;
			} catch(Exception e){
			}
		}

	  	PageReference pdf = Page.ZuoraQuotePDF;
    	// add parent id to the parameters for standardcontroller
    	pdf.getParameters().put('id', this.zQuoteId);

    	Blob body;

    	try { 
    		body = pdf.getContent();
    	} catch (VisualforceException e) {
    		body = Blob.valueOf('Some Text');
    	}
	  
	  	Attachment attachment = new Attachment();
	  	attachment.Body = body;
	  	attachment.Name = quote.Name;
	  	attachment.IsPrivate = false;
	  	attachment.ParentId = this.zQuoteId; 
	  	insert attachment;
	}




    public void updateQuote() {
        zqu__Quote__c q = [SELECT Quote_Amount__c, Quote_Discount__c, Quote_Setup_Fee__c, zqu__Opportunity__r.IsClosed FROM zqu__Quote__c WHERE Id = :this.zQuoteId LIMIT 1];
        if(!q.zqu__Opportunity__r.IsClosed) {
	        q.Quote_Amount__c = (this.platformTotalReccuring + this.addonsTotalReccuring + this.slaTotalReccuring)-((this.discountTotalReccuring / 100) * (this.platformTotalReccuring + this.addonsTotalReccuring + this.slaTotalReccuring));
	        q.Quote_Discount__c = (this.discountTotalReccuring / 100) * (this.platformTotalReccuring + this.addonsTotalReccuring + this.slaTotalReccuring);
	        q.Quote_Setup_Fee__c  = this.setupFee;
        	update q;
        }
       	//saveAttachment();
    }

	private void checkSLA(String sla) {
		if (sla == 'silver_sla')
			isSilverSLA = true;
		if (sla == 'gold_sla')
			isGoldSLA = true;
		if (sla == 'platinum_sla')
			isPlatinumSLA = true;
		if (sla == 'diamond_sla') 
			isDiamondSLA = true;
	}

	private void setTotals(Decimal price, String chargeType, String chargeGeneratedName, Decimal quantity) {
		if(chargeType == 'Recurring') {
			this.showTotalReccuring = true;
			if(chargeGeneratedName == 'addons') {
				this.addonsTotalReccuring += calculateTotalPriceBasedOnPaymentTerm(price);
			} else if (chargeGeneratedName == 'sla') {
				this.slaTotalReccuring += calculateTotalPriceBasedOnPaymentTerm(price);
			} else if (chargeGeneratedName == 'platform-total') {
				this.addonsTotalReccuring += calculateTotalPriceBasedOnPaymentTerm(price);
			} else if (chargeGeneratedName == 'disount') {
				this.discountTotalReccuring += price;
			} else if (chargeGeneratedName == 'platform') {
				this.platformTotalReccuring += calculateTotalPriceBasedOnPaymentTerm(price);
			} else if (chargeGeneratedName == 'setupfee') {
				this.setupFee += price;
			} else if (chargeGeneratedName == 'properties') {
				this.propertiesTotalReccuring += calculateTotalPriceBasedOnPaymentTerm(price*quantity);
			}
		}
		if(chargeType == 'One-Time') {
			this.showTotalOneTime = true;
			if(chargeGeneratedName == 'addons') {
				this.addonsTotalOneTime += price;
			} else if (chargeGeneratedName == 'sla') {
				this.slaTotalOneTime += calculateTotalPriceBasedOnPaymentTerm(price);
			} else if (chargeGeneratedName == 'platform-total') {
				this.addonsTotalOneTime += price;
			} else if (chargeGeneratedName == 'disount') {
				this.discountTotalOneTIme += price;
			} else if (chargeGeneratedName == 'platform') {
				this.platformTotalOneTime += price;
			} else if (chargeGeneratedName == 'setupfee') {
				this.setupFee += price;
			}
		}
	}

	private void addCharge(String name, String description, Decimal price, String chargeType, Decimal included, Decimal quantity) {
		Charge charge = new Charge(); 
		charge.name = name;
		charge.description = description;

		charge.price = price;
		charge.chargeType = chargeType;
		charge.included = included;
		charge.quantity = quantity;
		this.charges.add(charge);
	}

	private String paymentBasedOnSelectedBasePlan(String plan) {
		return plan.substringBetween('(', ')');
	}

	private String cleanPlanName(String plan) {
		return plan.substringBefore('(').replace('_', '').replace('*','');
	}

	private Decimal calculateTotalPriceBasedOnPaymentTerm(Decimal value) {
		if(this.quote.Payment__c == 'Monthly')
			return value * 12;
		else if(this.quote.Payment__c == 'Quarterly')
			return value * 4;
		else 
			return value;
	}
}