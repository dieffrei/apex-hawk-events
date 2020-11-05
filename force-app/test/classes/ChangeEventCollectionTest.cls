@IsTest
private class ChangeEventCollectionTest {

    @IsTest
    private static void constructor_CollectionParameter() {
        EventCollection collection = new EventCollection();
        collection.add(new Product2ChangeEvent());
        collection.add(new Product2ChangeEvent());
        System.assertEquals(2, collection.all().size(), 'Number of change events in original collection');

        ChangeEventCollection collectionCopy = new ChangeEventCollection(collection);
        System.assertEquals(2, collectionCopy.size(), 'Number of change events copied over');
    }

    @IsTest
    private static void getRecordsIds_NoEvents() {
        Set<Id> recordIds = new ChangeEventCollection().getRecordsIds();
        
        System.assertNotEquals(null, recordIds, 'Should return an empty list instead of null');
        System.assertEquals(0, recordIds.size(), 'List is not empty');
    }
    
    @IsTest
    private static void getRecordsIds_SingleEvent() {
        EventBus.ChangeEventHeader eventHeader = new EventBus.ChangeEventHeader();
        eventHeader.recordIds = new List<String> {
            fflib_IDGenerator.generate(Product2.SObjectType),
            fflib_IDGenerator.generate(Product2.SObjectType)
        };

        Product2ChangeEvent productEvent = new Product2ChangeEvent();
        productEvent.ChangeEventHeader = eventHeader;

        ChangeEventCollection collection = new ChangeEventCollection(
            new EventCollection(new List<SObject> {productEvent})
        );

        System.assertEquals(2, collection.getRecordsIds().size(), 'Number of records in a change event');
    }

    @IsTest
    private static void getRecordsIds_MultipleEvents() {
        EventBus.ChangeEventHeader eventHeader = new EventBus.ChangeEventHeader();
        eventHeader.recordIds = new List<String> {
            fflib_IDGenerator.generate(Product2.SObjectType),
            fflib_IDGenerator.generate(Product2.SObjectType)
        };
        Product2ChangeEvent productEvent1 = new Product2ChangeEvent();
        productEvent1.ChangeEventHeader = eventHeader;

        eventHeader = new EventBus.ChangeEventHeader();
        eventHeader.recordIds = new List<String> {
            fflib_IDGenerator.generate(Product2.SObjectType)
        };
        Product2ChangeEvent productEvent2 = new Product2ChangeEvent();
        productEvent2.ChangeEventHeader = eventHeader;

        ChangeEventCollection collection = new ChangeEventCollection(
            new EventCollection(new List<SObject> {productEvent1, productEvent2})
        );

        System.assertEquals(2, collection.size(), 'Number of change events');
        System.assertEquals(3, collection.getRecordsIds().size(), 'Number of records in both change event');
    }

    @IsTest
    private static void filterOnlyUpdates_MixedEvents() {
        EventBus.ChangeEventHeader eventUpdateHeader = new EventBus.ChangeEventHeader();
        eventUpdateHeader.changeType = 'UPDATE';
        EventBus.ChangeEventHeader eventCreateHeader = new EventBus.ChangeEventHeader();
        eventCreateHeader.changeType = 'CREATE';

        Product2ChangeEvent productUpdateEvent1 = new Product2ChangeEvent();
        productUpdateEvent1.ChangeEventHeader = eventUpdateHeader;        
        Product2ChangeEvent productUpdateEvent2 = new Product2ChangeEvent();
        productUpdateEvent2.ChangeEventHeader = eventUpdateHeader;        
        Product2ChangeEvent productCreateEvent = new Product2ChangeEvent();
        productCreateEvent.ChangeEventHeader = eventCreateHeader;
        
        ChangeEventCollection collection = new ChangeEventCollection(
            new EventCollection(new List<SObject> {productUpdateEvent1, productCreateEvent, productUpdateEvent2})
        );
        
        ChangeEventCollection updateCollection = collection.filterOnlyUpdates();

        System.assertEquals(2, updateCollection.size(), 'Number of events in collection');
        for (ChangeEvent event : updateCollection.all()) {
            System.assert(event.isUpdate(), 'Should be an update event');
        }
    }

    @IsTest
    private static void filterByFieldChanged_ListParameter() {
        EventBus.ChangeEventHeader eventHeader = new EventBus.ChangeEventHeader();
        eventHeader.changedFields = new List<String> {'Description', 'LastModifiedDate'};

        Product2ChangeEvent productEvent = new Product2ChangeEvent();
        productEvent.ChangeEventHeader = eventHeader;

        ChangeEventCollection collection = new ChangeEventCollection(new List<SObject> {productEvent});

        ChangeEventCollection resultCollection = collection.filterByFieldChanged(new List<String> {'Description'});
        System.assertNotEquals(null, resultCollection.events, 'Filter on Description should return an event');
        System.assertEquals(1, resultCollection.size(), 'Filter on Description should return one event');

        resultCollection = collection.filterByFieldChanged(new List<String> {'LastModifiedDate', 'Description'});
        System.assertNotEquals(null, resultCollection.events, 'Filter on LastModifiedDate/Description should return an event');
        System.assertEquals(2, resultCollection.size(), 'Filter on LastModifiedDate/Description should return one event');

        resultCollection = collection.filterByFieldChanged(new List<String> {'Name'});
        System.assertNotEquals(null, resultCollection.events, 'Filter on Name should return an empty event list');
        System.assertEquals(0, resultCollection.size(), 'Filter on Name should return an empty event list');
    }

    @IsTest
    private static void filterByFieldChanged_FieldsetParameter() {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Product2').getDescribe(); 
        Map<String, FieldSet> fieldSetsBySetName = describeResult.FieldSets.getMap();

        if (!fieldSetsBySetName.isEmpty()) {
            FieldSet fieldSetObj = fieldSetsBySetName.values()[0];

            EventBus.ChangeEventHeader eventHeader = new EventBus.ChangeEventHeader();
            eventHeader.changedFields = new List<String> {'SomeField__c'};
    
            Product2ChangeEvent productEvent = new Product2ChangeEvent();
            productEvent.ChangeEventHeader = eventHeader;
    
            ChangeEventCollection collection = new ChangeEventCollection(new List<SObject> {productEvent});

            ChangeEventCollection resultCollection = collection.filterByFieldChanged(fieldSetObj);
            System.assertNotEquals(null, resultCollection.events, 'Filter on Description should return an event');
            System.assertEquals(0, resultCollection.size(), 'Filter on Description should return one event');
        }
   }

}