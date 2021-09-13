public class ServiceOrderExt_April2020 {
        // Public Properties 
        public String ProjectName { get; set; }
        public String ProjectName2 { get; set; }
        public Integer smallLimits { get; set; }
        public Integer largeLimits { get; set; }
        public Decimal apiCalls { get; set; }
        public Decimal assetBandwidth { get; set; }
        public Decimal assetBandwidthTier2Price {get; set;}
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
        public Boolean showPlatform { get; set; }
        public Boolean showSpaces { get; set; }
        public Boolean showAddon { get; set; }
        public Boolean showDiscount { get; set; }
        public Boolean showProjects { get; set; }
        public Boolean showProperties { get; set; }
        public Boolean showUsers { get; set; }
        public Boolean showAdditionalUsers { get; set; }
        public Boolean showAdditionalAssetBandwidth { get; set; }
        public List<Charge> charges { get; set; }
        public Map<String, Charge> testCharges {get; set;}
        public List<Project__c> projects { get; set; }
        public Users user { get; set; }
        public Integer numberOfProjects { get; set; }
        public Decimal projectsPrice { get; set; }
        public Boolean projectsValueValidation { get; set; }
        public Decimal platformTotalReccuring { get; set; }
        public Decimal addonsTotalReccuring { get; set; }
        public Decimal slaTotalReccuring { get; set; }
        public Decimal discountTotalReccuring { get; set;}
        public Decimal propertiesTotalReccuring { get; set; }
        public Decimal utilitiesTotalReccuring { get; set; }
        public Decimal utilitiesBandwidthTotalReccuring { get; set; }
        public Decimal platformTotalOneTime { get; set; }
        public Decimal addonsTotalOneTime { get; set; }
        public Decimal slaTotalOneTime { get; set; }
        public Decimal discountTotalOneTime { get; set;}
        public Boolean showTotalReccuring { get; set; }
        public Boolean showTotalOneTime { get; set; }
        public Decimal setupFee { get; set; }
        public Boolean microSpace { get; set; }
        public Boolean communitySpace { get; set; }
        public Boolean smallSpace { get; set; }
        public Boolean mediumSpace { get; set; }
        public Boolean largeSpace { get; set; }
        public Boolean performance1xSpace { get; set; }
        public Boolean content2xSpace { get; set; }
        public Boolean development2xSpace { get; set; }
        public Boolean workflow2xSpace { get; set; }
        public Boolean development3xSpace { get; set; }
        public Boolean workflow3xSpace { get; set; }
        public Boolean performance2xSpace { get; set; }
        public Boolean content3xSpace { get; set; }
        public Boolean performance3xSpace { get; set; }
        public Boolean performanceUnlimited { get; set; }
        public String userTierId { get; set; }
        public Decimal tier1ApiCalls {get; set;}
        public Decimal tier2ApiCalls {get; set;}
        public Decimal discountAmount { get; set; }
        public Decimal showSpacesQuantity { get; set; }
        public Decimal showAdditionalUsersQuantity { get; set; }
        public Decimal showAdditionalBandwidthQuantity { get; set; }
        public Boolean addressInfoIsRequired { get; set; }
        public String platformType { get; set; }
        public Boolean apiChargeExists { get; set; }
        public Decimal totalListPriceSUM {get; set; }       
        public Decimal totalListPriceUser {get; set; }       
        public Decimal totalListPriceAsset {get; set; }        
        public Decimal totalListPriceSpaces {get; set; } 
        public Decimal totallistPricePlatform {get; set; }
        public Decimal totallistPriceSLA {get; set; }
        public String dealDeskApprovalStatus { get; set; }                    

        public class Users { 
                public String userTier1 { get; set; }
                public String userTier2 { get; set; }
                public Decimal tier1Price { get; set; }
                public Decimal tier2Price { get; set; }
                public Decimal tier1Start { get; set; }
                public Decimal tier1End { get; set; }
                public Decimal tier2Start { get; set; }
                public Decimal tier2End { get; set; }
                public Integer tier1Quantity { get; set; }
                public Integer tier2Quantity { get; set; }
                public Decimal amount { get; set; }
        }


        public class Charge implements Comparable {
                public String name { get; set; }
                public String description { get; set; }
                public Decimal price { get; set; }
                public Decimal included { get; set; } 
                public String additionalInformation { get; set; } 
                public String chargeType { get; set; } 
                public Decimal quantity { get; set; }
            
                public Integer compareTo(Object compareTo) {
                    
                    Charge compareToCharge = (Charge)compareTo;
                
                    // The return value of 0 indicates that both elements are equal.
                    Integer returnValue = 0;
                    if (this.name > compareToCharge.name) {
                            // Set return value to a positive value.
                            returnValue = 1;
                    } else if (this.name < compareToCharge.name) {
                            // Set return value to a negative value.
                            returnValue = -1;
                    }
                    
                    return returnValue;   
                }
        }

        public ServiceOrderExt_April2020(){}
        public ServiceOrderExt_April2020(ApexPages.StandardController controller) {
                this.zQuoteId = controller.getId();
                this.quote = (zqu__Quote__c)controller.getRecord();

                this.showTotalReccuring = false;
                this.showTotalOneTime = false;
                this.projectsValueValidation = true;

                this.discountAmount = 0;

                this.platformTotalReccuring = 0;
                this.addonsTotalReccuring = 0;
                this.slaTotalReccuring = 0;
                this.discountTotalReccuring = 0;
                this.propertiesTotalReccuring = 0;
                this.utilitiesTotalReccuring = 0;
                this.utilitiesBandwidthTotalReccuring = 0;

                this.platformTotalOneTime = 0;
                this.addonsTotalOneTime = 0;
                this.slaTotalOneTime = 0;
                this.discountTotalOneTime = 0;
                this.showAdditionalUsersQuantity = 0;
                this.showAdditionalBandwidthQuantity = 0;
                this.showSpacesQuantity = 0;
                
                this.isSilverSLA = false;
                this.isGoldSLA = false;
                this.isPlatinumSLA = false;
                this.isDiamondSLA = false;
                this.showAdditionalUsers = false;
                this.showAdditionalAssetBandwidth = false;
                this.showSLA = false;
                this.showBase = false;
                this.showAddon = false;
                this.showDiscount = false;

                this.setupFee = 0;
                this.totalListPriceSUM = 0;                
                this.totalListPriceAsset = 0;
                this.totalListPriceUser = 0;                
                this.totalListPriceSpaces = 0;
                this.totallistPricePlatform = 0;
                this.totallistPriceSLA = 0;

                this.smallLimits = 0;
                this.largeLimits = 0;

                this.apiCalls = 0;
                this.assetBandwidth = 0;

                this.microSpace = false;
                this.communitySpace = false;
                this.smallSpace = false;
                this.mediumSpace = false;
                this.largeSpace = false;
                this.performance1xSpace = false;
                this.performance2xSpace = false;
                this.performance3xSpace = false;
                this.performanceUnlimited = false;
                this.content2xSpace = false;
                this.development2xSpace = false;
                this.workflow2xSpace = false;
                this.content3xSpace = false;
                this.development3xSpace = false;
                this.workflow3xSpace = false;


                this.charges = new List<Charge>();

                this.testCharges = new Map<String,Charge>();
        

                this.user = new Users();
                this.user.amount = 0;

                addressInfoIsRequired = false;
                apiChargeExists = false;

                if(this.quote.Additional_Users__c == null) quote.Additional_Users__c = 0;
                if(this.quote.Additional_Asset_Bandwidth__c == null) quote.Additional_Asset_Bandwidth__c = 0;
                if(this.quote.Additional_API_Calls__c == null) quote.Additional_API_Calls__c = 0;

                /*if(this.quote.zqu__BillToContact__r.MailingStreet == null){
                        addressInfoIsRequired = true;
                }*/

                getQuote();

                getQuoteDealDeskApprovalStatus();
        }

        public void getQuoteDealDeskApprovalStatus() {

                List<zqu__Quote__c> zQuotesList = [SELECT Id, Deal_Desk_Approval_Status__c
                                                   FROM zqu__Quote__c 
                                                   WHERE Id =: zQuoteId];
 
                this.dealDeskApprovalStatus = zQuotesList.size() > 0 ? zQuotesList[0].Deal_Desk_Approval_Status__c : '';
        }

        public void getQuote() {

                List<zqu__QuoteRatePlan__c> selectedRatePlanssFromZuora = [SELECT Id, Name, Quantity__c, ProjectName__c, zqu__QuoteProductName__c, zqu__Product__r.Description, 
                                                                        zqu__ProductRatePlan__r.zqu__Product__r.zqu__Category__c, zqu__ProductRatePlan__r.zqu__Product__r.InternalName__c, zqu__ProductRatePlan__r.ProjectName__c,
                                                                        zqu__ProductRatePlan__r.InternalName__c, zqu__ProductRatePlan__r.Name, (SELECT Name, zqu__Description__c, zqu__Quantity__c, zqu__EffectivePrice__c,zqu__ListPrice__c, 
                                                                        zqu__QuoteRatePlan__r.Name, zqu__ChargeType__c, zqu__ProductRatePlanCharge__r.InternalName__c, zqu__ProductRatePlanCharge__r.zqu__Description__c,
                                                                        zqu__ProductRatePlanCharge__r.zqu__Type__c, zqu__ProductRatePlanCharge__r.unit_type__c FROM zqu__Quote_Rate_Plan_Charges__r) FROM zqu__QuoteRatePlan__c 
                                                                        WHERE zqu__Quote__c = :zQuoteId];

                Set<Id> quoteRatePlanChargeIds = new Set<Id>();
                for(zqu__QuoteRatePlan__c qrp : selectedRatePlanssFromZuora) {
                        for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {
                                quoteRatePlanChargeIds.add(qrpc.Id);
                                if(qrpc.zqu__ProductRatePlanCharge__r.InternalName__c == 'api_requests'){
                                        apiChargeExists = true;
                                }
                        }
                }

                System.debug('apiChargeExists:---- ' + apiChargeExists);

                List<zqu__QuoteCharge_Tier__c> usagePlanTiers = [SELECT Id, zqu__StartingUnit__c, zqu__Effective_Price__c,  zqu__EndingUnit__c, zqu__Price__c, zqu__RatePlanCharge__r.InternalName__c, zqu__Tier__c  FROM zqu__QuoteCharge_Tier__c   WHERE zqu__QuoteRatePlanCharge__c IN: quoteRatePlanChargeIds];
                
        

                if(!selectedRatePlanssFromZuora.isEmpty()) {
                        loadQuoteData(selectedRatePlanssFromZuora, usagePlanTiers);
                }
        }

        public void loadQuoteData(List<zqu__QuoteRatePlan__c> quoteRatePlans, List<zqu__QuoteCharge_Tier__c> usagePlanTiers) {
            
            if(this.quote.Included_Users__c == null){
                        this.quote.Included_Users__c = 0;
            }
            
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
                                                                if(qrp.zqu__ProductRatePlan__r.Name == 'Community'){
                                                                checkSpace(qrp.zqu__ProductRatePlan__r.Name);
                                                        } else {
                                                            checkSpace(qrp.zqu__ProductRatePlan__r.InternalName__c);
                                                        }
                                                        addCharge(cleanPlanName(qrpc.Name), qrpc.zqu__Description__c, calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'properties', null, qrpc.zqu__Quantity__c);
                                                        setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'properties', qrpc.zqu__Quantity__c);
                                        }

                                }
                                
                        } 

                        //Total List Price
                        // if(qrp.zqu__ProductRatePlan__r.InternalName__c == 'additional_users_standalone'){                               
                        //         for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {                                      
                        //                 if(qrpc.zqu__ListPrice__c != null && qrpc.zqu__Quantity__c != null){ 
                                               
                        //                 this.totalListPriceUser += (qrpc.zqu__ListPrice__c * qrpc.zqu__Quantity__c);
                        //                 System.debug('this.totalListPriceUser::::');
                        //                 System.debug(this.totalListPriceUser);
                        //                 } else continue;                             
                        //         }
                        // }

                        // if(qrp.zqu__ProductRatePlan__r.InternalName__c == 'additional_asset_bandwidth_standalone'){                              
                        //         for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {
                        //                 if(qrpc.zqu__ListPrice__c != null && qrpc.zqu__Quantity__c != null){
                        //                 this.totalListPriceAsset += (qrpc.zqu__ListPrice__c * qrpc.zqu__Quantity__c);
                        //                 } else continue;                                
                        //         }
                        //  }
                        //  System.debug('Prije IFA');
                        //  if(qrp.zqu__ProductRatePlan__r.InternalName__c != null){
                        //          if(qrp.zqu__ProductRatePlan__r.InternalName__c.containsIgnoreCase('space')){
                        //                  System.debug('Poslije IFA');
                        //                  for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {                                       
                        //                          if(qrpc.zqu__ListPrice__c != null){
                        //                                  if(qrp.quantity__c != null){                                                        
                        //                                          qrp.quantity__c = qrp.quantity__c == 0 ? 1 : qrp.quantity__c;
                        //                                          this.totalListPriceSpaces +=  (qrpc.zqu__ListPrice__c * qrp.quantity__c);
                        //                                  } else{
                        //                                          this.totalListPriceSpaces += qrpc.zqu__ListPrice__c;
                        //                                  }
                        //                          } else continue;
                        //                  }                               
                        //            }
                        //  }
                          
                        //   if(Label.Zuora_Quote_Platform.contains(qrp.zqu__ProductRatePlan__r.InternalName__c)){                             
                        //         for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {
                        //                 if(qrpc.zqu__ListPrice__c != null){
                        //                         this.totallistPricePlatform += qrpc.zqu__ListPrice__c;
                        //                 } else continue;
                        //         }                               
                        //   }                          
                          
                        //   this.totalListPriceSUM = totalListPriceSpaces + totalListPriceAsset + totalListPriceUser + totallistPricePlatform;
                          
                        // Base Plan
                        if(qrp.zqu__ProductRatePlan__r.zqu__Product__r.zqu__Category__c == 'Base Products') {
                                // Charges                                
                                qrp.quantity__c = qrp.quantity__c == null ? 1 : qrp.quantity__c;
                                System.debug('QRPQuantity:::');
                                System.debug(qrp.quantity__c);
                                if(qrp.zqu__ProductRatePlan__r.InternalName__c == 'additional_users_standalone'){
                                        for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {
                                                if(qrpc.Name != 'Discount') {
                                                        qrpc.zqu__Quantity__c = qrpc.zqu__Quantity__c == null ? 1 : qrpc.zqu__Quantity__c;
                                                        this.showAdditionalUsers = true;
                                                        if(qrp.zqu__ProductRatePlan__r.Name == 'Community'){
                                                                checkSpace(qrp.zqu__ProductRatePlan__r.Name);
                                                        } else {
                                                            checkSpace(qrp.zqu__ProductRatePlan__r.InternalName__c);
                                                        }
                                                        
                                                        addCharge(cleanPlanName(qrpc.zqu__QuoteRatePlan__r.Name), qrp.ProjectName__c, calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'utilities', null, qrpc.zqu__Quantity__c);
                                                        setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'utilities', qrpc.zqu__Quantity__c);
                                                        this.showAdditionalUsersQuantity += qrpc.zqu__Quantity__c;
                                                        System.debug('showAdditionalUsersQuantity:::');
                                                        System.debug(this.showAdditionalUsersQuantity);
                                                }
                                        }
                                }
                                if(qrp.zqu__ProductRatePlan__r.InternalName__c == 'additional_asset_bandwidth_standalone'){
                                        for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {
                                            qrpc.zqu__Quantity__c = qrpc.zqu__Quantity__c == null ? 1 : qrpc.zqu__Quantity__c;
                                            this.showAdditionalAssetBandwidth = true;
                                            checkSpace(qrp.zqu__ProductRatePlan__r.InternalName__c);
                                            addCharge(cleanPlanName(qrpc.zqu__QuoteRatePlan__r.Name), qrp.ProjectName__c, calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'utilitiesAssetBandwidth', null, qrpc.zqu__Quantity__c);
                                            setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'utilitiesAssetBandwidth', qrpc.zqu__Quantity__c);
                                            this.showAdditionalBandwidthQuantity += qrpc.zqu__Quantity__c;
                                            
                                        }
                                }

                                for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {
                                        if(qrpc.zqu__ProductRatePlanCharge__r.InternalName__c != null) {
                                                qrpc.zqu__Quantity__c = qrpc.zqu__Quantity__c == null ? 1 : qrpc.zqu__Quantity__c;                                                
                                                if(Label.Zuora_Quote_Platform.contains(qrpc.zqu__ProductRatePlanCharge__r.InternalName__c)) {                                                        
                                                        this.showPlatform = true;
                                                        this.showUsers = true;
                                                        platformType = qrp.Name;
                                                        //this.payment = paymentBasedOnSelectedBasePlan(qrpc.zqu__QuoteRatePlan__r.Name);
                                                        addCharge(cleanPlanName(qrpc.zqu__QuoteRatePlan__r.Name), qrpc.zqu__Description__c, 
                                                                                        calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'platform', null, null);
                                                        setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'platform', null);
                                                } else if(qrpc.zqu__ProductRatePlanCharge__r.InternalName__c.containsIgnoreCase('space') && !qrpc.zqu__ProductRatePlanCharge__r.InternalName__c.equalsIgnoreCase('poc_spaces')) {
                                                        if(Label.Zuora_Quote_SmallLimits.contains(qrp.zqu__ProductRatePlan__r.InternalName__c)) {
                                                                this.smallLimits += 1;
                                                                this.assetBandwidth += (0.75 * qrp.quantity__c);
                                                                if(apiChargeExists == true){
                                                                        this.apiCalls += (2 * qrp.quantity__c);
                                                                        tier1ApiCalls = this.apiCalls;
                                                                }
                                                        }if(Label.Zuora_Quote_LargeLimits.contains(qrp.zqu__ProductRatePlan__r.InternalName__c)) {
                                                                this.largeLimits += 1;
                                                                this.assetBandwidth += (2 * qrp.quantity__c);
                                                                if(apiChargeExists == true){
                                                                        this.apiCalls += (7 * qrp.quantity__c);
                                                                        tier2ApiCalls = this.apiCalls;
                                                                }
                                                        }
                                                        this.showSpaces = true;
                                                        if(qrp.zqu__ProductRatePlan__r.Name == 'Community'){
                                                                checkSpace(qrp.zqu__ProductRatePlan__r.Name);
                                                        } else {
                                                            checkSpace(qrp.zqu__ProductRatePlan__r.InternalName__c);
                                                        }
                                                        addCharge(cleanPlanName(qrpc.zqu__QuoteRatePlan__r.Name), qrp.ProjectName__c, calculateTotalPriceBasedOnPaymentTerm(qrpc.zqu__EffectivePrice__c), 'properties', null, qrp.quantity__c);
                                                        setTotals(qrpc.zqu__EffectivePrice__c, qrpc.zqu__ChargeType__c, 'properties', qrp.quantity__c);
                                                        this.showSpacesQuantity +=qrp.quantity__c;
                                                } else if(Label.Zuora_Quote_Limits.contains(qrpc.zqu__ProductRatePlanCharge__r.InternalName__c)) {
                                                        Decimal price = 0;
                                                        Decimal included = null;
                                                        for(zqu__QuoteCharge_Tier__c tier : usagePlanTiers) {
                                                                if(tier.zqu__RatePlanCharge__r.InternalName__c == qrpc.zqu__ProductRatePlanCharge__r.InternalName__c) {
                                                                        if(usagePlanTiers.size() == 1) {
                                                                                included = tier.zqu__EndingUnit__c;
                                                                                price = qrpc.zqu__EffectivePrice__c;
                                                                        } else {
                                                                                if(tier.zqu__RatePlanCharge__r.InternalName__c == 'organization_memberships') {

                                                                                        if(tier.zqu__Tier__c == 1) {
                                                                                                
                                                                                                this.user.tier1Price = tier.zqu__Price__c;
                                                                                                this.user.tier1Start = tier.zqu__StartingUnit__c;
                                                                                                this.user.tier1End = tier.zqu__EndingUnit__c;
                                                                                                this.user.userTier1 = String.valueOf(tier.zqu__StartingUnit__c.intValue()) + '-' + String.valueOf(tier.zqu__EndingUnit__c.intValue());
                                                                                                this.user.tier1Quantity = tier.zqu__EndingUnit__c.intValue();
                                                                                                System.debug('tier1Quantity');
                                                                                                System.debug(this.user.tier1Quantity);
                                                                                        }
                                                                                        if(tier.zqu__Tier__c == 2) {
                                                                                                userTierId = tier.id;
                                                                                                this.user.tier2Price = tier.zqu__Price__c;
                                                                                                this.user.tier2Start = tier.zqu__StartingUnit__c;
                                                                                                this.user.tier2End = tier.zqu__EndingUnit__c;
                                                                                                //this.user.userTier2 = String.valueOf(tier.zqu__StartingUnit__c.intValue()) + '-' + String.valueOf(tier.zqu__EndingUnit__c.intValue());
                                                                                                //this.user.tier2Quantity = tier.zqu__EndingUnit__c.intValue() - this.user.tier1Quantity;
                                                                                                if(this.quote.Additional_Users__c != null && this.user.tier2Price != null) {
                                                                                                        this.user.amount = this.quote.Additional_Users__c * this.user.tier2Price * 12;
                                                                                                }
                                                                                        }
                                                                                }else if (tier.zqu__RatePlanCharge__r.InternalName__c == 'asset_bandwidth'){
                                                                                       
                                                                                        if(tier.zqu__Tier__c == 1) {
                                                                                                
                                                                                               
                                                                                        }
                                                                                        if(tier.zqu__Tier__c == 2) {
                                                                                                this.assetBandwidthTier2Price = tier.zqu__Effective_Price__c;  
                                                                                        }
                                                                                }
                                                                                if(tier.zqu__Tier__c == 1)
                                                                                        included = tier.zqu__EndingUnit__c;
                                                                                if(tier.zqu__Tier__c == 2)
                                                                                        price = tier.zqu__Price__c;
                                                                                else 
                                                                                        price = qrpc.zqu__EffectivePrice__c;
                                                                        }
                                                                }
                                                        }
                                                       
                                                        if(qrpc.Name.containsIgnoreCase('Users')) {
                                                                this.showUsers = true;
                                                                addCharge(qrpc.Name, qrpc.zqu__Description__c, price, 'users', included, null);
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
                        System.debug('apiChargeExists:---- ' + apiChargeExists);
                        }
                }
                if(isSilverSLA){
                        this.slaTotalReccuring = (this.platformTotalReccuring + this.propertiesTotalReccuring) * 0.14;
                        // this.totallistPriceSLA = (this.totallistPricePlatform+this.totalListPriceSpaces) * 0.14;
                }
                if(isGoldSLA){
                        this.slaTotalReccuring = (this.platformTotalReccuring + this.propertiesTotalReccuring) * 0.18;
                        // this.totallistPriceSLA = (this.totallistPricePlatform+this.totalListPriceSpaces) * 0.18;

                }
                if(isPlatinumSLA){
                        this.slaTotalReccuring = (this.platformTotalReccuring + this.propertiesTotalReccuring) * 0.24;
                        // this.totallistPriceSLA = (this.totallistPricePlatform+this.totalListPriceSpaces) * 0.24;
                }
                // totalListPriceSUM += totallistPriceSLA;
                // totalListPriceSUM = calculateTotalPriceBasedOnPaymentTerm(totalListPriceSUM);
                
        //updateQuote(this.zQuoteId);
       
        }

        /*public void saveAttachment(){
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
        }*/




    public void updateQuote() {

        List<zqu__Quote__c> q = [SELECT Id,
                                        zqu__Account__c,
                                        zqu__Opportunity__c,
                                        Bill_From__c,
                                        zqu__StartDate__c,
                                        Payment__c,
                                        zqu__InvoiceTemplate__c,
                                        zqu__Certificate_ID__c,
                                        zqu__CommunicationProfile__c,
                                        zqu__BillCycleDay__c,
                                        CF_Organization_Key__c,
                                        Debitor_Number__c,
                                        X3_year_contract_discount__c, 
                                        X2_year_contract_discount__c, 
                                        Marketing_reference_discount__c,
                                        Marketing_Reference_Discount_Tier_1__c,
                                        Mkt_Reference_Discount_Tier_2_4__c,
                                        Mkt_Reference_Discount_Tier_3_2__c,
                                        Mkt_Reference_Discount_Custom__c,
                                        Special_incentives_discount__c, 
                                        Quote_Amount__c, 
                                        Quote_Discount__c, 
                                        Quote_Setup_Fee__c,
                                        Total_List_Price__c,
                                        Total_Effective_Price__c,
                                        zqu__Opportunity__r.IsClosed,
                                        zqu__VAT_ID__c
                                        FROM zqu__Quote__c WHERE Id = :this.zQuoteId LIMIT 1];


        if(q.isEmpty()) return;

        // q[0].Total_List_Price__c = totalListPriceSUM;
        q[0].Total_Effective_Price__c = (platformTotalReccuring+addonsTotalReccuring+slaTotalReccuring+propertiesTotalReccuring+utilitiesTotalReccuring+utilitiesBandwidthTotalReccuring)-(discountAmount / 100) * (platformTotalReccuring+addonsTotalReccuring+slaTotalReccuring+propertiesTotalReccuring+utilitiesTotalReccuring+utilitiesBandwidthTotalReccuring);
        q[0].zqu__CommunicationProfile__c = String.valueOf(Label.Zuora_Communication_Profile);

        if(q[0].Bill_From__c == 'Contentful GmbH'){
           q[0].zqu__InvoiceTemplate__c = String.valueof(Label.Zuora_Invoice_Id_Contenful_GmbH);
        } else if(q[0].Bill_From__c == 'Contentful Inc.'){
           q[0].zqu__InvoiceTemplate__c = String.valueof(Label.Zuora_Invoice_Id_Contenful_Inc);
           //q[0].zqu__Certificate_ID__c = 'non-eu';
        }

        if(q[0].zqu__StartDate__c != null){
                q[0].zqu__BillCycleDay__c = String.valueOf(q[0].zqu__StartDate__c.day());
        }

        if(q[0].zqu__StartDate__c != null){
                q[0].Bill_Cycle_Month__c = String.valueOf(q[0].zqu__StartDate__c.month());
        }

        q[0].Bill_Run_Frequency_in_months__c = '3';

        /*if(q[0].Payment__c != null){
                if(q[0].Payment__c == 'Annual'){
                        q[0].Bill_Run_Frequency_in_months__c = '12';
                } else if(q[0].Payment__c == 'Quarterly'){
                        q[0].Bill_Run_Frequency_in_months__c = '3';
                } else if(q[0].Payment__c == 'Monthly'){
                        q[0].Bill_Run_Frequency_in_months__c = '1';
                }
        }*/

        if(q[0].CF_Organization_Key__c != '' && q[0].CF_Organization_Key__c != null){
                q[0].organization_key__c = q[0].CF_Organization_Key__c;
        }

        if(q[0].zqu__VAT_ID__c != '' && q[0].zqu__VAT_ID__c != null){
                q[0].zqu__Certificate_ID__c = q[0].zqu__VAT_ID__c;
        }

        update q[0];

        if(q[0].zqu__Account__c != null){

                Account acc = new Account(Id = q[0].zqu__Account__c);

                if(q[0].CF_Organization_Key__c != '' && q[0].CF_Organization_Key__c != null){
                      acc.organization_key__c = q[0].CF_Organization_Key__c;
                }

                if(q[0].zqu__VAT_ID__c != '' && q[0].zqu__VAT_ID__c != null){
                        acc.VAT_Id__c = q[0].zqu__VAT_ID__c;
                }

                if(q[0].Bill_From__c != null){
                        if(q[0].Bill_From__c == 'Contentful GmbH'){
                                acc.Billing_Entity__c = 'gmbh';
                        } else if(q[0].Bill_From__c == 'Contentful Inc.'){
                                acc.Billing_Entity__c = 'inc';
                        }
                }
                if(q[0].zqu__StartDate__c != null){
                        acc.Bill_Cycle_Month__c = String.valueOf(q[0].zqu__StartDate__c.month());
                }

                if(q[0].Debitor_Number__c != '' && q[0].Debitor_Number__c != null){
                        acc.Debitor_Number__c = q[0].Debitor_Number__c;
                }

                acc.Bill_Run_Frequency_in_months__c = '3';
                
                /*if(q[0].Payment__c != null){
                        if(q[0].Payment__c == 'Annual'){
                          acc.Bill_Run_Frequency_in_months__c = '12';
                        } else if(q[0].Payment__c == 'Quarterly'){
                          acc.Bill_Run_Frequency_in_months__c = '3';
                        } else if(q[0].Payment__c == 'Monthly'){
                          acc.Bill_Run_Frequency_in_months__c = '1';
                        }
                }*/
                
                upsert acc;
        }


        List<zqu__QuoteRatePLanCharge__c> discount = [SELECT Id, zqu__EffectivePrice__c, zqu__DiscountAmount__c, zqu__Discount__c FROM zqu__QuoteRatePLanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :this.zQuoteId AND zqu__ProductRatePlanCharge__r.InternalName__c = 'discount'];
        

        //Decimal discountAmount = 0;
        if(q[0].X2_year_contract_discount__c && !q[0].X3_year_contract_discount__c)
                discountAmount += 2;
        if(q[0].X3_year_contract_discount__c)
                discountAmount += 4;
        /*if(q[0].Marketing_reference_discount__c)
                discountAmount += 5;*/
        if(q[0].Mkt_Reference_Discount_Custom__c != null && q[0].Mkt_Reference_Discount_Custom__c > 0){
                discountAmount += q[0].Mkt_Reference_Discount_Custom__c;
        } else if(q[0].Marketing_Reference_Discount_Tier_1__c){
                discountAmount += 7;
        } else if(q[0].Mkt_Reference_Discount_Tier_2_4__c){
                discountAmount += 5;
        } else if(q[0].Mkt_Reference_Discount_Tier_3_2__c){
                discountAmount += 2;
        } else if(q[0].Marketing_reference_discount__c){
                discountAmount += 5;
        }

        if(q[0].Special_incentives_discount__c > 0)
                discountAmount += q[0].Special_incentives_discount__c;

        if(discount.isEmpty()) return;

        // discount[0].zqu__EffectivePrice__c = discountAmount;       
        // discount[0].zqu__DiscountAmount__c = discountAmount;
        // discount[0].zqu__Discount__c = discountAmount;



        //Automatically add spaces ("Large", "Medium", etc) based on the quantity entered
        List<zqu__QuoteRatePlan__c> selectedRatePlanssFromZuora = [SELECT Id, Name, Quantity__c, 
                                                                        zqu__QuoteAmendment__c, 
                                                                        zqu__QuoteAmendment__r.zqu__TotalAmount__c, 
                                                                        zqu__QuoteAmendment__r.zqu__DeltaTCV__c,
                                                                        zqu__QuoteAmendment__r.zqu__DeltaMRR__c,
                                                                        zqu__QuoteAmendment__r.zqu__Description__c,
                                                                        zqu__QuoteAmendment__r.zqu__Status__c,
                                                                        zqu__QuoteAmendment__r.zqu__Type__c,
                                                                        ProjectName__c, 
                                                                        zqu__QuoteProductName__c, 
                                                                        zqu__ProductRatePlan__c,
                                                                        zqu__Product__r.Description, 
                                                                        zqu__ProductRatePlan__r.zqu__Product__r.zqu__Category__c, 
                                                                        zqu__ProductRatePlan__r.zqu__Product__r.InternalName__c, 
                                                                        zqu__ProductRatePlan__r.ProjectName__c,
                                                                        zqu__ProductRatePlan__r.InternalName__c, 
                                                                        (SELECT Name, zqu__Description__c, zqu__Quantity__c, zqu__EffectivePrice__c, 
                                                                        zqu__QuoteRatePlan__r.Name, zqu__ChargeType__c, zqu__ProductRatePlanCharge__r.InternalName__c, zqu__ProductRatePlanCharge__r.zqu__Description__c,
                                                                        zqu__ProductRatePlanCharge__r.zqu__Type__c, zqu__ProductRatePlanCharge__r.unit_type__c FROM zqu__Quote_Rate_Plan_Charges__r) FROM zqu__QuoteRatePlan__c 
                                                                        WHERE zqu__Quote__c = :zQuoteId];

        /*for(zqu__QuoteRatePlan__c qrp : selectedRatePlanssFromZuora) {

                if(qrp.Quantity__c != null && qrp.Quantity__c > 0){
                        for(Integer i = 1; i<qrp.Quantity__c; i++){
                                zqu.zChargeGroup zcg = zqu.zQuoteUtil.getChargeGroup(q[0].Id, (Id) qrp.zqu__ProductRatePlan__c);
                                zqu.zQuoteUtil.addChargeGroup(zcg);
                        }
                        qrp.Quantity__c = 0;
                        update qrp;

                }

        }*/

        Set<Id> quoteRatePlanIds = new Set<Id>();

        for(zqu__QuoteRatePlan__c qrp : selectedRatePlanssFromZuora) {
                if(qrp.Quantity__c > 0){
                        quoteRatePlanIds.add(qrp.Id);
                }
        }

          //ServiceOrderExt_April2020.addAdditionalSpaces(quoteRatePlanIds);

        /*if(this.quote.Additional_Users__c != null) {
                if(this.quote.Additional_Users__c > 0) {
                        List<zqu__QuoteCharge_Tier__c> additionalUser = [SELECT Id, zqu__EndingUnit__c FROM zqu__QuoteCharge_Tier__c WHERE Id = :userTierId ];
                        if(!additionalUser.isEmpty()){
                                additionalUser[0].zqu__EndingUnit__c = this.quote.Additional_Users__c + this.user.tier1End;
                                update additionalUser[0];
                        }
                        
                }
        }

        if(this.quote.Additional_API_Calls__c != null) {
                if(this.quote.Additional_API_Calls__c > 0) {
                        List<zqu__QuoteCharge_Tier__c> additionalAPIREQUESTS = [SELECT Id, zqu__Tier__c, zqu__StartingUnit__c, zqu__EndingUnit__c FROM zqu__QuoteCharge_Tier__c WHERE zqu__QuoteRatePlanCharge__r.Name = 'API requests'];
                        if(!additionalAPIREQUESTS.isEmpty()){
                                for(zqu__QuoteCharge_Tier__c zqct : additionalAPIREQUESTS){
                                        if(zqct.zqu__Tier__c == 1){
                                                zqct.zqu__EndingUnit__c = apiCalls;
                                        } else if(zqct.zqu__Tier__c == 2){
                                                zqct.zqu__StartingUnit__c = apiCalls + 0.001;
                                                zqct.zqu__EndingUnit__c = apiCalls + this.quote.Additional_API_Calls__c;
                                        }

                                        update zqct;
                                        
                                }
                                
                        }
                        
                }
        }

        if(this.quote.Additional_Asset_Bandwidth__c != null) {
                if(this.quote.Additional_Asset_Bandwidth__c > 0) {
                        List<zqu__QuoteCharge_Tier__c> additionalAssetBandwidth = [SELECT Id, zqu__Tier__c, zqu__StartingUnit__c, zqu__EndingUnit__c FROM zqu__QuoteCharge_Tier__c WHERE zqu__QuoteRatePlanCharge__r.Name = 'Asset Bandwidth'];
                        if(!additionalAssetBandwidth.isEmpty()){
                                for(zqu__QuoteCharge_Tier__c zqct : additionalAssetBandwidth){
                                        if(zqct.zqu__Tier__c == 1){
                                                zqct.zqu__EndingUnit__c = assetBandwidth;
                                        } else if(zqct.zqu__Tier__c == 2){
                                                zqct.zqu__StartingUnit__c = assetBandwidth + 1;
                                                zqct.zqu__EndingUnit__c = assetBandwidth + this.quote.Additional_Asset_Bandwidth__c;
                                        }

                                        update zqct;
                                        
                                }
                                
                        }
                        
                }
        }*/

         List<zqu__QuoteRatePlanCharge__c> quoteRatePlans = [SELECT Id, zqu__Quantity__c, zqu__EffectivePrice__c, Name, InternalName__c, zqu__ProductRatePlanCharge__r.InternalName__c
                                                                FROM zqu__QuoteRatePlanCharge__c 
                                                                WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :zQuoteId AND 
                                                                (zqu__ProductRatePlanCharge__r.InternalName__c = 'additional_api_calls' OR
                                                                 zqu__ProductRatePlanCharge__r.InternalName__c = 'additional_users' OR
                                                                 zqu__ProductRatePlanCharge__r.InternalName__c = 'additional_bandwidth' OR 
                                                                 zqu__ProductRatePlanCharge__r.InternalName__c LIKE '%_sla%'
                                                                )];

        if(!quoteRatePlans.isEmpty()){
                for(zqu__QuoteRatePlanCharge__c qrp : quoteRatePlans){
                        if(qrp.zqu__ProductRatePlanCharge__r.InternalName__c == 'additional_api_calls'){
                                qrp.zqu__Quantity__c = this.quote.Additional_API_Calls__c;
                        }
                        if(qrp.zqu__ProductRatePlanCharge__r.InternalName__c == 'additional_users'){
                                qrp.zqu__Quantity__c = this.quote.Additional_Users__c;
                        }
                        // if(qrp.Name == 'Additional Users'){
                        //         qrp.zqu__Quantity__c = this.quote.Additional_Users__c;
                        //         System.debug('MuhamedDebug');
                        //         System.debug(this.quote.Additional_Users__c);
                        // }
                        if(qrp.zqu__ProductRatePlanCharge__r.InternalName__c == 'additional_bandwidth'){
                                qrp.zqu__Quantity__c = this.quote.Additional_Asset_Bandwidth__c;
                        }
                        if(qrp.zqu__ProductRatePlanCharge__r.InternalName__c.contains('_sla')){
                                qrp.zqu__EffectivePrice__c = calculateTotalPriceBasedOnPaymentTermForSLA(this.slaTotalReccuring);
                                qrp.zqu__Total__c = calculateTotalPriceBasedOnPaymentTermForSLA(this.slaTotalReccuring);

                        }
                }

                update quoteRatePlans;
        }


        //if(this.quote.Additional_Users__c != null || this.quote.Additional_API_Calls__c != null || this.quote.Additional_Asset_Bandwidth__c != null) {

                List<zqu__QuoteCharge_Tier__c> lstOfQuoteChargeTierRecordsForUpdate = new List<zqu__QuoteCharge_Tier__c>();

                List<zqu__QuoteCharge_Tier__c> scopedChargeRecords = [SELECT Id, zqu__Tier__c, zqu__RatePlanCharge__r.InternalName__c, zqu__StartingUnit__c, zqu__EndingUnit__c, zqu__QuoteRatePlanCharge__r.Name 
                                                                                FROM zqu__QuoteCharge_Tier__c 
                                                                                WHERE (zqu__RatePlanCharge__r.InternalName__c = 'asset_bandwidth' OR 
                                                                                zqu__RatePlanCharge__r.InternalName__c = 'api_requests' OR 
                                                                                zqu__RatePlanCharge__r.InternalName__c = 'organization_memberships')
                                                                                AND zqu__QuoteRatePlanCharge__r.zqu__QuoteRatePlan__r.zqu__Quote__c = :zQuoteId
                                                                                ];  

                if(!scopedChargeRecords.isEmpty()){
                                                                
                                for(zqu__QuoteCharge_Tier__c zqct : scopedChargeRecords){

                                        if(zqct.zqu__RatePlanCharge__r.InternalName__c == 'organization_memberships' && this.showAdditionalUsersQuantity != null) {
                                                if(this.showAdditionalUsersQuantity > 0) {
                                                                if(zqct.zqu__Tier__c == 1){
                                                                        zqct.zqu__EndingUnit__c = this.showAdditionalUsersQuantity + this.quote.Included_Users__c +this.quote.Additional_Users__c;
                                                        } else if(zqct.zqu__Tier__c == 2){
                                                                zqct.zqu__StartingUnit__c = this.showAdditionalUsersQuantity+ this.quote.Included_Users__c + this.quote.Additional_Users__c+  1;
                                                               
                                                        }
                                                } else {

                                                        if(zqct.zqu__Tier__c == 1){
                                                                        zqct.zqu__EndingUnit__c = this.quote.Included_Users__c +this.quote.Additional_Users__c;
                                                        } else if(zqct.zqu__Tier__c == 2){
                                                                zqct.zqu__StartingUnit__c = this.quote.Included_Users__c +this.quote.Additional_Users__c + 1;
                                                               
                                                        }

                                                }
                                                        
                                        }

                                        if(zqct.zqu__RatePlanCharge__r.InternalName__c == 'asset_bandwidth' && (this.showAdditionalBandwidthQuantity != null || this.quote.Additional_Asset_Bandwidth__c > 0)) {
                                            
                                                if(this.showAdditionalBandwidthQuantity > 0 || this.quote.Additional_Asset_Bandwidth__c > 0) {
                                                        if(zqct.zqu__Tier__c == 1){
                                                                zqct.zqu__EndingUnit__c = (assetBandwidth + this.showAdditionalBandwidthQuantity +this.quote.Additional_Asset_Bandwidth__c) * 1000;//assetBandwidth * 1000;
                                                        } else if(zqct.zqu__Tier__c == 2){
                                                                zqct.zqu__StartingUnit__c = ((assetBandwidth + this.showAdditionalBandwidthQuantity +this.quote.Additional_Asset_Bandwidth__c) * 1000) + 1;//assetBandwidth * 1000 + 1;
                                                                //zqct.zqu__EndingUnit__c = (assetBandwidth + this.quote.Additional_Asset_Bandwidth__c) * 1000;
                                                        }
                                                } else {
                                                                                                                
                                                        if(zqct.zqu__Tier__c == 1){
                                                                        zqct.zqu__EndingUnit__c = (assetBandwidth +this.quote.Additional_Asset_Bandwidth__c) * 1000;
                                                        } else if(zqct.zqu__Tier__c == 2){
                                                                zqct.zqu__StartingUnit__c = ((assetBandwidth +this.quote.Additional_Asset_Bandwidth__c) * 1000) + 1 ;
                                                               
                                                        }

                                                }
                                                        
                                        }
                                        

                                        //if(this.quote.Additional_Asset_Bandwidth__c != null) {
                                              /*  if(zqct.zqu__RatePlanCharge__r.InternalName__c == 'asset_bandwidth') {
                                                                
                                                        if(zqct.zqu__Tier__c == 1){
                                                                zqct.zqu__EndingUnit__c = (assetBandwidth + this.quote.Additional_Asset_Bandwidth__c) * 1000;//assetBandwidth * 1000;
                                                        } else if(zqct.zqu__Tier__c == 2){
                                                                zqct.zqu__StartingUnit__c = ((assetBandwidth + this.quote.Additional_Asset_Bandwidth__c) * 1000) + 1;//assetBandwidth * 1000 + 1;
                                                                //zqct.zqu__EndingUnit__c = (assetBandwidth + this.quote.Additional_Asset_Bandwidth__c) * 1000;
                                                        }

                                                          
                                                        
                                                }*/
                                        //}

                                        //if(this.quote.Additional_API_Calls__c != null) {
                                                if(apiChargeExists &&  zqct.zqu__RatePlanCharge__r.InternalName__c == 'api_requests') {
                                                        
                                                        if(zqct.zqu__Tier__c == 1){
                                                                zqct.zqu__EndingUnit__c = (apiCalls + this.quote.Additional_API_Calls__c) * 1000;//apiCalls * 1000;
                                                        } else if(zqct.zqu__Tier__c == 2){
                                                                zqct.zqu__StartingUnit__c = ((apiCalls + this.quote.Additional_API_Calls__c) * 1000) + 0.001;//apiCalls  * 1000 + 0.001;
                                                                //zqct.zqu__EndingUnit__c = (apiCalls + this.quote.Additional_API_Calls__c) * 1000;
                                                        }

                                                        
                                                }                       
  
                                        //}

                                        lstOfQuoteChargeTierRecordsForUpdate.add(zqct);
                                }

                        if(!lstOfQuoteChargeTierRecordsForUpdate.isEmpty()){
                                update lstOfQuoteChargeTierRecordsForUpdate;
                        } 
                                
                }
                
        //}

        for(zqu__QuoteRatePLanCharge__c disc : discount){
                disc.zqu__EffectivePrice__c = discountAmount;       
                disc.zqu__DiscountAmount__c = discountAmount;
                disc.zqu__Discount__c = discountAmount;

        }

        update discount;
 
         //zqu__QuoteRatePLanCharge__c sla = [SELECT Id, zqu__EffectivePrice__c, zqu__DiscountAmount__c, zqu__Discount__c FROM zqu__QuoteRatePLanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :this.zQuoteId AND zqu__ProductRatePlanCharge__r.InternalName__c LIKE '%sla%'];
       //  sla.zqu__EffectivePrice__c = 1200;
        // update sla;
        //if(!q.zqu__Opportunity__r.IsClosed) {
            //    q.Quote_Amount__c = (this.platformTotalReccuring + this.addonsTotalReccuring + this.slaTotalReccuring)-((this.discountTotalReccuring / 100) * (this.platformTotalReccuring + this.addonsTotalReccuring + this.slaTotalReccuring));
            //    q.Quote_Discount__c = (this.discountTotalReccuring / 100) * (this.platformTotalReccuring + this.addonsTotalReccuring + this.slaTotalReccuring);
            //    q.Quote_Setup_Fee__c  = this.setupFee;
        //      update q;
        //}
        //saveAttachment();
    }

        @future
        private static void addAdditionalSpaces(Set<Id> scopedQuoteRatePlanIds){

                List<zqu__QuoteRatePlan__c> scopedQuoteRatePlans = [SELECT Id, zqu__Quote__c, zqu__ProductRatePlan__c, Quantity__c 
                                                                        FROM zqu__QuoteRatePlan__c WHERE Id IN :scopedQuoteRatePlanIds];

                for(zqu__QuoteRatePlan__c qrp : scopedQuoteRatePlans) {

                        if(qrp.Quantity__c != null && qrp.Quantity__c > 0){
                                for(Integer i = 1; i<qrp.Quantity__c; i++){
                                        zqu.zChargeGroup zcg = zqu.zQuoteUtil.getChargeGroup(qrp.zqu__Quote__c, (Id) qrp.zqu__ProductRatePlan__c);
                                        zqu.zQuoteUtil.addChargeGroup(zcg);
                                }
                                qrp.Quantity__c = 0;
                        }
                }

                update scopedQuoteRatePlans;
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

        private void checkSpace(String space) {
                if (space.containsIgnoreCase('Community'))
                        communitySpace = true;
                if (space.containsIgnoreCase('0') || space.containsIgnoreCase('1')) 
                        microSpace = true;
                if (space.containsIgnoreCase('2'))
                        smallSpace = true;
                if (space.containsIgnoreCase('3'))
                        mediumSpace = true;
                if (space.containsIgnoreCase('4')) 
                        largeSpace = true;
                if (space.containsIgnoreCase('5')) 
                        performance1xSpace = true;

                if (space.equalsIgnoreCase('space_size_6')) 
                        performance2xSpace = true;
                if (space.equalsIgnoreCase('space_size_6-c')) 
                        content2xSpace = true;
                if (space.equalsIgnoreCase('space_size_6-d')) 
                        development2xSpace = true;
                if (space.equalsIgnoreCase('space_size_6-w')) 
                        workflow2xSpace = true;

                if (space.equalsIgnoreCase('space_size_7')) 
                        performance3xSpace = true; 
                
                if (space.equalsIgnoreCase('space_size_7-c')) 
                        content3xSpace = true;
                if (space.equalsIgnoreCase('space_size_7-d')) 
                        development3xSpace = true;
                if (space.equalsIgnoreCase('space_size_7-w')) 
                        workflow3xSpace = true;
                
                if (space.containsIgnoreCase('8'))
                        performanceUnlimited = true;    
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
                        }else if (chargeGeneratedName == 'utilities') {
                                System.debug('this.utilitiesTotalReccuring:--- ' + this.utilitiesTotalReccuring);
                                System.debug('this.utilitiesTotalReccuring:--- ' + price);
                                System.debug('this.utilitiesTotalReccuring:--- ' + quantity);
                                this.utilitiesTotalReccuring += calculateTotalPriceBasedOnPaymentTerm(price*quantity);
                        }else if (chargeGeneratedName == 'utilitiesAssetBandwidth') {
                                this.utilitiesBandwidthTotalReccuring += calculateTotalPriceBasedOnPaymentTerm((price)*quantity);
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
               
                string key = name + price;

                Charge existing = this.testCharges.get(key);
                if (existing != null && charge.quantity != null) {
                        charge.quantity += existing.quantity != null ? existing.quantity : 1;
                } 
                
                this.testCharges.put(key, charge);
        }

        public Charge[] getAggregatedCharges(){
                List<Charge> values = this.testCharges.values();
                // Integer iterationSize = values.size();
                System.debug('Start sort:');
                System.debug(values.size());

                System.debug('Aggregated values::::');
                System.debug(values);
                values.sort();
                return values;
        }

        public List<AggregateResult> getSummaryOfCharges(){
                return [SELECT  zqu__QuoteRatePlan__r.Name,zqu__Description__c, COUNT (Id) Quantity, SUM(zqu__EffectivePrice__c) TotalAmount
                FROM zqu__QuoteRatePlanCharge__c 
                WHERE zqu__QuoteRatePlan__r.zqu__Quote__c =:this.quote.Id AND Name = 'Space Fee' 
                GROUP BY zqu__QuoteRatePlan__r.Name,zqu__Description__c];
        }
                @TestVisible
        private String paymentBasedOnSelectedBasePlan(String plan) {
                return plan.substringBetween('(', ')');
        }
                @TestVisible
        private String cleanPlanName(String plan) {
                return plan.substringBefore('(').replace('_', '').replace('*','');
        }
                @TestVisible
        private Decimal calculateTotalPriceBasedOnPaymentTerm(Decimal value) {       
                if(this.quote.Payment__c == 'Monthly')
                         return value * 12;
                else if(this.quote.Payment__c == 'Quarterly')
                        return value * 4;
                else 
                        return value;
        }
        @TestVisible
        private Decimal calculateTotalPriceBasedOnPaymentTermForSLA(Decimal value) {       
                if(this.quote.Payment__c == 'Monthly')
                         return value / 12;
                else if(this.quote.Payment__c == 'Quarterly')
                        return value / 4;
                else 
                        return value;
        }
}