<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    /* ================== 1. SESSION CHECK ================== */
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect("admin_login.jsp");
        return;
    }

    /* ================== 2. DB CONNECTION & LOGIC ================== */
    int totalAttempts = 0;
    int activeUsers = 0;
    int avgAccuracy = 0;
    double avgTime = 0.0;

    // Percentages (Defaults to 0)
    int bugHuntW = 0, codingArenaW = 0, mindMatrixW = 0, rapidFireW = 0;
    String weakestQuiz = "No Data";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify_db", "root", "root");
        Statement st = conn.createStatement();

        // Basic KPI Stats
        ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM results");
        if(rs.next()) totalAttempts = rs.getInt(1);

        rs = st.executeQuery("SELECT COUNT(DISTINCT user_id) FROM results");
        if(rs.next()) activeUsers = rs.getInt(1);

        rs = st.executeQuery("SELECT IFNULL(AVG(score), 0) FROM results");
        if(rs.next()) avgAccuracy = rs.getInt(1);

        rs = st.executeQuery("SELECT IFNULL(AVG(completion_time)/60, 0) FROM results");
        if(rs.next()) avgTime = rs.getDouble(1);

        // Category-wise Data for Progress Bars
        String catQuery = "SELECT q.title, IFNULL(AVG(r.score), 0) as avg_s FROM quizzes q " +
                          "LEFT JOIN results r ON q.id = r.quiz_id GROUP BY q.title ORDER BY avg_s ASC";
        rs = st.executeQuery(catQuery);
        
        boolean foundWeakest = false;
        while(rs.next()){
            String title = rs.getString("title");
            int score = rs.getInt("avg_s");
            
            if(!foundWeakest && totalAttempts > 0) { weakestQuiz = title; foundWeakest = true; }
            
            String t = title.toLowerCase();
            if(t.contains("bug")) bugHuntW = score;
            else if(t.contains("coding") || t.contains("arena")) codingArenaW = score;
            else if(t.contains("mind") || t.contains("matrix")) mindMatrixW = score;
            else if(t.contains("fire") || t.contains("rapid")) rapidFireW = score;
        }
        conn.close();
    } catch (Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>CODIFY · Admin Analytics</title>
<style>
:root{ --bg:#05070f; --panel:#0b1020; --border:#1f2a44; --accent:#38bdf8; --accent2:#6366f1; --green:#22c55e; --red:#ef4444; --yellow:#facc15; --text:#e5e7eb; --muted:#94a3b8; }
*{margin:0;padding:0;box-sizing:border-box;font-family:Inter,sans-serif}
body{ background: radial-gradient(900px at 80% 10%,#1e3a8a25,transparent), var(--bg); color:var(--text); animation: fadeIn 0.8s ease; }
@keyframes fadeIn { from{opacity:0; transform:translateY(10px);} to{opacity:1; transform:none;} }

/* HEADER */
.header{ position:sticky; top:0; padding:22px 36px; background:rgba(5,7,15,0.7); backdrop-filter:blur(12px); border-bottom:1px solid var(--border); display:flex; justify-content:space-between; align-items:center; z-index:100; }
.logo-box{ display:flex; align-items:center; gap:12px; }
.logo-circle{ width:44px; height:44px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--accent2)); display:grid; place-items:center; color:#020617; font-weight:900; }
.back-btn{ padding:10px 20px; border-radius:50px; background:linear-gradient(135deg,var(--accent),var(--accent2)); color:#020617; font-weight:bold; text-decoration:none; transition:0.3s; }

/* LAYOUT */
.container{ max-width:1400px; margin:auto; padding:40px 30px; }
.kpi-grid{ display:grid; grid-template-columns:repeat(auto-fit,minmax(250px,1fr)); gap:25px; margin-bottom:45px; }
.kpi-card{ background:var(--panel); border:1px solid var(--border); border-radius:24px; padding:26px; opacity:0; transform:translateY(20px); animation: slideUp 0.6s ease forwards; }
@keyframes slideUp { to{opacity:1; transform:none;} }

.kpi-card strong{ font-size:38px; color:var(--accent); display:block; }
.kpi-card span{ color:var(--muted); font-size:13px; }

/* CHARTS SECTION */
.charts-grid{ display:grid; grid-template-columns:1.6fr 1fr; gap:30px; }
.card{ background:var(--panel); border:1px solid var(--border); border-radius:24px; padding:30px; }

.bar-row{ margin:20px 0; }
.bar-info{ display:flex; justify-content:space-between; margin-bottom:8px; font-size:13px; color:var(--muted); }
.track{ height:10px; background:#020617; border-radius:10px; overflow:hidden; }
.fill{ height:100%; background:linear-gradient(90deg,var(--accent),var(--accent2)); width:0; transition: 1.5s cubic-bezier(0.1, 0.5, 0.5, 1); }

/* BUTTONS */
.action-box{ margin-top:40px; }
.btn-group{ display:flex; gap:15px; margin-top:20px; }
.btn{ padding:12px 25px; border-radius:50px; border:1px solid var(--border); background:transparent; color:white; cursor:pointer; font-weight:600; transition:0.3s; }
.btn-primary{ background:linear-gradient(135deg,var(--accent),var(--accent2)); color:#020617; border:none; }
.btn:hover{ transform:scale(1.05); }

#toast{ position:fixed; bottom:30px; right:30px; background:var(--accent); color:#020617; padding:15px 25px; border-radius:12px; font-weight:bold; opacity:0; transition:0.4s; }
</style>
</head>
<body>

<div class="header">
  <div class="brand">
    <div class="logo-circle" style="background: none; border: none; overflow: hidden;">
        <img src="images/quiz/codify.png" style="width: 100%; height: 100%; object-fit: contain;" onerror="this.src='https://ui-avatars.com/api/?name=C&background=38bdf8&color=020617'">
    </div>
    <div class="brand-text">
      <h2>CODIFY · Admin</h2>
      <span>Analytics Manager</span>
    </div>
  </div>
  <div style="display:flex;gap:16px;align-items:center">
    <div class="time" id="clock"></div>
    <a href="admin_dashboard.jsp" class="back-btn">← Dashboard</a>
  </div>
</div>
<div class="container">
    <div class="kpi-grid">
        <div class="kpi-card" style="animation-delay:0.1s"><strong data-val="<%= totalAttempts %>">0</strong><span>Total Attempts</span></div>
        <div class="kpi-card" style="animation-delay:0.2s"><strong data-val="<%= activeUsers %>">0</strong><span>Active Users</span></div>
        <div class="kpi-card" style="animation-delay:0.3s"><strong data-val="<%= avgAccuracy %>">0%</strong><span>Avg Accuracy</span></div>
        <div class="kpi-card" style="animation-delay:0.4s"><strong><%= String.format("%.1f", avgTime) %> min</strong><span>Avg Comp. Time</span></div>
    </div>

    <div class="charts-grid">
        <div class="card">
            <h3>Performance Distribution</h3>
            <div class="bar-row">
                <div class="bar-info"><span>Bug Hunting</span><span><%= bugHuntW %>%</span></div>
                <div class="track"><div class="fill" id="bar1" style="width:0%"></div></div>
            </div>
            <div class="bar-row">
                <div class="bar-info"><span>Coding Arena</span><span><%= codingArenaW %>%</span></div>
                <div class="track"><div class="fill" id="bar2" style="width:0%"></div></div>
            </div>
            <div class="bar-row">
                <div class="bar-info"><span>Mind Matrix</span><span><%= mindMatrixW %>%</span></div>
                <div class="track"><div class="fill" id="bar3" style="width:0%"></div></div>
            </div>
            <div class="bar-row">
                <div class="bar-info"><span>Rapid Fire</span><span><%= rapidFireW %>%</span></div>
                <div class="track"><div class="fill" id="bar4" style="width:0%"></div></div>
            </div>
        </div>

        <div class="card">
            <h3>System Insights</h3>
            <div style="margin-top:15px">
                <p style="padding:12px 0; border-bottom:1px solid var(--border)">Weakest Quiz: <b style="color:var(--red)"><%= weakestQuiz %></b></p>
                <p style="padding:12px 0; border-bottom:1px solid var(--border)">User Retention: <b style="color:var(--green)">High</b></p>
                <p style="padding:12px 0">Database Status: <b style="color:var(--accent)">Live</b></p>
            </div>
        </div>
    </div>

    <div class="action-box">
        <h3>Analytics Controls</h3>
        <div class="btn-group">
            <button class="btn btn-primary" onclick="pop('Exporting Data...')">Export CSV</button>
            <button class="btn" onclick="location.reload()">Refresh Data</button>
            <button class="btn" style="color:var(--red)" onclick="pop('Analytics Locked')">Lock Access</button>
        </div>
    </div>
</div>

<div id="toast"></div>

<script>
    setInterval(()=> document.getElementById('clock').innerText = new Date().toLocaleString(), 1000);

    // Stats Count-Up
    document.querySelectorAll('[data-val]').forEach(el => {
        let target = parseInt(el.getAttribute('data-val'));
        let isPercent = el.innerText.includes('%');
        let count = 0; let step = target / 40;
        if(target > 0) {
            let timer = setInterval(() => {
                count += step;
                if(count >= target) { el.innerText = target + (isPercent ? '%' : ''); clearInterval(timer); }
                else { el.innerText = Math.floor(count) + (isPercent ? '%' : ''); }
            }, 30);
        }
    });

    // Animate All 4 Bars
    window.onload = () => {
        setTimeout(() => {
            document.getElementById('bar1').style.width = '<%= bugHuntW %>%';
            document.getElementById('bar2').style.width = '<%= codingArenaW %>%';
            document.getElementById('bar3').style.width = '<%= mindMatrixW %>%';
            document.getElementById('bar4').style.width = '<%= rapidFireW %>%';
        }, 500);
    };

    function pop(m) {
        let t = document.getElementById('toast');
        t.innerText = m; t.style.opacity = 1;
        setTimeout(() => t.style.opacity = 0, 2500);
    }
</script>
</body>
</html>