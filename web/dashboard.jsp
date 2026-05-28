<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // 1. Session Check
    Integer userId = (Integer) session.getAttribute("user_id");
    if(userId == null){
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Default Variables
    String dashName = "User"; 
    String dashAvatar = "images/quiz/avatar1.jpg"; 

    // 3. Database Fetch Logic
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify_db","root","root");

        PreparedStatement ps = con.prepareStatement("SELECT full_name, current_avatar FROM users WHERE id=?");
        ps.setInt(1, userId);

        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            if(rs.getString("full_name") != null) dashName = rs.getString("full_name");
            if(rs.getString("current_avatar") != null && !rs.getString("current_avatar").isEmpty()) {
                dashAvatar = rs.getString("current_avatar");
            }
        }
        con.close();
    } catch(Exception e){
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Dashboard | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* SAME DESIGN (NO CHANGES) */
:root{ --glass:rgba(255,255,255,.07); --border:rgba(255,255,255,.15); --cyan:#22d3ee; --blue:#6366f1; --pink:#ec4899; --text:#e5e7eb; --muted:#94a3b8; }
*{margin:0;padding:0;box-sizing:border-box}
html{scroll-behavior:smooth}
body{ font-family:Inter,system-ui,sans-serif; color:var(--text); background: radial-gradient(900px at 10% 10%, rgba(99,102,241,.25), transparent 40%), radial-gradient(800px at 90% 20%, rgba(34,211,238,.22), transparent 45%), radial-gradient(700px at 50% 100%, rgba(236,72,153,.2), transparent 45%), linear-gradient(180deg,#020617,#030712); padding:24px; min-height:100vh; padding-bottom:120px; }
.container{max-width:1200px;margin:auto}

/* NAVBAR */
.navbar{ display:flex; justify-content:space-between; align-items:center; padding:18px 30px; background:rgba(255,255,255,.05); border:1px solid var(--border); border-radius:22px; backdrop-filter:blur(18px); margin-bottom:70px; position:relative; z-index:10; }
.logo{ display:flex; align-items:center; gap:14px; text-decoration:none; }
.logo-circle{ width:46px;height:46px;border-radius:50%; padding:3px; background:linear-gradient(135deg,var(--blue),var(--cyan)); }
.logo-circle img{width:100%;height:100%;border-radius:50%}
.logo span{ font-weight:900; letter-spacing:2px; background:linear-gradient(120deg,#7dd3fc,#c4b5fd,#5eead4,#fde68a); background-size:300% 300%; background-clip:text; -webkit-background-clip:text; color:transparent; -webkit-text-fill-color:transparent; }

/* MENU */
.nav-links{ display:flex; gap:26px; align-items:center; }
.menu-btn, .menu-link{ background:none; border:none; font-family:inherit; font-size:14px; color:var(--muted); cursor:pointer; text-decoration:none; padding:12px 10px; position:relative; display:inline-flex; align-items:center; }
.menu-btn::after, .menu-link::after{ content:''; position:absolute; left:0;right:0;bottom:6px; height:2px; background:linear-gradient(90deg,var(--cyan),var(--pink)); transform:scaleX(0); transform-origin:left; transition:transform .25s ease; pointer-events:none; }
.menu-btn:hover, .menu-link:hover{color:var(--cyan)}
.menu-btn:hover::after, .menu-link:hover::after{transform:scaleX(1)}
.menu-btn.active{color:var(--cyan)}
.menu-btn.active::after{transform:scaleX(1)}

/* PROFILE */
.profile-menu{position:relative}
.avatar-img{ width:42px;height:42px;border-radius:50%; object-fit: cover; border: 2px solid var(--cyan); cursor: pointer; }
.dropdown{ position:absolute; top:56px;right:0; min-width:170px; background:rgba(10,15,30,.95); border:1px solid var(--border); border-radius:16px; padding:8px; backdrop-filter:blur(14px); opacity:0; transform:translateY(10px); pointer-events:none; transition:.25s ease; }
.profile-menu:hover .dropdown, .profile-menu:focus-within .dropdown{ opacity:1; transform:translateY(0); pointer-events:auto; }
.dropdown a{ display:block; padding:10px 14px; border-radius:10px; text-decoration:none; color:var(--text); font-size:14px; }
.dropdown a:hover{background:rgba(255,255,255,.08)}
.dropdown .logout{color:#f87171}

/* HERO */
.hero{text-align:center;margin-bottom:70px}
.hero h1{ font-size:3.2rem; letter-spacing:10px; background:linear-gradient(120deg,#7dd3fc,#c4b5fd,#5eead4,#fde68a); background-size:300% 300%; background-clip:text; -webkit-background-clip:text; color:transparent; -webkit-text-fill-color:transparent; }
.hero p{margin-top:12px;color:var(--muted);font-size: 1.2rem;}

/* STATS */
.stats{ display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:26px; margin-bottom:70px; }
.stat{ background:var(--glass); border:1px solid var(--border); border-radius:22px; padding:26px; }
.stat h3{font-size:30px}
.stat p{font-size:13px;color:var(--muted)}

/* QUIZZES */
.quiz-grid{ display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:26px; margin-bottom:70px; }
.quiz-card{ background:linear-gradient(135deg,rgba(255,255,255,.12),rgba(255,255,255,.02)); border:1px solid var(--border); border-radius:24px; overflow:hidden; transition:.3s; }
.quiz-card:hover{ transform:translateY(-8px); box-shadow:0 30px 60px rgba(99,102,241,.35); }
.quiz-img{aspect-ratio:1/1}
.quiz-img img{width:100%;height:100%;object-fit:cover}
.quiz-body{text-align:center;padding:22px}
.quiz-body p{font-size:13px;color:var(--muted);margin-bottom:16px}
.quiz-body a{ padding:12px 34px; border-radius:999px; border:1px solid rgba(34,211,238,.55); text-decoration:none; color:white; }
.quiz-body a:hover{ background:linear-gradient(135deg,var(--blue),var(--cyan),var(--pink)); color:#020617; }

/* FEATURES & FOOTER */
.features{ display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:26px; margin-bottom:70px; }
.feature{ background:var(--glass); border:1px solid var(--border); border-radius:22px; padding:26px; }
.feature h3{margin-bottom:6px}
.feature p{font-size:13px;color:var(--muted)}
.footer{ margin-top:100px; padding:32px; text-align:center; background:linear-gradient( 135deg, rgba(99,102,241,.18), rgba(34,211,238,.18) ); border:1px solid var(--border); border-radius:22px; color:white; position:relative; z-index:2; box-shadow: 0 20px 40px rgba(0,0,0,.6), 0 0 30px rgba(99,102,241,.35); }
</style>
</head>

<body>
<div class="container">

<div class="navbar">

  <a href="index.jsp" class="logo">
    <div class="logo-circle">
      <img src="images/quiz/codify.png" alt="CODIFY">
    </div>
    <span>CODIFY</span>
  </a>

  <div class="nav-links">
    <button class="menu-btn active">Dashboard</button>
    <a href="my quizes.jsp" class="menu-link">Quizzes</a>
    <a href="analytics.jsp" class="menu-link">Analytics</a>
    <a href="my attempt.jsp" class="menu-link">My Attempts</a>
    <a href="leaderboard.jsp" class="menu-link">Leaderboard</a>
    <a href="feedback.jsp" class="menu-link">Feedback</a>
  </div>

  <div class="profile-menu" tabindex="0">
    <img src="<%= dashAvatar %>" class="avatar-img" alt="Profile">
    
    <div class="dropdown">
      <a href="profile.jsp">Profile</a>
      <a href="settings.jsp">Settings</a>
      <a href="logout.jsp" class="logout">Logout</a>
    </div>
  </div>

</div>

<div class="hero">
  <h1>Welcome, <%= dashName %>!</h1>
  <p>Ready to code smarter and build faster?</p>
</div>

<div class="stats">
  <div class="stat"><h3>0</h3><p>Total Quizzes Attempted</p></div>
  <div class="stat"><h3>0%</h3><p>Average Accuracy</p></div>
  <div class="stat"><h3>0 🔥</h3><p>Current Streak</p></div>
  <div class="stat"><h3>#--</h3><p>Leaderboard Rank</p></div>
</div>

<div class="quiz-grid">

  <div class="quiz-card">
    <div class="quiz-img">
      <img src="images/quiz/debugzone.png" alt="Debug Zone">
    </div>
    <div class="quiz-body">
      <h4>Bug Hunt</h4>
      <p>Error detection practice</p>
      <a href="instruction.jsp?mode=debug">Start</a>
    </div>
  </div>

  <div class="quiz-card">
    <div class="quiz-img">
      <img src="images/quiz/coding arena.jpeg" alt="Coding Arena">
    </div>
    <div class="quiz-body">
      <h4>Coding Arena</h4>
      <p>DSA & logic</p>
      <a href="instruction.jsp?mode=coding">Start</a>
    </div>
  </div>

  <div class="quiz-card">
    <div class="quiz-img">
      <img src="images/quiz/time rapid.jpeg" alt="Rapid Fire">
    </div>
    <div class="quiz-body">
      <h4>Rapid Fire</h4>
      <p>Speed test</p>
      <a href="instruction.jsp?mode=rapid">Start</a>
    </div>
  </div>

  <div class="quiz-card">
    <div class="quiz-img">
      <img src="images/quiz/mind matrix.jpeg" alt="Mind Matrix">
    </div>
    <div class="quiz-body">
      <h4>Mind Matrix</h4>
      <p>Logic & reasoning</p>
      <a href="instruction.jsp?mode=mind">Start</a>
    </div>
  </div>

</div>

<div class="features">
  <div class="feature">
    <h3>🧠 Smart Quizzes</h3>
    <p>Adaptive quizzes based on your performance</p>
  </div>
  <div class="feature">
    <h3>📊 Analytics</h3>
    <p>Track accuracy, streaks and progress</p>
  </div>
  <div class="feature">
    <h3>🏆 Leaderboard</h3>
    <p>Compete with top performers</p>
  </div>
</div>

<div class="footer">
  © 2026 CODIFY • Code Your Future.
</div>

</div> </body>
</html>