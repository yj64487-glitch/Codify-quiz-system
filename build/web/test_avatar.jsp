<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>DB Debugger</title>
    <style>body{background:#000; color:#0f0; font-family:monospace; padding:20px; font-size:16px;}</style>
</head>
<body>
    <h2>🛠️ Database Connection & Avatar Tester</h2>
    <hr>

<%
    // 1. Session Check
    Integer userId = (Integer) session.getAttribute("user_id");
    if(userId == null){
        out.println("<h3 style='color:red'>ERROR: User not logged in. Please Login first.</h3>");
        return;
    }
    out.println("User ID: " + userId + "<br>");

    String dbUrl = "jdbc:mysql://localhost:3306/codify_db";
    String dbUser = "root";
    String dbPass = "root";
    
    Connection conn = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        out.println("✅ Database Connected Successfully.<br>");

        // --- BUTTON CLICK CHECK ---
        String action = request.getParameter("action");
        
        if("force_update".equals(action)){
            // Ha online image path ahe (jo 100% dislach pahije)
            String testImage = "https://api.dicebear.com/7.x/avataaars/svg?seed=Felix";
            
            String updateSql = "UPDATE users SET current_avatar = ? WHERE id = ?";
            PreparedStatement upStmt = conn.prepareStatement(updateSql);
            upStmt.setString(1, testImage);
            upStmt.setInt(2, userId);
            
            int rows = upStmt.executeUpdate();
            if(rows > 0){
                out.println("<h3 style='color:yellow'>✅ UPDATE SUCCESS! Avatar changed to Online Image.</h3>");
            } else {
                out.println("<h3 style='color:red'>❌ UPDATE FAILED! No rows affected. Check User ID.</h3>");
            }
        }

        // --- FETCH CURRENT DATA ---
        String sql = "SELECT full_name, current_avatar FROM users WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        ResultSet rs = pstmt.executeQuery();

        if(rs.next()){
            String currentAvatar = rs.getString("current_avatar");
            String name = rs.getString("full_name");
            
            out.println("<hr>");
            out.println("<b>Name in DB:</b> " + name + "<br>");
            out.println("<b>Avatar Path in DB:</b> " + currentAvatar + "<br>");
            out.println("<br><b>Preview:</b><br>");
            out.println("<img src='" + currentAvatar + "' width='100' height='100' style='border:2px solid white'><br>");
        } else {
            out.println("<h3 style='color:red'>❌ User ID not found in Database!</h3>");
        }

    } catch(Exception e) {
        out.println("<h3 style='color:red'>❌ EXCEPTION ERROR:</h3>");
        e.printStackTrace(new java.io.PrintWriter(out)); // Screen var error print karel
    } finally {
        if(conn != null) conn.close();
    }
%>

    <hr>
    <h3>👇 Click this button to FORCE Update Avatar</h3>
    <form method="post">
        <input type="hidden" name="action" value="force_update">
        <button type="submit" style="padding:10px 20px; font-weight:bold; cursor:pointer;">FORCE UPDATE TO CARTOON</button>
    </form>
    
    <br><br>
    <a href="profile.jsp" style="color:white">Go to Profile Page</a>

</body>
</html>