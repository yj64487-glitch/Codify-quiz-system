<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    String errorMsg = "";
    
    // Check if form is submitted
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String u = request.getParameter("username");
        String p = request.getParameter("password");

        if (u != null && p != null) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                // 1. Load Driver
                Class.forName("com.mysql.cj.jdbc.Driver");

                // 2. Connect to Database (FIXED: codify_db)
                // तुमची जुनी चूक: elite_quiz | बरोबर नाव: codify_db
                String url = "jdbc:mysql://localhost:3306/codify_db"; 
                String dbUser = "root";
                String dbPass = "root"; 
                
                conn = DriverManager.getConnection(url, dbUser, dbPass);

                // 3. Check Credentials
                String sql = "SELECT * FROM admins WHERE username = ? AND password = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, u);
                pstmt.setString(2, p);
                
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    // --- SUCCESS ---
                    session.setAttribute("adminUser", u);
                    // Redirect to dashboard (Check exact file name)
                    response.sendRedirect("admin_dashboard.jsp"); 
                    return;
                } else {
                    errorMsg = "Invalid Admin Credentials!";
                }

            } catch (Exception e) {
                errorMsg = "Database Error: " + e.getMessage();
                e.printStackTrace();
            } finally {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>CODIFY | Admin Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* CSS STYLES */
:root{ --bg:#020617; --glass:rgba(255,255,255,.06); --border:rgba(255,255,255,.12); --blue:#2563eb; --cyan:#22d3ee; --green:#22c55e; --danger:#f87171; --text:#e5e7eb; --muted:#94a3b8; }
*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter,system-ui,sans-serif; }
body{ min-height:100vh; background: radial-gradient(circle at top, rgba(37,99,235,.25), transparent 45%), radial-gradient(circle at bottom right, rgba(34,197,94,.15), transparent 45%), var(--bg); display:flex; align-items:center; justify-content:center; color:var(--text); }
.card{ width:420px; background:linear-gradient(180deg,rgba(255,255,255,.08),rgba(255,255,255,.02)); backdrop-filter:blur(18px); border:1px solid var(--border); border-radius:26px; padding:46px; box-shadow:0 40px 120px rgba(0,0,0,.7); animation:fadeUp .8s cubic-bezier(.22,.61,.36,1); }
@keyframes fadeUp{ from{opacity:0; transform:translateY(40px) scale(.96)} to{opacity:1; transform:none} }
@keyframes shake{ 0%,100%{transform:translateX(0)} 20%{transform:translateX(-6px)} 40%{transform:translateX(6px)} 60%{transform:translateX(-4px)} 80%{transform:translateX(4px)} }
.shake{ animation:shake .4s; }
.brand{ display:flex; align-items:center; justify-content:center; gap:14px; margin-bottom:16px; }
.logo{ width:56px; height:56px; border-radius:50%; background:linear-gradient(135deg,var(--blue),var(--cyan)); display:grid; place-items:center; font-weight:900; font-size:22px; color:#020617; box-shadow:0 0 22px rgba(34,211,238,.6); }
.title{ font-size:28px; font-weight:900; letter-spacing:3px; }
.title span{ background:linear-gradient(135deg,var(--blue),var(--green)); background-clip:text; -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
.sub{ text-align:center; font-size:13px; color:var(--muted); margin-bottom:34px; }
.field{ margin-bottom:22px; }
.field label{ font-size:12px; color:var(--muted); }
.field input{ width:100%; margin-top:8px; padding:15px 18px; background:#020617; border:1px solid var(--border); border-radius:14px; color:var(--text); outline:none; transition:.25s ease; }
.field input:focus{ border-color:var(--cyan); box-shadow:0 0 0 3px rgba(34,211,238,.2); }
.error-msg{ color: var(--danger); font-size: 13px; text-align: center; margin-bottom: 15px; font-weight: bold; display: <%= errorMsg.isEmpty() ? "none" : "block" %>; }
.btn{ width:100%; padding:16px; border:none; border-radius:999px; background:linear-gradient(135deg,var(--blue),var(--green)); color:#020617; font-weight:900; letter-spacing:1px; cursor:pointer; margin-top:10px; transition:.25s ease; box-shadow:0 12px 35px rgba(34,211,238,.45); }
.btn:hover{ transform:translateY(-2px); box-shadow:0 0 35px rgba(34,211,238,.7); }
.footer{ text-align:center; margin-top:26px; font-size:12px; color:var(--muted); }
</style>
</head>

<body>

<div class="card <%= !errorMsg.isEmpty() ? "shake" : "" %>">

  <a href="index.jsp" style="text-decoration: none; color: inherit;">
    <div class="brand">
        <div class="logo">
            <img src="images/quiz/codify.png" alt="Logo" style="width: 100%; height: 100%; object-fit: cover;">
        </div>
        <div class="title">COD<span>IFY</span></div>
    </div>
</a>

  <div class="sub">Secure Admin Authentication</div>

  <div class="error-msg"><%= errorMsg %></div>

  <form method="post" action="admin-login.jsp">
      <div class="field">
        <label>Admin Username</label>
        <input type="text" name="username" required autocomplete="off">
      </div>

      <div class="field">
        <label>Password</label>
        <input type="password" name="password" required>
      </div>

      <button type="submit" class="btn">Authorize Access</button>
  </form>

  <div class="footer">© 2026 CODIFY • Admin Panel</div>
</div>

</body>
</html>