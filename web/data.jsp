<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // 1. डेटाबेस सेटिंग्ज (Corrected Database Name: codify)
    String url = "jdbc:mysql://localhost:3306/codify"; 
    String dbUser = "root";
    String dbPass = "password"; // <--- इथे तुमचा पासवर्ड टाका

    // Mock User (सध्या 'You' म्हणून गृहीत धरले आहे)
    String currentUser = "You"; 

    String type = request.getParameter("type");
    if(type == null) type = "all";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    StringBuilder json = new StringBuilder("[");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        // 2. Query - टेबलचे नाव 'leaderboard' आहे का ते चेक करा
        String sql = "SELECT username, score FROM leaderboard ";
        
        if("weekly".equals(type)) {
            sql += "WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 WEEK) ";
        } else if("daily".equals(type)) {
            sql += "WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 DAY) ";
        }
        
        sql += "ORDER BY score DESC LIMIT 10";

        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        boolean first = true;
        while(rs.next()) {
            if(!first) json.append(",");
            first = false;

            String uName = rs.getString("username");
            int uScore = rs.getInt("score");
            boolean isYou = uName.equalsIgnoreCase(currentUser);

            json.append("{");
            json.append("\"user\":\"").append(uName).append("\",");
            json.append("\"score\":").append(uScore).append(",");
            json.append("\"isYou\":").append(isYou);
            json.append("}");
        }

    } catch(Exception e) {
        e.printStackTrace(); // Console मध्ये एरर दाखवेल
    } finally {
        if(rs != null) rs.close();
        if(pstmt != null) pstmt.close();
        if(conn != null) conn.close();
    }

    json.append("]");
    out.print(json.toString());
%>