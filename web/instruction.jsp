<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Get Mode from URL (default to debug if null)
    String mode = request.getParameter("mode");
    if(mode == null) mode = "debug";

    // Set Dynamic Title based on mode
    String title = "Quiz Instructions";
    if(mode.equals("debug")) title = "Debug Zone Protocols";
    else if(mode.equals("rapid")) title = "Rapid Fire Rules";
    else if(mode.equals("coding")) title = "Coding Arena Rules";
    else if(mode.equals("mind")) title = "Mind Matrix Protocols";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title><%= title %> | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
:root{
  --bg:#020617;
  --glass:rgba(255,255,255,.03);
  --border:rgba(255,255,255,.1);
  --cyan:#22d3ee;
  --violet:#8b5cf6;
  --green:#10b981;
  --text:#e5e7eb;
  --muted:#94a3b8;
  --danger:#ef4444;
  --warning:#f59e0b;
}

*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter,system-ui,sans-serif; }

body{
  min-height:100vh;
  background:
    radial-gradient(1200px at 10% 10%, rgba(139,92,246,.15), transparent 40%),
    radial-gradient(1000px at 90% 90%, rgba(34,211,238,.12), transparent 40%),
    var(--bg);
  color:var(--text);
  padding-bottom: 40px;
}

/* --- TOPBAR --- */
.topbar{
  height:70px;
  display:flex;
  align-items:center;
  justify-content:space-between;
  padding:0 40px;
  border-bottom:1px solid var(--border);
  backdrop-filter:blur(10px);
  position: sticky;
  top: 0;
  z-index: 10;
  background: rgba(2, 6, 23, 0.8);
}

.brand{ font-size:22px; font-weight:900; letter-spacing:2px; color: #fff; }
.brand span{ color: var(--cyan); }

.back-btn{
  padding:10px 24px;
  border-radius:12px;
  background:rgba(255,255,255,0.05);
  border: 1px solid var(--border);
  color:var(--text);
  text-decoration:none;
  font-size:14px;
  font-weight:600;
  transition:.3s;
}
.back-btn:hover{ background:rgba(255,255,255,0.1); border-color: var(--cyan); }

/* --- MAIN CONTAINER --- */
.main{
  max-width:1100px;
  margin:40px auto;
  padding:0 20px;
  animation: fadeIn 0.8s ease;
}

@keyframes fadeIn { from{opacity:0; transform:translateY(20px);} to{opacity:1; transform:translateY(0);} }

/* --- HEADER --- */
.header{
  margin-bottom:40px;
  text-align: center;
}
.header h1{
  font-size:36px;
  margin-bottom:10px;
  background:linear-gradient(90deg,var(--cyan),var(--violet));
  -webkit-background-clip:text; background-clip:text; color:transparent;
}
.header p{ color:var(--muted); font-size:16px; }

/* --- GRID SYSTEM --- */
.grid{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(250px,1fr));
  gap:24px;
  margin-bottom:30px;
}

/* --- CARDS --- */
.info-card{
  background: var(--glass);
  border:1px solid var(--border);
  border-radius:20px;
  padding:24px;
  transition: .3s;
}
.info-card:hover{ border-color: rgba(34,211,238,0.3); transform: translateY(-3px); }

.info-card h3{
  font-size:18px; margin-bottom:16px; color: #fff;
  display: flex; align-items: center; gap: 10px;
}
.info-card h3 svg { width: 20px; color: var(--cyan); }

.info-card ul{ list-style:none; }
.info-card li{
  font-size:14px; color:var(--muted); margin-bottom:10px;
  display: flex; align-items: start; gap: 8px;
}

/* Status Colors */
.status-good{ color: var(--green) !important; font-weight: 500; }
.status-warn{ color: var(--warning) !important; font-weight: 500; }

/* --- STRATEGY BOX --- */
.strategy{
  background: linear-gradient(180deg, rgba(34,211,238,0.05), transparent);
  border:1px solid var(--border);
  border-radius:20px;
  padding:30px;
  margin-bottom:40px;
}
.strategy h3{ color: var(--cyan); margin-bottom: 15px; font-size: 20px; }
.strategy li { margin-bottom: 8px; color: var(--text); }

/* --- CHECKBOX & BUTTON --- */
.action-area {
  background: var(--glass);
  border: 1px solid var(--border);
  padding: 30px;
  border-radius: 24px;
  text-align: center;
}

.agree-box{
  display:flex; justify-content: center; align-items:center; gap:12px;
  margin-bottom:24px; cursor: pointer;
}
.agree-box input { width: 18px; height: 18px; accent-color: var(--cyan); cursor: pointer;}
.agree-box label { font-size: 15px; color: var(--muted); cursor: pointer; user-select: none;}

.start-btn{
  padding:18px 60px;
  border-radius:99px;
  border:none;
  background: #1e293b;
  color: var(--muted);
  font-size:18px;
  font-weight:800;
  cursor:not-allowed;
  transition:.4s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: 1px;
}

.start-btn.active{
  background:linear-gradient(90deg,var(--cyan),var(--violet));
  color:#020617;
  cursor:pointer;
  box-shadow:0 0 30px rgba(34,211,238,.4);
  transform: scale(1.05);
}
.start-btn.active:hover { box-shadow:0 0 50px rgba(139,92,246,.6); }

/* --- MODAL --- */
.modal{
  position:fixed; inset:0;
  background:rgba(0,0,0,.8);
  backdrop-filter: blur(8px);
  display:none;
  align-items:center; justify-content:center;
  z-index: 100;
  opacity: 0; transition: opacity 0.3s;
}
.modal.show { opacity: 1; }

.modal-box{
  background:#0f172a;
  border:1px solid var(--cyan);
  border-radius:24px;
  padding:40px;
  width:400px;
  text-align:center;
  box-shadow: 0 0 50px rgba(34,211,238,0.15);
  transform: scale(0.9); transition: transform 0.3s;
}
.modal.show .modal-box { transform: scale(1); }

.modal-box h3{ font-size: 24px; margin-bottom: 10px; color: #fff; }
.modal-box p{ color: var(--muted); margin-bottom: 30px; }

.modal-btns button{
  padding:12px 30px; border-radius:12px; font-weight:700; cursor:pointer; border:none; transition: .2s;
}
.confirm{ background:var(--cyan); color:#020617; margin-right: 10px;}
.confirm:hover { background: #fff; }
.cancel{ background:transparent; border: 1px solid var(--border) !important; color:var(--muted); }
.cancel:hover { border-color: #fff !important; color: #fff; }

</style>
</head>

<body>

<div class="topbar">
  <div class="brand">COD<span>IFY</span></div>
  <a href="dashboard.jsp" class="back-btn">Exit</a>
</div>

<div class="main">

  <div class="header">
    <h1><%= title %></h1>
    <p>Review the protocol before initializing the sequence.</p>
  </div>

  <div class="grid">
    <div class="info-card">
      <h3>📋 Quiz Details</h3>
      <ul>
        <li>• Questions: <strong>20</strong></li>
        <li>• Time Limit: <strong>20 Mins</strong></li>
        <li>• Type: <strong>MCQ</strong></li>
        <li>• Difficulty: <strong>Adaptive</strong></li>
      </ul>
    </div>

    <div class="info-card">
      <h3>🎯 Marking Scheme</h3>
      <ul>
        <li><span class="status-good">+4</span> for Correct Answer</li>
        <li><span class="status-warn">-1</span> for Incorrect</li>
        <li><span>0</span> for Unanswered</li>
        <li>Instant Result Generation</li>
      </ul>
    </div>

    <div class="info-card">
      <h3>📡 System Status</h3>
      <ul>
        <li class="status-good">✔ Network Stable</li>
        <li class="status-good">✔ Database Connected</li>
        <li class="status-warn">⚠ Do Not Refresh</li>
        <li class="status-warn">⚠ Do Not Switch Tabs</li>
      </ul>
    </div>

    <div class="info-card">
      <h3>🧭 Navigation</h3>
      <ul>
        <li>• Use Next / Prev Buttons</li>
        <li>• Review Flag available</li>
        <li>• Auto-Submit on Timeout</li>
        <li>• One-time Submission</li>
      </ul>
    </div>
  </div>

  <div class="strategy">
    <h3>🚀 Optimization Strategy</h3>
    <ul>
      <li>1. Analyze the code snippet carefully before selecting an option.</li>
      <li>2. Skip complex debugging questions and return to them later.</li>
      <li>3. Maintain a pace of < 1 min per question.</li>
    </ul>
  </div>

  <div class="action-area">
    <div class="agree-box">
      <input type="checkbox" id="agree" onchange="toggleButton()">
      <label for="agree">I accept the rules and am ready to begin.</label>
    </div>

    <button id="startBtn" class="start-btn" onclick="openModal()">INITIALIZE QUIZ</button>
  </div>

</div>

<div class="modal" id="modal">
  <div class="modal-box">
    <h3>Start Assessment?</h3>
    <p>Timer will begin immediately. There is no pause button.</p>
    <div class="modal-btns">
      <button class="confirm" onclick="startQuiz()">YES, START</button>
      <button class="cancel" onclick="closeModal()">CANCEL</button>
    </div>
  </div>
</div>

<script>
  // Mode from JSP Logic
  const quizMode = "<%= mode %>";
  
  const btn = document.getElementById("startBtn");
  const checkbox = document.getElementById("agree");
  const modal = document.getElementById("modal");

  function toggleButton(){
    if(checkbox.checked){
      btn.disabled = false;
      btn.classList.add("active");
    }else{
      btn.disabled = true;
      btn.classList.remove("active");
    }
  }

  function openModal(){
    if(!btn.disabled){
        modal.style.display = "flex";
        setTimeout(() => modal.classList.add('show'), 10);
    }
  }

  function closeModal(){
    modal.classList.remove('show');
    setTimeout(() => modal.style.display = "none", 300);
  }

  function startQuiz(){
    // === ROUTING LOGIC ===
    const routes = {
      debug: "quiz.jsp?mode=debug",
      
      // ✅ LINK UPDATED HERE FOR RAPID FIRE:
      rapid: "time rapid.jsp", 
      
      coding: "arena.jsp",     
      mind: "mind-matrix.jsp"
    };

    if(routes[quizMode]){
      window.location.href = routes[quizMode];
    } else {
      // Default Fallback
      window.location.href = "quiz.jsp?mode=debug";
    }
  }
</script>

</body>
</html>