<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // 1. Session Check (Login नसले तर बाहेर फेका)
    Integer userId = (Integer) session.getAttribute("user_id");
    if(userId == null){
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Form मधून आलेला डेटा घेणे
    String fname   = request.getParameter("fname");
    String lname   = request.getParameter("lname");
    String college = request.getParameter("college");
    String avatar  = request.getParameter("avatar_path");

    // नाव जोडणे (First Name + Last Name) -> Full Name
    String fullName = "";
    if(fname != null) fullName += fname;
    if(lname != null) fullName += " " + lname;
    fullName = fullName.trim(); // एक्स्ट्रा स्पेस काढण्यासाठी

    // 3. Database Connection & Update
    Connection con = null;
    PreparedStatement ps = null;

    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify_db","root","root");

        // Query: फक्त तेच अपडेट करा जे फॉर्म मधून आले आहे
        String sql = "UPDATE users SET full_name=?, college=?, current_avatar=? WHERE id=?";
        ps = con.prepareStatement(sql);
        
        ps.setString(1, fullName);
        ps.setString(2, college);
        ps.setString(3, avatar);
        ps.setInt(4, userId);

        int rows = ps.executeUpdate();
        
        if(rows > 0){
            // 4. Update झाल्यावर Session मध्ये पण नाव अपडेट करा (Optional पण चांगले आहे)
            session.setAttribute("user_name", fullName); // किंवा "full_name" जे तुम्ही वापरत असाल

            // 5. SUCCESS: Profile Page वर परत पाठवा
            response.sendRedirect("profile.jsp");
        } else {
            // Update नाही झाले तर Error दाखवा
            out.println("<h3>Update Failed. Please try again.</h3>");
        }

    } catch(Exception e){
        e.printStackTrace();
        out.println("Error: " + e.getMessage());
    } finally {
        if(ps!=null) ps.close();
        if(con!=null) con.close();
    }
%>