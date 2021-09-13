global class ExecuteCodeLogic {
    
    global ExecuteSetting__c checkIfCodeLogicShouldBeExecuted(String scopedClassName){
        ExecuteSetting__c executeCustomSetting;
        
        if(String.isNotBlank(scopedClassName)){
            executeCustomSetting = ExecuteSetting__c.getValues(scopedClassName);
        }
        
        if(executeCustomSetting != null){
            return executeCustomSetting;
        }
        return null;
    }
}