global without sharing class FindApprovalHistory {
	
    global List<ProcessInstance> approvals;
    global String opportunityId{get;set;}

	public FindApprovalHistory() {
		
	}

	public List<ProcessInstance> getGeneratedApprovalHistory() {
		return approvals;
	}
    
    global List<ProcessInstance> generatedApprovalHistory{
        get{        
            approvals = new List<ProcessInstance>();
            approvals = [SELECT Id, (SELECT Id, StepStatus, OriginalActor.Name, ActorId, Actor.Name, Actor.Email, Comments, CreatedDate FROM StepsAndWorkitems ORDER BY CreatedDate DESC), TargetObjectId, Status, CompletedDate, LastActorId, SubmittedById, IsDeleted, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :opportunityId ORDER BY CreatedDate DESC];
            return approvals;
        }
        set;
    }
}