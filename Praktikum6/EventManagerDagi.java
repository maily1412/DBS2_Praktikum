package de.hsduesseldorf.medien.dbs.eventmgr.data;

import java.sql.Date;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Datenhaltung, verwaltet Events
 */
public class EventManager {

    private final List<Event> events = new ArrayList<Event>();

    public EventManager() {}

    /**
     * Liefert alle Events in einer logischen Rheinfolge zurueck.
     *
     * Hinweis: Verwenden Sie fuer die Rueckgabe eine ArrayList  mit folgender deklaration:
     * 		List<Event> res = new ArrayList<Event>();
     * @link  http://docs.oracle.com/javase/7/docs/api/java/util/ArrayList.html
     *
     * Mehr zu Generics in der OOP Vorlesung
     *
     * @return List mit allen Events
     */
    public List<Event> listEvents() {
        List<Event> res;
        synchronized (events) {
            res = new ArrayList<Event>(events);
        }
        Collections.sort(res, new Comparator<Event>() {
            @Override
            public int compare(Event e1, Event e2) {
                Calendar d1 = e1 == null ? null : e1.getEventDate();
                Calendar d2 = e2 == null ? null : e2.getEventDate();
                if (d1 == null && d2 == null) return 0;
                if (d1 == null) return 1; // null dates go last
                if (d2 == null) return -1;
                return Long.compare(d1.getTimeInMillis(), d2.getTimeInMillis());
            }
        });
        return res;
    }

    /**
     * Liefert ein Event anhand seiner Id zurueck
     *
     * @param id Id des Events
     * @return Datensatz des Events
     */
    public Event findById(int id) {
        synchronized (events) {
            for (Event e : events) {
                if (e != null && e.getEventId() != null && e.getEventId() == id) {
                    return e;
                }
            }
        }
        return null;
    }

    /**
     * Aktualisiert die Daten eines Events
     *
     *
     * @param event Event das gespeichert werden soll
     */
    public void save(Event event) {
        if (event == null || event.getEventId() == null) {
            throw new IllegalArgumentException("Event or eventId must not be null for save");
        }
        synchronized (events) {
            for (int i = 0; i < events.size(); i++) {
                Event cur = events.get(i);
                if (cur != null && cur.getEventId() != null && cur.getEventId().equals(event.getEventId())) {
                    events.set(i, event);
                    return;
                }
            }
        }
        throw new IllegalArgumentException("Event with id " + event.getEventId() + " not found");
    }

    /**
     * Fuegt eine neues Event in die Datenbank ein
     *
     *
     * @param event
     */
       public void insert(Event event) {
        if (event == null) {
            throw new IllegalArgumentException("Event must not be null");
        }

        String eventId = Integer.toString(event.getEventId());
        String eventLocation = event.getLocation();
        Date eventDate = new Date(event.getEventDate().getTime().getTime());
        String eventTitle = event.getEventTitle();
        String eventName = event.getName();
        
                 String sql = "INSERT INTO event (eventId, eventTitle, eventName, location, eventDate) VALUES(" + eventId + ", '" + eventTitle + "', '" + eventName + "', '" + eventLocation + "', TO_DATE('" + eventDate + "', 'YYYY-MM-DD'))";
        
        JdbcUtil.execSql(sql);
                synchronized (events) {
            events.add(event);
        }
    }

    /**
     * Loescht ein Event aus der Datenbank
     *
     * @param event
     */
    public void delete(Event event) {
        if (event == null || event.getEventId() == null) return;
                JdbcUtil.execSql("DELETE FROM event where eventId =" + Integer.toString(event.getEventId()));
        synchronized (events) {
            Event toRemove = null;
            for (Event e : events) {
                if (e != null && e.getEventId() != null && e.getEventId().equals(event.getEventId())) {
                    toRemove = e;
                    break;
                }
            }
            if (toRemove != null) events.remove(toRemove);
        }
    }



    /**
     * Wird beim schliessen der Anwendungaufgerufen
     */
    public void shutdown() {
        synchronized (events) {
            events.clear();
        }
    }

    public static String calendarToIsoDate(Calendar cal) {
    if (cal == null) return null;
    // Konvertiere Calendar -> ZonedDateTime in der Calendar-Zeitzone, dann LocalDate -> String
    return cal.toInstant()
              .atZone(cal.getTimeZone().toZoneId())
              .toLocalDate()
              .format(DateTimeFormatter.ISO_LOCAL_DATE); // "yyyy-MM-dd"
}
}