<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
/* ================== SESSION CHECK ================== */
Integer userId = (Integer) session.getAttribute("user_id");
if(userId == null){
    response.sendRedirect("login.jsp");
    return;
}

/* ================== FETCH CURRENT SETTINGS ================== */
String dbUrl = "jdbc:mysql://localhost:3306/codify_db";
String dbUser = "root";
String dbPass = "root";

String currentTheme = "dark";
int notifStatus = 1; // 1 = On, 0 = Off

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
    
    String sql = "SELECT theme, notifications FROM users WHERE id = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, userId);
    rs = pstmt.executeQuery();

    if(rs.next()){
        String dbTheme = rs.getString("theme");
        if(dbTheme != null) currentTheme = dbTheme;
        notifStatus = rs.getInt("notifications");
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if(rs != null) rs.close();
    if(pstmt != null) pstmt.close();
    if(conn != null) conn.close();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Settings | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* ================= THEME VARIABLES ================= */
:root{ --bg:#01030f; --panel:#050a1f; --border:#121a33; --cyan:#22d3ee; --blue:#3b82f6; --red:#ef4444; --text:#e2e8f0; --muted:#7c8aa5; }
body.light{ --bg:#f8fafc; --panel:#ffffff; --border:#e2e8f0; --text:#020617; --muted:#475569; }
*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter,system-ui,sans-serif; }
body{ min-height:100vh; background: radial-gradient(1200px at 20% 10%, rgba(59,130,246,.12), transparent 40%), radial-gradient(1000px at 80% 80%, rgba(34,211,238,.12), transparent 45%), var(--bg); color:var(--text); transition:.4s ease; }
.container{ max-width:820px; margin:auto; padding:50px 24px; animation:fadeIn .7s ease; }
@keyframes fadeIn{ from{opacity:0; transform:translateY(16px)} to{opacity:1; transform:translateY(0)} }

/* HEADER */
.header{ display:flex; justify-content:space-between; align-items:center; margin-bottom:36px; }
.header h1{ font-size:40px; font-weight:900; }
.back{ padding:12px 30px; border-radius:999px; background:linear-gradient(135deg,var(--cyan),var(--blue)); color:#020617; text-decoration:none; font-weight:900; box-shadow:0 0 14px rgba(34,211,238,.35); }

/* ACCORDION */
.setting{ background:linear-gradient(180deg,rgba(255,255,255,.06),rgba(255,255,255,.01)); border:1px solid var(--border); border-radius:26px; margin-bottom:22px; overflow:hidden; }
.setting:hover{ box-shadow:0 0 22px rgba(34,211,238,.18); }
.setting-header{ padding:26px; cursor:pointer; display:flex; justify-content:space-between; align-items:center; }
.setting-header h2{ font-size:22px; }
.arrow{ font-size:22px; transition:.4s; }
.setting.open .arrow{ transform:rotate(180deg); }

/* CONTENT */
.setting-content{ max-height:0; overflow:hidden; padding:0 26px; transition:max-height .5s ease, padding .4s ease; }
.setting.open .setting-content{ max-height:300px; padding:0 26px 26px; }
.setting-content p{ color:var(--muted); margin-bottom:18px; }

/* TOGGLE */
.toggle{ display:flex; justify-content:space-between; align-items:center; margin-bottom:18px; }
.switch{ width:60px; height:32px; background:#000; border:1px solid var(--border); border-radius:999px; position:relative; cursor:pointer; }
.switch::after{ content:""; width:26px; height:26px; background:var(--cyan); border-radius:50%; position:absolute; top:2px; left:2px; transition:.35s; }
.switch.on{ background:rgba(34,211,238,.18); }
.switch.on::after{ left:32px; }

/* BUTTON */
.btn{ padding:14px 36px; border-radius:999px; border:none; cursor:pointer; font-weight:900; background:linear-gradient(135deg,var(--blue),var(--cyan)); color:#020617; box-shadow:0 0 14px rgba(34,211,238,.35); }
.danger{ background:rgba(239,68,68,.12); border-radius:18px; padding:22px; }
.danger .btn{ background:linear-gradient(135deg,var(--red),#f87171); color:#fff; box-shadow:0 0 16px rgba(239,68,68,.45); }
</style>
</head>

<body class="<%= currentTheme.equals("light") ? "light" : "" %>">

<div class="container">

  <div class="header">
    <h1>⚙️ Settings</h1>
    <a href="dashboard.jsp" class="back">← Dashboard</a>
  </div>

  <div class="setting open">
    <div class="setting-header" onclick="toggleSection(this)">
      <h2>👤 Profile</h2>
      <span class="arrow">⌄</span>
    </div>
    <div class="setting-content">
      <p>Edit your personal details.</p>
      <button class="btn" onclick="window.location.href='profile_edit.jsp'">Edit Profile</button>
    </div>
  </div>

  <div class="setting">
    <div class="setting-header" onclick="toggleSection(this)">
      <h2>🎨 Appearance</h2>
      <span class="arrow">⌄</span>
    </div>
    <div class="setting-content">
      <p>Theme and visual preferences.</p>
      <div class="toggle">
        <span>Dark Mode (Toggle to Light)</span>
        <div class="switch <%= currentTheme.equals("light") ? "on" : "" %>" onclick="toggleTheme(this)"></div>
      </div>
    </div>
  </div>

  <div class="setting">
    <div class="setting-header" onclick="toggleSection(this)">
      <h2>🔔 Notifications</h2>
      <span class="arrow">⌄</span>
    </div>
    <div class="setting-content">
      <p>Quiz alerts & reminders.</p>
      <div class="toggle">
        <span>Quiz Alerts</span>
        <div class="switch <%= notifStatus == 1 ? "on" : "" %>" onclick="toggleNotif(this)"></div>
      </div>
    </div>
  </div>

  <div class="setting">
    <div class="setting-header" onclick="toggleSection(this)">
      <h2>🚪 Logout</h2>
      <span class="arrow">⌄</span>
    </div>
    <div class="setting-content">
      <div class="danger">
        <p>Are you sure you want to logout?</p>
        <button class="btn" onclick="logout()">Logout</button>
      </div>
    </div>
  </div>

</div>

<script>
// --- UI LOGIC ---
function toggleSection(header){
  header.parentElement.classList.toggle('open');
}

// --- DATABASE UPDATE LOGIC (AJAX) ---
function sendUpdate(type, value) {
    // This sends data to 'update_settings.jsp' without reloading the page
    fetch('update_settings.jsp?type=' + type + '&val=' + value)
    .then(response => console.log("Updated " + type))
    .catch(error => console.error("Error updating settings"));
}

function toggleTheme(el){
  el.classList.toggle('on');
  
  // Check if class 'on' exists. If ON, it means we switched to Light mode (based on your CSS logic)
  // Wait, looking at your CSS: .switch.on usually implies "Active". 
  // Let's assume: ON = Light Mode, OFF = Dark Mode
  
  if(el.classList.contains('on')){
      document.body.classList.add('light');
      sendUpdate('theme', 'light');
  } else {
      document.body.classList.remove('light');
      sendUpdate('theme', 'dark');
  }
}

function toggleNotif(el){
  el.classList.toggle('on');
  
  // If ON, set notifications to 1, else 0
  let val = el.classList.contains('on') ? 1 : 0;
  sendUpdate('notif', val);
}

function logout(){
  if(confirm("Confirm Logout?")){
      window.location.href="logout.jsp";
  }
}
</script>

</body>
</html>