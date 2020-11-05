/**
 * Representation of a CDC Platform Event
*/
public inherited sharing class ChangeEvent {

    private SObject changeEventSobject;
    EventBus.ChangeEventHeader headerInfo;

    public ChangeEvent(SObject changeEventSobject) {
        this.changeEventSobject = changeEventSobject;
        this.headerInfo = (EventBus.ChangeEventHeader) changeEventSobject.get('ChangeEventHeader');
    }

    public Boolean isChanged(String fieldName) {
        return this.headerInfo.changedFields.contains(fieldName);
    }

    public Boolean isChanged(Set<String> fieldNames) {
        for (String fieldName : fieldNames) {
            if (isChanged(fieldName)){
                return true;
            }
        }
        return false;
    }

    public Boolean isChanged(List<String> fieldNames) {
        for (String fieldName : fieldNames) {
            if (isChanged(fieldName)){
                return true;
            }
        }
        return false;
    }

    public Boolean isUpdate() {
        return this.headerInfo.changeType == 'UPDATE';
    }

    public Boolean isCreate() {
        return this.headerInfo.changeType == 'CREATE';
    }

    public Set<Id> getRecordIds() {
        Set<Id> recordIds = new Set<Id>();
        for (String recordId : this.headerInfo.recordIds) {
            recordIds.add(Id.valueOf(recordId));
        }
        return recordIds;
    }

}