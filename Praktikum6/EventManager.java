package de.hsduesseldorf.medien.dbs.eventmgr.data;

import java.sql.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Calendar;


/**
 * Datenhaltung, verwaltet Events
 */
public class EventManager {

    // Datenbankverbindung über Connector
    private Java_Database_Connector db;


    public EventManager() {
        try {
            // Datenbankverbindung über den Connector herstellen
            db = new Java_Database_Connector();
    }   catch (Exception e){
            // Fehler weiterwerfen, falls Verbindung fehlschlägt
            throw new RuntimeException(e);
    } 
    }

    // Wandelt ein SQL-Datum in ein Calendar-Objekt um 
    private Calendar toCalendar(java.sql.Date date) {
    Calendar cal = Calendar.getInstance();
    cal.setTime(date);
    return cal;
    }

    // Prüft, ob es in der Tabelle EVENT bereits einen Datensatz mit diesem Namen gibt
    private boolean existsEventName(String event_name) throws SQLException {

    // Zählt, wie viele Zeilen den Namen haben    
    String sql = "SELECT COUNT(*) FROM event WHERE event_name = ?";
    // PreparedStatement über deinen Java_Database_Connector erzeugen
    PreparedStatement stmt = db.createPreparedStatement(sql);

    //Platzhalter mit dem übergebenen Namen füllen
    stmt.setString(1, event_name);

    // Abfrage ausführen 
    ResultSet rs = stmt.executeQuery();
    // auf die erste Zeile springen
    if (rs.next()) {
        int count = rs.getInt(1);
         // true zurückgeben, wenn mindestens ein Datensatz existiert
        return count > 0;   
    }
     // falls kein Ergebnis : kein name vorhanden
    return false;
}

// Erzeugt einen eindeutigen Eventnamen auf Basis von event.getName()
    private String createUniqueEventName(Event event) throws SQLException {
        String base = event.getName();   
        String name = base;
        int i = 1;
        while (existsEventName(name)) {
            name = base + "-" + i;
            i++;
        }
        return name;
    }

// Wandelt eine Datenbankzeile (ResultSet) in ein Event-Objekt um
private Event resultToEvent(ResultSet rs) throws SQLException {
    int id = rs.getInt("id");
    String title = rs.getString("event_title");
    String location = rs.getString("location");
    Calendar date = toCalendar(rs.getDate("event_date"));

    // Dieser Konstruktor berechnet automatisch eventName = location + Jahr
    return new Event(id, title, location, date);
}


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
        
        List<Event> res = new ArrayList<Event>();
        try{
            String sql ="Select * From event Order By event_date";
             PreparedStatement stmt = db.createPreparedStatement(sql);
            ResultSet rs = stmt.executeQuery();

            while(rs.next()){
                Event event = resultToEvent(rs);
                res.add(event);
            }
        } catch (SQLException e){


        }
         return res;
    }

    /**
     * Liefert ein Event anhand seiner Id zurueck
     *
     * @param id Id des Events
     * @return Datensatz des Events
     */
    public Event findById(int id) {
        
        try {
            String sql = "SELECT * FROM event WHERE id = ?";
            PreparedStatement stmt = db.createPreparedStatement(sql);
            stmt.setInt(1, id);

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return resultToEvent(rs);
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Aktualisiert die Daten eines Events
     *
     *
     * @param event Event das gespeichert werden soll
     */
    public void save(Event event) {
        
        try {
        
        String sql = "UPDATE event SET id = ?, event_title = ?, location = ?, event_date = ?, event_name = ? "
                   + "WHERE id = ?";

        PreparedStatement stmt = db.createPreparedStatement(sql);

        
        stmt.setInt(1, event.getEventId());                                  
        stmt.setString(2, event.getEventTitle());                            
        stmt.setString(3, event.getLocation());                             
        stmt.setDate(4, new java.sql.Date(event.getEventDate().getTime().getTime()));         
        stmt.setString(5, event.getName());                                
        stmt.setInt(6, event.getEventId());                                 

        stmt.executeUpdate();
        stmt.close();
       // db.commit();
    } catch (SQLException e) 
    {
        throw new RuntimeException();
    }
}
    

    /**
     * Fuegt eine neues Event in die Datenbank ein
     *
     *
     * @param event
     */
    public void insert(Event event) {
    try {
        // eindeutigen Namen erzeugen
        String event_name = createUniqueEventName(event);

        String sql = "INSERT INTO event (id, event_title, event_name, location, event_date) "
                   + "VALUES (?, ?, ?, ?, ?)";
        PreparedStatement stmt = db.createPreparedStatement(sql);

        stmt.setInt(1, event.getEventId());                          
        stmt.setString(2, event.getEventTitle());                    
        stmt.setString(3, event_name);                               
        stmt.setString(4, event.getLocation());                     
        stmt.setDate(5, new java.sql.Date(event.getEventDate().getTime().getTime()));
        stmt.executeUpdate();
        stmt.close();
       //db.commit();
    } catch (SQLException e) {
        throw new RuntimeException(e);
    }
}


    /**
     * Loescht ein Event aus der Datenbank
     *
     * @param event
     */
    public void delete(Event event) {
        
        try {
            String sql = "DELETE FROM event WHERE id = ?";
            PreparedStatement stmt = db.createPreparedStatement(sql);
            stmt.setInt(1, event.getEventId());
            stmt.executeUpdate();
           // db.commit();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }



    /**
     * Wird beim schliessen der Anwendungaufgerufen
     */
    public void shutdown() {
        
        try {
            db.closeConnection();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }



}