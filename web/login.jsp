<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String error = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {

        // 1. Mobile Number ghene
        String mobile = request.getParameter("mobile");
        String pass   = request.getParameter("pass");

        try {
            // 2. Load Driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // 3. Connect to Database (DB Name: codify_db)
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/codify_db", "root", "root"
            );

            // 4. Query (MOBILE check karnyasathi)
            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM users WHERE mobile=? AND password=?"
            );
            
            ps.setString(1, mobile);
            ps.setString(2, pass);

            ResultSet rs = ps.executeQuery();
if (rs.next()) {

    int userId = rs.getInt("id");                 // ✅ id
    String fullName = rs.getString("full_name"); // ✅ DEFINE
    String username = rs.getString("username");  // ✅ DEFINE

    session.setAttribute("user_id", userId);
    session.setAttribute("full_name", fullName);
    session.setAttribute("username", username);
    session.setAttribute("userMobile", mobile); // optional

    response.sendRedirect("dashboard.jsp");
    return;
}

             else {
                error = "Invalid Mobile Number or Password";
            }

            con.close();

        } catch (Exception e) {
            error = "Database Error: " + e.getMessage();
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Login | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* CSS Styles (Dark Theme) */
:root{ --bg:#0b0e14; --card:#0f172a; --blue:#2563eb; --green:#22c55e; --cyan:#22d3ee; --text:#e5e7eb; --muted:#94a3b8; --error:#f87171; --border:rgba(255,255,255,.14); }
*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter,system-ui,sans-serif; }
body{ min-height:100vh; display:flex; justify-content:center; align-items:center; background:radial-gradient(circle at top,#111827,var(--bg)); color:var(--text); }
.card{ width:420px; background:var(--card); padding:44px; border-radius:22px; box-shadow:0 30px 80px rgba(0,0,0,.65); }
.brand{ text-align:center; margin-bottom:26px; }
.brand h1{ font-size:32px; font-weight:900; letter-spacing:6px; background:linear-gradient(135deg,var(--blue),var(--green)); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
.brand p{ font-size:12px; letter-spacing:3px; color:var(--muted); margin-top:8px; }
h2{ font-size:22px; text-align:center; margin-bottom: 6px;}
.desc{ font-size:14px; color:var(--muted); margin-bottom:24px; text-align:center; }
.server-error{ color:var(--error); font-size:14px; text-align:center; margin-bottom:15px; background: rgba(248,113,113,0.1); padding: 10px; border-radius: 8px; border: 1px solid rgba(248,113,113,0.2);}
.field{ margin-bottom:18px; position:relative; }
.field input{ width:100%; padding:15px 16px; padding-right:45px; border-radius:14px; border:1px solid var(--border); background:#020617; color:var(--text); outline:none; transition: border-color 0.3s;}
.field input:focus{ border-color: var(--cyan); }
button{ width:100%; padding:15px; border:none; border-radius:999px; background:linear-gradient(135deg,var(--blue),var(--green)); color:#020617; font-weight:700; cursor:pointer; font-size:16px; transition: transform 0.2s;}
button:hover{ transform: translateY(-2px); }
.links{ margin-top:22px; text-align:center; font-size:14px; }
.links a{ color:var(--cyan); text-decoration:none; }
</style>
</head>

<body>

<div class="card">

  <div class="brand">
    <h1>CODIFY</h1>
    <p>CODE YOUR FUTURE.</p>
  </div>

  <h2>Login to your account</h2>
  <p class="desc">Enter mobile number to continue</p>

  <% if(!error.isEmpty()) { %>
    <div class="server-error"><%= error %></div>
  <% } %>

  <form method="POST">

    <div class="field">
      <input type="number" name="mobile" placeholder="Mobile Number" required>
    </div>

    <div class="field">
      <input type="password" name="pass" placeholder="Password" required>
    </div>

    <button type="submit">Login</button>

  </form>

  <div class="links">
    <a href="forgot.jsp">Forgot password?</a><br><br>
    New user? <a href="register.jsp">Create account</a>
  </div>

</div>

</body>
</html>