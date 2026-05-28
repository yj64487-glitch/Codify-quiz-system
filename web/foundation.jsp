<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- DATABASE CONFIGURATION ---
    String url = "jdbc:mysql://localhost:3306/codify_db";
    String user = "root";
    String pwd = "root"; // <--- CHECK PASSWORD

    StringBuilder jsData = new StringBuilder("[");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(url, user, pwd);
        Statement stmt = con.createStatement();
        
        // --- FETCH FOUNDATION QUESTIONS ---
        // Fetching 10 Random questions where category is 'mind' and level is 'foundation'
        String sql = "SELECT * FROM mcq_questions WHERE category='mind' AND level='foundation' AND status='Active' ORDER BY RAND() LIMIT 10";
        ResultSet rs = stmt.executeQuery(sql);
        
        boolean first = true;
        while(rs.next()) {
            if(!first) jsData.append(",");
            
            String title = rs.getString("title").replace("'", "\\'").replace("\"", "\\\"");
            String optA = rs.getString("opt_a").replace("'", "\\'");
            String optB = rs.getString("opt_b").replace("'", "\\'");
            String optC = rs.getString("opt_c").replace("'", "\\'");
            String optD = rs.getString("opt_d").replace("'", "\\'");
            
            // Map Correct Answer (A->0, B->1...)
            String cStr = rs.getString("correct");
            int cIdx = 0;
            if(cStr != null && !cStr.isEmpty()) {
                char c = Character.toUpperCase(cStr.charAt(0));
                if(c == 'B') cIdx = 1; else if(c == 'C') cIdx = 2; else if(c == 'D') cIdx = 3;
            }

            jsData.append("{");
            jsData.append("q: '").append(title).append("',");
            jsData.append("options: ['").append(optA).append("','").append(optB).append("','").append(optC).append("','").append(optD).append("'],");
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
<title>Mind Matrix | Foundation</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap" rel="stylesheet">

<style>
/* --- YOUR ORIGINAL DESIGN --- */
*{ margin:0; padding:0; box-sizing:border-box; font-family: Inter, system-ui, sans-serif; }

body{
  min-height:100vh;
  display:flex;
  justify-content:center;
  align-items:center;
  background:radial-gradient(circle at top,#38bdf833,transparent 40%),#020617;
  color:#e5e7eb;
}

.hidden{display:none}

/* QUIZ */
.quiz-container{ width:90%; max-width:650px; background:#020617; border-radius:20px; padding:30px; box-shadow:0 0 35px rgba(56,189,248,0.35); animation:fadeIn .6s ease; }
@keyframes fadeIn{ from{opacity:0; transform:translateY(20px);} to{opacity:1; transform:translateY(0);} }

.quiz-header{ display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; }
.quiz-title{ font-size:24px; font-weight:800; color:#38bdf8; }
.timer{ background:#0f172a; padding:8px 16px; border-radius:12px; font-weight:700; color:#facc15; }
.question-count{ color:#94a3b8; margin-bottom:12px; }
.question-box{ background:#0f172a; padding:22px; border-radius:14px; font-size:18px; margin-bottom:22px; }

.options{ display:flex; flex-direction:column; gap:14px; }
.options label{ background:#020617; padding:14px 16px; border-radius:12px; cursor:pointer; border:1px solid #1e293b; transition:.25s; }
.options label:hover{ border-color:#38bdf8; transform:scale(1.02); }
.options input{margin-right:10px;}

.nav-buttons{ display:flex; justify-content:space-between; margin-top:28px; }
.nav-buttons button{ padding:12px 26px; border:none; border-radius:12px; background:linear-gradient(135deg,#38bdf8,#0ea5e9); color:#020617; font-weight:800; cursor:pointer; }
.nav-buttons button:disabled{ background:#64748b; cursor:not-allowed; }

/* VIEW RESULT BUTTON */
.view-result{ text-align:center; margin-top:26px; animation:pop .5s ease; }
@keyframes pop{ from{opacity:0;transform:scale(.85)} to{opacity:1;transform:scale(1)} }
.view-result button{ padding:14px 40px; border:none; border-radius:999px; background:linear-gradient(135deg,#22c55e,#16a34a); color:#020617; font-weight:900; cursor:pointer; box-shadow:0 0 30px rgba(34,197,94,.6); }

/* RESULT */
.result-container{ width:90%; max-width:520px; background:#020617; border-radius:22px; padding:35px; box-shadow:0 0 45px rgba(34,197,94,.4); text-align:center; animation:fadeIn .6s ease; }
.result-title{ font-size:26px; font-weight:800; color:#22c55e; margin-bottom:12px; }

.score-circle{ width:140px; height:140px; margin:20px auto; border-radius:50%; background:conic-gradient(#22c55e var(--percent), #1e293b 0); display:flex; align-items:center; justify-content:center; }
.score-circle span{ font-size:30px; font-weight:800; }

.result-info{ margin-top:15px; font-size:18px; }
.result-status{ margin-top:10px; font-size:20px; font-weight:700; }

.result-actions{ display:flex; justify-content:center; gap:15px; margin-top:30px; }
.result-actions button{ padding:12px 24px; border:none; border-radius:12px; background:linear-gradient(135deg,#38bdf8,#0ea5e9); color:#020617; font-weight:800; cursor:pointer; }
</style>
</head>

<body>

<div class="quiz-container" id="quizBox">
  <div class="quiz-header">
    <div class="quiz-title">Mind Matrix – Foundation</div>
    <div class="timer" id="timer">15:00</div>
  </div>

  <div class="question-count" id="qCount">Loading...</div>
  <div class="question-box" id="questionBox"></div>
  <div class="options" id="optionsBox"></div>

  <div class="nav-buttons">
    <button id="prevBtn" disabled>Previous</button>
    <button id="nextBtn">Next</button>
    <button id="submitBtn" style="display:none;">Submit</button>
  </div>

  <div class="view-result hidden" id="viewResultBox">
    <button id="viewResultBtn">View Result</button>
  </div>
</div>

<div class="result-container hidden" id="resultBox">
  <div class="result-title">Quiz Result</div>

  <div class="score-circle" id="scoreCircle">
    <span id="percentText">0%</span>
  </div>

  <div class="result-info" id="scoreText"></div>
  <div class="result-status" id="statusText"></div>

  <div class="result-actions">
  <button onclick="goHome()">Back to Menu</button>
</div>

</div>

<script>
// --- INJECT DB QUESTIONS ---
const questions = <%= jsData.toString() %>;

let index=0;
let userAnswers = new Array(questions.length).fill(null);
let ended=false;
let score=0;
let percent=0;

/* ELEMENTS */
const quizBox=document.getElementById("quizBox");
const resultBox=document.getElementById("resultBox");
const questionBox=document.getElementById("questionBox");
const optionsBox=document.getElementById("optionsBox");
const qCount=document.getElementById("qCount");
const prevBtn=document.getElementById("prevBtn");
const nextBtn=document.getElementById("nextBtn");
const submitBtn=document.getElementById("submitBtn");
const timerEl=document.getElementById("timer");
const viewResultBox=document.getElementById("viewResultBox");
const viewResultBtn=document.getElementById("viewResultBtn");

/* --- TIMER SET TO 15 MINUTES (900 SECONDS) --- */
let time = 900;

const timer=setInterval(()=>{
  if(ended) return;
  let m=Math.floor(time/60);
  let s=time%60;
  // Simple Concatenation
  let mStr = String(m).padStart(2,"0");
  let sStr = String(s).padStart(2,"0");
  timerEl.innerText = mStr + ":" + sStr;
  
  if(time--<=0) finishQuiz();
},1000);

/* LOAD QUESTIONS */
function load(){
  if(questions.length === 0) {
      questionBox.innerText = "No Foundation Questions found in Database.";
      return;
  }
  
  const q=questions[index];
  questionBox.innerText=q.q;
  qCount.innerText="Question " + (index+1) + " of " + questions.length;
  optionsBox.innerHTML="";

  q.options.forEach((opt, i)=>{
    const label=document.createElement("label");
    const isChecked = userAnswers[index] === i ? "checked" : "";
    
    label.innerHTML='<input type="radio" name="opt" '+isChecked+'> ' + opt;
    
    label.onclick=()=>{
        userAnswers[index]=i;
        // Visual Update
        document.querySelectorAll("input[name='opt']").forEach(e => e.parentElement.style.borderColor="#1e293b");
        label.style.borderColor="#38bdf8";
        label.querySelector("input").checked = true;
    };
    
    if(isChecked) label.style.borderColor="#38bdf8";
    optionsBox.appendChild(label);
  });

  prevBtn.disabled = index===0;
  if(index === questions.length-1){
      nextBtn.style.display="none";
      submitBtn.style.display="inline-block";
  } else {
      nextBtn.style.display="inline-block";
      submitBtn.style.display="none";
  }
}

/* NAV */
prevBtn.onclick=()=>{if(index>0){index--;load();}};
nextBtn.onclick=()=>{if(index<questions.length-1){index++;load();}};
submitBtn.onclick=finishQuiz;

/* FINISH */
function finishQuiz(){
  if(ended) return;
  ended=true;
  clearInterval(timer);

  score=0;
  questions.forEach((q, i)=>{
      if(userAnswers[i] === q.a) score++;
  });
  percent = Math.round((score / questions.length) * 100);

  // Hide Controls
  prevBtn.style.display="none";
  nextBtn.style.display="none";
  submitBtn.style.display="none";
  optionsBox.style.pointerEvents="none"; // Disable clicks
  
  viewResultBox.classList.remove("hidden");
}

/* VIEW RESULT */
viewResultBtn.onclick=()=>{
  quizBox.classList.add("hidden");
  resultBox.classList.remove("hidden");

  document.getElementById("scoreText").innerText="Score: " + score + "/" + questions.length;
  document.getElementById("percentText").innerText=percent + "%";
  document.getElementById("scoreCircle").style.setProperty("--percent", percent + "%");
  
  const statusEl = document.getElementById("statusText");
  if(percent >= 60) {
      statusEl.innerText = "🎉 Passed - Next Level Unlocked!";
      statusEl.style.color = "#22c55e";
  } else {
      statusEl.innerText = "❌ Failed - Try Again";
      statusEl.style.color = "#ef4444";
  }
};

/* ACTIONS */
function restartQuiz(){ location.reload(); }
function goHome(){ window.location.href="mind-matrix.jsp"; }

/* INIT */
load();
</script>

</body>
</html>