public without sharing class TaskAndEventRollups {

	public void updateTaskRollupFields(List<Task> newRecords){

		Boolean executeLogic = true;

		ExecuteSetting__c taskRollupsSetting = new ExecuteCodeLogic().checkIfCodeLogicShouldBeExecuted('Task Rollups');

		if(taskRollupsSetting != null){

			if(taskRollupsSetting.Active__c == false){
				executeLogic = false;
			}
		}

		if(executeLogic == false) return; //stop code execution

		Set<Id> setOfScopedParentIds = new Set<Id>();

		for(Task record : newRecords){

			if(record.WhoId <> null){
				setOfScopedParentIds.add(record.WhoId);
			}
			if(record.WhatId <> null){
				setOfScopedParentIds.add(record.WhatId);
			}
		}

		if(setOfScopedParentIds.isEmpty()) return;

		/*Map<Id, Opportunity> mapOfScopedOpps = new Map<Id, Opportunity>([SELECT Id, StageName, Last_Task_Creation_Date__c, Task_Count__c, Last_Task_Date__c
												FROM Opportunity WHERE Id IN :setOfScopedParentIds]);

	    List<Opportunity> oppsForUpdate = new List<Opportunity>();

		for(AggregateResult agg : [SELECT 
									count(Id) numberOfRecords, 
									WhatId relatedRec, 
									max(Activity_Date_Proxy__c) maxProxyDate, 
									max(CreatedDate) maxCreatedDate 
									FROM Task WHERE WhatId IN :setOfScopedParentIds AND What.Type = 'Opportunity' GROUP BY WhatId]){

			if(!mapOfScopedOpps.values().isEmpty() && (Id)agg.get('relatedRec') != null){

				Opportunity opp = mapOfScopedOpps.get((Id)agg.get('relatedRec'));
				
				if(opp != null && opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost'){
					opp.Last_Task_Creation_Date__c = (DateTime)agg.get('maxCreatedDate');
					opp.Task_Count__c = (Integer)agg.get('numberOfRecords');
					opp.Last_Task_Date__c = (DateTime)agg.get('maxProxyDate');
					oppsForUpdate.add(opp);
				}
			}
		}*/

		Map<Id, Order> ordersForUpdate = new Map<Id, Order>();
		Integer totalRecordCount = 0;
		Integer totalOpenCount = 0;
		Integer totalOpenWithDueDate = 0;
		String recId = '';
		Set<Id> setOfAddedOrderIds = new Set<Id>();

		for(AggregateResult agg : [SELECT 
									count(Id) numberOfRecords, WhatId relatedRec, isClosed closed, ActivityDate aDate
									FROM Task WHERE WhatId IN :setOfScopedParentIds AND What.Type = 'Order' 
									GROUP BY WhatId, isClosed, ActivityDate ORDER BY WhatId]){

			System.debug('Entered:Order Tasks:---- ');

			if(!recId.contains((String)agg.get('relatedRec'))){
				totalRecordCount = 0;
				totalOpenCount = 0;
				totalOpenWithDueDate = 0;
			}

			Order order = new Order();
			order.Id = (Id)agg.get('relatedRec');

			if(recId != (String)agg.get('relatedRec')){

				recId = (String)agg.get('relatedRec');
								
				totalRecordCount = (Integer)agg.get('numberOfRecords');
				if(!(Boolean)agg.get('closed')){
					totalOpenCount = (Integer)agg.get('numberOfRecords');
				}

				if((Date)agg.get('aDate') != null && !(Boolean)agg.get('closed')){
					totalOpenWithDueDate = (Integer)agg.get('numberOfRecords');
				}

			} else {

				totalRecordCount += (Integer)agg.get('numberOfRecords'); 

				if(!(Boolean)agg.get('closed')){
					totalOpenCount += (Integer)agg.get('numberOfRecords');
				}

				if((DateTime)agg.get('aDate') != null && !(Boolean)agg.get('closed')){
					totalOpenWithDueDate += (Integer)agg.get('numberOfRecords');
				}
			}

			order.Open_Task_With_Due_Date_Count__c = totalOpenWithDueDate;
			order.Task_Count__c = totalRecordCount;
			order.Open_Task_Count__c = totalOpenCount;

			ordersForUpdate.put(order.Id, order);

		}

		List<Lead> leadsForUpdate = new List<Lead>();

		for(AggregateResult agg : [SELECT 
									count(Id) numberOfRecords, 
									WhoId personId, 
									max(Activity_Date_Proxy__c) maxProxyDate, 
									max(CreatedDate) maxCreatedDate 
									FROM Task WHERE WhoId IN :setOfScopedParentIds AND Who.Type = 'Lead' GROUP BY WhoId]){

			if((Id)agg.get('personId') != null){
				Lead ld = new Lead(Id = (Id)agg.get('personId'));
				ld.Last_Task_Creation_Date__c = (DateTime)agg.get('maxCreatedDate');
				ld.Last_Task_Date__c = (DateTime)agg.get('maxProxyDate');
				ld.Task_Count__c = (Integer)agg.get('numberOfRecords');
				leadsForUpdate.add(ld);
			}
		}

		//if(oppsForUpdate.size() > 0) update oppsForUpdate;
		if(leadsForUpdate.size() > 0) update leadsForUpdate;
		if(ordersForUpdate != null) update ordersForUpdate.values();
	}

	public void updateEventRollupFields(List<Event> newRecords){

		Boolean executeLogic = true;

		ExecuteSetting__c eventRollupsSetting = new ExecuteCodeLogic().checkIfCodeLogicShouldBeExecuted('Event Rollups');

		if(eventRollupsSetting != null){

			if(eventRollupsSetting.Active__c == false){
				executeLogic = false;
			}
		}

		if(executeLogic == false) return; //stop code execution

		Set<Id> setOfScopedParentIds = new Set<Id>();

		for(Event record : newRecords){

			if(record.WhoId <> null){
				setOfScopedParentIds.add(record.WhoId);
			}
			if(record.WhatId <> null){
				setOfScopedParentIds.add(record.WhatId);
			}
		}

		if(setOfScopedParentIds.isEmpty()) return;

		/*Map<Id, Opportunity> mapOfScopedOpps = new Map<Id, Opportunity>([SELECT Id, StageName, Last_Event_Creation_Date__c, Event_Count__c, Last_Event_Date__c
												FROM Opportunity WHERE Id IN :setOfScopedParentIds]);

		List<Opportunity> oppsForUpdate = new List<Opportunity>();
		

		for(AggregateResult agg : [SELECT 
									count(Id) numberOfRecords, 
									WhatId relatedRec, 
									max(Activity_Date_Proxy__c) maxProxyDate, 
									max(CreatedDate) maxCreatedDate 
									FROM Event WHERE WhatId IN :setOfScopedParentIds AND What.Type = 'Opportunity' GROUP BY WhatId]){

			
			if(!mapOfScopedOpps.values().isEmpty() && (Id)agg.get('relatedRec') != null){

				Opportunity opp = mapOfScopedOpps.get((Id)agg.get('relatedRec'));
				
				if(opp != null && opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost'){
					opp.Last_Event_Creation_Date__c = (DateTime)agg.get('maxCreatedDate');
					opp.Event_Count__c = (Integer)agg.get('numberOfRecords');
					opp.Last_Event_Date__c = (DateTime)agg.get('maxProxyDate');
					oppsForUpdate.add(opp);
				}
			}
		}*/

		List<Lead> leadsForUpdate = new List<Lead>();

		for(AggregateResult agg : [SELECT 
									count(Id) numberOfRecords, 
									WhoId personId, 
									max(Activity_Date_Proxy__c) maxProxyDate, 
									max(CreatedDate) maxCreatedDate 
									FROM Event WHERE WhoId IN :setOfScopedParentIds AND Who.Type = 'Lead' GROUP BY WhoId]){

				if((Id)agg.get('personId') != null){
					Lead ld = new Lead(Id = (Id)agg.get('personId'));
					ld.Last_Event_Creation_Date__c = (DateTime)agg.get('maxCreatedDate');
					ld.Last_Event_Date__c = (DateTime)agg.get('maxProxyDate');
					ld.Event_Count__c = (Integer)agg.get('numberOfRecords');
					leadsForUpdate.add(ld);
				}
		}

		//if(oppsForUpdate.size() > 0) update oppsForUpdate;
		if(leadsForUpdate.size() > 0) update leadsForUpdate;
	}
}