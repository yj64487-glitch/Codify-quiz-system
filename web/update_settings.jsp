<%@ page language="java" contentType="text/plain; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    Integer userId = (Integer) session.getAttribute("user_id");
    if(userId == null) return; // Stop if not logged in

    String type = request.getParameter("type"); // 'theme' or 'notif'
    String val = request.getParameter("val");

    if(type != null && val != null) {
        String dbUrl = "jdbc:mysql://localhost:3306/codify_db";
        String dbUser = "root";
        String dbPass = "root";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            
            String sql = "";
            PreparedStatement pstmt = null;

            if(type.equals("theme")) {
                sql = "UPDATE users SET theme = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, val); // 'dark' or 'light'
                pstmt.setInt(2, userId);
            } 
            else if(type.equals("notif")) {
                sql = "UPDATE users SET notifications = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(val)); // 1 or 0
                pstmt.setInt(2, userId);
            }

            if(pstmt != null) {
                pstmt.executeUpdate();
                pstmt.close();
            }
            conn.close();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
%>
Success