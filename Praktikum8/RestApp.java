package dbs2;


import io.javalin.Javalin;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class RestApp {

    private static String host = "195.37.239.139"; 
    private static String port = "1521";
    private static String sid = "poradb";
    private static String user = "user058";
    private static String password = "jvhgjcdz";
    private static String connectorString = "jdbc:oracle:thin:@" + host + ":" + port + "/" + sid;


    public static void main(String[] args) {

        var app = Javalin.create(config -> {
            config.plugins.enableCors(cors -> { // Damit die API per Browser von https://dbs.hosting.medien.hs-duesseldorf.de/folien/rest-api/index.html aufgerufen werden darf.
                cors.add(it -> {
                    it.anyHost();
                });
            });
        })
                .get("/", ctx -> ctx.result("Hello World"))
                .get("/events", ctx -> {
                    Connection con = openConnection();
                    Statement st = con.createStatement();
                    ResultSet rs = st.executeQuery("SELECT * FROM EVENT");

                    // JSON-Array bauen
                    StringBuilder json = new StringBuilder();
                    json.append("[");

                    boolean first = true;
                    while (rs.next()) {
                        if (!first) json.append(",");
                        json.append("{")
                                        .append("\"EVENTID\":").append(rs.getInt("EVENTID")).append(",")
                                        .append("\"EVENTDATE\":\"").append(rs.getDate("EVENTDATE")).append("\",")
                                        .append("\"EVENTTITLE\":\"").append(rs.getString("EVENTTITLE")).append("\",")
                                        .append("\"LOCATION\":\"").append(rs.getString("LOCATION")).append("\",")
                                        .append("\"NAME\":\"").append(rs.getString("NAME")).append("\"").append(",")
                                        .append("\"PROMOTER_ID\":").append(rs.getInt("PROMOTER_ID"))
                            .append("}");
                        first = false;
                    }
                    json.append("]");

                    rs.close();
                    st.close();
                    con.close();

                    ctx.contentType("application/json");
                    ctx.result(json.toString());

                })
                .post("/event", ctx -> {
                    Connection con = openConnection();
                    Statement statement = con.createStatement();
                    statement.executeQuery("INSERT INTO EVENT (EVENTID, EVENTDATE, EVENTTITLE, LOCATION, NAME, PROMOTER_ID) " +
                 "VALUES (1, TO_DATE('2025-12-08', 'YYYY-MM-DD'), " +
                 "'c6ColumbinaPARTY', 'TOKYO', 'Planarcadia', 1)");
                    con.close();
                    ctx.status(201);
                })
                .get("/event/{id}", ctx -> {
                    Connection con = openConnection();
                    Statement statement = con.createStatement();
                    ResultSet rs = statement.executeQuery("SELECT * FROM EVENT WHERE EVENTID = " + ctx.pathParam("id"));
                    if (rs.next()) {
                        // Beispiel für JSON-Ausgabe
                        String json = "{"
                                + "\"EVENTID\": " + rs.getInt("EVENTID") + ","
                                + "\"EVENTDATE\": \"" + rs.getDate("EVENTDATE") + "\","
                                + "\"EVENTTITLE\": \"" + rs.getString("EVENTTITLE") + "\","
                                + "\"LOCATION\": \"" + rs.getString("LOCATION") + "\","
                                + "\"NAME\": \"" + rs.getString("NAME") + "\"" + "\","
                                + "\"PROMOTER_ID\": \"" + rs.getString("PROMOTER_ID") + "\","
                                + "}";

                        ctx.contentType("application/json");
                        ctx.result(json);
                        ctx.status(200);
                    } else {
                        ctx.status(404).result("Event not found");
                    }
                    con.close();
                })
                .put("/event/{id}", ctx -> {
                    Connection con = openConnection();
                    Statement statement = con.createStatement();
                    statement.executeUpdate("UPDATE EVENT SET NAME = 'Sandrone' WHERE EVENTID = " +  ctx.pathParam("id"));
                    con.close();
                    ctx.status(201);
                    ctx.result("UPDATE Erfolgreich! PARTY YAY");
                })
                .delete("/event/{id}", ctx -> {
                    Connection con = openConnection();
                    Statement statement = con.createStatement();
                    statement.executeUpdate("DELETE FROM EVENT WHERE EVENTID = " + ctx.pathParam("id"));
                    con.close();
                    ctx.status(201);
                    ctx.result("geLÖSCHT! Verstanden?");
                })
                .start(8080);


    }

    /**
     * Prozedur openConnection öffnet eine neue Instanz des JDBC-Treibers und
     * stellt Verbindung zur Datenbank her
     *
     * @throws SQLException
     */
    public static Connection openConnection() throws SQLException {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        Connection con = DriverManager.getConnection(connectorString, user, password);
        return con;
    }

}
