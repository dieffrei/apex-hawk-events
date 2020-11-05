public inherited sharing class EventCollectionFactory {

    public static EventCollection buildFromTriggerContext(){
        return new EventCollection(Trigger.new);
    }

}