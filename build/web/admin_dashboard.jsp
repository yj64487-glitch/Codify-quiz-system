<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    /* ================== 1. SESSION CHECK ================== */
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    /* ================== 2. DB LOGIC FOR STATS & ACTIONS ================== */
    Connection conn = null;
    int totalUsers = 0, totalQuizzes = 0, totalAttempts = 0, avgAccuracy = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify_db", "root", "root");

        // Action Handler (Block/Delete)
        String action = request.getParameter("action");
        String uid = request.getParameter("uid");
        if (uid != null && action != null) {
            if ("delete".equals(action)) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE id = ?");
                ps.setString(1, uid);
                ps.executeUpdate();
            } else if ("toggle".equals(action)) {
                String currentStatus = request.getParameter("s");
                String newStatus = "Active".equalsIgnoreCase(currentStatus) ? "Blocked" : "Active";
                PreparedStatement ps = conn.prepareStatement("UPDATE users SET status = ? WHERE id = ?");
                ps.setString(1, newStatus);
                ps.setString(2, uid);
                ps.executeUpdate();
            }
            response.sendRedirect("admin_dashboard.jsp");
            return;
        }

        // Fetch Stats
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM users");
        if(rs.next()) totalUsers = rs.getInt(1);
        
        rs = st.executeQuery("SELECT COUNT(*) FROM quizzes");
        if(rs.next()) totalQuizzes = rs.getInt(1);
        
        rs = st.executeQuery("SELECT COUNT(*) FROM results");
        if(rs.next()) totalAttempts = rs.getInt(1);
        
        rs = st.executeQuery("SELECT IFNULL(AVG(score), 0) FROM results");
        if(rs.next()) avgAccuracy = rs.getInt(1);

    } catch (Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Panel | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
:root{ --bg:#020617; --panel:#0b1228; --glass:rgba(255,255,255,.06); --border:#1e293b; --cyan:#22d3ee; --blue:#3b82f6; --green:#22c55e; --yellow:#facc15; --red:#ef4444; --text:#e5e7eb; --muted:#94a3b8; }
*{margin:0;padding:0;box-sizing:border-box;font-family:Inter,system-ui,sans-serif}
body{ background: radial-gradient(1200px at 20% 10%, rgba(34,211,238,.12), transparent 40%), radial-gradient(1000px at 80% 80%, rgba(59,130,246,.12), transparent 45%), #020617; color:var(--text); }

.app{ display:grid; grid-template-columns:260px 1fr; min-height:100vh; }

/* SIDEBAR */
.sidebar{ background:var(--panel); padding:30px 22px; border-right:1px solid var(--border); }
.sidebar h2{ color:var(--cyan); letter-spacing:2px; margin-bottom:30px; }
.sidebar a{ display:block; padding:14px 16px; border-radius:14px; margin-bottom:10px; color:var(--text); text-decoration:none; transition:.3s; }
.sidebar a.active, .sidebar a:hover{ background:rgba(34,211,238,.15); color:var(--cyan); }

/* MAIN */
.main{ padding:42px; animation:fade .7s ease; }
@keyframes fade{ from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }
.top{ display:flex; justify-content:space-between; align-items:center; margin-bottom:36px; }
.admin{ padding:10px 18px; background:var(--glass); border-radius:999px; border:1px solid var(--border); }

/* STATS */
.stats{ display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:24px; margin-bottom:50px; }
.stat{ background:var(--glass); border:1px solid var(--border); border-radius:24px; padding:26px; transition:.35s; }
.stat:hover{ transform:translateY(-8px); box-shadow:0 0 30px rgba(34,211,238,.25); }
.stat h3{ font-size:34px; }
.stat span{ font-size:13px; color:var(--muted); }

/* TABLE */
.card{ background:var(--glass); border:1px solid var(--border); border-radius:26px; overflow:hidden; }
.card h2{ padding:22px; border-bottom:1px solid var(--border); }
table{ width:100%; border-collapse:collapse; }
th,td{ padding:16px 20px; text-align:left; font-size:14px; }
th{ font-size:12px; color:var(--muted); background:rgba(255,255,255,.04); }
tbody tr{ border-top:1px solid var(--border); transition:.25s; }
tbody tr:hover{ background:rgba(34,211,238,.08); }

.status{ font-weight:700; }
.active-st{ color:var(--green); }
.blocked-st{ color:var(--red); }

/* BUTTONS */
.btn{ padding:7px 16px; border-radius:999px; font-size:12px; font-weight:800; border:none; cursor:pointer; transition:.2s; margin-right:5px; }
.view{ background:var(--cyan); color:#020617; }
.block{ background:var(--yellow); color:#020617; }
.delete{ background:var(--red); color:white; }
.btn:hover{ transform:scale(1.08); }

/* MODAL */
.modal{ position:fixed; inset:0; background:rgba(2,6,23,.75); display:none; align-items:center; justify-content:center; z-index:100; }
.modal-box{ background:var(--panel); border:1px solid var(--border); border-radius:26px; padding:30px; width:360px; text-align:center; animation:pop .3s ease; }
@keyframes pop{ from{transform:scale(.9);opacity:0} to{transform:scale(1);opacity:1} }
.close{ margin-top:18px; padding:10px 28px; border-radius:999px; background:var(--cyan); border:none; font-weight:900; cursor:pointer; }
</style>
</head>

<body>
<div class="app">
    <aside class="sidebar">
    <h2>CODIFY</h2>
    <a href="admin_dashboard.jsp">Dashboard</a>
    <a href="admin_users.jsp">Users</a>
    <a href="quiz_mastery.jsp">Quiz Manager</a>
    
    <a href=".admin_analytic.jsp">Analytics</a>
    <a href="admin_feedback.jsp">Feedback Manager</a>
    <a href="admin_settings.jsp">Settings</a>
    
    <a href="admin_logout.jsp" style="color:var(--red); font-weight:800; margin-top:30px; border:1px solid rgba(239,68,68,0.2);">
       Logout 🚪
    </a>
</aside>

    <main class="main">
        <div class="top">
            <h1>Admin Dashboard</h1>
            <div class="admin">👤 <%= adminUser %></div>
        </div>

        <div class="stats">
            <div class="stat"><h3><%= totalUsers %></h3><span>Total Users</span></div>
            <div class="stat"><h3><%= totalQuizzes %></h3><span>Total Quizzes</span></div>
            <div class="stat"><h3><%= totalAttempts %></h3><span>Total Attempts</span></div>
            <div class="stat"><h3><%= avgAccuracy %>%</h3><span>Avg Accuracy</span></div>
        </div>

        <div class="card">
            <h2>Recent Users</h2>
            <table>
                <thead>
                    <tr><th>Name</th><th>Email</th><th>Status</th><th>Action</th></tr>
                </thead>
                <tbody>
                <%
                    PreparedStatement psUsers = conn.prepareStatement("SELECT * FROM users ORDER BY id DESC LIMIT 5");
                    ResultSet rsUsers = psUsers.executeQuery();
                    while(rsUsers.next()) {
                        String uId = rsUsers.getString("id");
                        String uName = rsUsers.getString("username");
                        String uEmail = rsUsers.getString("email");
                        String uStatus = rsUsers.getString("status");
                        if(uStatus == null) uStatus = "Active";
                        
                        String statusClass = "Active".equalsIgnoreCase(uStatus) ? "active-st" : "blocked-st";
                        String blockBtnText = "Active".equalsIgnoreCase(uStatus) ? "Block" : "Unblock";
                %>
                    <tr>
                        <td><%= uName %></td>
                        <td><%= (uEmail != null) ? uEmail : "No Email" %></td>
                        <td class="status <%= statusClass %>"><%= uStatus %></td>
                        <td>
                            <button class="btn view" onclick="viewUser('<%= uName %>','<%= uEmail %>')">View</button>
                            <button class="btn block" onclick="toggleStatus('<%= uId %>', '<%= uStatus %>')"><%= blockBtnText %></button>
                            <button class="btn delete" onclick="deleteUser('<%= uId %>')">Delete</button>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </main>
</div>

<div class="modal" id="modal">
    <div class="modal-box">
        <h3 id="mName"></h3>
        <p id="mEmail" style="color:var(--muted); margin:10px 0;"></p>
        <button class="close" onclick="closeModal()">Close</button>
    </div>
</div>

<script>
function viewUser(name, email){
    document.getElementById("mName").innerText = name;
    document.getElementById("mEmail").innerText = (email !== 'null') ? email : "No Email Provided";
    document.getElementById("modal").style.display="flex";
}
function closeModal(){ document.getElementById("modal").style.display="none"; }

function deleteUser(id) {
    if(confirm("Are you sure you want to delete this user?")) {
        window.location.href = "admin_dashboard.jsp?action=delete&uid=" + id;
    }
}
function toggleStatus(id, current) {
    if(confirm("Change status for this user?")) {
        window.location.href = "admin_dashboard.jsp?action=toggle&uid=" + id + "&s=" + current;
    }
}
</script>
</body>
</html>