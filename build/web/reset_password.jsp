<%@ page import="java.sql.*" %>
<%
String token = request.getParameter("token");
String msg="";

if("POST".equalsIgnoreCase(request.getMethod())){
    String pass = request.getParameter("password");

    Connection con = DriverManager.getConnection(
      "jdbc:mysql://localhost:3306/codify_db","root","root"
    );

    PreparedStatement ps = con.prepareStatement(
      "UPDATE users SET password=?, reset_token=NULL WHERE reset_token=? AND token_expiry > NOW()"
    );
    ps.setString(1, pass);
    ps.setString(2, token);

    if(ps.executeUpdate()>0){
        msg="Password reset successful!";
    }else{
        msg="Invalid or expired link.";
    }
}
%>

<form method="post" style="text-align:center;margin-top:100px;">
<h2>Reset Password</h2>
<p style="color:red"><%=msg%></p>
<input type="password" name="password" placeholder="New Password" required>
<br><br>
<button>Reset</button>
</form>
