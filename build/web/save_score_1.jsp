<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
Connection con = null;
PreparedStatement ps = null;

try {
    // ===============================
    // 1. REQUEST DATA
    // ===============================
    int score = Integer.parseInt(request.getParameter("score"));
    int total = Integer.parseInt(request.getParameter("total"));

    // 👉 session मधून user_id घ्यायचा (login system असल्यास)
    // Integer userId = (Integer) session.getAttribute("user_id");

    // 🔹 testing साठी hardcode
    int userId = 1;
    int quizId = 1;

    // ===============================
    // 2. DB CONNECTION
    // ===============================
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/codify_db",
        "root",
        "root"
    );

    // ===============================
    // 3. INSERT OR UPDATE (UPSERT)
    // ===============================
    String sql =
        "INSERT INTO results (user_id, quiz_id, score, total_questions, attempted_at) " +
        "VALUES (?, ?, ?, ?, NOW()) " +
        "ON DUPLICATE KEY UPDATE " +
        "score = VALUES(score), " +
        "total_questions = VALUES(total_questions), " +
        "attempted_at = NOW()";

    ps = con.prepareStatement(sql);
    ps.setInt(1, userId);
    ps.setInt(2, quizId);
    ps.setInt(3, score);
    ps.setInt(4, total);

    int x = ps.executeUpdate();

    if (x > 0) {
        out.print("Success");
    } else {
        out.print("Failed");
    }

} catch (Exception e) {
    out.print("ERROR: " + e.getMessage());
} finally {
    try { if (ps != null) ps.close(); } catch(Exception e){}
    try { if (con != null) con.close(); } catch(Exception e){}
}
%>
