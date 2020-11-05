/**
 * Platform Event collection
*/
public inherited sharing virtual class EventCollection {

    @TestVisible
    protected List<SObject> events;

    public EventCollection() {
        this.events = new List<SObject>();
    }

    public EventCollection(List<SObject> events) {
        this();
        this.events.addAll(events);
    }

    public EventCollection add(SObject event) {
        this.events.add(event);
        return this;
    }

    public EventCollection addAll(List<SObject> events) {
        this.events.addAll(events);
        return this;
    }

    public List<SObject> all() {
        return events;
    }

    public SObjectType getSObjectType() {
        return this.events.getSObjectType();
    }

    public EventCollection getFirsts(Integer numberOfEvents) {
        EventCollection scopedEvent = new EventCollection();
        Integer counter = 0;
        for (SObject event : this.events) {
            scopedEvent.add(event);
            counter++;
            if (counter == numberOfEvents) {
                break;
            }
        }
        return scopedEvent;
    }

    public String getFirstReplayId() {
        if (this.events.isEmpty()) {
            return null;
        }
        return (String) this.events
            .get(0)
            .get('ReplayId');
    }

    public String getLastReplayId() {
        if (this.events.isEmpty()) {
            return null;
        }
        return (String) this.events
            .get(this.events.size() - 1)
            .get('ReplayId');
    }

}