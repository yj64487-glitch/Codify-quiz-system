<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    String username = (String) session.getAttribute("username");
    if(username == null) { response.sendRedirect("login.jsp"); return; }

    String quizType = request.getParameter("type");
    if(quizType == null) quizType = "foundation";

    StringBuilder jsonBuilder = new StringBuilder("[");
    Connection conn = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/elite_quiz", "root", "root");
        
        String sql = "SELECT * FROM logic_questions WHERE difficulty_level = ? ORDER BY RAND() LIMIT 10";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, quizType);
        ResultSet rs = pstmt.executeQuery();

        boolean first = true;
        while(rs.next()) {
            if(!first) jsonBuilder.append(",");
            String q = rs.getString("question_text").replace("'", "\\'").replace("\n", " ");
            String o1 = rs.getString("option_1").replace("'", "\\'");
            String o2 = rs.getString("option_2").replace("'", "\\'");
            String o3 = rs.getString("option_3").replace("'", "\\'");
            String o4 = rs.getString("option_4").replace("'", "\\'");
            String ans = rs.getString("correct_answer").replace("'", "\\'");

            jsonBuilder.append("{'q':'").append(q).append("', 'options':['").append(o1).append("','").append(o2).append("','").append(o3).append("','").append(o4).append("'], 'correct':'").append(ans).append("'}");
            first = false;
        }
    } catch(Exception e) { e.printStackTrace(); } finally { if(conn!=null) conn.close(); }
    
    jsonBuilder.append("]");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Quiz | <%= quizType %></title>
<style>
body{ background:#020617; color:white; font-family:sans-serif; display:flex; justify-content:center; align-items:center; min-height:100vh; margin:0; }
.card{ background:#0f172a; padding:30px; border-radius:20px; width:90%; max-width:600px; box-shadow:0 0 30px rgba(56,189,248,0.2); }
h2{ color:#38bdf8; text-transform:capitalize; }
.opt-btn{ display:block; width:100%; padding:15px; margin:10px 0; background:#1e293b; border:1px solid #334155; color:white; text-align:left; cursor:pointer; border-radius:10px; }
.opt-btn:hover{ border-color:#38bdf8; }
.opt-btn.selected{ background:#38bdf8; color:black; font-weight:bold; }
.nav-btn{ padding:10px 25px; background:#38bdf8; border:none; border-radius:5px; cursor:pointer; font-weight:bold; float:right; margin-top:20px; }
.hidden{ display:none; }
</style>
</head>
<body>

<div class="card" id="quizView">
    <h2><%= quizType %> Quiz</h2>
    <p id="qText">Loading...</p>
    <div id="opts"></div>
    <button class="nav-btn" onclick="nextQ()">Next</button>
</div>

<div class="card hidden" id="resultView" style="text-align:center;">
    <h1>Quiz Complete!</h1>
    <h2 id="scoreText"></h2>
    <button class="nav-btn" style="float:none;" onclick="window.location.href='mind-matrix.jsp'">Back to Menu</button>
</div>

<script>
const questions = <%= jsonBuilder.toString() %>;
const type = "<%= quizType %>";
let curr = 0;
let score = 0;

function loadQ() {
    if(questions.length === 0) { document.getElementById("qText").innerText = "No questions found."; return; }
    const q = questions[curr];
    document.getElementById("qText").innerText = (curr+1) + ". " + q.q;
    const optsDiv = document.getElementById("opts");
    optsDiv.innerHTML = "";
    
    q.options.forEach(opt => {
        const btn = document.createElement("button");
        btn.className = "opt-btn";
        btn.innerText = opt;
        btn.onclick = () => {
            document.querySelectorAll(".opt-btn").forEach(b => b.classList.remove("selected"));
            btn.classList.add("selected");
            q.userAns = opt;
        };
        optsDiv.appendChild(btn);
    });
}

function nextQ() {
    if(!questions[curr].userAns) return alert("Select an answer!");
    if(questions[curr].userAns === questions[curr].correct) score++;
    
    if(curr < questions.length - 1) {
        curr++; loadQ();
    } else {
        saveAndShowResult();
    }
}

function saveAndShowResult() {
    fetch(`save_score.jsp?type=${type}&score=${score}`, { method:'POST' });
    document.getElementById("quizView").classList.add("hidden");
    document.getElementById("resultView").classList.remove("hidden");
    document.getElementById("scoreText").innerText = "Score: " + score + "/" + questions.length;
}

loadQ();
</script>
</body>
</html>