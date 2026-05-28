<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
/* ==========================================
   1. SESSION & AUTHENTICATION
   ========================================== */
Integer userId = (Integer) session.getAttribute("user_id");
if(userId == null){
    response.sendRedirect("login.jsp");
    return;
}

/* ==========================================
   2. DATABASE CONFIGURATION
   ========================================== */
String dbUrl = "jdbc:mysql://localhost:3306/codify_db";
String dbUser = "root";
String dbPass = "root";

/* ==========================================
   3. VARIABLE INITIALIZATION (Defaults)
   ========================================== */
int overallAccuracy = 0;
int totalChallenges = 0;
int consistencyStreak = 0;
int peakRank = 0;

// Default Category Scores (Radar Chart)
int logicScore = 0;
int codingScore = 0;
int aptitudeScore = 0;
int speedScore = 75; // Default average

// Lists for Graph Data
List<String> graphDays = new ArrayList<>();
List<Integer> graphScores = new ArrayList<>();

// Insight Strings
String strongZone = "General Knowledge";
String weakZone = "None";
String nextFocus = "Keep practicing";

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

    /* --- QUERY 1: FETCH MAIN USER STATS --- */
    String sqlStats = "SELECT IFNULL(accuracy,0) as acc, " +
                      "IFNULL(quizzes_attempted,0) as challenges, " +
                      "IFNULL(badges_earned,0) as streak, " + // Using badges as streak for demo
                      "IFNULL(questions_solved,0) as rank_score " + // Using questions as rank proxy
                      "FROM user_stats WHERE user_id=?";
    pstmt = conn.prepareStatement(sqlStats);
    pstmt.setInt(1, userId);
    rs = pstmt.executeQuery();

    if(rs.next()){
        overallAccuracy = rs.getInt("acc");
        totalChallenges = rs.getInt("challenges");
        consistencyStreak = rs.getInt("streak");
        peakRank = (rs.getInt("rank_score") > 0) ? (10000 / rs.getInt("rank_score")) : 0; // Fake rank logic
    }
    rs.close(); pstmt.close();

    /* --- QUERY 2: FETCH CATEGORY AVERAGES (For Radar) --- */
    // Assuming you have a table 'quiz_attempts' with 'category' and 'score'
    // If not, these will remain 0.
    String sqlCats = "SELECT category, AVG(score) as avg_score FROM quiz_attempts " +
                     "WHERE user_id=? GROUP BY category";
    try {
        pstmt = conn.prepareStatement(sqlCats);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        while(rs.next()){
            String cat = rs.getString("category").toLowerCase();
            int val = rs.getInt("avg_score");
            
            if(cat.contains("logic")) logicScore = val;
            else if(cat.contains("code") || cat.contains("java")) codingScore = val;
            else if(cat.contains("apti")) aptitudeScore = val;
        }
    } catch(Exception e) {
        // Table might not exist, ignore
    }
    if(rs != null) rs.close(); 
    if(pstmt != null) pstmt.close();

    /* --- QUERY 3: FETCH LAST 7 ATTEMPTS (For Graph) --- */
    String sqlGraph = "SELECT score, attempt_date FROM quiz_attempts " +
                      "WHERE user_id=? ORDER BY attempt_date DESC LIMIT 7";
    try {
        pstmt = conn.prepareStatement(sqlGraph);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        
        // Use a stack to reverse order (Oldest -> Newest) for the graph
        Stack<String> dayStack = new Stack<>();
        Stack<Integer> scoreStack = new Stack<>();
        
        SimpleDateFormat sdf = new SimpleDateFormat("E"); // Mon, Tue...

        while(rs.next()){
            scoreStack.push(rs.getInt("score"));
            Timestamp ts = rs.getTimestamp("attempt_date");
            dayStack.push(ts != null ? sdf.format(ts) : "Day");
        }

        while(!scoreStack.isEmpty()){
            graphScores.add(scoreStack.pop());
            graphDays.add(dayStack.pop());
        }
    } catch(Exception e) {
        // Fallback data if table doesn't exist
        for(int i=0; i<7; i++) { graphScores.add(0); graphDays.add("-"); }
    }

    /* --- LOGIC: DETERMINE INSIGHTS --- */
    if(logicScore > codingScore && logicScore > aptitudeScore) strongZone = "Logical Reasoning";
    else if(codingScore > aptitudeScore) strongZone = "Coding Syntax";
    else strongZone = "Aptitude";

    if(aptitudeScore < 50 && aptitudeScore > 0) { weakZone = "Aptitude"; nextFocus = "Train Aptitude Drills"; }
    else if(codingScore < 50 && codingScore > 0) { weakZone = "Coding"; nextFocus = "Review Syntax Basics"; }
    else { weakZone = "Speed"; nextFocus = "Improve Reaction Time"; }

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
<title>CODIFY Intelligence</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* ================= STYLE (UNCHANGED) ================= */
:root{ --bg:#020617; --card:#0b1228; --glass:rgba(255,255,255,.06); --border:#1e293b; --cyan:#22d3ee; --blue:#3b82f6; --green:#22c55e; --yellow:#facc15; --red:#ef4444; --text:#e5e7eb; --muted:#94a3b8; }
*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter,system-ui,sans-serif; }
body{ min-height:100vh; background: radial-gradient(1400px at 15% 10%, rgba(59,130,246,.18), transparent 40%), radial-gradient(1200px at 85% 80%, rgba(34,211,238,.18), transparent 45%), linear-gradient(180deg,#020617,#020617); color:var(--text); }
.container{ max-width:1300px; margin:auto; padding:40px 26px 56px; animation:fadeIn .9s ease; }
@keyframes fadeIn{ from{opacity:0; transform:translateY(10px)} to{opacity:1; transform:translateY(0)} }

/* BRAND */
.brand{ display:flex; align-items:center; gap:14px; margin-bottom:36px; }
.logo{ width:46px; height:46px; border-radius:50%; background:linear-gradient(135deg,var(--blue),var(--cyan)); display:flex; align-items:center; justify-content:center; box-shadow:0 0 18px rgba(34,211,238,.45); overflow:hidden; cursor:pointer; }
.logo img{ width:100%; height:100%; border-radius:50%; object-fit:cover; }
.brand h2{ font-size:22px; letter-spacing:2px; }
.brand span{ font-size:12px; color:var(--muted); }

/* HERO */
.hero{ display:grid; grid-template-columns:1.3fr .7fr; gap:40px; margin-bottom:80px; }
.hero h1{ font-size:48px; font-weight:900; line-height:1.1; }
.hero p{ margin-top:14px; color:var(--muted); max-width:520px; }
.hero .tag{ margin-top:22px; display:inline-block; padding:10px 22px; border-radius:999px; background:linear-gradient(135deg,var(--blue),var(--cyan)); color:#020617; font-weight:900; animation:pulse 3s ease-in-out infinite; }
@keyframes pulse{ 0%,100%{box-shadow:0 0 0 rgba(34,211,238,.0)} 50%{box-shadow:0 0 24px rgba(34,211,238,.6)} }

/* DNA CARD */
.dna{ background:linear-gradient(135deg,rgba(255,255,255,.08),rgba(255,255,255,.02)); border:1px solid var(--border); border-radius:30px; padding:36px; transition:.35s ease; }
.dna:hover{ transform:translateY(-8px); box-shadow:0 0 30px rgba(34,211,238,.25); }
.dna h2{margin-bottom:10px} .dna p{color:var(--muted); font-size:14px}
.dna-metrics{ display:grid; grid-template-columns:repeat(2,1fr); gap:20px; margin-top:26px; }
.metric{ background:rgba(255,255,255,.04); border:1px solid var(--border); border-radius:18px; padding:20px; transition:.3s ease; }
.metric:hover{ transform:scale(1.05); box-shadow:0 0 18px rgba(34,211,238,.3); }
.metric strong{ font-size:30px; display:block; }
.metric span{ font-size:12px; color:var(--muted); }

/* GROWTH PATH */
.path{margin-bottom:90px} .path h2{margin-bottom:26px}
.path-track{ display:grid; grid-template-columns:repeat(7,1fr); gap:18px; }
.node{ background:#020617; border:1px solid var(--border); border-radius:20px; padding:22px 10px; text-align:center; transition:.3s ease; }
.node:hover{ transform:translateY(-6px); box-shadow:0 0 18px rgba(34,211,238,.25); }
.node strong{ display:block; font-size:22px; }
.node span{ font-size:11px; color:var(--muted); }
.up{color:var(--green)} .mid{color:var(--yellow)} .down{color:var(--red)}

/* SKILL RADAR */
.radar{ display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr)); gap:24px; margin-bottom:90px; }
.radar-card{ background:var(--glass); border:1px solid var(--border); border-radius:26px; padding:28px; text-align:center; transition:.35s ease; }
.radar-card:hover{ transform:translateY(-8px); box-shadow:0 0 26px rgba(34,211,238,.3); }
.radar-card h3{margin-bottom:16px}
.ring{ position:relative; width:120px; height:120px; margin:auto; border-radius:50%; background:conic-gradient(var(--cyan) calc(var(--v)*1%), #020617 0); display:flex; align-items:center; justify-content:center; animation:spinIn 1.2s ease; }
@keyframes spinIn{ from{transform:rotate(-90deg); opacity:0} to{transform:rotate(0); opacity:1} }
.ring::after{ content:""; position:absolute; inset:12px; border-radius:50%; background:#020617; }
.ring span{ position:relative; font-weight:900; }

/* FEATURES & STORY */
.features, .story{ display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:26px; margin-bottom:100px; }
.feature, .story-card{ background:linear-gradient(135deg,rgba(255,255,255,.08),rgba(255,255,255,.02)); border:1px solid var(--border); border-radius:26px; padding:30px; transition:.35s ease; }
.feature:hover, .story-card:hover{ transform:translateY(-10px); box-shadow:0 0 30px rgba(34,211,238,.35); }
.feature h3, .story-card h3{margin-bottom:10px}
.feature p, .story-card p{font-size:14px; color:var(--muted)}

/* CTA & BTN */
.final{ background:linear-gradient(135deg,rgba(34,211,238,.28),rgba(59,130,246,.28)); border:1px solid var(--border); border-radius:34px; padding:50px; text-align:center; animation:float 4s ease-in-out infinite; }
@keyframes float{ 0%,100%{transform:translateY(0)} 50%{transform:translateY(-8px)} }
.final h2{ font-size:34px; margin-bottom:10px; }
.final p{ color:var(--muted); margin-bottom:22px; }
.final span{ display:inline-block; padding:16px 44px; border-radius:999px; background:linear-gradient(135deg,var(--cyan),var(--blue)); color:#020617; font-weight:900; }
.back-btn{ padding:12px 30px; border-radius:999px; background:linear-gradient(135deg,var(--cyan),var(--blue)); color:#020617; font-weight:900; text-decoration:none; box-shadow:0 0 20px rgba(34,211,238,.45); transition:.2s; }
.back-btn:hover{ transform:translateY(-2px); box-shadow:0 0 32px rgba(34,211,238,.65); }
</style>
</head>

<body>

<div class="container">

  <div class="brand" style="justify-content:space-between;width:100%">
    <a href="dashboard.jsp" style="text-decoration:none; color:inherit;display:flex;align-items:center;gap:14px;">
      <div class="logo">
        <img src="images/quiz/codify.png" alt="CODIFY">
      </div>
      <div>
        <h2>CODIFY</h2>
        <span>Intelligence Dashboard</span>
      </div>
    </a>
    <a href="dashboard.jsp" class="back-btn">← Dashboard</a>
  </div>

  <div class="hero">
    <div>
      <h1>Your Intelligence,<br>Decoded.</h1>
      <p>
        CODIFY doesn’t show marks.  
        It reveals how you think, adapt, and grow under pressure.
      </p>
      <div class="tag">CODIFY · Intelligence Engine</div>
    </div>

    <div class="dna">
      <h2>Your Quiz DNA</h2>
      <p>A cognitive snapshot of your learning behaviour.</p>

      <div class="dna-metrics">
        <div class="metric"><strong><%= overallAccuracy %>%</strong><span>Accuracy</span></div>
        <div class="metric"><strong><%= totalChallenges %></strong><span>Challenges</span></div>
        <div class="metric"><strong><%= consistencyStreak %> 🔥</strong><span>Consistency</span></div>
        <div class="metric"><strong>#<%= (peakRank == 0 ? "N/A" : peakRank) %></strong><span>Estimated Rank</span></div>
      </div>
    </div>
  </div>

  <div class="path">
    <h2>Recent Cognitive Growth (Last 7 Attempts)</h2>
    <div class="path-track">
      <% 
      if(graphScores.size() == 0){
          out.println("<p style='color:gray'>No quiz data available yet.</p>");
      } else {
          for(int i = 0; i < graphScores.size(); i++) { 
            int s = graphScores.get(i);
            String d = graphDays.get(i);
            String cls = (s >= 80) ? "up" : (s >= 60 ? "mid" : "down");
      %>
          <div class="node">
            <strong class="<%= cls %>"><%= s %>%</strong>
            <span><%= d %></span>
          </div>
      <% 
          } 
      }
      %>
    </div>
  </div>

  <div class="radar">
    <div class="radar-card">
        <h3>Logic</h3>
        <div class="ring" style="--v:<%= logicScore %>"><span><%= logicScore %>%</span></div>
    </div>
    <div class="radar-card">
        <h3>Coding</h3>
        <div class="ring" style="--v:<%= codingScore %>"><span><%= codingScore %>%</span></div>
    </div>
    <div class="radar-card">
        <h3>Aptitude</h3>
        <div class="ring" style="--v:<%= aptitudeScore %>"><span><%= aptitudeScore %>%</span></div>
    </div>
    <div class="radar-card">
        <h3>Speed</h3>
        <div class="ring" style="--v:<%= speedScore %>"><span><%= speedScore %>%</span></div>
    </div>
  </div>

  <div class="features">
    <div class="feature"><h3>🧠 AI-Driven Insights</h3><p>Patterns extracted from every attempt.</p></div>
    <div class="feature"><h3>📊 Smart Analytics</h3><p>Understand strengths, not just scores.</p></div>
    <div class="feature"><h3>🔥 Consistency Engine</h3><p>Daily streaks reshape performance.</p></div>
  </div>

  <div class="story">
    <div class="story-card">
        <h3>🧠 How You Win</h3>
        <p>Your dominance is in <b><%= strongZone %></b>.</p>
    </div>
    <div class="story-card">
        <h3>⚠️ Weak Zone</h3>
        <p>Accuracy dips in <b><%= weakZone %></b> questions.</p>
    </div>
    <div class="story-card">
        <h3>🎯 Next Focus</h3>
        <p><%= nextFocus %> to unlock next tier.</p>
    </div>
  </div>

  <div class="final">
    <h2>Your Next Upgrade</h2>
    <p>Train <b><%= weakZone %></b> for 5 days to unlock next tier.</p>
    <span onclick="window.location.href='quizes.jsp'">Start Personalized Training →</span>
  </div>

</div>

</body>
</html>