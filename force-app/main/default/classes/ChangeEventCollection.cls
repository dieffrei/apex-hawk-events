/**
 * Collection of platform event from CDC (Change Data Capture)
*/
public inherited sharing class ChangeEventCollection {

    public List<ChangeEvent> events;

    public ChangeEventCollection() {
        this.events = new List<ChangeEvent>();
    }

    public ChangeEventCollection(EventCollection events) {
        this(events.all());
    }

    public ChangeEventCollection(List<SObject> changeEventSObjects) {
        this();
        for (SObject changeEventSObject : changeEventSObjects) {
            this.events.add(new ChangeEvent(changeEventSObject));
        }
    }

    public Set<Id> getRecordsIds() {
        Set<Id> recordsIds = new Set<Id>();
        for (ChangeEvent changeEvent : events) {
            recordsIds.addAll(changeEvent.getRecordIds());
        }
        return recordsIds;
    }

    public ChangeEventCollection filterOnlyUpdates() {
        ChangeEventCollection updateEvents = new ChangeEventCollection();
        for (ChangeEvent changeEvent : events) {
            if (changeEvent.isUpdate()) {
                updateEvents.add(changeEvent);
            }
        }
        return updateEvents;
    }

    public void add(ChangeEvent changeEvent) {
        this.events.add(changeEvent);
    }

    public Integer size() {
        return this.events.size();
    }

    /**
     * Return only change events which has at least one diff field on @fieldNames parameter
    */
    public ChangeEventCollection filterByFieldChanged(List<String> fieldsNames) {
        ChangeEventCollection filteredChanges = new ChangeEventCollection();
        for (ChangeEvent changeEvent : events) {
            for (String fieldName : fieldsNames) {
                if (changeEvent.isChanged(fieldName)) {
                    filteredChanges.add(changeEvent);
                }
            }
        }
        return filteredChanges;
    }

    public ChangeEventCollection filterByFieldChanged(FieldSet fieldSet) {
        ChangeEventCollection filteredChanges = new ChangeEventCollection();
        for (ChangeEvent changeEvent : events) {
            for (FieldSetMember field : fieldSet.getFields()) {
                if (changeEvent.isChanged(field.getFieldPath())) {
                    filteredChanges.add(changeEvent);
                }
            }
        }
        return filteredChanges;
    }

    public List<ChangeEvent> all() {
        return events;
    }

}
