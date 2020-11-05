@IsTest
private class ChangeEventTest {

    @IsTest
    private static void isChanged_Successful() {
        EventBus.ChangeEventHeader eventHeader = new EventBus.ChangeEventHeader();
        eventHeader.changedFields = new List<String> {'Description', 'LastModifiedDate'};

        Product2ChangeEvent productEvent = new Product2ChangeEvent();
        productEvent.ChangeEventHeader = eventHeader;

        ChangeEvent event = new ChangeEvent(productEvent);
        System.assertEquals(true, event.isChanged('Description'), 'Single field check - changed');
        System.assertEquals(false, event.isChanged('Name'), 'Single field check - not changed');
        System.assertEquals(true, event.isChanged(new Set<String> {'Description', 'Name'}), 'Multiple fields (Set) check - changed');
        System.assertEquals(false, event.isChanged(new Set<String> {'Family', 'Name'}), 'Multiple fields (Set) check - not changed');
        System.assertEquals(true, event.isChanged(new List<String> {'Description', 'Name'}), 'Multiple fields (List) check - changed');
        System.assertEquals(false, event.isChanged(new List<String> {'Family', 'Name'}), 'Multiple fields (List) check - not changed');
    }

    @IsTest
    private static void changeType_IsUpdateAndIsCreate() {
        EventBus.ChangeEventHeader eventHeader = new EventBus.ChangeEventHeader();
        eventHeader.changeType = 'UPDATE';

        Product2ChangeEvent productEvent = new Product2ChangeEvent();
        productEvent.ChangeEventHeader = eventHeader;

        ChangeEvent event = new ChangeEvent(productEvent);
        System.assertEquals(true, event.isUpdate(), 'Is an update');
        System.assertEquals(false, event.isCreate(), 'Is an update, not a create');

        eventHeader.changeType = 'CREATE';
        System.assertEquals(false, event.isUpdate(), 'Is a create');
        System.assertEquals(true, event.isCreate(), 'Is a create, not an update');
    }

    @IsTest
    private static void getRecordIds_oneRecord() {
        EventBus.ChangeEventHeader eventHeader = new EventBus.ChangeEventHeader();
        eventHeader.recordIds = new List<String> {fflib_IDGenerator.generate(Product2.SObjectType)};

        Product2ChangeEvent productEvent = new Product2ChangeEvent();
        productEvent.ChangeEventHeader = eventHeader;

        ChangeEvent event = new ChangeEvent(productEvent);
        Set<Id> recordIds = event.getRecordIds();
        System.assertNotEquals(null, recordIds, 'Returned ID set is null');
        System.assertEquals(1, recordIds.size(), 'Excepted one ID');
    }

    @IsTest
    private static void getRecordIds_multipleRecords() {
        EventBus.ChangeEventHeader eventHeader = new EventBus.ChangeEventHeader();
        eventHeader.recordIds = new List<String> {
            fflib_IDGenerator.generate(Product2.SObjectType),
            fflib_IDGenerator.generate(Product2.SObjectType),
            fflib_IDGenerator.generate(Product2.SObjectType)
        };

        Product2ChangeEvent productEvent = new Product2ChangeEvent();
        productEvent.ChangeEventHeader = eventHeader;

        ChangeEvent event = new ChangeEvent(productEvent);
        Set<Id> recordIds = event.getRecordIds();
        System.assertNotEquals(null, recordIds, 'Returned ID set is null');
        System.assertEquals(3, recordIds.size(), 'Excepted one ID');
    }

}