public class FindPioneerContact {
    
    public static void accountsPioneerContact(List<CF_Organization__c> scopedCFOrganizations, Set<Decimal> createdByIds){

    	/*Set<Decimal> createdByIds = new Set<Decimal>();

    	for(CF_Organization__c org : scopedCFOrganizations){
    		createdByIds.add(Decimal.valueof(org.gk_created_by_id__c));
    	}*/
        
        Map<Id, Account> accForUpdate = new Map<Id, Account>();

        if(!scopedCFOrganizations.isEmpty()){

        	for(CF_Organization_Membership__c scopedCFuser : [SELECT Id, 
        																gk_organization__c, 
        																gk_organization__r.Account__c, 
                                                                        gk_organization__r.gk_created_by_id__c,
        																gk_user__c, 
        																gk_user__r.Contact__c,
                                                                        gk_user__r.gk_id__c
        																FROM CF_Organization_Membership__c 
        																WHERE gk_user__r.gk_id__c IN :createdByIds 
        																AND gk_organization__c IN :scopedCFOrganizations 
                                                                        ORDER BY gk_created_at__c DESC
                                                                        ]){

        		if(scopedCFuser != null){

                    if(scopedCFuser.gk_user__r.gk_id__c == Decimal.valueof(scopedCFuser.gk_organization__r.gk_created_by_id__c)){

                        Account newAcc = new Account(Id = scopedCFuser.gk_organization__r.Account__c);
                    
                        newAcc.Pioneer_CF_User__c = scopedCFuser.gk_user__c;

                        if(scopedCFuser.gk_user__r.Contact__c != null){
                            newAcc.Pioneer_Contact__c = scopedCFuser.gk_user__r.Contact__c;
                        }

                        accForUpdate.put(newAcc.Id, newAcc);
                    }
        		}
        		
        	}

        	if(accForUpdate != null && !accForUpdate.values().isEmpty()) Database.update(accForUpdate.values(), false);
            
        }
    }
}