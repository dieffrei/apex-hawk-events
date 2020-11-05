/**
 * Define interfaces for supported event handling: CSC and Regular events
*/
public class EventType {

    public interface ChangeDataCapture {
        void processChangeEvents(ChangeEventCollection events);
    }

    public interface PlatformEvent {
        void processEvents(EventCollection events);
    }
}