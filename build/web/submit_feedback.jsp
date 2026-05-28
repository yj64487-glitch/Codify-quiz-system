<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
   String url = "jdbc:mysql://localhost:3306/codify";
    String dbUser = "root";
    String dbPass = "root"; // <--- इथे तुझा पासवर्ड टाक

    String ratingStr = request.getParameter("rating");
    String message = request.getParameter("message");
    
    boolean isSuccess = false;
    String errorMsg = "";

    if(ratingStr != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            // ड्रायव्हर लोड करणे
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPass);

            String sql = "INSERT INTO feedback (rating, message) VALUES (?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(ratingStr));
            pstmt.setString(2, message);

            int rows = pstmt.executeUpdate();
            if(rows > 0) isSuccess = true;

        } catch (Exception e) {
            e.printStackTrace(); // हे कन्सोलमध्ये एरर दाखवेल
            errorMsg = e.getMessage();
        } finally {
            if(pstmt != null) pstmt.close();
            if(conn != null) conn.close();
        }
    }

    // JSON रिस्पॉन्स
    if(isSuccess) {
        out.print("{\"status\":\"success\"}");
    } else {
        out.print("{\"status\":\"error\", \"message\":\"" + errorMsg.replace("\"", "'") + "\"}");
    }
%>