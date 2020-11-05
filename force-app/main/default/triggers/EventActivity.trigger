trigger EventActivity on EventActivity__e (after insert) {
    List<EventStoreItem__c> eventStoreItems = new List<EventStoreItem__c>();
    for (EventActivity__e activity : Trigger.new) {
        eventStoreItems.add(new EventStoreItem__c(Type__c = activity.Type__c,
            FirstReplayId__c = activity.FirstReplayID__c,
            LastReplayID__c = activity.LastReplayID__c,
            ErrorMessage__c = activity.ErrorMessage__c,
            HandlerClassName__c = activity.HandlerClassName__c,
            IsCDC__c = activity.IsCDC__c,
            EventType__c = activity.EventType__c));
    }
    insert eventStoreItems;
}
