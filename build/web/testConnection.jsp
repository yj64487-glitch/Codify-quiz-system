<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>

<html>
<body>
<%
    Connection con = DBConnection.getConnection();
    if (con != null) {
%>
    <h2 style="color:green;">Database Connected Successfully ?</h2>
<%
    } else {
%>
    <h2 style="color:red;">Database Connection Failed ?</h2>
<%
    }
%>
</body>
</html>
