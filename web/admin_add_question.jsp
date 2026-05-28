<%@ page import="java.sql.*" %>

<%
String question = request.getParameter("question");
String optA = request.getParameter("optA");
String optB = request.getParameter("optB");
String optC = request.getParameter("optC");
String optD = request.getParameter("optD");
String correct = request.getParameter("correct");

Connection conn = null;
PreparedStatement ps = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/codify_db",
        "root",
        "root"
    );

    String sql = "INSERT INTO questions(question, optA, optB, optC, optD, correct_answer) VALUES (?,?,?,?,?,?)";
    ps = conn.prepareStatement(sql);

    ps.setString(1, question);
    ps.setString(2, optA);
    ps.setString(3, optB);
    ps.setString(4, optC);
    ps.setString(5, optD);
    ps.setString(6, correct);

    int i = ps.executeUpdate();

    if(i > 0){
        out.println("? Question Added Successfully");
    } else {
        out.println("? Failed to Add Question");
    }

} catch(Exception e){
    out.println("Error: " + e.getMessage());
}
%>
