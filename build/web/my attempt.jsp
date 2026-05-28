<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    // --- DATABASE CONNECTION & DATA FETCHING ---
    String url = "jdbc:mysql://localhost:3306/codify_db";
    String user = "root";
    String pass = "root"; // Root password

    // Variables for Summary
    int totalAttempts = 0, avgAccuracy = 0, streak = 0, bestRank = 0;
    
    // List to hold Table Data
    List<Map<String, String>> historyList = new ArrayList<>();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, pass);

        // 1. Fetch Summary Stats
        ps = conn.prepareStatement("SELECT * FROM user_summary WHERE user_id = 1");
        rs = ps.executeQuery();
        if(rs.next()) {
            totalAttempts = rs.getInt("total_attempts");
            avgAccuracy = rs.getInt("avg_accuracy");
            streak = rs.getInt("current_streak");
            bestRank = rs.getInt("best_rank");
        }
        rs.close(); ps.close();

        // 2. Fetch Attempt History (Ordered by ID Descending to show latest first)
        ps = conn.prepareStatement("SELECT * FROM quiz_attempts WHERE user_id = 1 ORDER BY id DESC");
        rs = ps.executeQuery();
        while(rs.next()) {
            Map<String, String> row = new HashMap<>();
            row.put("quiz", rs.getString("quiz_name"));
            row.put("date", rs.getString("attempt_date"));
            row.put("score", rs.getInt("score_obtained") + " / " + rs.getInt("score_total"));
            row.put("time", rs.getString("time_taken"));
            row.put("status", rs.getString("status")); // PASS or FAIL
            historyList.add(row);
        }

    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(rs != null) try{rs.close();}catch(Exception e){}
        if(ps != null) try{ps.close();}catch(Exception e){}
        if(conn != null) try{conn.close();}catch(Exception e){}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Attempts History | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* --- SAME CSS AS PROVIDED --- */
:root{ --bg:#020617; --panel:#0f172a; --glass:rgba(255,255,255,.05); --border:#1e293b; --cyan:#22d3ee; --blue:#3b82f6; --green:#22c55e; --yellow:#facc15; --red:#ef4444; --text:#e5e7eb; --muted:#94a3b8; }
*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter,system-ui,sans-serif; }
body{ min-height:100vh; background: radial-gradient(1100px at 20% 10%, rgba(34,211,238,.12), transparent 40%), radial-gradient(900px at 80% 80%, rgba(59,130,246,.10), transparent 45%), linear-gradient(180deg,#020617,#020617); color:var(--text); }
.container{ max-width:1200px; margin:auto; padding:46px 24px; }
.header{ margin-bottom:34px; }
.header h1{ font-size:36px; font-weight:900; }
.header p{ color:var(--muted); margin-top:6px; }
.summary{ display:grid; grid-template-columns:repeat(4,1fr); gap:18px; margin-bottom:42px; }
.sum-card{ background:var(--glass); border:1px solid var(--border); border-radius:18px; padding:20px; text-align:center; }
.sum-card h3{ font-size:26px; }
.sum-card p{ font-size:12px; color:var(--muted); }
.table-wrap{ background:var(--glass); border:1px solid var(--border); border-radius:22px; overflow:hidden; }
table{ width:100%; border-collapse:collapse; }
thead{ background:rgba(255,255,255,.04); }
th, td{ padding:16px 18px; text-align:left; font-size:14px; }
th{ font-size:12px; color:var(--muted); text-transform:uppercase; letter-spacing:1px; }
tbody tr{ border-top:1px solid var(--border); transition:.2s ease; }
tbody tr:hover{ background:rgba(34,211,238,.08); }
.status{ font-weight:800; font-size:12px; }
.PASS{color:var(--green)} /* Updated class match */
.FAIL{color:var(--red)}   /* Updated class match */
.score{ font-weight:900; }
.view-btn{ padding:8px 18px; border-radius:999px; border:1px solid rgba(34,211,238,.45); background:transparent; color:var(--cyan); font-size:12px; font-weight:800; cursor:pointer; transition:.2s; }
.view-btn:hover{ background:rgba(34,211,238,.12); }
.note{ margin-top:26px; font-size:13px; color:var(--muted); text-align:center; }
.modal{ position:fixed; inset:0; background:rgba(2,6,23,.75); display:none; justify-content:center; align-items:center; z-index:999; }
.modal-box{ background:var(--panel); border:1px solid var(--border); border-radius:22px; padding:28px; width:360px; text-align:center; }
.modal-box h2{ font-size:22px; margin-bottom:14px; }
.modal-box p{ font-size:14px; color:var(--muted); margin:6px 0; }
.close-btn{ margin-top:20px; padding:10px 26px; border-radius:999px; border:none; background:var(--cyan); color:#020617; font-weight:900; cursor:pointer; }
.back-btn{ padding:12px 28px; border-radius:999px; background:linear-gradient(135deg,var(--cyan),var(--blue)); color:#020617; font-weight:900; text-decoration:none; box-shadow:0 0 18px rgba(34,211,238,.45); transition:.2s; }
.back-btn:hover{ transform:translateY(-2px); box-shadow:0 0 28px rgba(34,211,238,.65); }
</style>
</head>

<body>

<div class="container">

  <div class="header" style="display:flex;justify-content:space-between;align-items:center">
  <div>
    <h1>Attempts History</h1>
    <p>Track your quiz attempts, scores and progress</p>
  </div>
  <a href="dashboard.jsp" class="back-btn">← Dashboard</a>
</div>

  <div class="summary">
    <div class="sum-card">
      <h3><%= totalAttempts %></h3>
      <p>Total Attempts</p>
    </div>
    <div class="sum-card">
      <h3><%= avgAccuracy %>%</h3>
      <p>Average Accuracy</p>
    </div>
    <div class="sum-card">
      <h3><%= streak %> 🔥</h3>
      <p>Current Streak</p>
    </div>
    <div class="sum-card">
      <h3>#<%= bestRank %></h3>
      <p>Best Rank</p>
    </div>
  </div>

  <div class="table-wrap">
    <table>
      <thead>
        <tr>
          <th>Quiz Name</th>
          <th>Date</th>
          <th>Score</th>
          <th>Time Taken</th>
          <th>Status</th>
          <th>Result</th>
        </tr>
      </thead>
      <tbody>
        <% 
           for(Map<String, String> row : historyList) { 
             // We use the exact string from DB ('PASS' or 'FAIL') for CSS class
             String statusClass = row.get("status"); 
        %>
        <tr>
          <td><%= row.get("quiz") %></td>
          <td><%= row.get("date") %></td>
          <td class="score"><%= row.get("score") %></td>
          <td><%= row.get("time") %></td>
          <td class="status <%= statusClass %>"><%= statusClass %></td>
          <td>
            <button class="view-btn" onclick="openResult('<%= row.get("quiz") %>','<%= row.get("score") %>','<%= row.get("time") %>','<%= statusClass %>')">
                View
            </button>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>

  <div class="note">
    Showing your recent quiz attempts. Older attempts are archived automatically.
  </div>

</div>

<div class="modal" id="modal">
  <div class="modal-box">
    <h2 id="mQuiz"></h2>
    <p><strong>Score:</strong> <span id="mScore"></span></p>
    <p><strong>Time:</strong> <span id="mTime"></span></p>
    <p><strong>Status:</strong> <span id="mStatus"></span></p>
    <button class="close-btn" onclick="closeModal()">Close</button>
  </div>
</div>

<script>
function openResult(quiz,score,time,status){
  document.getElementById("mQuiz").innerText = quiz;
  document.getElementById("mScore").innerText = score;
  document.getElementById("mTime").innerText = time;
  document.getElementById("mStatus").innerText = status;
  
  // Dynamic color for modal status
  const statElem = document.getElementById("mStatus");
  if(status === 'PASS') statElem.style.color = 'var(--green)';
  else statElem.style.color = 'var(--red)';

  document.getElementById("modal").style.display = "flex";
}

function closeModal(){
  document.getElementById("modal").style.display = "none";
}
</script>

</body>
</html>