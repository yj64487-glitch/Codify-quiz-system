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
    String currentEmail = "";
    String currentName = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify_db", "root", "root");

        /* ================== 2. ACTION HANDLERS ================== */
        String action = request.getParameter("action");
        
        // A. UPDATE PROFILE
        if ("updateProfile".equals(action)) {
            String newName = request.getParameter("newName");
            String newEmail = request.getParameter("newEmail");
            PreparedStatement ps = conn.prepareStatement("UPDATE admins SET username=?, email=? WHERE username=?");
            ps.setString(1, newName);
            ps.setString(2, newEmail);
            ps.setString(3, adminUser);
            ps.executeUpdate();
            session.setAttribute("adminUser", newName);
            response.sendRedirect("admin_settings.jsp?msg=Profile Updated Successfully");
            return;
        }

        // B. CHANGE PASSWORD
        if ("changePass".equals(action)) {
            String newPass = request.getParameter("newPass");
            PreparedStatement ps = conn.prepareStatement("UPDATE admins SET password=? WHERE username=?");
            ps.setString(1, newPass);
            ps.setString(2, adminUser);
            ps.executeUpdate();
            response.sendRedirect("admin_settings.jsp?msg=Password Changed Successfully");
            return;
        }

        // Fetch Current Admin Data
        PreparedStatement psFetch = conn.prepareStatement("SELECT * FROM admins WHERE username=?");
        psFetch.setString(1, adminUser);
        ResultSet rs = psFetch.executeQuery();
        if(rs.next()) {
            currentName = rs.getString("username");
            currentEmail = rs.getString("email");
        }
    } catch (Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Settings | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
    :root{ --bg:#020617; --panel:#0b1228; --border:#1e293b; --cyan:#22d3ee; --blue:#3b82f6; --red:#ef4444; --text:#e5e7eb; --muted:#94a3b8; }
    
    *{ margin:0; padding:0; box-sizing:border-box; font-family: 'Inter', sans-serif; }
    
    body{ 
        min-height:100vh; 
        background: radial-gradient(1200px at 15% 10%, rgba(59,130,246,.18), transparent 40%), 
                    radial-gradient(1000px at 85% 80%, rgba(34,211,238,.18), transparent 45%), 
                    var(--bg); 
        color:var(--text);
        overflow-x: hidden;
    }

    .container{ max-width:1100px; margin:auto; padding:50px 24px; animation:fadeSlideUp 0.8s cubic-bezier(0.2, 0.8, 0.2, 1); }

    @keyframes fadeSlideUp {
        from { opacity: 0; transform: translateY(40px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* HEADER */
    .header{ display:flex; justify-content:space-between; align-items:center; margin-bottom:40px; }
    .header h1{ font-size:36px; font-weight:900; letter-spacing:-1px; }

    .back{ 
        padding:12px 28px; border-radius:50px; 
        background: linear-gradient(135deg, var(--cyan), var(--blue)); 
        color:#020617; text-decoration:none; font-weight:800; 
        transition: 0.3s; box-shadow: 0 4px 15px rgba(34, 211, 238, 0.3);
    }
    .back:hover{ transform: translateX(-5px); box-shadow: 0 0 25px rgba(34, 211, 238, 0.5); }

    /* GRID SYSTEM */
    .grid{ display:grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap:26px; }

    .card{ 
        background: rgba(255, 255, 255, 0.03); 
        border: 1px solid var(--border); 
        border-radius: 28px; padding: 32px; 
        backdrop-filter: blur(10px);
        transition: 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative; overflow: hidden;
    }
    .card:hover{ 
        transform: translateY(-10px); 
        border-color: var(--cyan);
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4), 0 0 20px rgba(34, 211, 238, 0.1);
    }

    .card.full{ grid-column: 1 / -1; }

    /* ADMIN PROFILE */
    .admin{ display:flex; align-items:center; gap:20px; }
    .avatar{ 
        width:70px; height:70px; border-radius:24px; 
        background: linear-gradient(135deg, var(--cyan), var(--blue)); 
        display:grid; place-items:center; font-weight:900; font-size:28px; color:#020617;
        box-shadow: 0 0 20px rgba(34, 211, 238, 0.4);
    }

    /* BUTTONS */
    .btn{ 
        padding:14px 32px; border-radius:16px; border:none; 
        cursor:pointer; font-weight:700; font-size:14px;
        background: rgba(255, 255, 255, 0.05); color:var(--text);
        border: 1px solid var(--border); transition: 0.3s;
        margin-top: 20px;
    }
    .btn-primary{ background: linear-gradient(135deg, var(--blue), var(--cyan)); color:#020617; border:none; }
    .btn:hover{ transform: scale(1.05); background: var(--cyan); color:#020617; }
    .btn-red:hover{ background: var(--red); color: white; border-color: var(--red); box-shadow: 0 0 20px rgba(239, 68, 68, 0.4); }

    /* OVERLAY & MODALS */
    .overlay{ 
        position:fixed; inset:0; background:rgba(2, 6, 23, 0.85); 
        backdrop-filter:blur(8px); display:none; align-items:center; 
        justify-content:center; z-index:999; 
    }
    .overlay.show{ display:flex; animation: fadeIn 0.3s ease; }

    .edit-box{ 
        width:450px; background:var(--panel); border:1px solid var(--border); 
        border-radius:32px; padding:40px; transform: scale(0.8);
        transition: 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    .overlay.show .edit-box{ transform: scale(1); }

    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

    .field{ margin-bottom:20px; }
    .field label{ display:block; margin-bottom:8px; color:var(--muted); font-size:13px; font-weight:600; }
    .field input{ 
        width:100%; padding:14px; border-radius:12px; border:1px solid var(--border); 
        background:var(--bg); color:#fff; transition: 0.3s;
    }
    .field input:focus{ border-color: var(--cyan); outline: none; box-shadow: 0 0 15px rgba(34, 211, 238, 0.2); }

    /* TOGGLE SWITCH */
    .toggle{ display:flex; justify-content:space-between; align-items:center; margin-top:15px; }
    .switch{ 
        width:54px; height:28px; background:rgba(255,255,255,0.1); 
        border-radius:50px; cursor:pointer; position:relative; transition: 0.3s; 
    }
    .switch::after{
        content: ''; position: absolute; top: 3px; left: 3px;
        width: 22px; height: 22px; background: #fff; border-radius: 50%;
        transition: 0.3s cubic-bezier(0.18, 0.89, 0.35, 1.15);
    }
    .switch.on{ background: var(--cyan); }
    .switch.on::after{ left: 29px; }

</style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1>⚙️ Settings</h1>
        <a href="admin_dashboard.jsp" class="back">← Dashboard</a>
    </div>

    <div class="grid">
        <div class="card">
            <div class="admin">
                <div class="avatar"><%= currentName.substring(0,1).toUpperCase() %></div>
                <div>
                    <h2 style="font-size:20px;"><%= currentName %></h2>
                    <p style="color:var(--muted); font-size:14px;"><%= currentEmail %></p>
                </div>
            </div>
            <button class="btn btn-primary" onclick="openModal('editOverlay')">Edit Admin Profile</button>
        </div>

        <div class="card">
            <h2 style="margin-bottom:10px;">Security</h2>
            <p style="color:var(--muted); font-size:14px;">Update your password and manage session security.</p>
            <div style="display:flex; gap:12px;">
                <button class="btn" onclick="openModal('passOverlay')">Change Password</button>
                <button class="btn btn-red" onclick="triggerEffect('Sessions Cleared')">Logout All Users</button>
            </div>
        </div>

        <div class="card">
            <h2 style="margin-bottom:10px;">Platform Controls</h2>
            <div class="toggle">
                <span>Maintenance Mode</span>
                <div class="switch" onclick="this.classList.toggle('on')"></div>
            </div>
            <div class="toggle">
                <span>User Registrations</span>
                <div class="switch on" onclick="this.classList.toggle('on')"></div>
            </div>
        </div>

        <div class="card full" style="border-color: rgba(239, 68, 68, 0.3);">
            <h2 style="color:var(--red); margin-bottom:10px;">Danger Zone</h2>
            <p style="color:var(--muted); font-size:14px; margin-bottom:20px;">Actions here are permanent. Please be careful.</p>
            <button class="btn btn-red" onclick="triggerEffect('System Reset Initiated')">Reset Database</button>
        </div>
    </div>
</div>

<div class="overlay" id="editOverlay">
    <div class="edit-box">
        <h2 style="margin-bottom:20px;">Edit Profile</h2>
        <form action="admin_settings.jsp" method="POST">
            <input type="hidden" name="action" value="updateProfile">
            <div class="field">
                <label>Admin Username</label>
                <input type="text" name="newName" value="<%= currentName %>" required>
            </div>
            <div class="field">
                <label>Email Address</label>
                <input type="email" name="newEmail" value="<%= currentEmail %>" required>
            </div>
            <div style="display:flex; gap:12px; margin-top:30px;">
                <button type="submit" class="btn btn-primary" style="flex:1; margin:0;">Save Changes</button>
                <button type="button" class="btn" style="flex:1; margin:0;" onclick="closeModal('editOverlay')">Cancel</button>
            </div>
        </form>
    </div>
</div>

<div class="overlay" id="passOverlay">
    <div class="edit-box">
        <h2 style="margin-bottom:20px;">Update Password</h2>
        <form action="admin_settings.jsp" method="POST" id="passForm">
            <input type="hidden" name="action" value="changePass">
            <div class="field">
                <label>New Secure Password</label>
                <input type="password" name="newPass" id="nPass" placeholder="••••••••" required>
            </div>
            <div class="field">
                <label>Confirm Password</label>
                <input type="password" id="cPass" placeholder="••••••••" required>
            </div>
            <div style="display:flex; gap:12px; margin-top:30px;">
                <button type="button" class="btn btn-primary" style="flex:1; margin:0;" onclick="validatePass()">Update Password</button>
                <button type="button" class="btn" style="flex:1; margin:0;" onclick="closeModal('passOverlay')">Cancel</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openModal(id){
        const modal = document.getElementById(id);
        modal.style.display = 'flex';
        setTimeout(() => modal.classList.add('show'), 10);
    }

    function closeModal(id){
        const modal = document.getElementById(id);
        modal.classList.remove('show');
        setTimeout(() => modal.style.display = 'none', 300);
    }

    function validatePass(){
        const n = document.getElementById("nPass").value;
        const c = document.getElementById("cPass").value;
        if(n === c && n !== "") {
            document.getElementById("passForm").submit();
        } else {
            alert("Passwords do not match or are empty!");
        }
    }

    function triggerEffect(msg) {
        alert(msg);
    }

    <% if(request.getParameter("msg") != null) { %>
        alert("<%= request.getParameter("msg") %>");
    <% } %>
</script>

</body>
</html>