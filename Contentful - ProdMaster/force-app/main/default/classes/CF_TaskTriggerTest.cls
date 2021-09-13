@isTest
private class CF_TaskTriggerTest {
    static testMethod void myUnitTest() {
    	
        Task task = new Task(Subject = 'Task', Activity__c = 'Call - Demo');
        insert task;
        
		//System.assertEquals(task.type, task.activity__c);
    }
}