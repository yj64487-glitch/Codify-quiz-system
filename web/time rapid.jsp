<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- DATABASE CONFIGURATION ---
    String url = "jdbc:mysql://localhost:3306/codify_db";
    String user = "root";
    String pwd = "root"; // <--- PASSWORD CHECK KAR

    StringBuilder jsData = new StringBuilder("[");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(url, user, pwd);
        Statement stmt = con.createStatement();
        
        // --- LOGIC FIX: ONLY FETCH FROM MCQ TABLE ---
        // 'coding_challenges' table la touch pan nahi kelay, so coding question yenaracha nahi.
        // Random 15 questions ghetoy rapid fire sathi.
     String sql = "SELECT * FROM mcq_questions WHERE status='Active' AND category != 'coding' ORDER BY RAND() LIMIT 20";
        ResultSet rs = stmt.executeQuery(sql);
        
        boolean first = true;
        while(rs.next()) {
            if(!first) jsData.append(",");
            
            String title = rs.getString("title").replace("'", "\\'").replace("\"", "\\\"");
            String optA = rs.getString("opt_a").replace("'", "\\'");
            String optB = rs.getString("opt_b").replace("'", "\\'");
            String optC = rs.getString("opt_c").replace("'", "\\'");
            String optD = rs.getString("opt_d").replace("'", "\\'");
            
            // Correct Answer Logic (A->0, B->1...)
            String cStr = rs.getString("correct");
            int cIdx = 0;
            if(cStr != null && !cStr.isEmpty()) {
                char c = Character.toUpperCase(cStr.charAt(0));
                if(c == 'B') cIdx = 1; else if(c == 'C') cIdx = 2; else if(c == 'D') cIdx = 3;
            }

            jsData.append("{");
            jsData.append("q: '").append(title).append("',");
            jsData.append("opts: ['").append(optA).append("','").append(optB).append("','").append(optC).append("','").append(optD).append("'],");
            jsData.append("a: ").append(cIdx);
            jsData.append("}");
            first = false;
        }
        con.close();
    } catch(Exception e) { e.printStackTrace(); }
    jsData.append("]");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Rapid Fire Quiz</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700&display=swap" rel="stylesheet">

<style>
/* --- SCREENSHOT DESIGN (Clean Dark Theme) --- */
:root{
  --bg-dark: #0B0C15;
  --card-bg: rgba(21, 27, 43, 0.85);
  --primary-grad: linear-gradient(135deg, #0ea5e9, #10b981);
  --border: rgba(255, 255, 255, 0.08);
  --text: #ffffff;
  --text-muted: #94a3b8;
  --success: #10b981;
  --error: #ef4444;
}

*{ box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', sans-serif; }

body {
  min-height: 100vh;
  background: 
    radial-gradient(900px at 20% 10%, rgba(14,165,233,0.1), transparent 40%),
    radial-gradient(800px at 80% 90%, rgba(16,185,129,0.1), transparent 40%),
    var(--bg-dark);
  color: var(--text);
  display: flex; flex-direction: column;
}

/* NAV */
nav { padding: 25px 50px; }
.brand {
  font-weight: 800; font-size: 1.5rem;
  background: var(--primary-grad); -webkit-background-clip: text; color: transparent;
}

/* CONTAINER */
.container { flex: 1; display: grid; place-items: center; padding: 20px; }

/* CARD */
.quiz-card {
  width: 100%; max-width: 750px;
  background: var(--card-bg);
  backdrop-filter: blur(20px);
  border: 1px solid var(--border);
  border-radius: 24px;
  padding: 50px;
  box-shadow: 0 40px 80px rgba(0,0,0,0.5);
  position: relative; overflow: hidden;
}

/* HEADER INFO */
.info-row { display: flex; justify-content: space-between; color: var(--text-muted); font-weight: 600; font-size: 0.9rem; margin-bottom: 15px; }
.progress-track { width: 100%; height: 4px; background: rgba(255,255,255,0.05); border-radius: 4px; overflow: hidden; }
.progress-fill { height: 100%; background: var(--primary-grad); width: 100%; transition: width 1s linear; }

/* QUESTION */
h2 { font-size: 1.8rem; margin: 40px 0; line-height: 1.4; }

/* OPTIONS GRID */
.options-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }

.option-btn {
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border);
  padding: 20px 25px; border-radius: 12px;
  color: var(--text-muted); font-size: 1rem; font-weight: 500;
  cursor: pointer; transition: 0.2s;
  text-align: left;
}

.option-btn:hover { border-color: #0ea5e9; color: white; background: rgba(255,255,255,0.05); }
.option-btn.correct { border-color: var(--success); background: rgba(16, 185, 129, 0.15); color: white; }
.option-btn.wrong { border-color: var(--error); background: rgba(239, 68, 68, 0.15); color: white; opacity: 0.6; }

/* BOTTOM NAV */
.footer { margin-top: 40px; display: flex; justify-content: space-between; align-items: center; }
.nav-btn {
  padding: 12px 30px; border-radius: 50px;
  background: transparent; border: 1px solid var(--border);
  color: white; cursor: pointer; transition: 0.2s;
}
.nav-btn:hover { background: rgba(255,255,255,0.1); }
.nav-btn.next { border-color: #0ea5e9; }

/* RESULT SCREEN */
.result-view { display: none; text-align: center; flex-direction: column; align-items: center; animation: fadeUp 0.5s ease; }
@keyframes fadeUp { from{opacity:0;transform:translateY(20px)} to{opacity:1} }

.score-circle {
  width: 140px; height: 140px; border-radius: 50%;
  border: 4px solid #0ea5e9;
  display: flex; align-items: center; justify-content: center;
  font-size: 2.5rem; font-weight: 700; margin-bottom: 20px;
  box-shadow: 0 0 30px rgba(14,165,233,0.2);
}

.stats { display: flex; gap: 40px; margin-top: 30px; color: var(--text-muted); }
.stats b { display: block; color: white; font-size: 1.2rem; margin-top: 5px; }

.primary-btn {
  margin-top: 40px; padding: 15px 40px; border-radius: 50px; border: none;
  background: var(--primary-grad); color: white; font-weight: 600; cursor: pointer;
}
</style>
</head>
<body>

<nav><div class="brand">CODIFY</div></nav>

<div class="container">
  <div class="quiz-card">
    
    <div id="quizView">
      <div class="info-row">
        <span>Time Rapid Fire</span>
        <span id="timer">02:00</span>
      </div>
      <div class="progress-track"><div class="progress-fill" id="timeBar"></div></div>

      <h2 id="qText">Loading Question...</h2>

      <div class="options-grid" id="optContainer">
        </div>

      <div class="footer">
        <button class="nav-btn" onclick="prev()" id="prevBtn" disabled>Previous</button>
        <button class="nav-btn next" onclick="next()" id="nextBtn">Next</button>
      </div>
    </div>

    <div class="result-view" id="resultView">
      <div class="score-circle" id="finalScore">0</div>
      <h1>Quiz Complete</h1>
      
      <div class="stats">
        <div>Accuracy <b id="accVal">0%</b></div>
        <div>Time Left <b id="timeLeftVal">0s</b></div>
      </div>

      <button class="primary-btn" onclick="window.location.href='dashboard.jsp'">Back to Dashboard</button>
    </div>

  </div>
</div>

<script>
// --- 1. INJECT DB DATA ---
const questions = <%= jsData.toString() %>;

// --- STATE ---
let index = 0;
let score = 0;
let selected = false;
let totalTime = 120; // 2 Minutes
let timeLeft = totalTime;
let timerInterval;

const qEl = document.getElementById("qText");
const oEl = document.getElementById("optContainer");
const timerEl = document.getElementById("timer");
const barEl = document.getElementById("timeBar");

// --- INIT ---
function load(){
  if(questions.length === 0) {
      qEl.textContent = "No Rapid Fire questions found.";
      oEl.innerHTML = "<div style='color:#94a3b8'>Please ask Admin to add MCQs.</div>";
      return;
  }

  // Start Timer only once
  if(!timerInterval) timerInterval = setInterval(tick, 1000);

  selected = false;
  qEl.textContent = questions[index].q;
  oEl.innerHTML = "";
  
  // Update Buttons
  document.getElementById("prevBtn").disabled = (index === 0);
  document.getElementById("nextBtn").innerText = (index === questions.length - 1) ? "Submit" : "Next";

  questions[index].opts.forEach((text, i) => {
      const btn = document.createElement("div");
      btn.className = "option-btn";
      btn.textContent = text;
      btn.onclick = () => checkAnswer(btn, i);
      oEl.appendChild(btn);
  });
}

function tick() {
    if(timeLeft <= 0) {
        finish();
        return;
    }
    timeLeft--;
    const m = String(Math.floor(timeLeft/60)).padStart(2, '0');
    const s = String(timeLeft%60).padStart(2, '0');
    timerEl.textContent = `${m}:${s}`;
    barEl.style.width = (timeLeft/totalTime*100) + "%";
}

// --- LOGIC ---
function checkAnswer(btn, i) {
    if(selected) return;
    selected = true;
    
    const correctIndex = questions[index].a;
    const allOptions = oEl.children;

    if(i === correctIndex) {
        btn.classList.add("correct");
        score++;
    } else {
        btn.classList.add("wrong");
        timeLeft = Math.max(0, timeLeft - 10); // Penalty
        allOptions[correctIndex].classList.add("correct");
    }
}

function next() {
    if(index < questions.length - 1) {
        index++;
        load();
    } else {
        finish();
    }
}

function prev() {
    if(index > 0) {
        index--;
        load();
    }
}

function finish() {
    clearInterval(timerInterval);
    document.getElementById("quizView").style.display = "none";
    document.getElementById("resultView").style.display = "flex";
    
    document.getElementById("finalScore").textContent = score;
    const acc = Math.round((score / questions.length) * 100);
    document.getElementById("accVal").textContent = acc + "%";
    document.getElementById("timeLeftVal").textContent = timeLeft + "s";
}

// Start
load();
</script>

</body>
</html>