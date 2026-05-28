<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.net.URLEncoder" %>

<%!
    // 1. CONFIGURATION
    String url = "jdbc:mysql://localhost:3306/codify_db";
    String user = "root";
    String pwd = "root"; // PASSWORD CHECK KAR

    public String esc(String s) {
        if(s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
%>

<%
    // 2. BACKEND LOGIC
    request.setCharacterEncoding("UTF-8");
    String action = request.getParameter("action");
    
    if (action != null) {
        Connection con = null;
        PreparedStatement ps = null;
        String statusMsg = "";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pwd);
            
            if ("add".equals(action)) {
                String cat = request.getParameter("category");
                
                // CODING INSERT (Matches Screenshot: title, problem, solution, output, test_cases)
                if ("coding".equals(cat)) {
                    String sql = "INSERT INTO coding_challenges (title, problem, solution, output, test_cases, category, status) VALUES (?,?,?,?,?,?,'Active')";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, request.getParameter("title"));
                    ps.setString(2, request.getParameter("question")); // Form 'question' -> DB 'problem'
                    ps.setString(3, request.getParameter("solution"));
                    ps.setString(4, request.getParameter("output"));   // Form 'output' -> DB 'output'
                    ps.setString(5, request.getParameter("output"));   // Form 'output' -> DB 'test_cases' (Duplicate for safety)
                    ps.setString(6, cat);
                } 
                // MCQ INSERT
                else {
                    String sql = "INSERT INTO mcq_questions (category, level, title, opt_a, opt_b, opt_c, opt_d, correct, status) VALUES (?,?,?,?,?,?,?,?, 'Active')";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, cat);
                    ps.setString(2, request.getParameter("level"));
                    ps.setString(3, request.getParameter("title"));
                    ps.setString(4, request.getParameter("optA"));
                    ps.setString(5, request.getParameter("optB"));
                    ps.setString(6, request.getParameter("optC"));
                    ps.setString(7, request.getParameter("optD"));
                    ps.setString(8, request.getParameter("correct"));
                }
                ps.executeUpdate();
                statusMsg = "Question Added Successfully!";
            } 
            else if ("delete".equals(action)) {
                String type = request.getParameter("type");
                String delSql = "DELETE FROM mcq_questions WHERE id=?";
                if("coding".equals(type)) {
                    delSql = "DELETE FROM coding_challenges WHERE id=?";
                }
                ps = con.prepareStatement(delSql);
                ps.setInt(1, Integer.parseInt(request.getParameter("id")));
                ps.executeUpdate();
                statusMsg = "Deleted Successfully!";
            }
            
            // Redirect to SAME PAGE (Dynamic URI)
            response.sendRedirect(request.getRequestURI() + "?msg=" + URLEncoder.encode(statusMsg, "UTF-8"));
            return;

        } catch (Exception e) {
            statusMsg = "DB Error: " + e.getMessage();
            e.printStackTrace();
            response.sendRedirect(request.getRequestURI() + "?error=" + URLEncoder.encode(statusMsg, "UTF-8"));
            return;
        } finally {
            if(ps!=null) ps.close();
            if(con!=null) con.close();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Quiz Manager</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">

<style>
/* --- ELITE THEME --- */
:root { --bg: #020617; --glass: rgba(255,255,255,.08); --border: rgba(255,255,255,.15); --cyan: #22d3ee; --violet: #8b5cf6; --text: #e5e7eb; --muted: #94a3b8; --danger: #ef4444; --success: #22c55e; }
*{margin:0;padding:0;box-sizing:border-box;font-family:Inter,system-ui,sans-serif;}
body { min-height:100vh; background: radial-gradient(1000px at 15% 10%, rgba(139,92,246,.22), transparent 40%), radial-gradient(900px at 85% 90%, rgba(34,211,238,.18), transparent 40%), var(--bg); display:flex; flex-direction: column; color:var(--text); overflow-x:hidden; }

.header { width: 100%; padding: 20px 40px; background: rgba(2,6,23,0.8); backdrop-filter: blur(10px); border-bottom: 1px solid var(--border); display:flex; justify-content:space-between; align-items:center; position: sticky; top: 0; z-index: 100; }
.title { font-size:22px; font-weight:900; letter-spacing:2px; background:linear-gradient(90deg,var(--cyan),var(--violet)); -webkit-background-clip:text; background-clip:text; color:transparent; }
.nav-btn { padding:10px 20px; border-radius:12px; border:1px solid var(--border); background: transparent; color: var(--text); cursor:pointer; text-decoration: none; transition: 0.3s; }
.nav-btn:hover { background: var(--glass); }

.container { width: 100%; max-width: 1000px; margin: 40px auto; padding: 0 20px; }
.controls { display: flex; gap: 15px; margin-bottom: 30px; }
select { background: var(--bg); color: var(--text); border: 1px solid var(--border); padding: 12px 20px; border-radius: 12px; font-size: 1rem; outline: none; }
.add-btn { padding:12px 28px; border-radius:12px; border:none; font-weight:800; cursor:pointer; color:#020617; background:linear-gradient(90deg,var(--cyan),var(--violet)); transition:transform .25s ease; }
.add-btn:hover { transform:translateY(-2px); }

.q-card { background:linear-gradient(180deg,rgba(255,255,255,.05),rgba(255,255,255,.01)); border:1px solid var(--border); border-radius:24px; padding:28px; margin-bottom: 24px; position: relative; animation: enter 0.5s ease; }
@keyframes enter{ from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:none} }
.del-btn { position: absolute; top: 20px; right: 20px; background: rgba(239, 68, 68, 0.1); color: var(--danger); border: 1px solid var(--danger); padding: 6px 12px; border-radius: 8px; cursor: pointer; font-weight: 700; transition: 0.2s; }
.del-btn:hover { background: var(--danger); color: white; }
.q-title { font-size: 1.2rem; font-weight: 700; margin-bottom: 10px; color: white; padding-right: 60px; }
.badge { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; background: rgba(34, 211, 238, 0.1); color: var(--cyan); margin-bottom: 15px; border: 1px solid rgba(34, 211, 238, 0.2); }
.code-box { background: #0b0d14; border: 1px solid var(--border); padding: 15px; border-radius: 12px; font-family: 'JetBrains Mono', monospace; font-size: 0.9rem; color: #a5f3fc; margin-top: 15px; overflow-x: auto; white-space: pre-wrap; }
.opt-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 20px; }
.opt { padding: 12px; border-radius: 12px; background: rgba(255,255,255,0.03); border: 1px solid var(--border); color: var(--muted); font-size: 0.9rem; }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.8); backdrop-filter: blur(5px); display: none; justify-content: center; align-items: center; z-index: 200; }
.modal { background: #1e293b; border: 1px solid var(--border); padding: 30px; border-radius: 24px; width: 600px; max-width: 90%; box-shadow: 0 20px 50px rgba(0,0,0,0.5); }
.inp { width: 100%; background: #0f172a; border: 1px solid var(--border); padding: 12px; border-radius: 10px; color: white; margin-bottom: 15px; }
textarea.inp { min-height: 80px; font-family: 'JetBrains Mono'; }
.toast { position: fixed; bottom: 30px; right: 30px; background: #1e293b; border: 1px solid var(--cyan); padding: 15px 25px; border-radius: 12px; color: white; display: none; z-index: 1000; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border-left: 5px solid var(--cyan); }
.hidden { display: none; }
</style>
</head>
<body>

<div id="toast" class="toast">Action Successful</div>

<div class="header">
    <div class="title">QUIZ MANAGER</div>
    <div>
        <button class="nav-btn" onclick="downloadDB()">Export JSON</button>
        <a href=" admin_dashboard.jsp" class="nav-btn" style="margin-left: 10px;">Exit</a>
    </div>
</div>

<div class="container">
    <div class="controls">
        <select id="catSelect" onchange="handleCatChange()">
            <option value="coding">Coding Arena</option>
            <option value="mind">Mind Matrix</option>
            <option value="bug">Bug Hunting</option>
            <option value="rapid">Rapid Fire</option>
        </select>
        <select id="subSelect" class="hidden" onchange="render()">
            <option value="foundation">Foundation</option>
            <option value="intermediate">Intermediate</option>
            <option value="critical">Critical</option>
        </select>
        <button class="add-btn" onclick="openModal()">+ Add Question</button>
    </div>
    
    <div id="grid"></div>
</div>

<div class="modal-overlay" id="modalOverlay">
    <div class="modal">
        <h2 style="margin-bottom: 20px; color:white;">Add New Question</h2>
        <input id="inpTitle" class="inp" placeholder="Question Title">
        
        <div id="codingFields">
            <textarea id="inpQ" class="inp" placeholder="Problem Description"></textarea>
            <textarea id="inpSol" class="inp" placeholder="Hidden Solution Code"></textarea>
            <textarea id="inpOut" class="inp" placeholder="Test Cases / Output"></textarea>
        </div>
        
        <div id="mcqFields" class="hidden">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                <input id="optA" class="inp" placeholder="Option A">
                <input id="optB" class="inp" placeholder="Option B">
                <input id="optC" class="inp" placeholder="Option C">
                <input id="optD" class="inp" placeholder="Option D">
            </div>
            <select id="correctOpt" class="inp" style="margin-top: 10px;">
                <option value="A">Correct: A</option>
                <option value="B">Correct: B</option>
                <option value="C">Correct: C</option>
                <option value="D">Correct: D</option>
            </select>
        </div>
        
        <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 10px;">
            <button class="nav-btn" onclick="closeModal()">Cancel</button>
            <button class="add-btn" onclick="save()">Save to DB</button>
        </div>
    </div>
</div>

<form id="dbForm" method="post" action="<%=request.getRequestURI()%>" style="display:none">
    <input type="hidden" name="action" id="formAction">
    <input type="hidden" name="type" id="formType">
    <input type="hidden" name="id" id="formId">
    <input type="hidden" name="category" id="formCat">
    <input type="hidden" name="level" id="formLevel">
    <input type="hidden" name="title" id="formTitle">
    <input type="hidden" name="question" id="formQ">
    <input type="hidden" name="solution" id="formSol">
    <input type="hidden" name="output" id="formOut">
    <input type="hidden" name="optA" id="formOptA">
    <input type="hidden" name="optB" id="formOptB">
    <input type="hidden" name="optC" id="formOptC">
    <input type="hidden" name="optD" id="formOptD">
    <input type="hidden" name="correct" id="formCorrect">
</form>

<script>
// --- FETCH DATA ---
let db = { coding:[], mind:[], bug:[], rapid:[] };

<%
    Connection conFetch = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conFetch = DriverManager.getConnection(url, user, pwd);
        
        // 1. Fetch MCQs
        try {
            Statement stmt1 = conFetch.createStatement();
            ResultSet rs1 = stmt1.executeQuery("SELECT * FROM mcq_questions ORDER BY id DESC");
            while(rs1.next()) {
                String c = rs1.getString("category");
                if(c == null) c = "rapid";
                int id = rs1.getInt("id");
                String title = esc(rs1.getString("title"));
                String lvl = rs1.getString("level"); if(lvl==null) lvl="";
                String correct = rs1.getString("correct"); 
%>
    if(!db['<%=c%>']) db['<%=c%>'] = [];
    db['<%=c%>'].push({ 
        id:<%=id%>, type:'mcq', level:"<%=lvl%>", title:"<%=title%>", 
        opts:{ A:"<%=esc(rs1.getString("opt_a"))%>", B:"<%=esc(rs1.getString("opt_b"))%>", C:"<%=esc(rs1.getString("opt_c"))%>", D:"<%=esc(rs1.getString("opt_d"))%>" }, 
        correct:"<%=esc(correct)%>" 
    });
<%
            }
        } catch(Exception e) { out.println("console.error('MCQ Fetch Error: " + esc(e.getMessage()) + "');"); }
        
        // 2. Fetch Coding
        try {
            Statement stmt2 = conFetch.createStatement();
            ResultSet rs2 = stmt2.executeQuery("SELECT * FROM coding_challenges ORDER BY id DESC");
            while(rs2.next()) {
                String c = rs2.getString("category"); if(c==null) c="coding";
                
                // Matches 'problem' column from your screenshot
                String prob = rs2.getString("problem"); 
                // Matches 'test_cases' column from your screenshot
                String outStr = rs2.getString("test_cases"); 
%>
    if(!db.coding) db.coding = [];
    db.coding.push({ 
        id:<%=rs2.getInt("id")%>, type:'coding', title:"<%=esc(rs2.getString("title"))%>", 
        question:"<%=esc(prob)%>", solution:"<%=esc(rs2.getString("solution"))%>", 
        output:"<%=esc(outStr)%>" 
    });
<%
            }
        } catch(Exception e) { out.println("console.error('Coding Fetch Error: " + esc(e.getMessage()) + "');"); }

    } catch(Exception e) {
%>
    console.error("DB Connection Error: <%= esc(e.getMessage()) %>");
<%
    } finally { if(conFetch!=null) conFetch.close(); }
%>

// --- RENDER LOGIC ---
function handleCatChange() {
    const cat = document.getElementById('catSelect').value;
    const sub = document.getElementById('subSelect');
    if(cat === 'mind') sub.classList.remove('hidden');
    else sub.classList.add('hidden');
    render();
}

function render() {
    const cat = document.getElementById('catSelect').value;
    const sub = document.getElementById('subSelect').value;
    const grid = document.getElementById('grid');
    grid.innerHTML = "";

    let list = db[cat] || [];
    if(cat === 'mind') list = list.filter(function(q) { return q.level === sub; });

    if(list.length === 0) {
        grid.innerHTML = '<div style="text-align:center; padding:50px; color:#64748b;">No questions found. Click + Add Question</div>';
        return;
    }

    list.forEach(function(q) {
        const card = document.createElement('div');
        card.className = 'q-card';
        const delBtn = '<button class="del-btn" onclick="del(' + q.id + ', \'' + q.type + '\')">✕ DELETE</button>';

        if(cat === 'coding') {
            card.innerHTML = delBtn +
                '<div class="q-title">' + q.title + '</div><span class="badge">CODING</span>' +
                '<div style="font-size:0.9rem; color:#94a3b8; margin-top:10px;">' + q.question + '</div>' +
                '<div class="code-box">' + q.solution.substring(0, 50) + '...</div>';
        } else {
            card.innerHTML = delBtn +
                '<div class="q-title">#' + q.id + ' ' + q.title + '</div><span class="badge">' + (cat === 'mind' ? q.level : cat) + '</span>' +
                '<div class="opt-grid">' +
                    '<div class="opt ' + (q.correct=='A'?'correct':'') + '">A. ' + q.opts.A + '</div>' +
                    '<div class="opt ' + (q.correct=='B'?'correct':'') + '">B. ' + q.opts.B + '</div>' +
                    '<div class="opt ' + (q.correct=='C'?'correct':'') + '">C. ' + q.opts.C + '</div>' +
                    '<div class="opt ' + (q.correct=='D'?'correct':'') + '">D. ' + q.opts.D + '</div>' +
                '</div>';
        }
        grid.appendChild(card);
    });
}

const modalOverlay = document.getElementById('modalOverlay');
function openModal() {
    const cat = document.getElementById('catSelect').value;
    const coding = document.getElementById('codingFields');
    const mcq = document.getElementById('mcqFields');
    if(cat === 'coding') { coding.classList.remove('hidden'); mcq.classList.add('hidden'); }
    else { coding.classList.add('hidden'); mcq.classList.remove('hidden'); }
    modalOverlay.style.display = 'flex';
}
function closeModal() { modalOverlay.style.display = 'none'; }

function save() {
    const cat = document.getElementById('catSelect').value;
    const title = document.getElementById('inpTitle').value;
    if(!title.trim()) { alert("Title Required"); return; }

    document.getElementById('formAction').value = "add";
    document.getElementById('formCat').value = cat;
    document.getElementById('formLevel').value = document.getElementById('subSelect').value;
    document.getElementById('formTitle').value = title;
    
    if(cat === 'coding') {
        document.getElementById('formQ').value = document.getElementById('inpQ').value;
        document.getElementById('formSol').value = document.getElementById('inpSol').value;
        document.getElementById('formOut').value = document.getElementById('inpOut').value;
    } else {
        document.getElementById('formOptA').value = document.getElementById('optA').value;
        document.getElementById('formOptB').value = document.getElementById('optB').value;
        document.getElementById('formOptC').value = document.getElementById('optC').value;
        document.getElementById('formOptD').value = document.getElementById('optD').value;
        document.getElementById('formCorrect').value = document.getElementById('correctOpt').value;
    }
    document.getElementById('dbForm').submit();
}

function del(id, type) {
    if(confirm('Delete this question permanently?')) {
        document.getElementById('formAction').value = "delete";
        document.getElementById('formType').value = type;
        document.getElementById('formId').value = id;
        document.getElementById('dbForm').submit();
    }
}

function downloadDB() {
    const data = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(db, null, 2));
    const a = document.createElement('a'); a.href = data; a.download = "codify_data.json"; a.click();
}

window.onload = function() {
    const params = new URLSearchParams(window.location.search);
    if(params.has('msg')) {
        const toast = document.getElementById('toast');
        toast.innerText = decodeURIComponent(params.get('msg'));
        toast.style.display = 'block';
        toast.style.borderLeft = '5px solid var(--success)';
        setTimeout(() => toast.style.display = 'none', 3000);
    }
    if(params.has('error')) {
        const toast = document.getElementById('toast');
        toast.innerText = decodeURIComponent(params.get('error'));
        toast.style.display = 'block';
        toast.style.borderLeft = '5px solid var(--danger)';
        setTimeout(() => toast.style.display = 'none', 5000);
    }
    render();
};
</script>
</body>
</html>