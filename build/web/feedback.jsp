<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>CODIFY · User Feedback</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
/* तुझी ओरिजिनल स्टाईल */
:root{ --bg:#05070f; --panel:#0b1020; --border:#1f2a44; --accent:#38bdf8; --accent2:#6366f1; --green:#22c55e; --text:#e5e7eb; --muted:#94a3b8; }
*{margin:0;padding:0;box-sizing:border-box;font-family:Inter,sans-serif}
body{ min-height:100vh; background:radial-gradient(900px at 80% 10%,#1e3a8a25,transparent), var(--bg); display:flex; align-items:center; justify-content:center; color:var(--text); }
.card{ width:420px; background:var(--panel); border:1px solid var(--border); border-radius:28px; padding:34px; }
.header{ display:flex; justify-content:space-between; align-items:center; margin-bottom:26px; }
.brand{ display:flex; align-items:center; gap:12px; font-weight:900; }
.logo{ width:38px;height:38px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--accent2)); display:grid;place-items:center; color:#000; }
.back{ padding:8px 18px; border-radius:999px; background:#020617; border:1px solid var(--border); color:var(--text); text-decoration:none; font-size:13px; }
.rating{ display:flex; gap:10px; margin-bottom:22px; }
.star{ width:42px;height:42px; border-radius:12px; background:#020617; border:1px solid var(--border); display:grid;place-items:center; font-size:24px; cursor:pointer; transition:.2s; }
.star.active{ background:linear-gradient(135deg,var(--accent),var(--accent2)); color:#000; box-shadow:0 0 18px #38bdf870; }
textarea{ width:100%; min-height:110px; padding:14px; border-radius:16px; border:1px solid var(--border); background:#020617; color:var(--text); margin-bottom:20px; outline:none; }
.btn{ width:100%; padding:14px; border-radius:999px; border:none; font-weight:900; cursor:pointer; background:linear-gradient(135deg,var(--accent),var(--accent2)); color:#000; }
.success{ text-align:center; display:none; }
.success h2{color:var(--green);margin-bottom:6px}
</style>
</head>
<body>

<div class="card" id="formBox">
  <div class="header">
    <div class="brand"><div class="logo">C</div> CODIFY</div>
    <a href="dashboard.jsp" class="back">&#8592; Dashboard</a>
  </div>
  <h1>Give Your Feedback</h1>
  <p style="color:#94a3b8; margin-bottom:20px">Your feedback helps us improve &#128640;</p>

  <div class="rating">
    <div class="star" onclick="rate(1)">&#9733;</div>
    <div class="star" onclick="rate(2)">&#9733;</div>
    <div class="star" onclick="rate(3)">&#9733;</div>
    <div class="star" onclick="rate(4)">&#9733;</div>
    <div class="star" onclick="rate(5)">&#9733;</div>
  </div>

  <textarea id="message" placeholder="Write your experience here..."></textarea>
  <button id="submitBtn" class="btn" onclick="submitFeedback()">Submit Feedback</button>
</div>

<div class="card success" id="successBox">
  <h2>Thank You! &#128153;</h2>
  <p style="color:#94a3b8">Your feedback has been submitted successfully.</p>
  <br><a href="dashboard.jsp" class="back">Back to Dashboard</a>
</div>

<script>
let rating = 0;
function rate(val){
  rating = val;
  document.querySelectorAll(".star").forEach((s,i) => s.classList.toggle("active", i < val));
}

function submitFeedback(){
  if(rating === 0) { alert("Please select a rating!"); return; }
  
  const btn = document.getElementById("submitBtn");
  btn.innerHTML = "Submitting...";
  btn.disabled = true;

  const params = new URLSearchParams();
  params.append("rating", rating);
  params.append("message", document.getElementById("message").value);

  fetch('submit_feedback.jsp', { method: 'POST', body: params })
  .then(res => res.json())
  .then(data => {
      if(data.status === "success"){
          document.getElementById("formBox").style.display = "none";
          document.getElementById("successBox").style.display = "block";
      } else {
          alert("Error: " + data.message);
          btn.innerHTML = "Submit Feedback";
          btn.disabled = false;
      }
  })
  .catch(err => {
      console.error(err);
      alert("Server connection failed! Check console for details.");
      btn.innerHTML = "Submit Feedback";
      btn.disabled = false;
  });
}
</script>

</body>
</html