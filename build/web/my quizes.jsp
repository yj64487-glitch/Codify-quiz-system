<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>My Quizzes | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* CSS styles same as before */
:root{
  --bg:#020617; --panel:#0f172a; --glass:rgba(255,255,255,.05);
  --border:#1e293b; --cyan:#22d3ee; --blue:#3b82f6;
  --green:#22c55e; --yellow:#facc15; --text:#e5e7eb; --muted:#94a3b8;
}
*{margin:0;padding:0;box-sizing:border-box;font-family:Inter,system-ui,sans-serif;}
body{
  min-height:100vh;
  background: radial-gradient(1200px at 15% 10%, rgba(34,211,238,.12), transparent 40%),
              radial-gradient(900px at 85% 80%, rgba(59,130,246,.10), transparent 45%),
              linear-gradient(180deg,#020617,#020617);
  color:var(--text);
}
.container{max-width:1200px;margin:auto;padding:42px 24px;}
.header{display:flex;justify-content:space-between;align-items:center;margin-bottom:30px;}
.header h1{font-size:36px;font-weight:900} .header p{color:var(--muted)}
.back-btn{padding:12px 26px;border-radius:999px;background:linear-gradient(135deg,var(--cyan),var(--blue));color:#020617;font-weight:900;text-decoration:none;box-shadow:0 0 22px rgba(34,211,238,.5);transition:.25s;}
.back-btn:hover{transform:translateY(-2px) scale(1.05);box-shadow:0 0 40px rgba(34,211,238,.8);}
.hint-bar{background:linear-gradient(135deg,rgba(34,211,238,.18),rgba(59,130,246,.18));border:1px solid var(--border);padding:14px 22px;border-radius:16px;margin-bottom:30px;}
.filters{display:flex;gap:14px;margin-bottom:36px;}
.filter-btn{padding:11px 26px;border-radius:999px;border:1px solid var(--border);background:var(--glass);cursor:pointer;font-weight:800;transition:.3s;}
.filter-btn.active{background:linear-gradient(135deg,var(--blue),var(--cyan));color:#020617;box-shadow:0 0 25px rgba(34,211,238,.7);}
.quick-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:18px;margin-bottom:40px;}
.stat{background:var(--glass);border:1px solid var(--border);border-radius:18px;padding:20px;text-align:center;}
.stat h3{font-size:26px} .stat p{font-size:12px;color:var(--muted)}
.quiz-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:24px;margin-bottom:60px;}
.quiz-card{background:linear-gradient(135deg,rgba(255,255,255,.06),rgba(255,255,255,.02));border:1px solid var(--border);border-radius:22px;padding:24px;transition:.4s ease;}
.quiz-card.hide{opacity:0;transform:scale(.92);pointer-events:none;display: none;} 
.quiz-card:hover{transform:translateY(-10px) scale(1.02);box-shadow:0 0 30px rgba(34,211,238,.4);}
.badge{padding:6px 14px;border-radius:999px;font-size:11px;font-weight:900;border:1px solid var(--border);}
.live{color:var(--yellow)} .new{color:var(--cyan)} .done{color:var(--green)}
.progress span{font-size:12px;color:var(--muted)}
.bar{height:6px;background:#020617;border-radius:999px;overflow:hidden;margin:6px 0 14px;}
.fill{height:100%;background:linear-gradient(90deg,var(--blue),var(--cyan));}
.meta{display:flex;justify-content:space-between;font-size:12px;color:var(--muted);margin-bottom:16px; margin-top: 10px;}
.action-btn{padding:10px 24px;border-radius:999px;background:linear-gradient(135deg,var(--blue),var(--cyan));color:#020617;font-weight:900;cursor:pointer;border:none;width:100%;}
.coding-arena{margin:80px 0;padding:50px;border-radius:26px;background:radial-gradient(400px at 10% 10%, rgba(34,211,238,.25), transparent 50%),linear-gradient(135deg,#020617,#020617);border:1px solid var(--border);text-align:center;animation:float 6s ease-in-out infinite;}
@keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-12px)}}
.coding-arena h2{font-size:34px;font-weight:900;} .coding-arena p{color:var(--muted);margin:14px 0 26px;}
.coding-arena a{display:inline-block;padding:14px 44px;border-radius:999px;background:linear-gradient(135deg,var(--green),var(--cyan));color:#020617;font-weight:900;text-decoration:none;box-shadow:0 0 30px rgba(34,211,238,.7);}
footer{margin-top:80px;padding:40px 20px;border-top:1px solid var(--border);text-align:center;}
footer h3{font-weight:900;letter-spacing:2px;} footer p{color:var(--muted);font-size:13px;margin-top:6px;} footer span{color:var(--cyan);}
</style>
</head>

<body>

<%
    // --- UPDATED DB CONNECTION ---
    String url = "jdbc:mysql://localhost:3306/codify_db"; 
    String dbUser = "root";  
    String dbPass = "root";   // Empty password

    Connection con = null;
    PreparedStatement psStats = null;
    PreparedStatement psQuiz = null;
    ResultSet rsStats = null;
    ResultSet rsQuiz = null;

    int qPlayed = 0, accuracy = 0, streak = 0, rank = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, dbUser, dbPass);

        // Fetch Stats
        psStats = con.prepareStatement("SELECT * FROM user_stats WHERE id = 1");

        rsStats = psStats.executeQuery();
        
        if(rsStats.next()){
            qPlayed = rsStats.getInt("quizzes_played");
            accuracy = rsStats.getInt("accuracy");
            streak = rsStats.getInt("streak");
            rank = rsStats.getInt("rank_val");
        }
%>

<div class="container">

<div class="header">
  <div>
    <h1>My Quizzes</h1>
    <p>Practice smart, compete hard & improve daily.</p>
  </div>
  <a href="dashboard.jsp" class="back-btn">← Dashboard</a>
</div>

<div class="hint-bar">💡 Maintain streaks to unlock elite challenges.</div>

<div class="filters">
  <div class="filter-btn active" data-filter="all">All</div>
  <div class="filter-btn" data-filter="live">Live</div>
  <div class="filter-btn" data-filter="new">New</div>
  <div class="filter-btn" data-filter="done">Completed</div>
</div>

<div class="quick-stats">
  <div class="stat"><h3><%= qPlayed %></h3><p>Quizzes Played</p></div>
  <div class="stat"><h3><%= accuracy %>%</h3><p>Accuracy</p></div>
  <div class="stat"><h3><%= streak %> 🔥</h3><p>Streak</p></div>
  <div class="stat"><h3>#<%= rank %></h3><p>Rank</p></div>
</div>

<div class="quiz-grid">
    <%
        // Fetch Quizzes
        psQuiz = con.prepareStatement("SELECT * FROM quiz");
        rsQuiz = psQuiz.executeQuery();

        while(rsQuiz.next()) {
            String title = rsQuiz.getString("title");
            String status = rsQuiz.getString("status");
            int questions = rsQuiz.getInt("questions");
            int time = rsQuiz.getInt("time_mins");
            int progress = rsQuiz.getInt("progress");
            
            String badgeClass = status; 
    %>
    <div class="quiz-card <%= status %>">
        <span class="badge <%= badgeClass %>"><%= status.toUpperCase() %></span>
        <h3 style="margin-top:10px;"><%= title %></h3>
        
        <div class="meta">
            <span><%= questions %> Qs</span>
            <span><%= time %> Mins</span>
        </div>

        <div class="progress">
            <span>Progress: <%= progress %>%</span>
            <div class="bar">
                <div class="fill" style="width: <%= progress %>%;"></div>
            </div>
        </div>

        <button class="action-btn">
            <%= (status.equals("done")) ? "Review" : "Start Quiz" %>
        </button>
    </div>
    <%
        } // End While Loop
    %>
</div>

<%
    } catch (Exception e) {
        // Error handling
        out.println("<h3 style='color:red; text-align:center;'>Error: " + e.getMessage() + "</h3>");
        e.printStackTrace();
    } finally {
        if(con != null) con.close();
    }
%>

<div class="coding-arena">
  <h2>⚔️ Coding Arena</h2>
  <p>Real-time coding battles, ranked matches & elite challenges.</p>
  <a href="#">Enter Arena</a>
</div>

<footer>
  <h3>CODIFY</h3>
  <p>Built for developers who <span>compete</span>, <span>learn</span> & <span>win</span>.</p>
  <p>© 2026 CODIFY. All rights reserved.</p>
</footer>

</div>

<script>
const btns=document.querySelectorAll(".filter-btn");
const cards=document.querySelectorAll(".quiz-card");

btns.forEach(b=>{
  b.onclick=()=>{
    btns.forEach(x=>x.classList.remove("active"));
    b.classList.add("active");
    const t=b.dataset.filter;
    
    cards.forEach(c=>{
      c.style.display = "block";
      c.classList.remove("hide");
      
      if(t !== "all" && !c.classList.contains(t)){
         c.classList.add("hide");
         setTimeout(()=>{
             if(c.classList.contains("hide")) c.style.display = "none";
         }, 400); 
      }
    });
  };
});
</script>

</body>
</html>