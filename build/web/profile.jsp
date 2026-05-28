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
String name = "User";
String avatar = "images/quiz/avatar1.jpg"; // Default Avatar

// हे Variables खाली HTML मध्ये वापरले आहेत, म्हणून इथे declare करणे गरजेचे आहे
int quizzes = 0;
int accuracy = 0;
int questions = 0;
int badges = 0;

try{
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/codify_db","root","root"
    );

    // Fetch Name and Avatar
    PreparedStatement ps = con.prepareStatement(
        "SELECT full_name, current_avatar FROM users WHERE id=?"
    );
    ps.setInt(1,userId);

    ResultSet rs = ps.executeQuery();
    if(rs.next()){
        if(rs.getString("full_name")!=null) name = rs.getString("full_name");
        
        // जर DB मध्ये फोटो असेल तर तो घे, नाहीतर Default राहील
        if(rs.getString("current_avatar")!=null && !rs.getString("current_avatar").isEmpty()){
            avatar = rs.getString("current_avatar");
        }
    }
    
    // NOTE: इथे तुम्ही stats (quizzes/accuracy) साठी वेगळी query लिहू शकता
    // सध्या मी 0 ठेवले आहेत जेणेकरून एरर येणार नाही.
    
    con.close();
}catch(Exception e){ e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Quiz Profile | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* तुझी सेम Design */
:root{ --bg1:#050612; --bg2:#0b102a; --panel:#0f172a; --border:#1e293b;
       --cyan:#22d3ee; --blue:#3b82f6; --text:#e5e7eb; --muted:#94a3b8; }
*{margin:0;padding:0;box-sizing:border-box;font-family:Inter,system-ui,sans-serif;}
body{
 min-height:100vh;
 background:radial-gradient(1000px at 20% 10%, rgba(59,130,246,.15), transparent 40%),
            radial-gradient(900px at 80% 80%, rgba(34,211,238,.12), transparent 45%),
            linear-gradient(180deg,var(--bg1),var(--bg2));
 color:var(--text);
}
.layout{display:grid;grid-template-columns:300px 1fr;min-height:100vh;}
.sidebar{background:rgba(15,23,42,.96);border-right:1px solid var(--border);padding:32px 22px;}

.avatar-wrap{width:112px;margin:0 auto 18px;}
.avatar-ring{
 width:112px;height:112px;border-radius:50%;padding:3px;
 background:linear-gradient(135deg,var(--blue),var(--cyan));
}
.avatar{
 width:100%;height:100%;border-radius:50%;
 overflow:hidden;background:#020617;
}
.avatar img{width:100%;height:100%;object-fit:cover;}

.user{text-align:center}
.user h2{font-size:22px}
.user p{font-size:14px;color:var(--muted);margin-top:6px}

.menu{margin-top:30px}
.menu a{
 display:block;padding:14px 16px;border-radius:12px;
 text-decoration:none;color:var(--text);margin-bottom:10px;
 background:rgba(255,255,255,.04);
}
.menu a:hover{background:rgba(34,211,238,.18);transform:translateX(4px)}

.main{padding:36px}
.slogan{
 font-size:34px;font-weight:900;
 background:linear-gradient(135deg,var(--blue),var(--cyan));
 -webkit-background-clip:text;background-clip:text;color:transparent;
}
.tagline{color:var(--muted);margin-bottom:28px}

.section{
 background:rgba(15,23,42,.88);
 border:1px solid var(--border);
 border-radius:20px;
 padding:26px;
}
.stats{
 display:grid;
 grid-template-columns:repeat(auto-fit,minmax(180px,1fr));
 gap:16px;
}
.stat{
 background:rgba(255,255,255,.05);
 border:1px solid var(--border);
 border-radius:16px;
 padding:20px;
}
.stat h3{font-size:24px}
.stat p{font-size:13px;color:var(--muted)}
</style>
</head>

<body>

<div class="layout">

<aside class="sidebar">

  <div class="avatar-wrap">
    <div class="avatar-ring">
      <div class="avatar">
        <img src="<%= avatar %>?v=<%= System.currentTimeMillis() %>" alt="Avatar">
      </div>
    </div>
  </div>

  <div class="user">
    <h2><%= name %></h2>
    <p>@User</p>
  </div>

  <div class="menu">
    <a href="dashboard.jsp">🏠 Dashboard</a>
    <a href="my quizes.jsp">🧠 Quizzes</a>
    <a href="my attempt.jsp">📊 Attempts</a>
    <a href="leaderboard.jsp">🏆 Leaderboard</a>
    <a href="analytics.jsp">📈 Analytics</a>
    <a href="settings.jsp">⚙️ Settings</a>
  </div>

</aside>

<main class="main">
  <div class="slogan">Think Fast. Learn Deep. Win Smart.</div>
  <div class="tagline">Built for competitive minds & curious coders</div>

  <div class="section">
    <h2>Your Performance</h2><br>
    <div class="stats">
      <div class="stat"><h3><%= quizzes %></h3><p>Quizzes Attempted</p></div>
      <div class="stat"><h3><%= accuracy %>%</h3><p>Accuracy</p></div>
      <div class="stat"><h3><%= questions %></h3><p>Questions Solved</p></div>
      <div class="stat"><h3><%= badges %></h3><p>Badges Earned</p></div>
    </div>
  </div>
</main>

</div>

</body>
</html>