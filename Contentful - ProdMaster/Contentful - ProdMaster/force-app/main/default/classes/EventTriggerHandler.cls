public class EventTriggerHandler extends TriggerHandler {

    /****************************************************/
    /* TRIGGER EXECUTION                                */
    /****************************************************/

    public override void beforeUpdate() {
        populateActivityDateProxyField(trigger.new);
    }

    public override void beforeInsert() {
        populateActivityDateProxyField(trigger.new);
    }

    public override void afterUpdate() {
        new TaskAndEventRollups().updateEventRollupFields(trigger.new);
    }

    public override void afterInsert() {
        new TaskAndEventRollups().updateEventRollupFields(trigger.new);
    }

    //The expected value of the standard Event.ActivityDate field, copied here to facilitate SOQL aggregate functions
    public void populateActivityDateProxyField(List<Event> newEvents){
        for (Event eachEvent : newEvents) {
            eachEvent.Activity_Date_Proxy__c = eachEvent.ActivityDateTime;
        }
    }
}