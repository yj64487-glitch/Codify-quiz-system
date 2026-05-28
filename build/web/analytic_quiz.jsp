<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // --- 1. SESSION CHECK ---
    // String username = (String) session.getAttribute("username");
    // if(username == null) { response.sendRedirect("login.jsp"); return; }

    // --- 2. FETCH ANALYTIC QUESTIONS ---
    StringBuilder jsonBuilder = new StringBuilder("[");
    Connection conn = null;
    String fetchedQuestions = "[]"; 

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        // Update DB credentials if needed
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify_db", "root", "root");

        // Fetch 10 Random Analytic Questions
        // Note: Using 'mcq_questions' table with category='mind' and level='analytic'
        // If you strictly use 'logic_questions' table, change the query below.
        String sql = "SELECT * FROM mcq_questions WHERE category='mind' AND level='intermediate' AND status='Active' ORDER BY RAND() LIMIT 10"; 
        // Note: Using 'intermediate' as mapping for 'Analytic' usually, or change to 'analytic' if your DB has that value.
        
        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();

        boolean first = true;
        while(rs.next()) {
            if(!first) jsonBuilder.append(",");
            
            // Mapping columns based on standard MCQ table
            String q = rs.getString("title").replace("'", "\\'").replace("\n", " ");
            String o1 = rs.getString("opt_a").replace("'", "\\'");
            String o2 = rs.getString("opt_b").replace("'", "\\'");
            String o3 = rs.getString("opt_c").replace("'", "\\'");
            String o4 = rs.getString("opt_d").replace("'", "\\'");
            
            // Handle Correct Answer Logic
            String correctStr = rs.getString("correct"); // "A", "B", "C", "D"
            String correctAns = "";
            if("A".equalsIgnoreCase(correctStr)) correctAns = o1;
            else if("B".equalsIgnoreCase(correctStr)) correctAns = o2;
            else if("C".equalsIgnoreCase(correctStr)) correctAns = o3;
            else if("D".equalsIgnoreCase(correctStr)) correctAns = o4;

            jsonBuilder.append("{'q':'").append(q).append("',");
            jsonBuilder.append("'options':['").append(o1).append("','").append(o2).append("','").append(o3).append("','").append(o4).append("'],");
            jsonBuilder.append("'correct':'").append(correctAns).append("'}");
            
            first = false;
        }
        jsonBuilder.append("]");
        fetchedQuestions = jsonBuilder.toString();
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(conn != null) conn.close();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Mind Matrix | Analytical</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
/* ANALYTIC THEME (Purple/Violet) */
*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter,sans-serif; }
body{ min-height:100vh; display:flex; justify-content:center; align-items:center; background: radial-gradient(circle at top,#38bdf833,transparent 40%), radial-gradient(circle at bottom,#8b5cf633,transparent 40%), #020617; color:#e5e7eb; }
.hidden{display:none}
.quiz-container{ width:92%; max-width:720px; background:#020617; border-radius:26px; padding:34px; box-shadow:0 0 55px rgba(139,92,246,0.35); animation:fadeUp .6s ease; }
@keyframes fadeUp{ from{opacity:0;transform:translateY(30px)} to{opacity:1;transform:translateY(0)} }
.quiz-header{ display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
.quiz-title{ font-size:26px; font-weight:900; color:#8b5cf6; } 
.timer{ background:#0f172a; padding:10px 18px; border-radius:14px; font-weight:800; color:#facc15; }
.question-count{ color:#94a3b8; margin-bottom:12px; }
.question-box{ background:#0f172a; padding:26px; border-radius:18px; font-size:19px; margin-bottom:24px; border-left:4px solid #8b5cf6; }
.options{ display:flex; flex-direction:column; gap:16px; }
.options label{ background:#020617; padding:16px 18px; border-radius:16px; border:1px solid #1e293b; cursor:pointer; transition:.25s; }
.options label:hover{ border-color:#8b5cf6; transform:translateX(6px); }
.options input{margin-right:12px}
.nav-buttons{ display:flex; justify-content:space-between; margin-top:30px; }
.nav-buttons button{ padding:14px 30px; border:none; border-radius:14px; background:linear-gradient(135deg,#8b5cf6,#6366f1); color:#fff; font-weight:900; cursor:pointer; }
.nav-buttons button:disabled{ background:#334155; cursor:not-allowed; }
.view-result{ text-align:center; margin-top:28px; }
.view-result button{ padding:16px 44px; border:none; border-radius:999px; background:linear-gradient(135deg,#22c55e,#16a34a); color:#fff; font-weight:900; font-size:16px; cursor:pointer; }
.result-container{ width:92%; max-width:560px; background:#020617; border-radius:26px; padding:38px; text-align:center; box-shadow:0 0 70px rgba(139,92,246,0.45); animation:fadeUp .6s ease; }
.score-circle{ width:150px; height:150px; margin:26px auto; border-radius:50%; background:conic-gradient(#22c55e var(--percent), #1e293b 0); display:flex; align-items:center; justify-content:center; }
.score-circle span{ font-size:32px; font-weight:900; }
.result-actions button{ padding:14px 28px; border:none; border-radius:14px; background:linear-gradient(135deg,#8b5cf6,#6366f1); color:#fff; font-weight:900; cursor:pointer; margin: 10px; }
</style>
</head>
<body>

<div class="quiz-container" id="quizBox">
  <div class="quiz-header">
    <div class="quiz-title">Mind Matrix – ANALYTICAL</div>
    <div class="timer" id="timer">10:00</div>
  </div>
  <div class="question-count" id="qCount">Loading...</div>
  <div class="question-box" id="questionBox"></div>
  <div class="options" id="optionsBox"></div>
  <div class="nav-buttons">
    <button id="prevBtn" disabled>Previous</button>
    <button id="nextBtn">Next</button>
    <button id="submitBtn" style="display:none;">Submit</button>
  </div>
  <div class="view-result hidden" id="viewResultBox"><button id="viewResultBtn">View Result</button></div>
</div>

<div class="result-container hidden" id="resultBox">
  <h2 style="color:#8b5cf6">Quiz Result</h2>
  <div class="score-circle" id="scoreCircle"><span id="percentText">0%</span></div>
  <h3 id="scoreText"></h3>
  <h2 id="statusText"></h2>
  <div class="result-actions">
    <button onclick="window.location.href='mind-matrix.jsp'">Back to Dashboard</button>
   
</div>

<script>
// --- INJECT DB QUESTIONS ---
const questions = <%= fetchedQuestions %>;

let index=0, score=0, ended=false;
let userAnswers = new Array(questions.length).fill(null);
const qBox=document.getElementById("questionBox"), oBox=document.getElementById("optionsBox");

// --- TIMER: 10 MINUTES (600 Seconds) ---
let time = 600; 

setInterval(function(){
  if(ended) return;
  let m=Math.floor(time/60);
  let s=time%60;
  // Simple Concatenation
  let mStr = m < 10 ? "0" + m : m;
  let sStr = s < 10 ? "0" + s : s;
  document.getElementById("timer").innerText = mStr + ":" + sStr;
  
  if(time--<=0) finishQuiz();
},1000);

function load(){
  if(questions.length===0){ qBox.innerText="No Questions Found."; return; }
  qBox.innerText=questions[index].q;
  document.getElementById("qCount").innerText="Question " + (index+1) + "/" + questions.length;
  oBox.innerHTML="";
  
  questions[index].options.forEach(function(opt){
    let lbl=document.createElement("label");
    let isChecked = userAnswers[index] === opt ? "checked" : "";
    
    // String concatenation fix
    lbl.innerHTML='<input type="radio" name="opt" '+isChecked+'> ' + opt;
    
    lbl.onclick=function(){ 
        userAnswers[index]=opt; 
        // Visual Update
        let inputs = document.querySelectorAll("input[name='opt']");
        for(let i=0; i<inputs.length; i++) {
            inputs[i].parentElement.style.borderColor = "#1e293b";
        }
        lbl.style.borderColor="#8b5cf6";
        lbl.querySelector("input").checked = true;
    };
    
    if(isChecked) lbl.style.borderColor="#8b5cf6";
    oBox.appendChild(lbl);
  });
  
  document.getElementById("prevBtn").disabled=index===0;
  if(index===questions.length-1) { 
      document.getElementById("nextBtn").style.display="none"; 
      document.getElementById("submitBtn").style.display="inline-block"; 
  } else { 
      document.getElementById("nextBtn").style.display="inline-block"; 
      document.getElementById("submitBtn").style.display="none"; 
  }
}

document.getElementById("prevBtn").onclick=function(){if(index>0){index--; load();}};
document.getElementById("nextBtn").onclick=function(){if(index<questions.length-1){index++; load();}};
document.getElementById("submitBtn").onclick=finishQuiz;

function finishQuiz(){
  ended=true;
  score=0;
  questions.forEach(function(q,i){ if(userAnswers[i]===q.correct) score++; });
  
  // SAVE via AJAX (Optional)
  // fetch("save_score.jsp?type=analytic&score="+score, {method:'POST'});

  document.getElementById("quizBox").classList.add("hidden");
  document.getElementById("resultBox").classList.remove("hidden");
  
  let pct=0;
  if(questions.length > 0) pct=Math.round((score/questions.length)*100);
  
  document.getElementById("scoreText").innerText="Score: " + score + "/" + questions.length;
  document.getElementById("percentText").innerText=pct + "%";
  document.getElementById("scoreCircle").style.setProperty("--percent", pct + "%");
  
  let status=document.getElementById("statusText");
  if(pct>=60) { status.innerText="PASSED"; status.style.color="#22c55e"; }
  else { status.innerText="FAILED"; status.style.color="#ef4444"; }
}

document.getElementById("viewResultBtn").onclick=finishQuiz;
load();
</script>
</body>
</html>