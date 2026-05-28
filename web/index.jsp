<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // --- DATABASE CONNECTION & USER COUNT LOGIC ---
    int userCount = 0;
    try {
        // 1. Load Driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // 2. Connect to Database (DB Name: codify, User: root, Pass: blank or your_password)
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/codify", "root", ""); 
        
        // 3. Query Execution
        PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM users");
        ResultSet rs = ps.executeQuery();
        
        // 4. Get Result
        if(rs.next()) {
            userCount = rs.getInt(1); // Count variable update zala
        }
        con.close();
    } catch(Exception e) {
        e.printStackTrace(); // Error aalyas console var disel
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CODIFY | Code Your Future</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        :root {
            --bg: #0b0e14;
            --panel: #0f172a;
            --panel-dark: #020617;
            --blue: #2563eb;
            --green: #22c55e;
            --cyan: #22d3ee;
            --text: #e5e7eb;
            --muted: #94a3b8;
            --border: rgba(255, 255, 255, .08);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Inter, system-ui, sans-serif;
        }

        body {
            background: var(--bg);
            color: var(--text);
            overflow-x: hidden;
        }

        .container {
            max-width: 1400px;
            margin: auto;
            padding: 0 60px;
        }

        .section {
            padding: 110px 0;
        }

        /* ---------- FADE ---------- */
        .fade {
            opacity: 0;
            transform: translate3d(0, 24px, 0);
            transition: opacity .6s ease, transform .6s cubic-bezier(.22, .61, .36, 1);
            will-change: opacity, transform;
        }

        .fade.show {
            opacity: 1;
            transform: translate3d(0, 0, 0);
        }

        /* ---------- NAV ---------- */
        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-top: 28px;
        }

        .logo-circle {
            width: 46px;
            height: 46px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--blue), var(--cyan));
            padding: 3px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 0 18px rgba(34, 211, 238, .35);
        }

        .logo-circle img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
        }

        .logo-text {
            font-size: 26px;
            font-weight: 900;
            letter-spacing: 3px;
        }

        .logo-text span {
            background: linear-gradient(135deg, var(--blue), var(--green));
            background-clip: text;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .tagline {
            font-size: 12px;
            color: var(--muted);
            margin-top: 2px;
        }

        /* ---------- HERO ---------- */
        .hero {
            padding: 100px 0 80px;
        }

        .hero h1 {
            font-size: 64px;
            max-width: 900px;
            line-height: 1.1;
        }

        .hero p {
            margin-top: 22px;
            font-size: 20px;
            color: var(--muted);
            max-width: 850px;
        }

        /* ---------- BUTTON ---------- */
        .btn {
            position: relative;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 15px 44px;
            border-radius: 999px;
            background: linear-gradient(135deg, var(--blue), var(--green));
            color: #020617;
            font-weight: 700;
            text-decoration: none;
            border: none;
            cursor: pointer;
            box-shadow: 0 8px 26px rgba(34, 211, 238, .35);
            transition: .2s ease;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 0 24px rgba(34, 211, 238, .55), 0 18px 44px rgba(37, 99, 235, .45);
        }

        .btn.secondary {
            background: transparent;
            color: var(--text);
            border: 1px solid rgba(255, 255, 255, .18);
            box-shadow: none;
        }

        .btn.secondary:hover {
            border-color: var(--cyan);
            box-shadow: 0 0 14px rgba(34, 211, 238, .45);
        }

        /* ---------- METRICS ---------- */
        .metrics {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 26px;
            margin-top: 70px;
        }

        .metric {
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 26px;
        }

        .metric h3 {
            font-size: 30px;
            background: linear-gradient(135deg, var(--blue), var(--green));
            background-clip: text;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .metric p {
            margin-top: 6px;
            font-size: 14px;
            color: var(--muted);
        }

        /* ---------- ZIG ---------- */
        .zig {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 80px;
            align-items: center;
        }

        .zig.reverse {
            direction: rtl;
        }

        .zig.reverse>* {
            direction: ltr;
        }

        .zig img {
            width: 100%;
            border-radius: 24px;
            box-shadow: 0 30px 90px rgba(0, 0, 0, .6);
        }

        .zig h2 {
            font-size: 46px;
            margin-bottom: 16px;
        }

        .zig p {
            color: var(--muted);
            font-size: 18px;
            line-height: 1.7;
        }

        /* ---------- SUBJECTS ---------- */
        .subjects {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 22px;
            margin-top: 40px;
        }

        .subject {
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 22px;
        }

        /* ---------- CTA ---------- */
        .cta {
            background: linear-gradient(135deg, var(--panel), var(--panel-dark));
            border-radius: 28px;
            padding: 100px;
            text-align: center;
        }

        .cta h2 {
            font-size: 44px;
        }

        .cta p {
            color: var(--muted);
            margin-top: 14px;
        }

        /* ---------- FOOTER ---------- */
        .site-footer {
            margin-top: 140px;
            padding: 80px 0 30px;
            border-top: 1px solid var(--border);
            color: var(--muted);
        }

        .footer-grid {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 60px;
        }

        .footer-brand h3 {
            font-size: 26px;
            font-weight: 900;
            background: linear-gradient(135deg, var(--blue), var(--green));
            background-clip: text;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .footer-brand p {
            margin-top: 6px;
            color: var(--text);
        }

        .footer-brand span {
            display: block;
            margin-top: 10px;
            font-size: 14px;
        }

        .footer-block h4 {
            color: var(--text);
            margin-bottom: 14px;
        }

        .footer-block p,
        .footer-block a {
            display: block;
            font-size: 14px;
            color: var(--muted);
            margin-bottom: 8px;
            text-decoration: none;
            cursor: pointer;
        }

        .footer-block a:hover {
            color: var(--cyan);
        }

        /* SOCIAL */
        .socials {
            display: flex;
            gap: 14px;
        }

        .socials a {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--panel);
            border: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: var(--text);
            transition: .2s ease;
        }

        .socials a:hover {
            background: linear-gradient(135deg, var(--blue), var(--cyan));
            color: #020617;
            transform: translateY(-3px);
        }

        .socials a svg {
            width: 18px;
            height: 18px;
            fill: currentColor;
        }

        .footer-bottom {
            margin-top: 60px;
            text-align: center;
            font-size: 13px;
            color: var(--muted);
        }

        /* RESPONSIVE */
        @media(max-width: 1000px) {
            .zig {
                grid-template-columns: 1fr;
            }

            .metrics,
            .subjects {
                grid-template-columns: 1fr;
            }
        }

        @media(max-width: 900px) {
            .footer-grid {
                grid-template-columns: 1fr;
                gap: 40px;
            }
        }

        html {
            scroll-behavior: smooth;
        }
    </style>
</head>

<body tabindex="0">

    <div class="container">

        <div class="brand">
            <div class="logo-circle">
                <img src="images/quiz/codify.png" alt="CODIFY">
            </div>
            <div>
                <div class="logo-text">COD<span>IFY</span></div>
                <div class="tagline">Code Your Future</div>
            </div>
        </div>


        <section class="hero fade">
            <h1>Practice Coding with<br>Logic, Speed & Clarity</h1>
            <p>
                CODIFY is built for focused learners who want structured practice,
                real-time evaluation and measurable improvement — not distractions.
            </p>

            <div style="margin-top:36px">
                <a href="register.jsp" class="btn">Start Practicing</a>
                <a href="#explore" class="btn secondary">Explore Platform</a>
            </div>

            <div class="metrics">
                
                <div class="metric">
                    <h3><%= userCount %>+</h3>
                    <p>Registered Users</p>
                </div>

                <div class="metric">
                    <h3>120+</h3>
                    <p>Practice Sets</p>
                </div>
                <div class="metric">
                    <h3>Live</h3>
                    <p>Rank & Accuracy</p>
                </div>
                <div class="metric">
                    <h3>Instant</h3>
                    <p>Detailed Analysis</p>
                </div>
            </div>
        </section>

        <section id="explore" class="section fade">
            <div class="zig">
                <div>
                    <h2>Practice Like Real Coding Tests</h2>
                    <p>
                        Timed questions, smart navigation, marking for review and
                        automatic submission — just like real coding assessments.
                    </p>
                </div>
                <img src="images/quiz/index2.png" alt="Practice">
            </div>
        </section>

        <section class="section fade">
            <div class="zig reverse">
                <div>
                    <h2>Understand Your Performance</h2>
                    <p>
                        Accuracy, time usage, weak topics and rank comparison —
                        everything explained clearly with analytics.
                    </p>
                </div>
                <img src="images/quiz/performance.jpg" alt="Performance">
            </div>
        </section>

        <section class="section fade">
            <div class="zig">
                <div>
                    <h2>Improve Step by Step</h2>
                    <p>
                        Topic-wise practice sets and progressive difficulty
                        help you improve with confidence.
                    </p>
                </div>
                <img src="images/quiz/step.jpg" alt="Structure">
            </div>
        </section>

        <section class="section fade">
            <h2 style="font-size:44px">Topics Covered</h2>
            <div class="subjects">
                <div class="subject">Data Structures</div>
                <div class="subject">Algorithms</div>
                <div class="subject">DBMS</div>
                <div class="subject">Operating System</div>
                <div class="subject">Computer Networks</div>
                <div class="subject">Java & Python</div>
                <div class="subject">Aptitude</div>
                <div class="subject">SQL</div>
            </div>
        </section>

        <section class="cta fade">
            <h2>Code Daily. Improve Consistently.</h2>
            <p>Join CODIFY and build strong problem-solving skills.</p>
            <a href="register.jsp" class="btn">Enroll Free</a>
        </section>

        <footer class="site-footer">
            <div class="footer-grid">

                <div class="footer-brand">
                    <h3>CODIFY</h3>
                    <p>Code Your Future</p>
                    <span>Practice smart. Think deep. Grow daily.</span>
                </div>

                <div class="footer-block">
                    <h4>Contact</h4>
                    <p>📧 support@codify.com</p>
                    <p>📞 +91 8432334502</p>
                    <p>📞 +91 9022041318</p>
                    <p>📍 India</p>
                </div>

                <div class="footer-block">
                    <h4>Quick Links</h4>
                    <a href="index.jsp">Home</a>
                    <a href="practice.jsp">Practice</a>
                    <a href="login.jsp">Login</a>
                    <a href="analytics.jsp">Analytics</a>
                    <a href="admin.jsp">Admin</a>
                </div>

                <div class="socials">
                    <a href="#" title="LinkedIn" aria-label="LinkedIn">
                        <svg viewBox="0 0 24 24">
                            <path d="M4.98 3.5C4.98 4.88 3.88 6 2.5 6S0 4.88 0 3.5 1.12 1 2.5 1 4.98 2.12 4.98 3.5zM0 8h5v16H0zM8 8h4.8v2.2h.1c.7-1.3 2.4-2.6 5-2.6 5.3 0 6.2 3.5 6.2 8v8H19v-7.1c0-1.7 0-4-2.5-4s-2.9 2-2.9 3.9V24H8z" />
                        </svg>
                    </a>
                    <a href="#" title="GitHub" aria-label="GitHub">
                        <svg viewBox="0 0 24 24">
                            <path d="M12 .5C5.73.5.5 5.74.5 12.02c0 5.11 3.29 9.44 7.86 10.97.57.1.78-.25.78-.55v-2.1c-3.2.7-3.88-1.38-3.88-1.38-.52-1.33-1.27-1.69-1.27-1.69-1.04-.71.08-.7.08-.7 1.15.08 1.75 1.18 1.75 1.18 1.02 1.75 2.67 1.24 3.32.95.1-.74.4-1.24.72-1.52-2.56-.29-5.26-1.28-5.26-5.7 0-1.26.45-2.3 1.18-3.11-.12-.29-.51-1.46.11-3.05 0 0 .97-.31 3.18 1.19a11.1 11.1 0 0 1 5.8 0c2.2-1.5 3.17-1.19 3.17-1.19.62 1.59.23 2.76.11 3.05.73.81 1.17 1.85 1.17 3.11 0 4.43-2.7 5.4-5.28 5.69.41.36.78 1.07.78 2.16v3.2c0 .3.21.66.79.55 4.56-1.53 7.84-5.86 7.84-10.97C23.5 5.74 18.27.5 12 .5z" />
                        </svg>
                    </a>
                    <a href="#" title="Instagram" aria-label="Instagram">
                        <svg viewBox="0 0 24 24">
                            <path d="M7 2h10c2.76 0 5 2.24 5 5v10c0 2.76-2.24 5-5 5H7c-2.76 0-5-2.24-5-5V7c0-2.76 2.24-5 5-5zm10 2H7C5.35 4 4 5.35 4 7v10c0 1.65 1.35 3 3 3h10c1.65 0 3-1.35 3-3V7c0-1.65-1.35-3-3-3zm-5 3.2a4.8 4.8 0 1 1 0 9.6 4.8 4.8 0 0 1 0-9.6zm0 2a2.8 2.8 0 1 0 0 5.6 2.8 2.8 0 0 0 0-5.6zM17.8 6.2a1.1 1.1 0 1 1 0 2.2 1.1 1.1 0 0 1 0-2.2z" />
                        </svg>
                    </a>
                    <a href="#" title="X" aria-label="X">
                        <svg viewBox="0 0 24 24">
                            <path d="M18.9 2H22l-7.2 8.2L23.5 22h-7l-5.5-6.8L5.6 22H2.5l7.7-8.8L.5 2h7.2l5 6.2L18.9 2z" />
                        </svg>
                    </a>
                </div>
            </div>

            <div class="footer-bottom">
                © 2026 CODIFY • All rights reserved.
            </div>

            <div id="adminTrigger" style="position:fixed;bottom:0;right:0;width:40px;height:40px;cursor:pointer;opacity:0;z-index:9999;"></div>

            <a id="adminIcon" href="admin-login.jsp" style="display:none;color:#22d3ee;font-size:14px;position:relative;z-index:9999;margin:10px auto;text-align:center;width:100%;">
                🔐
            </a>
        </footer>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", () => {
            // --- FADE ANIMATION LOGIC ---
            const items = document.querySelectorAll(".fade");
            const obs = new IntersectionObserver(entries => {
                entries.forEach(e => {
                    if (e.isIntersecting) {
                        e.target.classList.add("show");
                        obs.unobserve(e.target);
                    }
                });
            }, {
                threshold: 0.15
            });
            items.forEach(i => obs.observe(i));

            // --- ADMIN SECURITY LOGIC ---
            const ADMIN_HASH = "240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9";
            let clickCount = 0;
            let lockTimer = null;
            const trigger = document.getElementById("adminTrigger");
            const icon = document.getElementById("adminIcon");

            if (!trigger || !icon) return;

            async function sha256(text) {
                const buf = new TextEncoder().encode(text);
                const hash = await crypto.subtle.digest("SHA-256", buf);
                return [...new Uint8Array(hash)]
                    .map(b => b.toString(16).padStart(2, "0"))
                    .join("");
            }

            async function unlockAdmin() {
                const pass = prompt("Admin Access");
                if (!pass) return;

                const hash = await sha256(pass);
                if (hash !== ADMIN_HASH) {
                    alert("Access denied");
                    return;
                }

                icon.style.display = "block";
                alert("Admin unlocked (30 sec)");

                clearTimeout(lockTimer);
                lockTimer = setTimeout(() => {
                    icon.style.display = "none";
                    alert("Admin locked");
                }, 30000);

                setTimeout(() => location.href = "admin-login.jsp", 800);
            }

            trigger.addEventListener("click", () => {
                clickCount++;
                if (clickCount === 3) {
                    clickCount = 0;
                    unlockAdmin();
                }
                setTimeout(() => clickCount = 0, 600);
            });

            window.addEventListener("keydown", e => {
                if (e.altKey && e.code === "KeyA") {
                    e.preventDefault();
                    unlockAdmin();
                }
            });
        });
    </script>
</body>
</html>