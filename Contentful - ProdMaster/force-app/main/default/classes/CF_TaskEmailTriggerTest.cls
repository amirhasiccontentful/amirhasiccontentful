@isTest
private class CF_TaskEmailTriggerTest {

    static testMethod void testProductRelevantInput() {
        Task task = new Task(Subject = 'Task', Activity__c = 'Call - Demo', Product_Relevant_Input__c = true);
        insert task;
    }
     
}