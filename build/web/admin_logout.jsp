<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. Session purna clear kara
    session.removeAttribute("adminUser"); 
    session.invalidate(); 
    
    // 2. Browser la sanga ki he page cache karu nako (Back button protection)
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setHeader("Expires", "0"); // Proxies
    
    // 3. Exact Login Page cha path check kara (Spelling check: admin_login.jsp)
    response.sendRedirect("admin-login.jsp");
%>