<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%!
    // Ultimate String Cleaner - कोणत्याही special characters मुळे कोड ब्रेक होणार नाही
    public String esc(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "")
                  .replace("\t", "\\t")
                  .replace("<", "\\u003c") // HTML tags break होऊ नये म्हणून
                  .replace(">", "\\u003e");
    }
%>

<%
    String dbError = "";
    StringBuilder jsonBuilder = new StringBuilder();
    jsonBuilder.append("[");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify_db", "root", "root");
        Statement stmt = con.createStatement();
        
        ResultSet rs = stmt.executeQuery("SELECT * FROM mcq_questions WHERE status='Active' OR status='active'");
        
        boolean first = true;
        while(rs.next()) {
            if(!first) jsonBuilder.append(",");
            first = false;
            
            String q = esc(rs.getString("title"));
            String optA = esc(rs.getString("opt_a"));
            String optB = esc(rs.getString("opt_b"));
            String optC = esc(rs.getString("opt_c"));
            String optD = esc(rs.getString("opt_d"));
            
            // 'code' column डेटाबेसमध्ये नसेल तरीही क्रॅश होणार नाही
            String code = "";
            try {
                code = esc(rs.getString("code"));
            } catch(SQLException ignore) {}
            
            String correctStr = rs.getString("correct");
            int correctIdx = 0;
            if(correctStr != null && correctStr.trim().length() > 0) {
                char c = Character.toUpperCase(correctStr.trim().charAt(0));
                if(c == 'B') correctIdx = 1;
                else if(c == 'C') correctIdx = 2;
                else if(c == 'D') correctIdx = 3;
            }
            
            jsonBuilder.append("{")
                       .append("\"q\":\"").append(q).append("\",")
                       .append("\"code\":\"").append(code).append("\",")
                       .append("\"opts\":[\"").append(optA).append("\",\"").append(optB).append("\",\"").append(optC).append("\",\"").append(optD).append("\"],")
                       .append("\"a\":").append(correctIdx)
                       .append("}");
        }
        
        rs.close();
        stmt.close();
        con.close();
        
    } catch (Exception e) {
        dbError = e.getMessage();
    }
    jsonBuilder.append("]");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Debug Zone | Elite</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">

<style>
/* ================= ELITE DESIGN ================= */
:root{ --bg:#020617; --glass:rgba(255,255,255,.08); --border:rgba(255,255,255,.15); --cyan:#22d3ee; --violet:#8b5cf6; --text:#e5e7eb; --muted:#94a3b8; }
*{margin:0;padding:0;box-sizing:border-box;font-family:Inter,system-ui,sans-serif;}

body{
  min-height:100vh;
  background: radial-gradient(1000px at 15% 10%, rgba(139,92,246,.22), transparent 40%),
              radial-gradient(900px at 85% 90%, rgba(34,211,238,.18), transparent 40%),
              var(--bg);
  display:flex; align-items:center; justify-content:center;
  color:var(--text); overflow-x:hidden;
}

.card{
  width:980px; max-width: 95%;
  backdrop-filter:blur(22px);
  background:linear-gradient(180deg,rgba(255,255,255,.1),rgba(255,255,255,.02));
  border:1px solid var(--border); border-radius:28px; padding:36px;
  box-shadow:0 0 160px rgba(139,92,246,.35);
  animation:enter .8s cubic-bezier(.2,.8,.2,1);
}
@keyframes enter{ from{opacity:0;transform:scale(.96) translateY(40px)} to{opacity:1;transform:none} }

.header{ display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
.title{ font-size:22px; font-weight:900; letter-spacing:2px; background:linear-gradient(90deg,var(--cyan),var(--violet)); -webkit-background-clip:text; background-clip:text; color:transparent; }
.counter{ color:var(--muted); font-weight:700; }

.question{ font-size:22px; font-weight:700; margin-bottom:16px; line-height: 1.4; }

.code-wrapper { display:none; margin-bottom: 20px; } 
.code{ background:#020617; border-radius:18px; border:1px solid var(--border); padding:20px; font-family:'JetBrains Mono',monospace; font-size:14px; color:#a5f3fc; position:relative; overflow:hidden; white-space: pre-wrap; }
.code::after{ content:""; position:absolute; inset:0; background:linear-gradient(120deg,transparent,rgba(34,211,238,.22),transparent); animation:scan 3.2s infinite; pointer-events:none; }
@keyframes scan{ from{transform:translateX(-100%)} to{transform:translateX(100%)} }

.options{ display:grid; grid-template-columns:repeat(2,1fr); gap:18px; margin-top:28px; }
.option{ padding:18px; border-radius:18px; background:rgba(2,6,23,.9); border:1px solid var(--border); cursor:pointer; transition: all .35s ease; font-weight: 500; color: var(--muted); }
.option:hover{ transform:translateY(-3px); border-color:var(--cyan); box-shadow:0 12px 28px rgba(0,0,0,.45); color: var(--text); }
.option.selected{ border-color:var(--violet); box-shadow:0 0 28px rgba(139,92,246,.6); background: rgba(139, 92, 246, 0.1); color: #fff; }

.nav{ margin-top:34px; display:flex; justify-content:space-between; }
.nav button{ padding:14px 32px; border-radius:16px; border:none; font-weight:800; cursor:pointer; color:#020617; background:linear-gradient(90deg,var(--cyan),var(--violet)); transition:transform .25s ease, box-shadow .25s ease; }
.nav button:hover{ transform:translateY(-2px); box-shadow:0 12px 26px rgba(0,0,0,.45); }
.nav button:disabled { opacity: 0.5; cursor: not-allowed; transform: none; box-shadow: none; }

.result{ display:none; text-align:center; }
.score-ring{ width:200px; height:200px; border-radius:50%; margin:34px auto; background:conic-gradient(var(--violet) var(--deg), #1e293b 0); display:flex; align-items:center; justify-content:center; font-size:36px; font-weight:900; animation:pop .8s ease; position: relative; }
.score-ring::before { content: ""; position: absolute; width: 180px; height: 180px; background: #020617; border-radius: 50%; }
.score-ring span { position: relative; z-index: 2; color: white; }
@keyframes pop{ from{opacity:0;transform:scale(.8)} to{opacity:1;transform:none} }
.sub{ color:var(--muted); margin-top:10px; font-size: 1.1rem; }
.status-msg { margin-top: 15px; font-size: 0.9rem; font-family: 'JetBrains Mono', monospace; }
</style>
</head>

<body>

<div class="card" id="quiz">
  <div class="header">
    <div class="title">DEBUG ZONE</div>
    <div class="counter" id="counter">Initializing...</div>
  </div>

  <div class="question" id="question">Loading Data...</div>
  
  <div class="code-wrapper" id="codeWrapper">
      <div class="code" id="code"></div>
  </div>
  
  <div class="options" id="options"></div>

  <div class="nav" id="navButtons" style="display:none;">
    <button onclick="prev()" id="btnPrev">PREVIOUS</button>
    <button onclick="next()" id="btnNext">NEXT</button>
  </div>
</div>

<div class="card result" id="result">
  <h1>Result Analysis</h1>
  <div class="score-ring" id="ring" style="--deg:0deg">
      <span id="scoreText">0%</span>
  </div>
  <div class="sub" id="summary"></div>
  <div class="status-msg" id="saveStatus" style="color: #22d3ee;">Saving result...</div>
  <div class="nav" style="justify-content: center;">
      <button onclick="window.location.href='dashboard.jsp'" style="background: #334155; color: white; padding: 14px 50px;">EXIT TO DASHBOARD</button>
  </div>
</div>

<script id="quizData" type="application/json">
<%= jsonBuilder.toString() %>
</script>

<script>
const dbError = "<%= esc(dbError) %>";
let questions = [];
let index = 0;
let answers = {};

const qEl = document.getElementById("question");
const cEl = document.getElementById("code");
const cWrap = document.getElementById("codeWrapper");
const oEl = document.getElementById("options");
const counter = document.getElementById("counter");
const btnPrev = document.getElementById("btnPrev");
const btnNext = document.getElementById("btnNext");
const navButtons = document.getElementById("navButtons");

window.onload = function() {
    // जर Database Connection मध्ये एरर असेल
    if (dbError !== "") {
        qEl.innerHTML = "<span style='color:#ef4444;'>Database Error:</span><br><span style='font-size:16px; color:#94a3b8; font-weight:normal; display:block; margin-top:10px;'>" + dbError + "</span>";
        counter.textContent = "Error";
        return;
    }

    // सुरक्षितपणे JSON वाचणे 
    try {
        const rawJSON = document.getElementById("quizData").textContent;
        questions = JSON.parse(rawJSON);
    } catch(e) {
        qEl.innerHTML = "<span style='color:#ef4444;'>Parse Error!</span><br><span style='font-size:16px; color:#94a3b8; font-weight:normal;'>Failed to read questions.</span>";
        counter.textContent = "Error";
        console.error("JSON Error:", e);
        return;
    }

    // प्रश्न रिकामे असल्यास
    if(questions.length === 0) {
        qEl.innerHTML = "No active questions found.<br><span style='font-size:16px; color:#94a3b8; font-weight:normal;'>Go to Admin panel and add some Active questions.</span>";
        counter.textContent = "0 / 0";
        return;
    }

    navButtons.style.display = "flex";
    load();
};

function load(){
  counter.textContent = `Question ${index+1} / ${questions.length}`;
  qEl.textContent = questions[index].q;
  
  if(questions[index].code && questions[index].code.trim() !== ""){
      cEl.textContent = questions[index].code;
      cWrap.style.display = "block";
  } else {
      cWrap.style.display = "none";
  }
  
  oEl.innerHTML = "";
  questions[index].opts.forEach((text, i) => {
    const d = document.createElement("div");
    d.className = "option";
    d.textContent = text;
    
    if(answers[index] === i) d.classList.add("selected");
    
    d.onclick = () => {
      answers[index] = i;
      [...oEl.children].forEach(x => x.classList.remove("selected"));
      d.classList.add("selected");
    };
    
    oEl.appendChild(d);
  });

  btnPrev.disabled = (index === 0);
  if(index === questions.length - 1) {
      btnNext.textContent = "SUBMIT";
  } else {
      btnNext.textContent = "NEXT";
  }
}

function next(){
  if(index < questions.length - 1){
    index++;
    load();
  } else {
    showResult();
  }
}

function prev(){
  if(index > 0){
    index--;
    load();
  }
}

function showResult(){
  document.getElementById("quiz").style.display = "none";
  const r = document.getElementById("result");
  r.style.display = "block";
  
  let score = 0;
  questions.forEach((q, i) => {
    if(answers[i] === q.a) score++;
  });
  
  const percent = questions.length > 0 ? Math.round((score / questions.length) * 100) : 0;
  setTimeout(() => {
      document.getElementById("ring").style.setProperty("--deg", percent * 3.6 + "deg");
      document.getElementById("scoreText").textContent = percent + "%";
  }, 100);

  document.getElementById("summary").textContent = `You got ${score} correct out of ${questions.length}`;

  const statusEl = document.getElementById("saveStatus");
  statusEl.textContent = "Connecting to DB...";
  
  const formData = new URLSearchParams();
  formData.append('score', score);
  formData.append('total', questions.length);

  fetch('save_score_1.jsp', {
      method: 'POST',
      body: formData
  })
  .then(response => response.text())
  .then(data => {
      if(!data.trim().includes("Success")) {
          statusEl.style.color = "#ef4444";
          statusEl.textContent = "Error: " + data;
      } else {
          statusEl.style.color = "#4ade80";
          statusEl.textContent = "Result Saved Successfully!";
      }
  })
  .catch(err => {
      statusEl.style.color = "#ef4444";
      statusEl.textContent = "Fetch Error: " + err;
  });
}
</script>
</body>
</html>