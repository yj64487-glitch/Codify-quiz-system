<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    // Destroy the session (clear all data like user_id, full_name)
    session.invalidate();
    
    // Redirect to login page
    response.sendRedirect("login.jsp");
%>