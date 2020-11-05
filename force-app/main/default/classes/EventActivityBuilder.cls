public inherited sharing class EventActivityBuilder {

    private EventActivity__e activity;

    public EventActivityBuilder() {
        this.activity = new EventActivity__e();
    }

    public EventActivityBuilder isChangeDataCapture() {
        this.activity.IsCDC__c = true;
        return this;
    }

    public EventActivityBuilder handlerNamedAs(String handlerName) {
        this.activity.HandlerClassName__c = handlerName;
        return this;
    }

    public EventActivityBuilder forEvents(EventCollection events){
        if (events.all().isEmpty()) {
            return this;
        }
        this.activity.EventType__c = String.valueOf(events.all().get(0).getSObjectType());
        this.activity.FirstReplayID__c = events.getFirstReplayId();
        this.activity.LastReplayID__c = events.getLastReplayId();
        return this;
    }

    public EventActivityBuilder throwedException(Exception ex){
        this.activity.ErrorMessage__c = ex.getMessage();
        this.activity.Type__c = ex.getTypeName();
        return this;
    }

    public EventActivity__e build(){
        return this.activity;
    }

}
