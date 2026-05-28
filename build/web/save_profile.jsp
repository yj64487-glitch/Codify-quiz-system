<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // 1. Login Check
    Integer userId = (Integer) session.getAttribute("user_id");
    if(userId == null){ 
        response.sendRedirect("login.jsp"); 
        return; 
    }

    // 2. Form Data
    String fname   = request.getParameter("fname");
    String lname   = request.getParameter("lname");
    String college = request.getParameter("college");
    String avatar  = request.getParameter("avatar_path");

    // Full Name तयार करणे
    String fullName = "";
    if(fname != null) fullName += fname;
    if(lname != null) fullName += " " + lname;
    fullName = fullName.trim();

    // 3. Database Update (बॅकग्राउंडमध्ये)
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify_db","root","root");

        String sql = "UPDATE users SET full_name=?, college=?, current_avatar=? WHERE id=?";
        PreparedStatement ps = con.prepareStatement(sql);
        
        ps.setString(1, fullName);
        ps.setString(2, college);
        ps.setString(3, avatar);
        ps.setInt(4, userId);

        ps.executeUpdate(); // Update झाले
        
        con.close();

    } catch(Exception e) {
        e.printStackTrace(); // एरर आल्यास सर्व्हर लॉगमध्ये दिसेल, युजरला नाही
    }

    // 4. INSTANT REDIRECT (User ला कळणार पण नाही की प्रोसेसिंग झाली)
    response.sendRedirect("profile.jsp");
%>