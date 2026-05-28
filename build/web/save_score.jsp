<%@ page language="java" contentType="application/json; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String username = (String) session.getAttribute("username");
    String type = request.getParameter("type");
    String scoreStr = request.getParameter("score");

    if(username != null && type != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/elite_quiz", "root", "root");
            String sql = "INSERT INTO quiz_results (username, quiz_type, score) VALUES (?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, type);
            pstmt.setInt(3, Integer.parseInt(scoreStr));
            pstmt.executeUpdate();
            conn.close();
        } catch(Exception e) { e.printStackTrace(); }
    }
%>