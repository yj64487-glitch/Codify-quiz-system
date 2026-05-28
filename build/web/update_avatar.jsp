<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    /* ================== 1. SECURITY CHECK ================== */
    Integer userId = (Integer) session.getAttribute("user_id");
    
    // Jar user login nasel tar login page var pathva
    if(userId == null){
        response.sendRedirect("login.jsp");
        return;
    }

    /* ================== 2. GET IMAGE PARAMETER ================== */
    String newAvatar = request.getParameter("img");

    /* ================== 3. UPDATE DATABASE ================== */
    if(newAvatar != null && !newAvatar.trim().isEmpty()) {

        String dbUrl = "jdbc:mysql://localhost:3306/codify_db";
        String dbUser = "root";
        String dbPass = "root";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // DB query to update avatar path
            String sql = "UPDATE users SET current_avatar = ? WHERE id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newAvatar);
            pstmt.setInt(2, userId);
            
            pstmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if(pstmt != null) pstmt.close();
            if(conn != null) conn.close();
        }
    }

    /* ================== 4. REDIRECT BACK ================== */
    // Database update zalyavar parat profile.jsp var pathva
    response.sendRedirect("profile.jsp"); 
%>