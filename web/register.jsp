<%@ page import="java.sql.*" %>
<%@ page import="java.util.Random" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String message = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fullname = request.getParameter("fullname");
        String mobile = request.getParameter("mobile");
        String age = request.getParameter("age");
        String dob = request.getParameter("dob");
        String pass = request.getParameter("pass");
        String confirmPass = request.getParameter("confirmPass");

        if (pass != null && pass.equals(confirmPass)) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify_db", "root", "root");
                
                // 1. Check if Mobile Already Exists
                PreparedStatement checkStmt = con.prepareStatement("SELECT * FROM users WHERE mobile = ?");
                checkStmt.setString(1, mobile);
                ResultSet rs = checkStmt.executeQuery();

                if (rs.next()) {
                    message = "Mobile number already registered!";
                } else {
                    // 2. Generate Auto Username (@Name + RandomNumber)
                    String firstName = (fullname != null) ? fullname.split(" ")[0] : "User";
                    int randomNum = new Random().nextInt(9000) + 1000;
                    String genUsername = "@" + firstName + randomNum;

                    // 3. Insert into Database
                    PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO users (full_name, username, mobile, age, dob, password) VALUES (?, ?, ?, ?, ?, ?)"
                    );

                    ps.setString(1, fullname);
                    ps.setString(2, genUsername);
                    ps.setString(3, mobile);
                    ps.setInt(4, Integer.parseInt(age));
                    ps.setString(5, dob);
                    ps.setString(6, pass);

                    ps.executeUpdate();
                    con.close();

                    // 4. Success - Redirect to Login
                    session.setAttribute("tempMsg", "Registration Successful! Your Username is: " + genUsername);
                    response.sendRedirect("login.jsp");
                    return;
                }
                con.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                e.printStackTrace();
            }
        } else {
            message = "Passwords do not match!";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Register | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
/* CSS Styles */
:root{ --bg:#0b0e14; --card:#0f172a; --blue:#2563eb; --green:#22c55e; --cyan:#22d3ee; --text:#e5e7eb; --muted:#94a3b8; --error:#f87171; --border:rgba(255,255,255,.14); }
*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter,system-ui,sans-serif; }
body{ min-height:100vh; display:flex; justify-content:center; align-items:center; background:radial-gradient(circle at top,#111827,var(--bg)); color:var(--text); }
.card{ width:460px; background:var(--card); padding:44px; border-radius:22px; box-shadow:0 30px 80px rgba(0,0,0,.65); animation:fadeUp .7s ease forwards; }
@keyframes fadeUp{ from{opacity:0;transform:translateY(40px);} to{opacity:1;transform:translateY(0);} }
.brand{text-align:center;margin-bottom:26px}
.brand h1{ font-size:32px; font-weight:900; letter-spacing:6px; background:linear-gradient(135deg,var(--blue),var(--green)); background-clip:text; -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
.brand p{ font-size:12px; letter-spacing:3px; color:var(--muted); margin-top:8px; }
h2{text-align:center;margin-bottom:6px}
.desc{text-align:center;color:var(--muted);margin-bottom:22px}
.server-msg { text-align: center; margin-bottom: 15px; font-size: 14px; color: var(--error); border: 1px solid rgba(248,113,113,0.2); padding: 10px; border-radius: 8px; background: rgba(248,113,113,0.1); }
.error{ color:var(--error); font-size:13px; margin-bottom:14px; display:none; text-align:center;}
.field{ margin-bottom:14px; position: relative; }
.field input{ width:100%; padding:14px 16px; padding-right: 45px; border-radius:14px; border:1px solid var(--border); background:#020617; color:var(--text); outline:none; transition: border-color 0.3s; }
.field input:focus{ border-color: var(--cyan); }
.eye-icon { position: absolute; right: 15px; top: 50%; transform: translateY(-50%); cursor: pointer; color: var(--muted); display: flex; align-items: center; }
.eye-icon:hover { color: var(--cyan); }
.eye-icon svg { width: 20px; height: 20px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
button{ width:100%; padding:15px; border:none; border-radius:999px; background:linear-gradient(135deg,var(--blue),var(--green)); font-weight:700; cursor:pointer; transition:transform .15s ease; color: #020617; font-size: 16px; margin-top: 10px; }
button:hover{ transform:translateY(-2px); box-shadow: 0 0 18px rgba(34,211,238,.45); }
.links{text-align:center;margin-top:22px}
.links a{color:var(--cyan);text-decoration:none}
</style>
</head>
<body>

<div class="card">
  <div class="brand">
    <h1>CODIFY</h1>
    <p>CODE YOUR FUTURE.</p>
  </div>

  <h2>Create Account</h2>
  <p class="desc">Username will be auto-generated</p>

  <% if(!message.isEmpty()) { %> 
      <div class="server-msg"><%= message %></div> 
  <% } %>

  <div class="error" id="err"></div>

  <form id="regForm" action="register.jsp" method="POST">
      <div class="field"><input type="text" class="input-nav" name="fullname" id="user" placeholder="Full Name"></div>
      <div class="field"><input type="number" class="input-nav" name="mobile" id="mobile" placeholder="Mobile Number"></div>
      <div class="field"><input type="number" class="input-nav" name="age" id="age" placeholder="Age"></div>
      <div class="field"><input type="date" class="input-nav" name="dob" id="dob"></div>
      
      <div class="field">
          <input type="password" class="input-nav" name="pass" id="pass" placeholder="Password">
          <span class="eye-icon" onclick="togglePass('pass', this)"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg></span>
      </div>
      
      <div class="field">
          <input type="password" class="input-nav" name="confirmPass" id="confirmPass" placeholder="Confirm Password">
          <span class="eye-icon" onclick="togglePass('confirmPass', this)"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg></span>
      </div>

      <button type="button" onclick="registerUser()">Register</button>
  </form>
  
  <div class="links">Already registered? <a href="login.jsp">Login</a></div>
</div>

<script>
// --- 1. ENTER KEY NAVIGATION ---
document.addEventListener("DOMContentLoaded", () => {
    const inputs = document.querySelectorAll(".input-nav");
    inputs.forEach((input, index) => {
        input.addEventListener("keydown", (e) => {
            if (e.key === "Enter") {
                e.preventDefault(); 
                const nextInput = inputs[index + 1];
                if (nextInput) nextInput.focus();
                else registerUser(); 
            }
        });
    });
});

// --- 2. PASSWORD TOGGLE ---
function togglePass(inputId, iconSpan) {
    const input = document.getElementById(inputId);
    const svg = iconSpan.querySelector('svg');
    if (input.type === "password") {
        input.type = "text";
        svg.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M1 1l22 22"></path><path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"></path>';
    } else {
        input.type = "password";
        svg.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle>';
    }
}

// --- 3. VALIDATION & SUBMIT ---
function registerUser(){
  const user = document.getElementById("user").value;
  const mobile = document.getElementById("mobile").value;
  const age = document.getElementById("age").value;
  const dob = document.getElementById("dob").value;
  const pass = document.getElementById("pass").value;
  const confirmPass = document.getElementById("confirmPass").value;
  const err = document.getElementById("err");
  const form = document.getElementById("regForm");

  err.style.display="none";

  if(!user || !mobile || !age || !dob || !pass || !confirmPass){
    err.style.display="block";
    err.innerText="Please fill all fields.";
    return;
  }
  if(pass !== confirmPass){
    err.style.display="block";
    err.innerText="Passwords do not match.";
    return;
  }
  form.submit();
}
</script>
</body>
</html>