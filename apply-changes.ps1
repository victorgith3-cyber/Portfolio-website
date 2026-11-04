$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$path = Join-Path (Get-Location) 'index.html'

# Backup (only once, so the original is never overwritten)
if (-not (Test-Path 'index.backup.html')) { Copy-Item 'index.html' 'index.backup.html' }

$h = [System.IO.File]::ReadAllText($path, $utf8)

# --- A. Hero title ---
if ($h.Contains('Graphics Designer &amp; Data Analyst')) {
    'SKIP: hero already updated'
} elseif ($h.Contains('Web Developer')) {
    $h = $h.Replace('Web Developer', 'Web Developer, Graphics Designer &amp; Data Analyst')
    'OK: hero title'
} else {
    'NOT FOUND: hero title'
}

# --- B. Footer Services list ---
$pattern = '(<li>\s*<a[^>]*>)Web Consulting(</a>\s*</li>)'
if ($h.Contains('Graphic Design</a>')) {
    'SKIP: services already updated'
} elseif ($h -match $pattern) {
    $h = [regex]::Replace($h, $pattern, '$0$1Graphic Design$2$1Data Cleaning &amp; Visualization$2')
    'OK: services list'
} else {
    'NOT FOUND: services list'
}

# --- C. Graphic Design & Data section (before Contact) ---
$section = @'
<section id="design-data" class="design-data">
  <div class="container">
    <h2>Graphic Design &amp; Data</h2>
    <div class="dd-grid">
      <div class="dd-card">
        <h3>Graphics Designer</h3>
        <p>Promotional posters, social media designs and marketing materials created in Canva, plus video editing in Adobe Premiere Pro.</p>
      </div>
      <div class="dd-card">
        <h3>Data Analyst</h3>
        <p>Data cleaning and visualization in Excel, turning raw data into clear, readable charts and reports. Worked at Roots Data, Jul&ndash;Oct 2026.</p>
      </div>
    </div>
  </div>
</section>
<style>
  .design-data { padding: 4rem 1rem; text-align: center; }
  .design-data .dd-grid { display: grid; gap: 1.5rem; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); max-width: 900px; margin: 2rem auto 0; }
  .design-data .dd-card { padding: 1.5rem; border: 1px solid rgba(128,128,128,.3); border-radius: 12px; }
</style>

'@
if ($h.Contains('id="design-data"')) {
    'SKIP: section already added'
} else {
    $m = [regex]::Match($h, '<section[^>]*id="contact"')
    if ($m.Success) {
        $h = $h.Insert($m.Index, $section)
        'OK: new section'
    } else {
        'NOT FOUND: contact section'
    }
}

# --- D. Premium full-screen mobile menu ---
$menu = @'
<!-- premium-menu -->
<button class="pm-toggle" aria-label="Open menu" aria-expanded="false"><span></span><span></span></button>
<div class="pm-overlay" aria-hidden="true">
  <nav class="pm-nav">
    <a href="#home"><small>01</small>Home</a>
    <a href="#about"><small>02</small>About</a>
    <a href="#projects"><small>03</small>Projects</a>
    <a href="#design-data"><small>04</small>Design &amp; Data</a>
    <a href="#contact"><small>05</small>Contact</a>
  </nav>
  <p class="pm-foot">victorgith3@gmail.com &middot; Nairobi, Kenya</p>
</div>
<style>
  .pm-toggle, .pm-overlay { display: none; }
  @media (max-width: 768px) {
    .hamburger, .menu-toggle, .nav-toggle, .burger, .menu-btn, .mobile-menu-btn, #hamburger, #menu-toggle { display: none !important; }
    .pm-toggle { display: block; position: fixed; top: 14px; right: 14px; z-index: 10001; width: 48px; height: 48px; border-radius: 50%;
      border: 1px solid rgba(255,255,255,.25); background: rgba(20,20,28,.55); backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px); cursor: pointer; }
    .pm-toggle span { position: absolute; left: 14px; right: 14px; height: 2px; background: #fff; border-radius: 2px; transition: transform .4s cubic-bezier(.7,0,.2,1), top .4s cubic-bezier(.7,0,.2,1); }
    .pm-toggle span:nth-child(1) { top: 19px; }
    .pm-toggle span:nth-child(2) { top: 27px; }
    .pm-toggle.pm-open span:nth-child(1) { top: 23px; transform: rotate(45deg); }
    .pm-toggle.pm-open span:nth-child(2) { top: 23px; transform: rotate(-45deg); }
    .pm-overlay { display: flex; flex-direction: column; justify-content: center; position: fixed; inset: 0; z-index: 10000; padding: 2rem 2.2rem;
      background: rgba(10,10,16,.94); backdrop-filter: blur(18px); -webkit-backdrop-filter: blur(18px);
      opacity: 0; visibility: hidden; transition: opacity .45s ease, visibility .45s; }
    .pm-overlay.pm-open { opacity: 1; visibility: visible; }
    .pm-nav { display: flex; flex-direction: column; gap: .4rem; }
    .pm-nav a { color: #fff; text-decoration: none; font-size: clamp(2rem, 9vw, 3rem); font-weight: 600; letter-spacing: -.02em; padding: .3rem 0;
      opacity: 0; transform: translateY(30px); transition: opacity .5s ease, transform .6s cubic-bezier(.2,.8,.2,1), color .2s; }
    .pm-nav a small { display: inline-block; width: 2.2rem; font-size: .8rem; font-weight: 400; letter-spacing: .1em; color: rgba(255,255,255,.45); vertical-align: middle; }
    .pm-nav a:active { color: #7aa2ff; }
    .pm-overlay.pm-open .pm-nav a { opacity: 1; transform: none; }
    .pm-overlay.pm-open .pm-nav a:nth-child(1) { transition-delay: .10s; }
    .pm-overlay.pm-open .pm-nav a:nth-child(2) { transition-delay: .16s; }
    .pm-overlay.pm-open .pm-nav a:nth-child(3) { transition-delay: .22s; }
    .pm-overlay.pm-open .pm-nav a:nth-child(4) { transition-delay: .28s; }
    .pm-overlay.pm-open .pm-nav a:nth-child(5) { transition-delay: .34s; }
    .pm-foot { position: absolute; left: 2.2rem; bottom: 2rem; margin: 0; font-size: .85rem; color: rgba(255,255,255,.5); }
    body.pm-lock { overflow: hidden; }
  }
</style>
<script>
(function () {
  var t = document.querySelector('.pm-toggle'), o = document.querySelector('.pm-overlay');
  if (!t || !o) return;
  function setOpen(open) {
    t.classList.toggle('pm-open', open); o.classList.toggle('pm-open', open);
    document.body.classList.toggle('pm-lock', open);
    t.setAttribute('aria-expanded', open ? 'true' : 'false');
    t.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
    o.setAttribute('aria-hidden', open ? 'false' : 'true');
  }
  t.addEventListener('click', function () { setOpen(!o.classList.contains('pm-open')); });
  o.querySelectorAll('a').forEach(function (a) { a.addEventListener('click', function () { setOpen(false); }); });
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape') setOpen(false); });
  window.addEventListener('resize', function () { if (window.innerWidth > 768) setOpen(false); });
})();
</script>

'@
if ($h.Contains('pm-toggle')) {
    'SKIP: menu already added'
} else {
    $i = $h.LastIndexOf('</body>')
    if ($i -ge 0) {
        $h = $h.Insert($i, $menu)
        'OK: premium menu'
    } else {
        'NOT FOUND: </body>'
    }
}

# --- Save ---
[System.IO.File]::WriteAllText($path, $h, $utf8)
'Saved index.html'