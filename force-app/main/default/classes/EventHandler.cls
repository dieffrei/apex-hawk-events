/**
 * An event handler implementation for platform events.
 * It provides follows functionalities:
 * <ul>
 * <li><b>Limits management:</b> Define how many events can be processed per transaction</li>
 * <li><b>Error handling:</b> Retry automatically up to @maxRetries</li>
 * <li><b>Traceability:</b> When attempts reach to the maxRetries limits, platform event transaction information like: first and last platforme event Id are stored,
 * they are stored in a EventStoreItem__c record</li>
 * </ul>
 * For <i>change data capture events</i> override @processChangeEvents() or regular events @processEvents()
*/
public inherited sharing virtual class EventHandler {

    private class EventHandlerException extends Exception{}

    @TestVisible
    private Integer maxRetries = 10;

    @TestVisible
    private Integer maxEvents = 2000;

    @TestVisible
    private EventCollection events;

    protected EventHandler() {
        this.events = EventCollectionFactory.buildFromTriggerContext();
    }

    @TestVisible
    protected EventHandler(EventCollection events) {
        Objects.assertIsNotNull('events', events);
        this.events = events;
    }

    /**
     * Set how many platform events can be processed per transaction
     * @return @self
    */
    public EventHandler canHandleMax(Integer maxEvents) {
        this.maxEvents = maxEvents;
        return this;
    }

    private Boolean isChangeDataCapture() {
        return (this instanceof EventType.ChangeDataCapture);
    }

    /**
     * @return true if is the last attempt
     * Platform events can be retried up to 9 times, if the attempt fail more than 10 (initial attempt + 9), trigger is deactivated
    */
    private Boolean doesItLastTry() {
        // retries start to count from 0
        return (EventBus.TriggerContext.currentContext().retries == (this.maxRetries - 1));
    }

    /**
     * @return EventBus.TriggerContext useful for mocking purposes
    */
    public EventBus.TriggerContext getTriggerContext() {
        return EventBus.TriggerContext.currentContext();
    }

    @TestVisible
    protected void skipEventsAndStore(EventCollection skippedEvents, Exception ex) {
        EventBus.publish(new EventActivityBuilder()
            .handlerNamedAs('ProductChangeListener')
            .isChangeDataCapture()
            .throwedException(ex)
            .forEvents(skippedEvents)
            .build());

        whenLastTryFails(events, ex);
    }

    /**
     * @description Set latest platform event processed in a transaction
    */
    @TestVisible
    private void setResumeCheckPoint(String replayId) {
        getTriggerContext()
            .setResumeCheckpoint(replayId);
    }

    /**
     * @description Register a listener for a specific event
     * Events are processed by batch size <b>maxEvents</b> determines how many events can be processed in a transaction.
    */
    public void register() {
        try {
            EventCollection scope = this.events.getFirsts(this.maxEvents);
            delegateByEventTypeHandler(scope);
            setResumeCheckPoint(scope.getLastReplayId());
        } catch (Exception ex) {
            if (doesItLastTry()) {
                skipEventsAndStore(events, ex);
            } else {
                throw new EventBus.RetryableException(String.format('[{0}] throwed an exception in the [{1}] attempt: {2}', new Object[]{
                    'ProductChangeListener',
                    EventBus.TriggerContext.currentContext().retries + 1,
                    ex.getMessage() + ex.getStackTraceString()
                }));
            }
        }

    }

    /**
     * @description Delegate right method implementation based on event type
    */
    @TestVisible
    private void delegateByEventTypeHandler(EventCollection events){
        if (this instanceof EventType.PlatformEvent) {
            ((EventType.PlatformEvent)(this))
                .processEvents(events);
        } else if (this instanceof EventType.ChangeDataCapture) {
            ((EventType.ChangeDataCapture)(this))
                .processChangeEvents(new ChangeEventCollection(events));
        } else {
            throw new EventHandlerException('Event handler doesnt implement a valid interface. See @EventType class. ');
        }
    }

    /**
     *  @description Executed in the last unsuccessful attempt.
    */
    public virtual void whenLastTryFails(EventCollection failedEvents, Exception ex) {
    }

}
