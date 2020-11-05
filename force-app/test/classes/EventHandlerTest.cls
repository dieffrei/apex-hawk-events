@IsTest
private class EventHandlerTest {

    private class EventHandlerException extends Exception {
    }

    private class LogEventListenerFailing extends EventHandler implements EventType.PlatformEvent {

        public LogEventListenerFailing() {
            super();
        }

        @TestVisible
        private LogEventListenerFailing(EventCollection events) {
            super(events);
        }

        public void processEvents(EventCollection events) {
            throw new EventHandlerException();
        }
    }

    @IsTest
    static void constructor_DontAcceptInvalid_args() {
        try {
            new EventHandler(null);
            System.assert(false, 'should try exception when is parameter is null');
        } catch (Exception ex) {

        }
    }

    @IsTest
    static void canHandleMax_setValue() {
        EventHandler eventHandler = new EventHandler(new EventCollection())
            .canHandleMax(5);
        System.assertEquals(5, eventHandler.maxEvents);
    }

    @IsTest
    static void delegateByEventTypeHandler_whenImplements_RegularPlatformEvent() {
        new LogEventHandler(new EventCollection())
            .delegateByEventTypeHandler(new EventCollection());
    }

    @IsTest
    static void skipEventsAndStore_dispatchActivityEvents() {
        Test.startTest();
        EventHandler eventHandler = new EventHandler(new EventCollection());
        eventHandler.skipEventsAndStore(new EventCollection(),
            new EventHandlerException());
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM EventStoreItem__c]);
    }

    @IsTest
    static void whenBulkPublishing_ShouldSplitEventsPerTransaction() {
        Test.startTest();

        // publish 5 events
        EventBus.publish(new List<SObject>{
            new Log__e(),
            new Log__e(),
            new Log__e(),
            new Log__e(),
            new Log__e()
        });

        // log event trigger just process 1 item per transaction
        // every delivery call (another transaction is created)
        // in the end we have 5 log events processed per transaction
        for (Integer i = 1; i <= 5; i++) {
            Test.getEventBus()
                .deliver();
        }

        // EventBusSubscriber has the information of log event trigger
        EventBusSubscriber subscriber = [
            SELECT Name, Type, Position, Retries, LastError
            FROM EventBusSubscriber
            WHERE Topic = 'Log__e'
            LIMIT 1
        ];

        System.assertNotEquals(null, subscriber);
        System.assertEquals(5, subscriber.Position);

        Test.stopTest();
    }

    @IsTest
    static void whenEventProcessingFails_RetryUpTo9Attempts() {
        Test.startTest();

        CommonsModule.provider = new DI.ServiceCollection()
            .addSingleton(LogEventHandler.class, LogEventListenerFailing.class)
            .buildServiceProvider();

        // publish 5 events
        EventBus.publish(new List<SObject>{
            new Log__e(),
            new Log__e(),
            new Log__e(),
            new Log__e(),
            new Log__e()
        });

        for (Integer i = 1; i <= 10; i++) {
            Test.getEventBus()
                .deliver();
        }

        // EventBusSubscriber has the information of log event trigger
        EventBusSubscriber subscriber = [
            SELECT Name, Type, Position, Retries, LastError
            FROM EventBusSubscriber
            WHERE Topic = 'Log__e'
            LIMIT 1
        ];

        System.assertNotEquals(null, subscriber);
        System.assertEquals(9, subscriber.Retries);

        // after last attempt, dispatches and event activity which creates and event store item
        Test.getEventBus()
            .deliver();

        System.assertEquals(1, [SELECT count() FROM EventStoreItem__c]);

        Test.stopTest();
    }


}
