package db;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static Connection con;

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/codify?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
                "root",
                "root"
            );

        } catch (Exception e) {
            e.printStackTrace();
        }
        return con;
    }
}
