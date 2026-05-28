<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    /* ================== 1. SESSION CHECK ================== */
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect("admin_login.jsp");
        return;
    }

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify_db", "root", "root");

        /* ================== 2. ACTION HANDLERS ================== */
        // Handler for Status Updates (Solved/Progress)
        String fIdStatus = request.getParameter("fid");
        String newStatus = request.getParameter("status");
        if(fIdStatus != null && newStatus != null) {
            PreparedStatement psStatus = conn.prepareStatement("UPDATE feedback SET status = ? WHERE id = ?");
            psStatus.setString(1, newStatus.toUpperCase());
            psStatus.setString(2, fIdStatus);
            psStatus.executeUpdate();
            response.sendRedirect("admin_feedback.jsp");
            return;
        }

        // Handler for Saving Replies
        String feedbackId = request.getParameter("feedbackId");
        String replyMsg = request.getParameter("replyMsg");
        if(feedbackId != null && replyMsg != null && !replyMsg.trim().isEmpty()) {
            PreparedStatement psReply = conn.prepareStatement(
                "INSERT INTO feedback_replies (feedback_id, admin_name, reply_message) VALUES (?, ?, ?)"
            );
            psReply.setString(1, feedbackId);
            psReply.setString(2, adminUser);
            psReply.setString(3, replyMsg);
            psReply.executeUpdate();
            
            // Auto-update status to Progress on reply
            PreparedStatement psUpd = conn.prepareStatement("UPDATE feedback SET status = 'PROGRESS' WHERE id = ?");
            psUpd.setString(1, feedbackId);
            psUpd.executeUpdate();
            
            response.sendRedirect("admin_feedback.jsp?success=replied");
            return;
        }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CODIFY · Admin Feedback</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        :root{ --bg:#05070f; --panel:#0b1020; --border:#1f2a44; --accent:#38bdf8; --accent2:#6366f1; --green:#22c55e; --yellow:#facc15; --red:#ef4444; --text:#e5e7eb; --muted:#94a3b8; }
        *{margin:0;padding:0;box-sizing:border-box;font-family:Inter,sans-serif}
        body{ background: radial-gradient(900px at 80% 10%,#1e3a8a25,transparent), var(--bg); color:var(--text); animation:pageFade .7s ease; }
        @keyframes pageFade{ from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:none} }
        .header{ display:flex;justify-content:space-between;align-items:center; padding:22px 36px; background:rgba(5,7,15,.85); backdrop-filter:blur(14px); border-bottom:1px solid var(--border); position:sticky;top:0;z-index:10; }
        .logo{ width:44px;height:44px;border-radius:14px; background:linear-gradient(135deg,var(--accent),var(--accent2)); display:grid;place-items:center;font-weight:900;color:#020617; }
        .back-btn{ padding:10px 22px;border-radius:999px; background:linear-gradient(135deg,var(--accent),var(--accent2)); color:#020617; font-weight:800; text-decoration:none; }
        .container{max-width:1400px;margin:auto;padding:40px 34px 80px}
        .card{ background:var(--panel); border:1px solid var(--border); border-radius:24px; padding:24px; margin-bottom:18px; transition:.3s; }
        .card:hover{ transform:translateY(-3px); box-shadow:0 18px 40px rgba(56,189,248,.12); }
        .top{display:flex;justify-content:space-between;align-items:center}
        .status{ padding:6px 14px;border-radius:999px; font-size:12px;font-weight:800; }
        .open{background:rgba(250,204,21,.15);color:var(--yellow)}
        .progress{background:rgba(56,189,248,.15);color:var(--accent)}
        .done{background:rgba(34,197,94,.15);color:var(--green)}
        .message{ margin:16px 0;font-size:14px;color:#d1d5db; }
        .actions{display:flex;gap:10px;flex-wrap:wrap}
        .actions button, .actions a{ padding:8px 18px;border-radius:999px;border:none; font-size:12px;font-weight:800;cursor:pointer; text-decoration:none; transition:.2s; }
        .solve{background:var(--green);color:#020617}
        .progress-btn{background:var(--accent);color:#020617}
        .reply-trigger{background:#020617;color:var(--text);border:1px solid var(--border)}
        
        /* Reply Box Styles */
        .reply-box { display:none; margin-top:15px; background:rgba(255,255,255,0.03); padding:15px; border-radius:15px; border:1px solid var(--border); }
        .reply-box textarea { width:100%; background:#05070f; border:1px solid var(--border); color:white; padding:10px; border-radius:10px; min-height:80px; margin-bottom:10px; }
        .send-btn { background:var(--accent); color:#020617; padding:8px 20px; border-radius:50px; border:none; font-weight:bold; cursor:pointer; }
        
        .toast{ position:fixed;bottom:28px;right:28px; background:#020617;border:1px solid var(--border); padding:14px 20px;border-radius:14px; opacity:0; transition:0.3s; pointer-events:none;}
        .toast.show{opacity:1;}
    </style>
</head>
<body>

<div class="header">
    <div class="brand">
        <div class="logo">C</div>
        <div class="brand-text">
            <h2>CODIFY · Admin</h2>
            <span>Feedback Resolver</span>
        </div>
    </div>
    <a href="admin_dashboard.jsp" class="back-btn">← Dashboard</a>
</div>

<div class="container">
    <div class="title">
        <h1>User Feedback Management</h1>
        <p style="color:var(--muted)">Manage feedback and improve user experience</p>
    </div>

    <%
        /* ================== 3. FETCH FEEDBACKS ================== */
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT * FROM feedback ORDER BY created_at DESC");

        while(rs.next()){
            int id = rs.getInt("id");
            String username = rs.getString("username");
            String category = rs.getString("category");
            String message = rs.getString("message");
            String status = rs.getString("status");
            int rating = rs.getInt("rating");

            String statusClass = "open";
            if(status.equalsIgnoreCase("PROGRESS")) statusClass = "progress";
            else if(status.equalsIgnoreCase("SOLVED")) statusClass = "done";
    %>
    <div class="card">
        <div class="top">
            <div class="user">
                <h3><%= username %></h3>
                <span>
                    <% for(int i=0; i<rating; i++) out.print("★"); %> 
                    · <%= category %>
                </span>
            </div>
            <span class="status <%= statusClass %>"><%= status %></span>
        </div>

        <div class="message">“<%= message %>”</div>

        <div class="actions">
            <a href="admin_feedback.jsp?fid=<%= id %>&status=progress" class="progress-btn">Mark In-Progress</a>
            <a href="admin_feedback.jsp?fid=<%= id %>&status=solved" class="solve">Mark Solved</a>
            <button class="reply-trigger" onclick="toggleReply(<%= id %>)">Reply</button>
        </div>

        <div class="reply-box" id="reply-box-<%= id %>">
            <form action="admin_feedback.jsp" method="POST">
                <input type="hidden" name="feedbackId" value="<%= id %>">
                <textarea name="replyMsg" placeholder="Write your response to <%= username %>..." required></textarea>
                <button type="submit" class="send-btn">Send Reply</button>
            </form>
        </div>

        <%
            PreparedStatement psGetReply = conn.prepareStatement("SELECT * FROM feedback_replies WHERE feedback_id = ?");
            psGetReply.setInt(1, id);
            ResultSet rsReply = psGetReply.executeQuery();
            while(rsReply.next()){
        %>
            <div style="margin-top:15px; padding:12px; background:rgba(99,102,241,0.05); border-left:3px solid var(--accent2); border-radius:10px;">
                <small style="color:var(--accent2); font-weight:bold;">Admin Reply (<%= rsReply.getTimestamp("replied_at") %>):</small>
                <p style="font-size:13.5px; margin-top:5px; color:#e5e7eb;"><%= rsReply.getString("reply_message") %></p>
            </div>
        <% } %>
    </div>
    <%
        }
        conn.close();
    } catch(Exception e) { e.printStackTrace(); }
    %>
</div>

<div class="toast" id="toast"></div>

<script>
    function toggleReply(id) {
        const box = document.getElementById('reply-box-' + id);
        box.style.display = (box.style.display === 'block') ? 'none' : 'block';
    }

    function notify(msg){
        const toast = document.getElementById("toast");
        toast.textContent = msg;
        toast.classList.add("show");
        setTimeout(()=>toast.classList.remove("show"), 2500);
    }
    
    <% if(request.getParameter("success") != null) { %>
        notify("Reply sent successfully!");
    <% } %>
</script>
</body>
</html>