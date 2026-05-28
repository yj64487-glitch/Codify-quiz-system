<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- 1. DATABASE CONFIGURATION ---
    String url = "jdbc:mysql://localhost:3306/codify_db";
    String user = "root";
    String pwd = "root"; // <--- तुझा पासवर्ड चेक कर

    StringBuilder jsData = new StringBuilder("[");
    String dbErrorMsg = ""; 

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(url, user, pwd);
        Statement stmt = con.createStatement();
        
        // Fetch Questions
        ResultSet rs = stmt.executeQuery("SELECT * FROM coding_challenges WHERE status='Active'");
        
        boolean first = true;
        while(rs.next()) {
            if(!first) jsData.append(",");
            
            // --- DATA FETCHING & STRICT ESCAPING ---
            String title = rs.getString("title");
            if(title == null) title = "";
            title = title.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"");

            String desc = rs.getString("problem");
            if(desc == null) desc = "";
            desc = desc.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
            
            // --- SAFE COLUMN FETCHING (Errors Ignore करण्यासाठी) ---
            
            // 1. Template Code (कॉलम नसेल तर डिफॉल्ट व्हॅल्यू घेईल)
            String tCode = "// Write your solution here...";
            try {
                String temp = rs.getString("template_code");
                if(temp != null && !temp.isEmpty()) tCode = temp;
            } catch(SQLException ignore) {} // कॉलम नाही सापडला तरी कोड पुढे जाईल
            
            // 2. Validation Logic & Test Cases
            String vLogic = "return false;"; 
            try {
                String dbLogic = rs.getString("validation_logic");
                if(dbLogic != null && !dbLogic.trim().isEmpty()) {
                    vLogic = dbLogic; 
                } else {
                    String expected = null;
                    try { expected = rs.getString("test_cases"); } catch(SQLException ignore) {}
                    
                    if(expected == null) {
                        try { expected = rs.getString("output"); } catch(SQLException ignore) {}
                    }
                    
                    if(expected != null && !expected.trim().isEmpty()) {
                        String cleanExpected = expected.replace("'", "\\'").replace("\n", "").replace("\r", "");
                        vLogic = "return code.includes('" + cleanExpected + "');";
                    }
                }
            } catch(SQLException ignore) {} // कॉलम नाही सापडला तरी कोड पुढे जाईल
            
            jsData.append("{");
            jsData.append("t: '").append(title).append("',");
            jsData.append("d: '").append(desc).append("',");
            jsData.append("c: `").append(tCode.replace("`", "\\`").replace("\\", "\\\\")).append("`,");
            jsData.append("validate: function(code) { ").append(vLogic).append(" }");
            jsData.append("}");
            first = false;
        }
        con.close();
    } catch(Exception e) {
        dbErrorMsg = e.getMessage(); 
        e.printStackTrace();
    }
    jsData.append("]");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Coding Arena | Elite Mode</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Orbitron:wght@600;900&family=Inter:wght@300;600&display=swap" rel="stylesheet">

<style>
/* --- ELITE DESIGN --- */
:root{ --bg: #020617; --cyan: #22d3ee; --violet: #8b5cf6; --pink: #f472b6; --green: #10b981; --red: #ef4444; --border: rgba(34, 211, 238, 0.2); --text: #e5e7eb; --muted: #94a3b8; }
*{margin:0;padding:0;box-sizing:border-box}
body{ height:100vh; background: var(--bg); color:var(--text); font-family:Inter,sans-serif; overflow:hidden; perspective: 1000px; }
body::before { content: ""; position: absolute; inset: -50%; width: 200%; height: 200%; background: radial-gradient(circle at 50% 50%, rgba(139, 92, 246, 0.1), transparent 60%), linear-gradient(rgba(34, 211, 238, 0.05) 1px, transparent 1px), linear-gradient(90deg, rgba(34, 211, 238, 0.05) 1px, transparent 1px); background-size: 100% 100%, 40px 40px, 40px 40px; transform: perspective(500px) rotateX(60deg); animation: planeMove 20s linear infinite; z-index: -1; }
@keyframes planeMove { 0% { transform: perspective(500px) rotateX(60deg) translateY(0); } 100% { transform: perspective(500px) rotateX(60deg) translateY(40px); } }
.arena{ height:100%; display:grid; grid-template-columns: 35% 65%; opacity: 0; animation: fadeIn 1s ease-out forwards; }
@keyframes fadeIn { to{opacity:1} }
.problem{ padding:40px; border-right:1px solid var(--border); position: relative; display: flex; flex-direction: column; background: rgba(2, 6, 23, 0.6); backdrop-filter: blur(10px); transition: transform 0.4s ease, opacity 0.4s ease; }
.slide-in { opacity: 0; transform: translateX(50px); animation: slideEnter 0.5s forwards; }
@keyframes slideEnter { to { opacity: 1; transform: translateX(0); } }
.brand{ font-family: Orbitron, sans-serif; font-size: 24px; letter-spacing: 4px; background: linear-gradient(90deg, var(--cyan), var(--violet)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin-bottom: 10px; text-shadow: 0 0 20px rgba(34, 211, 238, 0.3); }
.mode{ font-size:12px; color:var(--cyan); font-family: 'JetBrains Mono'; margin-bottom: 20px; padding: 4px 8px; border: 1px solid var(--border); display: inline-block; border-radius: 4px; width: fit-content; }
.problem h2{ font-size:28px; margin-bottom: 20px; color: #fff; font-family: Orbitron; text-shadow: 0 5px 15px rgba(0,0,0,0.5); }
.problem p{ color:var(--muted); line-height:1.7; margin-bottom: 25px; font-size: 15px; flex-grow: 1; }
pre{ background: #0d1117; border-left:4px solid var(--violet); padding:20px; border-radius:8px; font-family:JetBrains Mono; font-size:13px; color:#a5f3fc; box-shadow: inset 0 0 20px rgba(0,0,0,0.5); overflow-x: auto; }
.editor{ padding:36px; display:flex; flex-direction:column; background: rgba(2, 6, 23, 0.4); }
.top{ display:flex; justify-content:space-between; margin-bottom:16px; align-items: center; }
.timer{ padding:8px 16px; border-radius:4px; border:1px solid var(--cyan); color:var(--cyan); font-family:JetBrains Mono; font-weight: bold; background: rgba(34, 211, 238, 0.1); box-shadow: 0 0 10px rgba(34, 211, 238, 0.2); }
.code-wrapper { position: relative; flex: 1; border: 1px solid var(--border); border-radius: 12px; background: #020617; overflow: hidden; box-shadow: 0 0 30px rgba(0,0,0,0.3); transition: border-color 0.3s; }
.code-wrapper.success { border-color: var(--green); box-shadow: 0 0 30px rgba(16, 185, 129, 0.3); }
.code-wrapper.fail { border-color: var(--red); box-shadow: 0 0 30px rgba(239, 68, 68, 0.3); }
.scanline { position: absolute; top: 0; left: 0; width: 100%; height: 2px; background: var(--cyan); opacity: 0.6; animation: scan 3s linear infinite; z-index: 5; pointer-events: none; box-shadow: 0 0 15px var(--cyan); }
@keyframes scan { 0% { top: 0%; opacity: 0; } 100% { top: 100%; opacity: 0; } }
textarea{ width: 100%; height: 100%; resize:none; background:transparent; border:none; padding:24px; font-family:'JetBrains Mono', monospace; font-size:14px; color:var(--text); outline:none; line-height: 1.6; caret-color: var(--cyan); position: relative; z-index: 2; }
.nav{ display:flex; justify-content:flex-end; gap: 16px; margin-top:20px; }
button{ padding:14px 28px; border-radius:8px; border:1px solid rgba(34, 211, 238, 0.3); font-family: Orbitron; font-size: 12px; letter-spacing: 1px; cursor:pointer; background: rgba(34, 211, 238, 0.05); color: var(--cyan); transition: all 0.3s; min-width: 130px; }
button:hover:not(:disabled) { background: var(--cyan); color: #000; box-shadow: 0 0 20px rgba(34, 211, 238, 0.4); transform: translateY(-2px); }
button:disabled { opacity: 0.3; cursor: not-allowed; border-color: #333; color: #555; box-shadow: none; }
.toast { position: fixed; top: 30px; right: 30px; padding: 16px 24px; border-radius: 6px; font-family: 'JetBrains Mono'; font-size: 13px; color: #fff; transform: translateX(200%); transition: transform 0.4s cubic-bezier(0.18, 0.89, 0.32, 1.28); z-index: 9999; display: flex; align-items: center; gap: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
.toast.success { background: rgba(6, 78, 59, 0.95); border: 1px solid var(--green); }
.toast.error { background: rgba(127, 29, 29, 0.95); border: 1px solid var(--red); }
.toast.show { transform: translateX(0); }
.result{ position:absolute; inset:0; display:none; align-items:center; justify-content:center; background: rgba(2,6,23,0.95); z-index: 100; backdrop-filter: blur(10px); }
.card{ text-align:center; background: rgba(15, 23, 42, 0.8); padding: 60px; border-radius: 20px; border: 1px solid var(--border); box-shadow: 0 0 50px rgba(34, 211, 238, 0.1); animation: zoomIn 0.6s cubic-bezier(0.18, 0.89, 0.32, 1.28); position: relative; overflow: hidden; max-width: 600px; width: 90%; }
@keyframes zoomIn { from{transform:scale(0.8);opacity:0} to{transform:scale(1);opacity:1} }
.ring{ font-size: 80px; font-family: Orbitron; font-weight: 900; color: var(--cyan); margin: 30px 0; text-shadow: 0 0 30px var(--cyan); }
.rank-badge { font-family: Orbitron; font-size: 24px; margin-top: 10px; letter-spacing: 2px; }
.dashboard-btn { margin-top: 40px; background: transparent; border: 1px solid var(--violet); color: var(--violet); width: 100%; padding: 18px; }
.dashboard-btn:hover { background: var(--violet); color: #fff; box-shadow: 0 0 25px rgba(139, 92, 246, 0.4); }
.particles span { position: absolute; width: 4px; height: 4px; background: var(--cyan); border-radius: 50%; animation: floatUp 3s linear infinite; }
@keyframes floatUp { 0% { transform: translateY(100%) scale(0); opacity:0;} 50% { opacity: 1; } 100% { transform: translateY(-100px) scale(1); opacity:0;} }
</style>
</head>
<body>

<div id="toast" class="toast">
  <span id="toastIcon"></span>
  <span id="toastMsg"></span>
</div>

<div class="arena" id="arena">
  <div class="problem" id="problemPanel">
    <div class="brand">CODING ARENA</div>
    <div class="mode" id="step">LOADING...</div>
    
    <h2 id="qTitle"></h2>
    <p id="qDesc"></p>
    <pre id="qCode"></pre>
  </div>

  <div class="editor">
    <div class="top">
      <div style="font-family: JetBrains Mono; font-size: 12px; color: var(--muted); display:flex; align-items:center; gap:8px">
        <span style="width:8px; height:8px; background:var(--green); border-radius:50%; box-shadow:0 0 8px var(--green)"></span>
        SYSTEM ONLINE
      </div>
      <div class="timer" id="timer">15:00</div>
    </div>

    <div class="code-wrapper" id="codeWrapper">
      <div class="scanline"></div>
      <textarea id="code" spellcheck="false"></textarea>
    </div>

    <div class="nav">
      <button id="btnPrev" onclick="prev()">PREVIOUS</button>
      <button id="btnNext" onclick="next()">RUN TESTS & NEXT</button>
    </div>
  </div>
</div>

<div class="result" id="result">
  <div class="card">
    <div class="particles" id="particles"></div>
    <h1 style="color:white; font-family: Orbitron; letter-spacing:2px">ASSESSMENT REPORT</h1>
    
    <div class="ring" id="finalScore">0%</div>
    <div class="rank-badge" id="rank">CALCULATING...</div>
    
    <p style="color:var(--muted); margin-top:15px" id="correctCount">Correct Answers: 0/0</p>

    <button class="dashboard-btn" onclick="goToDashboard()">
      <span style="margin-right:10px">←</span> RETURN TO DASHBOARD
    </button>
  </div>
</div>

<script>
// --- DATABASE ERROR CHECK ---
const dbError = "<%= dbErrorMsg != null ? dbErrorMsg.replace("\"", "\\\"").replace("\n", " ") : "" %>";
if(dbError !== "") {
    alert("Connection Failed: \n" + dbError);
    console.error("DB Error Details:", dbError);
}

// --- INJECT DATA FROM DB ---
const questions = <%= jsData.toString() %>;

// --- STATE ---
let index = 0;
let userAnswers = new Array(questions.length).fill(null);
let correctCount = 0;
const codeArea = document.getElementById('code');
const btnPrev = document.getElementById('btnPrev');
const btnNext = document.getElementById('btnNext');
const problemPanel = document.getElementById('problemPanel');

// --- INIT ---
function load(){
  if(questions.length === 0) {
      document.getElementById('qTitle').textContent = dbError !== "" ? "Connection Error" : "No Data Found";
      document.getElementById('qDesc').textContent = dbError !== "" ? "Check MySQL connection." : "Please add active questions in Admin Panel.";
      return;
  }

  // Animation Reset
  problemPanel.classList.remove('slide-in');
  void problemPanel.offsetWidth; 
  problemPanel.classList.add('slide-in');

  // Text Update
  document.getElementById('step').textContent = `QUESTION ${index+1} / ${questions.length}`;
  document.getElementById('qTitle').textContent = questions[index].t;
  document.getElementById('qDesc').textContent = questions[index].d;
  
  // Show Template Code
  document.getElementById('qCode').textContent = questions[index].c; 
  
  // Load previous answer OR template code
  if(userAnswers[index]) {
      codeArea.value = userAnswers[index];
  } else {
      codeArea.value = questions[index].c;
  }
  
  // Button State
  btnPrev.disabled = (index === 0);
  btnNext.textContent = (index === questions.length - 1) ? "SUBMIT ASSESSMENT" : "RUN TESTS & NEXT";
  
  // Color logic
  btnNext.style.borderColor = (index === questions.length - 1) ? "var(--pink)" : "var(--cyan)";
  btnNext.style.color = (index === questions.length - 1) ? "var(--pink)" : "var(--cyan)";
}

load();

// --- NOTIFICATIONS ---
function showToast(type, msg) {
  const t = document.getElementById('toast');
  const i = document.getElementById('toastIcon');
  const m = document.getElementById('toastMsg');
  
  t.className = `toast ${type} show`;
  i.textContent = type === 'success' ? '✔' : '✖';
  m.textContent = msg;
  
  setTimeout(() => t.classList.remove('show'), 2500);
}

// --- NAVIGATION & GRADING ---
function next(){
  if(questions.length === 0) return;

  const currentCode = codeArea.value;
  userAnswers[index] = currentCode;

  // Execute Validation Logic
  let isCorrect = false;
  try {
      isCorrect = questions[index].validate(currentCode);
  } catch(e) {
      console.error("Validation Logic Error:", e);
  }
  
  const wrapper = document.getElementById('codeWrapper');
  
  if(isCorrect) {
    showToast('success', 'TEST PASSED: Output Matches');
    wrapper.classList.add('success');
  } else {
    showToast('error', 'TEST FAILED: Incorrect Output');
    wrapper.classList.add('fail');
  }

  setTimeout(() => {
    wrapper.classList.remove('success', 'fail');
    if(index < questions.length - 1){
      index++;
      load();
    } else {
      finish();
    }
  }, 1000);
}

function prev(){
  if(index > 0){
    userAnswers[index] = codeArea.value; 
    index--;
    load();
  }
}

// --- RESULTS ---
function calculateScore() {
  let score = 0;
  questions.forEach((q, i) => {
    try {
        if (userAnswers[i] && q.validate(userAnswers[i])) score++;
    } catch(e){}
  });
  return score;
}

function finish(){
  document.getElementById('arena').style.display = 'none';
  document.getElementById('result').style.display = 'flex';
  
  const pContainer = document.getElementById('particles');
  pContainer.innerHTML = '';
  for(let i=0; i<20; i++){
    let p = document.createElement('span');
    p.style.left = Math.random()*100 + "%";
    p.style.animationDelay = Math.random()*2 + "s";
    pContainer.appendChild(p);
  }

  correctCount = calculateScore();
  let percentage = 0;
  if (questions.length > 0) percentage = Math.round((correctCount / questions.length) * 100);

  let current = 0;
  const scoreElem = document.getElementById('finalScore');
  const rankElem = document.getElementById('rank');
  document.getElementById('correctCount').textContent = `Correct Answers: ${correctCount} / ${questions.length}`;

  const tick = setInterval(() => {
    if(percentage === 0) {
        scoreElem.textContent = "0%";
        scoreElem.style.color = "var(--red)";
        rankElem.textContent = "RANK: TRAINEE"; 
        rankElem.style.color = "var(--red)";
        clearInterval(tick);
        return;
    }

    if(current < percentage) current++;
    scoreElem.textContent = current + "%";
    
    if(current < 50) scoreElem.style.color = "var(--red)";
    else if(current < 80) scoreElem.style.color = "var(--cyan)";
    else scoreElem.style.color = "var(--green)";

    if(current >= percentage) {
      clearInterval(tick);
      if(percentage === 100) { rankElem.textContent = "RANK: GODLIKE"; rankElem.style.color = "var(--green)"; }
      else if(percentage >= 80) { rankElem.textContent = "RANK: SENIOR DEV"; rankElem.style.color = "var(--cyan)"; }
      else if(percentage >= 50) { rankElem.textContent = "RANK: JUNIOR DEV"; rankElem.style.color = "var(--violet)"; }
      else { rankElem.textContent = "RANK: TRAINEE"; rankElem.style.color = "var(--red)"; }
    }
  }, 30);
}

function goToDashboard() {
  const btn = document.querySelector('.dashboard-btn');
  btn.innerHTML = '<span style="margin-right:10px">⌛</span> REDIRECTING...';
  btn.style.opacity = "0.7";
  btn.style.cursor = "wait";
  setTimeout(() => {
    window.location.href = "dashboard.jsp"; // तुझी डॅशबोर्ड फाईल
  }, 800);
}

// Global Timer
let time = 900;
let timerInterval = setInterval(() => {
  if(document.getElementById('arena').style.display === 'none') {
      clearInterval(timerInterval);
      return;
  }
  time--;
  const m = String(Math.floor(time/60)).padStart(2,'0');
  const s = String(time%60).padStart(2,'0');
  document.getElementById('timer').textContent = `${m}:${s}`;
  if(time<=0) finish();
}, 1000);
</script>
</body>
</html>