public inherited sharing class LogEventHandler extends EventHandler implements EventType.PlatformEvent {

    public LogEventHandler(){
        super();
    }

    @TestVisible
    private LogEventHandler(EventCollection events) {
        super(events);
    }

    public void processEvents(EventCollection events) {
        System.debug('LogEventHandler()' + events);
    }

}
