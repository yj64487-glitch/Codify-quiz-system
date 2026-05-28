<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    /* ================== SESSION & DB CHECK ================== */
    Integer userId = (Integer) session.getAttribute("user_id");
    if(userId == null){ response.sendRedirect("login.jsp"); return; }

    String firstName="", lastName="", email="", college="", avatar="images/anime/a1.png";
    String username = "User";
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify_db", "root", "root");
        
        String sql = "SELECT full_name, email, username, current_avatar, college FROM users WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        ResultSet rs = pstmt.executeQuery();
        
        if(rs.next()){
            String fullName = rs.getString("full_name");
            if(fullName != null && fullName.contains(" ")){
                String[] parts = fullName.split(" ", 2);
                firstName = parts[0]; lastName = parts[1];
            } else { firstName = fullName; }
            
            email = rs.getString("email");
            if(rs.getString("username") != null) username = rs.getString("username");
            
            String dbAvatar = rs.getString("current_avatar");
            if(dbAvatar != null && !dbAvatar.trim().isEmpty()) {
                avatar = dbAvatar;
            }

            if(rs.getString("college") != null) college = rs.getString("college");
        }
        conn.close();
    } catch(Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Edit Profile | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* ================= ORIGINAL DESIGN CSS ================= */
:root{ --bg:#01030f; --panel:#050a1f; --border:#121a33; --cyan:#22d3ee; --blue:#3b82f6; --text:#e2e8f0; --muted:#7c8aa5; }
*{ margin:0; padding:0; box-sizing:border-box; font-family:Inter,system-ui,sans-serif; }

body{ 
    min-height:100vh; 
    background: radial-gradient(900px at 15% 10%, rgba(59,130,246,.12), transparent 40%), 
                radial-gradient(800px at 85% 80%, rgba(34,211,238,.12), transparent 45%), 
                var(--bg); 
    color:var(--text); 
}

.wrapper{ max-width:1000px; margin:auto; padding:60px 24px 80px; display:grid; grid-template-columns:320px 1fr; gap:40px; animation:fadeUp .7s ease; }
@keyframes fadeUp{ from{opacity:0; transform:translateY(20px)} to{opacity:1; transform:translateY(0)} }

/* Left & Right Panels (Glass Effect) */
.left, .right{ 
    background:linear-gradient(180deg,rgba(255,255,255,.06),rgba(255,255,255,.01)); 
    border:1px solid var(--border); 
    border-radius:28px; 
    padding:30px; 
}

.left h2{ font-size:28px; margin-bottom:10px; }
.left p{ color:var(--muted); font-size:14px; margin-bottom:26px; }

/* Avatar Preview Section */
.avatar-preview{ text-align:center; margin-bottom: 25px; }
.avatar-preview img{ 
    width:140px; height:140px; 
    border-radius:50%; 
    object-fit:cover; 
    border:3px solid var(--cyan); 
    box-shadow:0 0 25px rgba(34,211,238,.35); 
    transition: 0.3s;
}

/* New Grid Style for Original Design */
.avatar-grid { 
    display: grid; 
    grid-template-columns: repeat(3, 1fr); 
    gap: 12px; 
    margin-top: 10px; 
}
.avatar-option { 
    width: 100%; aspect-ratio: 1/1; 
    border-radius: 50%; 
    cursor: pointer; 
    border: 2px solid transparent; 
    transition: .2s; 
    object-fit: cover;
    background: rgba(0,0,0,0.3);
}
.avatar-option:hover { transform: scale(1.1); border-color: var(--cyan); }
.avatar-option.selected { border-color: var(--cyan); box-shadow: 0 0 15px rgba(34,211,238,0.5); transform: scale(1.05); }

/* Form Styles */
.right h3{ font-size:22px; margin-bottom:18px; }
.form{ display:grid; grid-template-columns:1fr 1fr; gap:24px; }
.field{ display:flex; flex-direction:column; }
.field.full{ grid-column:1 / -1; }
.field label{ font-size:13px; color:var(--muted); margin-bottom:6px; }
.field input{ 
    padding:15px 16px; 
    border-radius:14px; 
    background:#000; 
    border:1px solid var(--border); 
    color:var(--text); 
    outline:none; 
    transition:.3s; 
}
.field input:focus{ border-color:var(--cyan); box-shadow:0 0 0 2px rgba(34,211,238,.2); }

/* Buttons */
.actions{ margin-top:36px; display:flex; justify-content:flex-end; gap:16px; }
.back{ text-decoration:none; color:var(--cyan); font-weight:600; padding:14px 26px; display:inline-block; margin-top:10px;}
.btn{ 
    padding:14px 44px; 
    border-radius:999px; 
    border:none; 
    cursor:pointer; 
    font-weight:900; 
    background:linear-gradient(135deg,var(--blue),var(--cyan)); 
    color:#020617; 
    box-shadow:0 0 16px rgba(34,211,238,.4); 
    transition:.3s; 
}
.btn:hover{ transform:scale(1.05); }
</style>
</head>

<body>

<div class="wrapper">

  <div class="left">
    <h2>Edit Avatar</h2>
    <p>Select a new profile picture</p>

    <div class="avatar-preview">
      <img id="mainPreview" src="<%= avatar %>" alt="Current Profile">
    </div>

    <div class="avatar-grid">
       <img src="images/quiz/avatar1.jpg" class="avatar-option" onclick="selectAvatar('images/quiz/avatar1.jpg', this)">
       <img src="images/quiz/avatar2.jpg" class="avatar-option" onclick="selectAvatar('images/quiz/avatar2.jpg', this)">
       <img src="images/quiz/avatar3.jpg" class="avatar-option" onclick="selectAvatar('images/quiz/avatar3.jpg', this)">
       <img src="images/quiz/avatar4.jpg" class="avatar-option" onclick="selectAvatar('images/quiz/avatar4.jpg', this)">
       <img src="images/quiz/avatar5.jpg" class="avatar-option" onclick="selectAvatar('images/quiz/avatar5.jpg', this)">
       <img src="images/quiz/avatar6.jpg" class="avatar-option" onclick="selectAvatar('images/quiz/avatar6.jpg', this)">
    </div>
  </div>

  <div class="right">
    <h3>Account Details</h3>

    <form action="save_profile.jsp" method="post">
        
        <input type="hidden" id="avatarPathInput" name="avatar_path" value="<%= avatar %>">

        <div class="form">
          <div class="field">
            <label>First Name</label>
            <input type="text" name="fname" value="<%= firstName %>" required>
          </div>

          <div class="field">
            <label>Last Name</label>
            <input type="text" name="lname" value="<%= lastName %>" required>
          </div>

          <div class="field full">
            <label>Email</label>
            <input type="email" value="<%= email %>" readonly style="opacity:0.6; cursor:not-allowed;">
          </div>
          
          <div class="field">
            <label>Username</label>
            <input type="text" value="<%= username %>" disabled style="opacity:0.6;">
          </div>

          <div class="field">
            <label>College</label>
            <input type="text" name="college" value="<%= college %>" placeholder="Enter college name">
          </div>
        </div>

        <div class="actions">
          <a href="profile.jsp" class="back">← Cancel</a>
          <button type="submit" class="btn">Save Changes</button>
        </div>
    </form>
  </div>

</div>

<script>
function selectAvatar(path, el) {
    // 1. Preview update
    document.getElementById("mainPreview").src = path;

    // 2. Hidden input update (MOST IMPORTANT for Database)
    document.getElementById("avatarPathInput").value = path;

    // 3. Highlight Selected
    var allOptions = document.querySelectorAll('.avatar-option');
    allOptions.forEach(opt => opt.classList.remove('selected'));
    
    // Add border to clicked image
    el.classList.add('selected');

    console.log("Avatar selected:", path); 
}
</script>

</body>
</html>