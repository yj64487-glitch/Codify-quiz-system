<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- 1. SESSION CHECK (Security) ---
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect("admin_login.jsp");
        return;
    }

    // --- 2. DATABASE CONFIGURATION ---
    String url = "jdbc:mysql://localhost:3306/codify_db"; 
    String dbUser = "root";
    String dbPass = "root";

    // --- 3. HANDLE ACTIONS (Block / Unblock / Delete) ---
    String action = request.getParameter("action");
    String uid = request.getParameter("uid");

    if (action != null && uid != null) {
        Connection connAction = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connAction = DriverManager.getConnection(url, dbUser, dbPass);

            if ("delete".equals(action)) {
                // CHANGE: user_id -> id
                PreparedStatement pstmt = connAction.prepareStatement("DELETE FROM users WHERE id = ?");
                pstmt.setString(1, uid);
                pstmt.executeUpdate();
            } 
            else if ("toggle".equals(action)) {
                String currentStatus = request.getParameter("s");
                String newStatus = "Active".equalsIgnoreCase(currentStatus) ? "Blocked" : "Active";
                
                // CHANGE: user_id -> id
                PreparedStatement pstmt = connAction.prepareStatement("UPDATE users SET status = ? WHERE id = ?");
                pstmt.setString(1, newStatus);
                pstmt.setString(2, uid);
                pstmt.executeUpdate();
            }
            response.sendRedirect("admin_users.jsp");
            return;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (connAction != null) connAction.close();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Users | CODIFY</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* ... CSS BEGINS ... */
:root{ --bg:#020617; --panel:#0b1228; --glass:rgba(255,255,255,.06); --border:#1e293b; --cyan:#22d3ee; --green:#22c55e; --yellow:#facc15; --red:#ef4444; --text:#e5e7eb; --muted:#94a3b8; }
*{margin:0;padding:0;box-sizing:border-box;font-family:Inter,system-ui,sans-serif}
body{ background: radial-gradient(1200px at 20% 10%, rgba(34,211,238,.12), transparent 40%), radial-gradient(1000px at 80% 80%, rgba(59,130,246,.12), transparent 45%), #020617; color:var(--text); }

.container{ max-width:1200px; margin:auto; padding:50px 24px; animation:fade .6s ease; }
@keyframes fade{ from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }

.header{ display:flex; justify-content:space-between; align-items:center; margin-bottom:34px; }
.header h1{ font-size:32px; }
.header-right{ display:flex; align-items:center; gap:14px; }

.back-btn{ padding:10px 22px; border-radius:999px; background:linear-gradient(135deg,var(--cyan),#3b82f6); color:#020617; font-weight:900; text-decoration:none; font-size:14px; transition:.2s; box-shadow:0 0 18px rgba(34,211,238,.4); }
.back-btn:hover{ transform:translateY(-2px); box-shadow:0 0 26px rgba(34,211,238,.65); }

.search{ background:var(--glass); border:1px solid var(--border); padding:12px 18px; border-radius:999px; color:white; width:260px; }

.table-box{ background:var(--glass); border:1px solid var(--border); border-radius:26px; overflow:hidden; }
table{ width:100%; border-collapse:collapse; }
th,td{ padding:18px 22px; text-align:left; font-size:14px; }
th{ font-size:12px; letter-spacing:1px; text-transform:uppercase; color:var(--muted); background:rgba(255,255,255,.04); }
tbody tr{ border-top:1px solid var(--border); transition:.25s; }
tbody tr:hover{ background:rgba(34,211,238,.08); }

.status{ padding:6px 14px; border-radius:999px; font-size:12px; font-weight:800; }
.active{background:rgba(34,197,94,.15);color:var(--green)}
.blocked{background:rgba(239,68,68,.15);color:var(--red)}

.actions button{ padding:7px 14px; border-radius:999px; font-size:12px; font-weight:800; border:none; cursor:pointer; margin-right:6px; transition:.2s; }
.view{background:var(--cyan);color:#020617}
.block{background:var(--yellow);color:#020617}
.delete{background:var(--red);color:white}
.actions button:hover{transform:scale(1.08)}

.modal{ position:fixed; inset:0; background:rgba(2,6,23,.75); display:none; align-items:center; justify-content:center; }
.modal-box{ background:var(--panel); border:1px solid var(--border); border-radius:26px; padding:30px; width:360px; text-align:center; animation:pop .3s ease; }
@keyframes pop{ from{transform:scale(.9);opacity:0} to{transform:scale(1);opacity:1} }
.close{ margin-top:18px; padding:10px 30px; border-radius:999px; background:var(--cyan); border:none; font-weight:900; cursor:pointer; }
/* ... CSS ENDS ... */
</style>
</head>

<body>

<div class="container">

  <div class="header">
    <h1>Users Management</h1>
    <div class="header-right">
      <input class="search" placeholder="Search users..." onkeyup="searchUser(this.value)">
      <a href="admin_dashboard.jsp" class="back-btn">← Dashboard</a>
    </div>
  </div>

  <div class="table-box">
    <table id="userTable">
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Email</th>
          <th>Status</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
      <%
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPass);

            // CHANGE: user_id -> id (Assuming column name is 'id')
            String query = "SELECT * FROM users ORDER BY id DESC";
            stmt = conn.createStatement();
            rs = stmt.executeQuery(query);
            
            boolean hasData = false;

            while(rs.next()) {
                hasData = true;
                
                // CHANGE: user_id -> id
                int uId = rs.getInt("id"); 
                
                // --- NOTE ---
                // जर 'username' column वर error आला, तर तो 'name' असू शकतो.
                String uName = rs.getString("username");
                String uEmail = rs.getString("email");
                String uStatus = rs.getString("status");

                if(uStatus == null) uStatus = "Active";

                boolean isActive = "Active".equalsIgnoreCase(uStatus);
                String statusClass = isActive ? "active" : "blocked";
                String btnText = isActive ? "Block" : "Unblock";
      %>
        <tr>
          <td>#<%= uId %></td>
          <td><%= uName %></td>
          <td><%= uEmail %></td>
          <td><span class="status <%= statusClass %>"><%= uStatus %></span></td>
          <td class="actions">
            <button class="view" onclick="viewUser('<%= uName %>','<%= uEmail %>')">View</button>
            <button class="block" onclick="toggleStatus('<%= uId %>', '<%= uStatus %>')"><%= btnText %></button>
            <button class="delete" onclick="deleteUser('<%= uId %>')">Delete</button>
          </td>
        </tr>
      <%
            }
            if(!hasData) {
      %>
            <tr><td colspan="5" style="text-align:center; padding:30px;">No users found in database.</td></tr>
      <%
            }
        } catch(Exception e) {
      %>
        <tr>
            <td colspan="5" style="text-align:center; padding:20px; color:#ef4444; font-weight:bold;">
                Error: <%= e.getMessage() %>
            </td>
        </tr>
      <%
            e.printStackTrace();
        } finally {
            if(conn != null) conn.close();
        }
      %>
      </tbody>
    </table>
  </div>

</div>

<div class="modal" id="modal">
  <div class="modal-box">
    <h3 id="mName" style="font-size:22px; margin-bottom:5px;"></h3>
    <p id="mEmail" style="color:var(--cyan); margin-bottom:20px;"></p>
    <button class="close" onclick="closeModal()">Close</button>
  </div>
</div>

<script>
function viewUser(name,email){
  document.getElementById("mName").innerText = name;
  document.getElementById("mEmail").innerText = email;
  document.getElementById("modal").style.display="flex";
}
function closeModal(){ document.getElementById("modal").style.display="none"; }

function toggleStatus(id, currentStatus){
  if(confirm("Change status?")){
      window.location.href = "admin_users.jsp?action=toggle&uid=" + id + "&s=" + currentStatus;
  }
}

function deleteUser(id){
  if(confirm("Delete this user?")){
      window.location.href = "admin_users.jsp?action=delete&uid=" + id;
  }
}

function searchUser(val){
  val = val.toLowerCase();
  document.querySelectorAll("#userTable tbody tr").forEach(row=>{
    row.style.display = row.innerText.toLowerCase().includes(val) ? "" : "none";
  });
}
</script>

</body>
</html>