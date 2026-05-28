<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // --- 1. USER AUTH CHECK ---
    String username = (String) session.getAttribute("username");
    if(username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // --- 2. DATABASE CONFIGURATION ---
    String url = "jdbc:mysql://localhost:3306/elite_quiz";
    String dbUser = "root";
    String dbPass = "root"; 

    int foundationScore = 0;
    int analyticScore = 0;
    
    // Default Lock States
    boolean unlockAnalytic = false;
    boolean unlockCritical = false;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        String sql = "SELECT quiz_type, MAX(score) as max_score FROM quiz_results WHERE username = ? GROUP BY quiz_type";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, username);
        rs = pstmt.executeQuery();

        while(rs.next()) {
            String type = rs.getString("quiz_type");
            int score = rs.getInt("max_score");

            if("foundation".equals(type)) foundationScore = score;
            if("analytic".equals(type)) analyticScore = score;
        }

        // --- UNLOCK LOGIC ---
        if(foundationScore >= 6) unlockAnalytic = true;
        if(analyticScore >= 6) unlockCritical = true;

    } catch(Exception e) {
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
<title>Mind Matrix | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
:root{ --bg:#020617; --panel:#0f172a; --glass:rgba(255,255,255,.06); --border:#1e293b; --accent:#38bdf8; --text:#e5e7eb; --muted:#94a3b8; --green:#22c55e; --danger:#ef4444; }
*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter,system-ui,sans-serif; }
body{ min-height:100vh; background: radial-gradient(1200px at 20% 10%, rgba(56,189,248,.15), transparent 40%), var(--bg); color:var(--text); }

/* TOP BAR */
.topbar{ height:72px; display:flex; align-items:center; justify-content:space-between; padding:0 40px; background:rgba(2,6,23,.85); backdrop-filter:blur(12px); border-bottom:1px solid var(--border); position:sticky; top:0; z-index:100; }
.brand{ display:flex; align-items:center; gap:14px; }

/* LOGO STYLE UPDATED FOR IMAGE */
.logo{ 
    width:44px; 
    height:44px; 
    border-radius:50%; 
    background:linear-gradient(135deg,var(--accent),#0ea5e9); 
    display:flex; 
    align-items:center; 
    justify-content:center; 
    box-shadow:0 0 20px rgba(56,189,248,.5); 
    overflow: hidden; /* Ensures image stays in circle */
}

/* IMAGE STYLE */
.logo img {
    width: 100%;
    height: 100%;
    object-fit: cover; /* Keeps aspect ratio */
}

.brand strong{ font-size:16px; letter-spacing:1px; }
.brand span{ display:block; font-size:11px; color:var(--muted); }
.back-btn{ padding:10px 28px; border-radius:999px; background:linear-gradient(135deg,var(--accent),#0ea5e9); color:#020617; font-weight:900; text-decoration:none; box-shadow:0 0 22px rgba(56,189,248,.5); transition:.2s; }
.back-btn:hover{ transform:translateY(-2px); box-shadow:0 0 34px rgba(56,189,248,.7); }

/* HERO */
.hero{ padding:90px 40px 70px; max-width:1200px; margin:auto; display:grid; grid-template-columns:1.2fr .8fr; gap:60px; }
.hero h1{ font-size:56px; line-height:1.1; }
.hero h1 span{color:var(--accent)}
.hero p{ margin-top:18px; color:var(--muted); font-size:18px; max-width:520px; }
.hero-stats{ display:flex; gap:22px; margin-top:34px; }
.stat{ background:var(--glass); border:1px solid var(--border); border-radius:18px; padding:18px 22px; }
.stat h2{color:var(--accent)}
.stat small{color:var(--muted)}
.hero-card{ background:linear-gradient(135deg,rgba(255,255,255,.08),rgba(255,255,255,.02)); border:1px solid var(--border); border-radius:30px; padding:38px; transition:.3s; }
.hero-card:hover{ transform:translateY(-8px); box-shadow:0 0 30px rgba(56,189,248,.35); }

/* LEVELS */
.level-section{ padding:80px 40px 100px; }
.level-section h2{ font-size:36px; text-align:center; }
.level-section p{ text-align:center; color:var(--muted); margin-bottom:50px; }
.levels{ max-width:1100px; margin:auto; display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:30px; }

.level{ background:linear-gradient(145deg,#0f172a,#020617); border:1px solid var(--border); border-radius:26px; padding:32px; position:relative; transition:.35s; overflow: hidden; }
.level:hover{ transform:translateY(-10px); box-shadow:0 0 35px rgba(56,189,248,.35); }

.badge{ position:absolute; top:20px; right:20px; background:rgba(56,189,248,.15); color:var(--accent); padding:6px 16px; border-radius:999px; font-size:12px; }
.level h3{ font-size:26px; margin-bottom:10px; }
.level ul{ list-style:none; color:var(--muted); font-size:15px; }
.level ul li{margin-bottom:8px}

/* BUTTON STYLE */
.level-btn {
    display: block; width: 100%; margin-top: 26px; padding: 14px;
    border-radius: 16px; background: var(--accent); color: #020617;
    font-weight: 900; text-align: center; text-decoration: none; border: none;
    cursor: pointer; transition: 0.3s;
}
.level-btn:hover { background: #fff; }

/* LOCKED STATE */
.level.locked { opacity: 0.6; pointer-events: none; filter: grayscale(0.8); }
.level.locked .level-btn { background: #334155; color: #94a3b8; cursor: not-allowed; }
.lock-icon { font-size: 40px; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 10; opacity: 0; transition: 0.3s; }
.level.locked:hover .lock-icon { opacity: 1; }

.status-text { font-size: 13px; margin-top: 10px; display: block; }
.text-green { color: var(--green); }
.text-red { color: var(--danger); }

/* FOOTER */
footer{ text-align:center; padding:40px; color:var(--muted); border-top:1px solid rgba(255,255,255,.06); }

@media(max-width:900px){ .hero{ grid-template-columns:1fr; padding:70px 24px; } .hero h1{ font-size:42px; } .topbar{ padding:0 20px; } }
</style>
</head>

<body>

<div class="topbar">
  <div class="brand">
    <div class="logo">
        <img src="images/quiz/mind matrix.jpeg" alt="Logo">
    </div>
    <div>
      <strong>Mind Matrix</strong>
      <span>Welcome, <%= username %></span>
    </div>
  </div>
  <a href="dashboard.jsp" class="back-btn">← Dashboard</a>
</div>

<section class="hero">
  <div>
    <h1>Think Faster.<br><span>Think Sharper.</span></h1>
    <p>
      Mind Matrix is CODIFY’s intelligence engine designed to test
      logic, speed, and decision-making under pressure.
    </p>

    <div class="hero-stats">
      <div class="stat"><h2>3</h2><small>Levels</small></div>
      <div class="stat"><h2>60%</h2><small>Unlock Score</small></div>
      <div class="stat"><h2>⚡</h2><small>Timed Logic</small></div>
    </div>
  </div>

  <div class="hero-card">
    <h3>Your Progress</h3>
    <p style="color:var(--muted);margin-top:10px">
       Foundation Best: <strong style="color:white"><%= foundationScore %>/10</strong><br>
       Analytic Best: <strong style="color:white"><%= analyticScore %>/10</strong>
    </p>
  </div>
</section>

<section class="level-section">
  <h2>Choose Your Level</h2>
  <p>Progress through increasingly complex logic challenges</p>

  <div class="levels">

    <div class="level">
      <div class="badge">Beginner</div>
      <h3>Foundation</h3>
      <ul>
        <li>✔ Pattern recognition</li>
        <li>✔ Series & basics</li>
        <li>✔ Comfortable timing</li>
      </ul>
      <span class="status-text text-green">● Unlocked</span>
      <a href="foundation.jsp" class="level-btn">Start Challenge</a>
    </div>

    <div class="level <%= unlockAnalytic ? "" : "locked" %>">
      <div class="badge">Intermediate</div>
      <div class="lock-icon">🔒</div> 
      <h3>Analytical</h3>
      <ul>
        <li>✔ Multi-step reasoning</li>
        <li>✔ Coding-decoding</li>
        <li>✔ Less time</li>
      </ul>
      
      <% if(unlockAnalytic) { %>
          <span class="status-text text-green">● Unlocked</span>
          <a href="analytic_quiz.jsp" class="level-btn">Start Challenge</a>
      <% } else { %>
          <span class="status-text text-red">● Locked (Score 6+ in Foundation)</span>
          <a href="#" class="level-btn">Locked</a>
      <% } %>
    </div>

    <div class="level <%= unlockCritical ? "" : "locked" %>">
      <div class="badge">Advanced</div>
      <div class="lock-icon">🔒</div>
      <h3>Critical</h3>
      <ul>
        <li>✔ Logic grids</li>
        <li>✔ Statements</li>
        <li>✔ High pressure</li>
      </ul>

      <% if(unlockCritical) { %>
          <span class="status-text text-green">● Unlocked</span>
          <a href="critical_quiz.jsp" class="level-btn">Start Challenge</a>
      <% } else { %>
          <span class="status-text text-red">● Locked (Score 6+ in Analytic)</span>
          <a href="#" class="level-btn">Locked</a>
      <% } %>
    </div>

  </div>
</section>

<footer>© 2026 CODIFY · Mind Matrix</footer>

</body>
</html>