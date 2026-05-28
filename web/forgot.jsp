<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.UUID" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Forgot Password | QUIZORA</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
:root{ --bg:#0b0e14; --card:#0f172a; --blue:#2563eb; --green:#22c55e; --cyan:#22d3ee; --text:#e5e7eb; --muted:#94a3b8; --error:#f87171; --success:#4ade80; --border:rgba(255,255,255,.14); }
*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter, system-ui, sans-serif; }
body{ height:100vh; display:flex; justify-content:center; align-items:center; background:radial-gradient(circle at top,#111827,var(--bg)); color:var(--text); }
.card{ width:420px; background:var(--card); padding:48px; border-radius:22px; box-shadow:0 30px 80px rgba(0,0,0,.6); }
h2{ font-size:28px; margin-bottom:8px; }
p{ font-size:14px; color:var(--muted); margin-bottom:26px; }
.field{ margin-bottom:20px; }
.field input{ width:100%; padding:16px 14px; border-radius:14px; border:1px solid var(--border); background:#020617; color:var(--text); outline:none; }
.msg{ font-size:13px; margin-bottom:14px; text-align:center; }
.msg.error{ color:var(--error); }
.msg.success{ color:var(--success); }
button{ width:100%; padding:15px; border:none; border-radius:999px; background:linear-gradient(135deg,var(--blue),var(--green)); color:#020617; font-weight:700; cursor:pointer; }
.links{ margin-top:22px; text-align:center; font-size:14px; }
.links a{ color:var(--cyan); text-decoration:none; }
.reset-link{ word-break:break-all; font-size:13px; margin-top:12px; }
</style>
</head>

<body>

<%
String msg="", msgType="", resetLink="";

if("POST".equalsIgnoreCase(request.getMethod())){

    String email = request.getParameter("email");

    String url="jdbc:mysql://localhost:3306/codify_db";
    String user="root";
    String pass="root";

    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(url,user,pass);

        PreparedStatement check = con.prepareStatement(
            "SELECT id FROM users WHERE email=?"
        );
        check.setString(1,email);
        ResultSet rs = check.executeQuery();

        if(rs.next()){
            String token = UUID.randomUUID().toString();

            PreparedStatement upd = con.prepareStatement(
                "UPDATE users SET reset_token=?, token_expiry=DATE_ADD(NOW(), INTERVAL 15 MINUTE) WHERE email=?"
            );
            upd.setString(1,token);
            upd.setString(2,email);
            upd.executeUpdate();

            resetLink = "http://localhost:8080/codify/reset_password.jsp?token="+token;
            msg="Reset link generated successfully!";
            msgType="success";
        }else{
            msg="Email not registered.";
            msgType="error";
        }
        con.close();
    }catch(Exception e){
        msg="Error: "+e.getMessage();
        msgType="error";
    }
}
%>

<div class="card">
<h2>Forgot Password</h2>
<p>Enter your registered email address.</p>

<% if(!msg.isEmpty()){ %>
<div class="msg <%=msgType%>"><%=msg%></div>
<% } %>

<% if(!resetLink.isEmpty()){ %>
<div class="reset-link">
<b>TEST LINK:</b><br>
<a href="<%=resetLink%>" style="color:#4ade80"><%=resetLink%></a>
</div>
<% } %>

<form method="post">
  <div class="field">
    <input type="email" name="email" placeholder="Enter email" required>
  </div>
  <button>Send Reset Link</button>
</form>

<div class="links">
  <a href="login.jsp">Back to Login</a>
</div>
</div>

</body>
</html>
