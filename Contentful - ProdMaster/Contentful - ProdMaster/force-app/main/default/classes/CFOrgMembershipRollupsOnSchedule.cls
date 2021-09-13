global class CFOrgMembershipRollupsOnSchedule implements Schedulable 
{
    global void execute(SchedulableContext SC) 
    {	
        Date scopedNumberOfDays = System.today().addDays(-Integer.valueOf(Label.Number_Of_Days_For_CF_Memberships_Rollup ));
        cfOrganizationMemberships(scopedNumberOfDays);
        cFUserActivatedAt(scopedNumberOfDays);
    }
    public void cfOrganizationMemberships(Date scopedDate){

		Boolean executeFromCustomSetting = false;
		Boolean executeLogic = true;

		ExecuteSetting__c zuoraCFMembershipRollupSetting = new ExecuteCodeLogic().checkIfCodeLogicShouldBeExecuted('CF Organization Membership Rollup');

		if(zuoraCFMembershipRollupSetting != null){

			if(zuoraCFMembershipRollupSetting.Active__c == false){
				executeLogic = false;
			}

			if(zuoraCFMembershipRollupSetting.Execute__c == true){
				executeFromCustomSetting = true;
			}
		}

		if(executeLogic == false) return;

		List<CF_Organization__c> cfOrgsForUpdate = new List<CF_Organization__c>();

		Set<Id> scopedOrgIds = new Set<Id>();

		for(CF_Organization_Membership__c membership : [SELECT Id, gk_organization__c, gk_user__c 
														FROM CF_Organization_Membership__c 
                                  						WHERE gk_organization__c != null AND gk_user__c != null AND LastModifiedDate >= :scopedDate]){
			scopedOrgIds.add(membership.gk_organization__c);
		}

		if(!scopedOrgIds.isEmpty()){

			for(AggregateResult ag : [SELECT gk_organization__c cfOrg, count(Id) total 
										FROM CF_Organization_Membership__c 
                                  		WHERE gk_organization__c != null AND gk_user__c != null AND gk_organization__c IN : scopedOrgIds
										GROUP BY gk_organization__c]){

				if(ag.get('cfOrg') != null){
					CF_Organization__c org = new CF_Organization__c(Id = (Id)ag.get('cfOrg'));
					org.cf_user_count__c = (Integer)ag.get('total');
					cfOrgsForUpdate.add(org);
				}
			}


		}

		if(!cfOrgsForUpdate.isEmpty()) update cfOrgsForUpdate;
	}
    
    private void cFUserActivatedAt(Date scopedDate){

		System.debug('entered:cFUserActivatedAt:---- ');

		Boolean executeFromCustomSetting = false;
		Boolean executeLogic = true;

		ExecuteSetting__c zuoraCFMembershipRollupSetting = new ExecuteCodeLogic().checkIfCodeLogicShouldBeExecuted('CF Organization Membership Rollup');

		if(zuoraCFMembershipRollupSetting != null){

			if(zuoraCFMembershipRollupSetting.Active__c == false){
				executeLogic = false;
			}

			if(zuoraCFMembershipRollupSetting.Execute__c == true){
				executeFromCustomSetting = true;
			}
		}

		if(executeLogic == false) return;

		Set<Id> cfUserIds = new Set<Id>();

		for(CF_Organization_Membership__c orgMembership : [SELECT Id, Activated_At__c, gk_organization__c, gk_user__c
                                                           	FROM CF_Organization_Membership__c 
                                                          	WHERE gk_organization__c != null AND gk_user__c != null AND LastModifiedDate >= :scopedDate]){
			cfUserIds.add(orgMembership.gk_user__c);
		}

		System.debug('entered:cFUserActivatedAt:cfUserIds---- ' + cfUserIds);

		if(!cfUserIds.isEmpty()){
			List<CF_User__c> cfUsersForUpdate = new List<CF_User__c>();

            for(CF_User__c cfU : [SELECT Id, BI_User_Activated_At__c, Organization_Count__c, 
                                    (SELECT Id, Activated_At__c, gk_organization__c FROM CF_Organization_Memberships__r ORDER BY Activated_At__c ASC NULLS LAST)
                                        FROM CF_User__c WHERE Id IN :cfUserIds]){
    
                cfU.Organization_Count__c = 0;
                cfU.BI_User_Activated_At__c = cfU.CF_Organization_Memberships__r[0].Activated_At__c;
    
                for(CF_Organization_Membership__c orgM : cfU.CF_Organization_Memberships__r){
                    if(orgM.gk_organization__c != null){
                        cfU.Organization_Count__c += 1;
                    }
                }
    
                cfUsersForUpdate.add(cfU);
            }
    
            if(cfUsersForUpdate.size() > 0) update cfUsersForUpdate;
		} 
	}
}