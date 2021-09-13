global without sharing class ZuoraAddMicroFreeOnSave implements zqu.SelectProductComponentOptions.ISaveRatePlanPlugin {
 public void onSave(List < zqu.zChargeGroup > addedChargeGroups, List < zqu.zChargeGroup > updatedChargeGroups, List < zqu.zChargeGroup > removedChargeGroups, List < zqu.zChargeGroup > persistedChargeGroups) {

  // Validate addedChargeGroups
    if (!persistedChargeGroups.isEmpty()) {
       
    zqu.zChargeGroup tst = persistedChargeGroups.get(0);
       
    if (tst.quote != null) {
        
     zqu__Quote__c q = tst.quote;
     String pInternalName = q.Payment__c;
     if(pInternalName == 'Monthly'){
          pInternalName = 'month';
     } else if(pInternalName == 'Quarterly'){
          pInternalName = 'quarter';
     }
        
    if(q.RecordTypeId == Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('Amendment').getRecordTypeId()){
     for (zqu.zChargeGroup cg : persistedChargeGroups) {
      if (cg.ratePlanName.containsIgnoreCase('Professional') || cg.ratePlanName.containsIgnoreCase('Scale')) {
          System.debug('ZuoraAddMicroFreeOnSave:cg:--- ' + cg);
          for(zqu.zCharge zC : cg.zCharges){
            System.debug('ZuoraAddMicroFreeOnSave:zCharge:--- ' + zC);
            
            if(zC.chargeTiersObjects.size()>0){
            for(zqu__QuoteCharge_Tier__c t : zC.chargeTiersObjects){
                t.zqu__ZuoraId__c = '';
              }
            }
          }
          zqu.zQuoteUtil.updateChargeGroup(cg);
      }
     }        
    }        
    }
   }
 }

 global class SavePluginException extends Exception {}
}