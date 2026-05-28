<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Leaderboard | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* CSS तसाच ठेवला आहे */
:root{ --bg:#020617; --panel:#0b1228; --border:#1e293b; --cyan:#22d3ee; --blue:#3b82f6; --green:#22c55e; --text:#e5e7eb; --muted:#94a3b8; }
*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter,system-ui,sans-serif; }
body{ min-height:100vh; background: radial-gradient(1200px at 15% 10%, rgba(59,130,246,.18), transparent 40%), radial-gradient(1000px at 85% 80%, rgba(34,211,238,.18), transparent 45%), var(--bg); color:var(--text); }
.container{ max-width:900px; margin:auto; padding:50px 22px 100px; }
.header{ display:flex; justify-content:space-between; align-items:center; margin-bottom:28px; }
.header h1{ font-size:42px; font-weight:900; }
.back{ padding:12px 30px; border-radius:999px; background:linear-gradient(135deg,var(--cyan),var(--blue)); color:#020617; text-decoration:none; font-weight:900; }
.controls{ display:flex; gap:14px; margin-bottom:30px; }
.controls button{ padding:10px 26px; border-radius:999px; border:1px solid var(--border); background:rgba(255,255,255,.04); color:var(--text); cursor:pointer; transition:.25s ease; }
.controls button.active{ background:linear-gradient(135deg,var(--cyan),var(--blue)); color:#020617; font-weight:900; box-shadow:0 0 20px rgba(34,211,238,.45); }
.list{ display:flex; flex-direction:column; gap:16px; }
.row{ background:linear-gradient(135deg,rgba(255,255,255,.06),rgba(255,255,255,.02)); border:1px solid var(--border); border-radius:22px; padding:18px 24px; display:grid; grid-template-columns:60px 1fr 120px; align-items:center; transition:.25s ease; }
.row:hover{ transform:translateY(-3px); box-shadow:0 0 24px rgba(34,211,238,.25); }
.row.you{ background:linear-gradient(135deg,rgba(34,211,238,.25),rgba(59,130,246,.25)); border-color:var(--cyan); font-weight:900; }
.rank{ width:44px; height:44px; border-radius:50%; background:linear-gradient(135deg,var(--cyan),var(--blue)); color:#020617; display:flex; align-items:center; justify-content:center; font-weight:900; }
.user strong{ font-size:17px; }
.user span{ font-size:13px; color:var(--muted); }
.score{ text-align:right; font-weight:900; }
.state{ text-align:center; padding:50px; color:var(--muted); display:none; }
.state.show{ display:block; }
</style>
</head>

<body>

<div class="container">

  <div class="header">
    <h1>&#127942; Leaderboard</h1>
    <a href="dashboard.jsp" class="back">&#8592; Dashboard</a>
  </div>

  <div class="controls">
    <button class="active" onclick="loadData('all', this)">All Time</button>
    <button onclick="loadData('weekly', this)">Weekly</button>
    <button onclick="loadData('daily', this)">Daily</button>
  </div>

  <div class="state show" id="loading">Loading leaderboard...</div>
  <div class="state" id="empty">No data available</div>

  <div class="list" id="list"></div>

</div>

<script>
function loadData(type, btn){
  document.querySelectorAll(".controls button").forEach(b => b.classList.remove("active"));
  if(btn) btn.classList.add("active");

  const list = document.getElementById("list");
  const loading = document.getElementById("loading");
  const empty = document.getElementById("empty");

  list.innerHTML = "";
  empty.classList.remove("show");
  loading.classList.add("show");

  // Fetching data from data.jsp
  fetch('data.jsp?type=' + type)
    .then(response => {
        if (!response.ok) throw new Error("Network response was not ok");
        return response.json();
    })
    .then(data => {
        loading.classList.remove("show");

        if(!data || data.length === 0){
            empty.classList.add("show");
            return;
        }

        data.forEach((u, i) => {
            const row = document.createElement("div");
            row.className = "row" + (u.isYou ? " you" : "");
            
            row.innerHTML = `
                <div class="rank">${i+1}</div>
                <div class="user">
                  <strong>${u.user}</strong><br>
                  <span>Rank #${i+1}</span>
                </div>
                <div class="score">${u.score}</div>
            `;
            list.appendChild(row);
        });
    })
    .catch(error => {
        console.error('Error fetching data:', error);
        loading.innerHTML = "Error loading data.";
    });
}

// INITIAL LOAD
loadData('all', document.querySelector(".controls button"));
</script>

</body>
</html>