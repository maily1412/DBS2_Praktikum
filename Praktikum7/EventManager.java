package org.dbprakt.hibernate.annotations;

import java.util.*;

import javax.persistence.Query;

import org.hibernate.Session;

/**
 * EventManager
 */
public class EventManager {
    // In ihr befindet sich ein Attribut session, das später die Hibernate-Datenbankverbindung hält
    Session session;
	
    /**
     * main
     * @param args 
     */
    public static void main(String[] args) {
        // neues EventManager-Objekt erzeugt
    	EventManager mgr = new EventManager();
    	
        // neues Promoter-Objekt wird erzeugt
    	Promoter promoter = new Promoter();
    	promoter.setAge(26);
    	promoter.setName("Promoter 1");
    	promoter.setSkills("Moderieren");
        // Die Eigenschaften des Promoters werden gesetzt
        // Dieses Objekt wird später dem Event zugeordnet
    	
    	ArrayList<Person> attendees = new ArrayList<Person>();
    	attendees.add(new Person("Person 1", 19));
    	attendees.add(new Person("Person 2", 20));
        // Eine Liste von Personen (Teilnehmern) wird erstellt
        // Zwei Personen werden hinzugefügt
    	
    	mgr.session=HibernateUtil.getSessionFactory().openSession();
        // Es wird eine SessionFactory verwendet, um eine Session zu öffnen
        // Diese Session ist die Verbindung zur Datenbank für die folgenden Operationen

    	Calendar calendar = new GregorianCalendar();
        // Ein Datum für das Event wird erstellt: 1. Dezember 2022, 9:00 Uhr
    	calendar.set(2022, 12, 1, 9, 0);
        // Es wird ein Event mit Titel „Test“ in die DB geschrieben
        // Teilnehmer und Promoter werden mitgespeichert
        mgr.createAndStoreEvent("Test", calendar, attendees, promoter);
        // Das Event mit ID = 1 erhält einen neuen Namen: „Columbina“
    	mgr.changeEventName(1,"Columbina");
        // Alle gespeicherten Events werden abgefragt
        // Jedes Event wird ausgegeben
    	List<Event> events = mgr.listEvents();
        events.forEach(e->{
            System.out.println("Ausgabe:");
            System.out.println(e);
        });
        // Der Eventname von ID 1 wird erneut geändert
    	mgr.changeEventName(1,"Damselette");
        // Session schließen und Programm beenden
        mgr.session.close();
    	
    	System.exit( 0 );
    }

    /**
     * Aufgabe 2)
     * Erstellt einen neuen Event und speichert diesen in der Datenbank.
     * 
     * @param title Der Name des Events
     * @param date Der Zeitpunkt des Events
     * @param attendees
     */
    private void createAndStoreEvent(String title, Calendar date, List<Person> attendees, Promoter promoter) {
        // neues Event-Objekt wird erzeugt
        Event e = new Event();
        // Titel und Datum werden gesetzt
        e.setEventTitle(title);
        e.setEventDate(date);
        // Die Teilnehmerliste (List) wird in ein Set umgewandelt
        // Sets werden häufig verwendet, um Duplikate zu vermeiden / speichert Liste von Personen ab
        Set<Person> s = new HashSet<>();
        s.addAll(attendees);
        e.setAttendees(s);
        // Der Promoter wird zugeordnet
        e.setPromoter(promoter);
        
        // DB-Transaktion wird gestartet
        this.session.beginTransaction();
        // Hibernate speichert das Objekt oder aktualisiert es, wenn es bereits existiert
        this.session.saveOrUpdate(e);
        // Transaktion wird abgeschlossen (Änderungen werden dauerhaft in DB geschrieben)
        this.session.getTransaction().commit();
    }
     
    /**
     * Aufgabe 3) Gibt eine Liste aller in der Datenbank gespeicherten Events zur�ck.
     * 
     * @return {@Code List<Events>} Eine Liste aller gespeicherten Events
     */
    private List<Event> listEvents() {
        // HQL-Abfrage: „Hole alle Objekte vom Typ Event“
        String hql = "FROM Event";
        // HQL wird ausgeführt
        // Ergebnisliste wird zurückgegeben
        Query q = this.session.createQuery(hql);
        List res = q.getResultList();
        return res;
    }
    
    /**
     * Aufgabe 4) Aendert den Namen eines Events.
     * 
     * @param eventId Die id des zu aendernden Events
     * @param name Der neue Name des zu aendernden Events
     */
    private void changeEventName (Integer eventId, String name) {
        // Beginn der Transaktion
        this.session.beginTransaction();
        // unterdrückt Warnungen falls Methode veraltet ist
        @SuppressWarnings("deprecation")
        // HQL-Abfrage, um das Event mit bestimmter ID zu suchen
        // :eventId ist ein Platzhalter, der gebunden wird
        Query query = session.createQuery("FROM Event WHERE eventId = :eventId");
        query.setParameter("eventId", eventId);
        
        // Ein einzelnes Ergebnis holen
        Event e = (Event) query.getSingleResult();
        // Name des Events wird geändert
        e.setEventName(name);
        // Objekt wird gespeichert
        // Transaktion wird abgeschlossen
        this.session.update(e);
        this.session.getTransaction().commit();
    }
    
}