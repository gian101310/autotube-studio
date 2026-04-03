<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AutoTube Studio — Content Engine</title>
<link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Manrope:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
  :root {
    --bg: #060609; --surface: #0c0c12; --surface2: #111118;
    --border: rgba(255,255,255,0.06); --border2: rgba(255,255,255,0.1);
    --text: #e8e4df; --muted: rgba(255,255,255,0.4);
    --accent: #c8ff00; --red: #ff4757; --green: #2ed573;
    --serif: 'Instrument Serif', serif; --sans: 'Manrope', sans-serif; --mono: 'JetBrains Mono', monospace;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: var(--sans); background: var(--bg); color: var(--text); min-height: 100vh; -webkit-font-smoothing: antialiased; }
  a { color: inherit; text-decoration: none; }
  body::before {
    content: ''; position: fixed; inset: 0; z-index: 999; pointer-events: none;
    background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.03'/%3E%3C/svg%3E");
    background-repeat: repeat; opacity: 0.4;
  }
  @keyframes fadeUp { from { opacity:0; transform:translateY(20px); } to { opacity:1; transform:translateY(0); } }
  @keyframes spin { to { transform: rotate(360deg); } }
  @keyframes pulse { 0%,100%{opacity:1;} 50%{opacity:0.5;} }

  nav {
    position: sticky; top: 0; z-index: 100; padding: 14px 24px;
    display: flex; justify-content: space-between; align-items: center;
    background: rgba(6,6,9,0.9); backdrop-filter: blur(20px); border-bottom: 1px solid var(--border);
  }
  .nav-logo { font-family: var(--serif); font-size: 22px; }
  .nav-logo span { color: var(--accent); }
  .nav-back { font-size: 13px; font-weight: 500; color: var(--muted); }
  .nav-back:hover { color: var(--text); }

  .app-container { max-width: 1200px; margin: 0 auto; padding: 32px 24px; }

  /* ─── Cards ─── */
  .card {
    background: var(--surface); border: 1px solid var(--border); border-radius: 16px;
    padding: 24px 28px; margin-bottom: 20px; animation: fadeUp 0.5s ease both;
  }
  .card h3 { font-size: 15px; font-weight: 700; margin-bottom: 16px; }
  .card-sub { font-size: 12px; color: var(--muted); margin-bottom: 14px; line-height: 1.5; }
  .card-sub a { color: var(--accent); text-decoration: underline; }

  /* ─── Provider ─── */
  .ptabs { display: flex; gap: 8px; margin-bottom: 20px; flex-wrap: wrap; }
  .ptab {
    padding: 10px 20px; border-radius: 10px; border: 1px solid var(--border);
    background: transparent; color: var(--muted); font-size: 13px; font-weight: 600;
    cursor: pointer; transition: all 0.2s; display: flex; align-items: center; gap: 8px; font-family: var(--sans);
  }
  .ptab:hover { border-color: var(--border2); color: var(--text); }
  .ptab.active { border-color: var(--accent); color: var(--accent); background: rgba(200,255,0,0.04); }
  .pdot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }

  .row { display: flex; gap: 10px; }
  .inp {
    flex: 1; padding: 11px 14px; border-radius: 10px; border: 1px solid var(--border);
    background: rgba(255,255,255,0.03); color: var(--text); font-size: 13px;
    font-family: var(--mono); outline: none;
  }
  .inp:focus { border-color: var(--accent); }
  .inp::placeholder { color: rgba(255,255,255,0.2); }
  .inp-text { font-family: var(--sans); font-size: 14px; }
  .btn-save {
    padding: 11px 20px; border-radius: 10px; border: none; background: var(--accent);
    color: #000; font-size: 13px; font-weight: 700; cursor: pointer; white-space: nowrap;
  }
  .btn-save:hover { box-shadow: 0 2px 12px rgba(200,255,0,0.3); }
  .mrow { display: flex; gap: 10px; margin-top: 12px; align-items: center; }
  .mrow label { font-size: 11px; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: var(--muted); white-space: nowrap; }
  .msel {
    flex: 1; padding: 9px 12px; border-radius: 8px; border: 1px solid var(--border);
    background: rgba(255,255,255,0.03); color: var(--text); font-size: 13px;
    font-family: var(--sans); outline: none; appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,0.3)' stroke-width='2'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
    background-repeat: no-repeat; background-position: right 12px center;
  }
  .msel option { background: var(--surface); }
  .status { font-size: 12px; margin-top: 8px; }
  .status.ok { color: var(--accent); } .status.err { color: var(--red); }

  /* ─── Controls ─── */
  .controls-header { font-family: var(--serif); font-size: 28px; margin-bottom: 20px; }
  .grid2 { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  .grid3 { display: grid; grid-template-columns: 1fr 1fr auto; gap: 14px; align-items: end; }
  .field label {
    display: block; font-size: 11px; font-weight: 700; letter-spacing: 1.5px;
    text-transform: uppercase; color: var(--muted); margin-bottom: 8px;
  }
  .sel {
    width: 100%; padding: 12px 14px; border-radius: 10px; border: 1px solid var(--border);
    background: rgba(255,255,255,0.03); color: var(--text); font-size: 14px;
    font-family: var(--sans); outline: none; appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,0.3)' stroke-width='2'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
    background-repeat: no-repeat; background-position: right 14px center;
  }
  .sel option { background: var(--surface); }
  .num-inp {
    width: 100%; padding: 12px 14px; border-radius: 10px; border: 1px solid var(--border);
    background: rgba(255,255,255,0.03); color: var(--text); font-size: 14px;
    font-family: var(--sans); outline: none;
  }
  .num-inp:focus, .sel:focus { border-color: var(--accent); }
  .textarea {
    width: 100%; padding: 12px 14px; border-radius: 10px; border: 1px solid var(--border);
    background: rgba(255,255,255,0.03); color: var(--text); font-size: 13px;
    font-family: var(--sans); outline: none; resize: vertical; min-height: 70px; line-height: 1.5;
  }
  .textarea:focus { border-color: var(--accent); }
  .textarea::placeholder { color: rgba(255,255,255,0.2); }

  .gen-btn {
    padding: 12px 32px; border-radius: 10px; border: none; background: var(--accent);
    color: #000; font-size: 15px; font-weight: 800; cursor: pointer; transition: all 0.2s;
    height: fit-content; display: flex; align-items: center; gap: 8px;
  }
  .gen-btn:hover:not(:disabled) { transform: translateY(-1px); box-shadow: 0 4px 20px rgba(200,255,0,0.35); }
  .gen-btn:disabled { opacity: 0.5; cursor: not-allowed; }
  .spinner { width: 16px; height: 16px; border: 2px solid rgba(0,0,0,0.2); border-top-color: #000; border-radius: 50%; animation: spin 0.6s linear infinite; }

  .toggle-row { display: flex; align-items: center; gap: 10px; margin-top: 12px; }
  .toggle-label { font-size: 13px; font-weight: 600; color: var(--muted); }
  .toggle {
    width: 40px; height: 22px; border-radius: 11px; border: none;
    background: rgba(255,255,255,0.1); cursor: pointer; position: relative; transition: background 0.2s;
  }
  .toggle.on { background: var(--accent); }
  .toggle::after {
    content: ''; position: absolute; top: 3px; left: 3px; width: 16px; height: 16px;
    border-radius: 50%; background: white; transition: transform 0.2s;
  }
  .toggle.on::after { transform: translateX(18px); }

  .hidden { display: none; }

  /* ─── Progress ─── */
  .pbar { height: 4px; background: var(--surface2); border-radius: 4px; margin-bottom: 20px; overflow: hidden; display: none; }
  .pbar.active { display: block; }
  .pfill { height: 100%; background: var(--accent); border-radius: 4px; transition: width 0.5s ease; width: 0%; }
  .ptxt { font-size: 12px; color: var(--muted); text-align: center; margin-bottom: 16px; display: none; }
  .ptxt.active { display: block; animation: pulse 1.5s infinite; }

  /* ─── Results ─── */
  .rhead { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; flex-wrap: wrap; gap: 12px; }
  .rhead h2 { font-family: var(--serif); font-size: 24px; }
  .ractions { display: flex; gap: 8px; }
  .rbtn {
    padding: 8px 18px; border-radius: 8px; border: 1px solid var(--border); background: transparent;
    color: var(--text); font-size: 12px; font-weight: 600; cursor: pointer;
  }
  .rbtn:hover { border-color: var(--accent); color: var(--accent); }

  .vcard {
    background: var(--surface); border: 1px solid var(--border); border-radius: 16px;
    margin-bottom: 16px; overflow: hidden;
  }
  .vcard:hover { border-color: rgba(200,255,0,0.1); }
  .vhead {
    padding: 20px 24px; display: flex; justify-content: space-between; align-items: center;
    cursor: pointer; user-select: none;
  }
  .vhead:hover { background: rgba(255,255,255,0.01); }
  .vday {
    font-size: 11px; font-weight: 800; letter-spacing: 2px; text-transform: uppercase;
    color: var(--accent); background: rgba(200,255,0,0.08); padding: 3px 10px;
    border-radius: 6px; margin-right: 12px; flex-shrink: 0;
  }
  .vtitle { font-size: 16px; font-weight: 700; flex: 1; }
  .vtog { font-size: 20px; color: var(--muted); transition: transform 0.2s; flex-shrink: 0; }
  .vcard.open .vtog { transform: rotate(45deg); }
  .vbody { display: none; padding: 0 24px 24px; }
  .vcard.open .vbody { display: block; }

  .sb { margin-bottom: 20px; }
  .sbl { font-size: 10px; font-weight: 800; letter-spacing: 2px; text-transform: uppercase; color: var(--accent); margin-bottom: 8px; }
  .sbc {
    font-size: 14px; line-height: 1.7; color: rgba(255,255,255,0.7);
    background: var(--surface2); border: 1px solid var(--border); border-radius: 10px;
    padding: 16px; position: relative; white-space: pre-wrap; word-wrap: break-word;
  }
  .cbtn {
    position: absolute; top: 8px; right: 8px; padding: 4px 10px; border-radius: 6px;
    border: 1px solid var(--border); background: var(--surface); color: var(--muted);
    font-size: 11px; font-weight: 600; cursor: pointer; opacity: 0;
  }
  .sbc:hover .cbtn { opacity: 1; }
  .cbtn:hover { border-color: var(--accent); color: var(--accent); }
  .cbtn.done { color: var(--accent); border-color: var(--accent); }

  .visual-cue { color: var(--accent); font-size: 12px; font-weight: 700; display: block; margin: 6px 0; padding: 6px 10px; background: rgba(200,255,0,0.04); border-radius: 6px; border-left: 3px solid var(--accent); }
  .neg-prompt { color: var(--red); font-size: 12px; font-style: italic; margin-top: 6px; opacity: 0.8; }
  .cta-block { background: rgba(200,255,0,0.04); border: 1px solid rgba(200,255,0,0.1); border-radius: 8px; padding: 12px; margin-top: 8px; }
  .cta-block strong { color: var(--accent); }

  .tags { display: flex; flex-wrap: wrap; gap: 6px; }
  .tag { padding: 4px 12px; border-radius: 100px; font-size: 12px; font-weight: 600; background: rgba(200,255,0,0.06); border: 1px solid rgba(200,255,0,0.1); color: var(--accent); }

  .empty-state { text-align: center; padding: 80px 24px; }
  .empty-icon { font-size: 64px; margin-bottom: 16px; opacity: 0.3; }
  .empty-title { font-family: var(--serif); font-size: 28px; margin-bottom: 8px; color: rgba(255,255,255,0.3); }
  .empty-sub { font-size: 14px; color: rgba(255,255,255,0.2); }

  .char-ref { background: rgba(100,100,255,0.05); border: 1px solid rgba(100,100,255,0.15); border-radius: 10px; padding: 14px; margin-bottom: 16px; }
  .char-ref-title { font-size: 11px; font-weight: 800; letter-spacing: 2px; text-transform: uppercase; color: #7b8cff; margin-bottom: 6px; }
  .char-ref-text { font-size: 13px; line-height: 1.6; color: rgba(255,255,255,0.6); }

  @media (max-width: 768px) {
    .grid2, .grid3 { grid-template-columns: 1fr; }
    .gen-btn { width: 100%; justify-content: center; }
    .row { flex-direction: column; }
    .ptabs { flex-direction: column; }
    .mrow { flex-direction: column; align-items: stretch; }
  }
</style>
</head>
<body>

<nav>
  <a href="index.html" class="nav-logo">Auto<span>Tube</span></a>
  <a href="index.html" class="nav-back">&larr; Home</a>
</nav>

<div class="app-container">

  <!-- PROVIDER -->
  <div class="card">
    <h3>&#9889; AI Provider</h3>
    <div class="ptabs" id="ptabs">
      <button class="ptab active" data-p="anthropic" onclick="setP('anthropic')"><span class="pdot" style="background:#d4a574"></span> Claude</button>
      <button class="ptab" data-p="openai" onclick="setP('openai')"><span class="pdot" style="background:#10a37f"></span> ChatGPT</button>
      <button class="ptab" data-p="gemini" onclick="setP('gemini')"><span class="pdot" style="background:#4285f4"></span> Gemini</button>
    </div>
    <div id="p-anthropic">
      <div class="card-sub">Get key: <a href="https://console.anthropic.com/" target="_blank">console.anthropic.com</a> &mdash; $5 min, ~$0.03/gen</div>
      <div class="row"><input type="password" class="inp" id="key-anthropic" placeholder="sk-ant-api03-..."><button class="btn-save" onclick="saveK('anthropic')">Save</button></div>
      <div class="mrow"><label>Model</label><select class="msel" id="mod-anthropic"><option value="claude-sonnet-4-20250514">Sonnet 4</option><option value="claude-opus-4-20250514">Opus 4</option><option value="claude-haiku-4-5-20251001">Haiku 4.5</option></select></div>
      <div class="status" id="st-anthropic"></div>
    </div>
    <div id="p-openai" class="hidden">
      <div class="card-sub">Get key: <a href="https://platform.openai.com/api-keys" target="_blank">platform.openai.com</a> &mdash; pay-as-you-go</div>
      <div class="row"><input type="password" class="inp" id="key-openai" placeholder="sk-proj-..."><button class="btn-save" onclick="saveK('openai')">Save</button></div>
      <div class="mrow"><label>Model</label><select class="msel" id="mod-openai"><option value="gpt-4o">GPT-4o</option><option value="gpt-4o-mini">GPT-4o Mini</option><option value="gpt-4.1">GPT-4.1</option></select></div>
      <div class="status" id="st-openai"></div>
    </div>
    <div id="p-gemini" class="hidden">
      <div class="card-sub">Get key: <a href="https://aistudio.google.com/apikey" target="_blank">aistudio.google.com</a> &mdash; free tier!</div>
      <div class="row"><input type="password" class="inp" id="key-gemini" placeholder="AIza..."><button class="btn-save" onclick="saveK('gemini')">Save</button></div>
      <div class="mrow"><label>Model</label><select class="msel" id="mod-gemini"><option value="gemini-2.0-flash">2.0 Flash</option><option value="gemini-2.5-pro-preview-05-06">2.5 Pro</option><option value="gemini-2.0-flash-lite">2.0 Flash Lite</option></select></div>
      <div class="status" id="st-gemini"></div>
    </div>
  </div>

  <!-- CONTENT SETTINGS -->
  <div class="card" style="animation-delay:0.1s;">
    <div class="controls-header">Content Engine</div>
    <div class="grid2">
      <div class="field"><label>Niche / Topic</label>
        <select class="sel" id="nicheSelect" onchange="document.getElementById('customWrap').classList.toggle('hidden', this.value!=='custom')">
          <option value="stoic_wisdom">&#127963;&#65039; Stoic Wisdom</option>
          <option value="mind_blowing_facts">&#129504; Mind-Blowing Facts</option>
          <option value="scary_stories">&#128123; Scary Stories</option>
          <option value="money_secrets">&#128176; Money &amp; Finance</option>
          <option value="ai_art">&#127912; AI Art &amp; Tech</option>
          <option value="top_10">&#128293; Top 10 Lists</option>
          <option value="dark_history">&#128220; Dark History</option>
          <option value="cosmic_mysteries">&#128640; Space &amp; Cosmos</option>
          <option value="mind_tricks">&#129513; Psychology</option>
          <option value="nature_scary">&#127754; Nature is Scary</option>
          <option value="motivation">&#128170; Motivation</option>
          <option value="conspiracy">&#128065;&#65039; Mysteries</option>
          <option value="custom">&#9997;&#65039; Custom</option>
        </select>
      </div>
      <div class="field"><label>Videos</label><input type="number" class="num-inp" id="numVids" value="7" min="1" max="30"></div>
    </div>
    <div id="customWrap" class="hidden" style="margin-top:14px;">
      <div class="field"><label>Custom Niche</label><input type="text" class="inp inp-text" id="customNiche" placeholder="e.g. Ancient Egypt secrets, Crypto psychology, Relationship red flags..."></div>
    </div>

    <!-- Series toggle -->
    <div class="toggle-row">
      <button class="toggle" id="seriesTog" onclick="this.classList.toggle('on');document.getElementById('seriesOpts').classList.toggle('hidden')"></button>
      <span class="toggle-label">Series Mode (consistent character + episode numbering)</span>
    </div>
    <div id="seriesOpts" class="hidden" style="margin-top:14px;">
      <div class="grid2">
        <div class="field"><label>Series Name</label><input type="text" class="inp inp-text" id="seriesName" placeholder="e.g. The Stoic Chronicles, Dark History Files..."></div>
        <div class="field"><label>Starting Episode #</label><input type="number" class="num-inp" id="startEp" value="1" min="1"></div>
      </div>
      <div class="field" style="margin-top:14px;"><label>Character Description (used in EVERY image prompt for consistency)</label>
        <textarea class="textarea" id="charDesc" placeholder="e.g. A wise old man with a long white beard, wearing dark robes, standing in a marble temple. Photorealistic, cinematic lighting, dark moody atmosphere. He has deep-set eyes and weathered skin."></textarea>
      </div>
      <div class="field" style="margin-top:14px;"><label>Reference Image Prompt Style (applied to all generations)</label>
        <textarea class="textarea" id="styleRef" placeholder="e.g. Hyper-realistic digital art, cinematic color grading, volumetric lighting, 8K, dramatic shadows, shot on ARRI Alexa, shallow depth of field, dark academia aesthetic"></textarea>
      </div>
    </div>

    <!-- AI Image tool preference -->
    <div class="field" style="margin-top:18px;"><label>Image Generation Tool (prompts optimized for)</label>
      <select class="sel" id="imgTool">
        <option value="midjourney">Midjourney</option>
        <option value="dalle">DALL-E 3</option>
        <option value="flux">Flux</option>
        <option value="leonardo">Leonardo AI</option>
        <option value="ideogram">Ideogram</option>
        <option value="stable_diffusion">Stable Diffusion / ComfyUI</option>
        <option value="generic">Generic (works with any)</option>
      </select>
    </div>

    <!-- Generate -->
    <div style="margin-top:20px; display:flex; justify-content:flex-end;">
      <button class="gen-btn" id="genBtn" onclick="generate()">
        <span id="btnTxt">Generate Content</span>
        <div class="spinner" id="btnSpin" style="display:none;"></div>
      </button>
    </div>
  </div>

  <!-- Progress -->
  <div class="pbar" id="pbar"><div class="pfill" id="pfill"></div></div>
  <div class="ptxt" id="ptxt"></div>

  <!-- Results -->
  <div id="resultsArea">
    <div class="empty-state">
      <div class="empty-icon">&#127916;</div>
      <div class="empty-title">Ready to create</div>
      <div class="empty-sub">Configure your niche, enable series mode if needed, and generate.</div>
    </div>
  </div>
</div>

<script>
let AP = 'anthropic', results = [];

const NICHES = {
  stoic_wisdom: "Stoic Wisdom & Philosophy — deep quotes and life lessons from Marcus Aurelius, Seneca, Epictetus",
  mind_blowing_facts: "Mind-Blowing Facts — shocking real facts that make people stop and question everything",
  scary_stories: "Scary Stories & Creepypasta — dark, eerie horror narratives with suspense and chills",
  money_secrets: "Money Secrets & Wealth Psychology — hidden finance truths the rich don't share",
  ai_art: "AI Art & Future Technology — stunning AI-generated worlds and tech predictions",
  top_10: "Top 10 Lists — fascinating rankings and comparisons on any topic",
  dark_history: "Dark History — disturbing real events they never taught in school",
  cosmic_mysteries: "Cosmic Mysteries & Space — terrifying and awe-inspiring facts about the universe",
  mind_tricks: "Psychology & Mind Tricks — how your brain deceives you and cognitive biases",
  nature_scary: "Nature is Scary — terrifying animals, natural phenomena, and survival stories",
  motivation: "Motivation & Discipline — hard-hitting self-improvement content with intensity",
  conspiracy: "Mysteries & Unexplained — real events and phenomena that still have no explanation",
};

const IMG_TOOL_HINTS = {
  midjourney: "Format the prompt for Midjourney v6+. Use --ar 9:16 for vertical, --ar 16:9 for thumbnail. Include --style raw for photorealism. Use :: for emphasis weighting. Include --no for negative prompts.",
  dalle: "Format for DALL-E 3. Be extremely descriptive and literal. Specify 'photorealistic' or 'digital art' style. Mention camera and lens. No special syntax needed.",
  flux: "Format for Flux (Black Forest Labs). Be descriptive and natural language. Specify resolution and aspect ratio in the prompt text. Works best with detailed scene descriptions.",
  leonardo: "Format for Leonardo AI. Include style keywords like 'cinematic', 'photorealistic'. Provide negative prompt separately. Suggest a Leonardo model (DreamShaper, PhotoReal, etc).",
  ideogram: "Format for Ideogram. Good at text rendering. Be specific about any text that should appear in the image. Describe composition clearly.",
  stable_diffusion: "Format for Stable Diffusion / ComfyUI. Use comma-separated keyword style. Include quality tags (masterpiece, best quality, 8k). Provide negative prompt separately with standard SD negative tags.",
  generic: "Write a detailed, natural language description that works with any AI image generator. Be extremely specific about composition, lighting, mood, colors, and style."
};

// ─── Init ───
document.addEventListener('DOMContentLoaded', () => {
  ['anthropic','openai','gemini'].forEach(p => {
    const k = localStorage.getItem('at2_k_'+p); if(k) document.getElementById('key-'+p).value = k;
    const m = localStorage.getItem('at2_m_'+p); if(m) { const s=document.getElementById('mod-'+p); for(let o of s.options) if(o.value===m) s.value=m; }
  });
  // Restore series settings
  const sd = localStorage.getItem('at2_series'); if(sd) { try { const d=JSON.parse(sd); if(d.charDesc) document.getElementById('charDesc').value=d.charDesc; if(d.styleRef) document.getElementById('styleRef').value=d.styleRef; if(d.seriesName) document.getElementById('seriesName').value=d.seriesName; } catch(e){} }
  const it = localStorage.getItem('at2_imgtool'); if(it) document.getElementById('imgTool').value=it;
});

function setP(p) { AP=p; document.querySelectorAll('.ptab').forEach(t=>t.classList.toggle('active',t.dataset.p===p)); ['anthropic','openai','gemini'].forEach(x=>document.getElementById('p-'+x).classList.toggle('hidden',x!==p)); }
function saveK(p) { const k=document.getElementById('key-'+p).value.trim(); if(!k){st(p,'Enter a key.','err');return;} localStorage.setItem('at2_k_'+p,k); localStorage.setItem('at2_m_'+p,document.getElementById('mod-'+p).value); st(p,'Saved.','ok'); }
function st(p,m,t) { const e=document.getElementById('st-'+p); e.textContent=m; e.className='status '+t; }
function gK(p) { return document.getElementById('key-'+p).value.trim()||localStorage.getItem('at2_k_'+p)||''; }
function gM(p) { return document.getElementById('mod-'+p).value; }

// ─── Build the MEGA prompt ───
function buildPrompt(niche, num) {
  const isSeries = document.getElementById('seriesTog').classList.contains('on');
  const seriesName = document.getElementById('seriesName').value.trim();
  const startEp = parseInt(document.getElementById('startEp').value) || 1;
  const charDesc = document.getElementById('charDesc').value.trim();
  const styleRef = document.getElementById('styleRef').value.trim();
  const imgTool = document.getElementById('imgTool').value;
  const imgHint = IMG_TOOL_HINTS[imgTool];

  // Save preferences
  localStorage.setItem('at2_series', JSON.stringify({charDesc, styleRef, seriesName}));
  localStorage.setItem('at2_imgtool', imgTool);

  let prompt = `You are AutoTube — the world's best YouTube Shorts content strategist and scriptwriter. You create VIRAL, scroll-stopping, emotionally compelling content that gets millions of views.

## YOUR TASK
Generate exactly ${num} unique YouTube Shorts video scripts for this niche: "${niche}"

## QUALITY STANDARDS — THIS IS CRITICAL
Every piece of content must be:
- VIRAL-WORTHY: Use proven psychological triggers (curiosity gap, shock value, emotional hooks, open loops)
- COPY-PASTE READY: The user pastes your output directly into their workflow with ZERO editing
- HYPER-DETAILED: Every visual scene must be described shot-by-shot so anyone can recreate it
- SEO-OPTIMIZED: Titles, descriptions, and hashtags must be researched-level quality

`;

  if (isSeries) {
    prompt += `## SERIES MODE — ACTIVE
Series name: "${seriesName || 'Untitled Series'}"
Episode numbers: ${startEp} through ${startEp + num - 1}
- Every title MUST include the series name and episode number
- Maintain narrative continuity between episodes
- Each episode should have a cliffhanger or teaser for the next
- Include "Part X" or "Ep X" in every title

`;
    if (charDesc) {
      prompt += `## CHARACTER REFERENCE — USE THIS EXACT DESCRIPTION IN EVERY IMAGE PROMPT
${charDesc}
- This SAME character must appear in every single image prompt
- Copy this description VERBATIM into each image prompt to ensure visual consistency
- The character's appearance, clothing, and setting must remain identical across all episodes

`;
    }
    if (styleRef) {
      prompt += `## VISUAL STYLE REFERENCE — APPLY TO ALL IMAGE PROMPTS
${styleRef}
- This style must be applied consistently to ALL image prompts (scene images AND thumbnails)

`;
    }
  }

  prompt += `## IMAGE PROMPT FORMAT
${imgHint}
- ALL image prompts must include: subject, action/pose, environment, lighting, camera angle, color palette, mood, texture/detail level
- ALWAYS include a NEGATIVE PROMPT section that explicitly lists what to AVOID (bad anatomy, extra fingers, blurry, text, watermark, low quality, deformed, ugly, duplicate, cropped, etc.)
- For vertical shorts scenes: specify 9:16 aspect ratio
- For thumbnails: specify 16:9 aspect ratio

## OUTPUT FORMAT
Return ONLY a valid JSON array. No markdown fences. No explanation. Just the JSON.

Each object in the array must have these EXACT fields:

{
  "day": (number),
  "title": (YouTube title — max 60 chars, includes keywords, creates curiosity gap),
  "hook_primary": (THE most important line — the first 2-3 seconds. Must create an IRRESISTIBLE curiosity gap or shock. Start with 'Did you know...', 'This will change...', 'Nobody talks about...', 'Stop scrolling if...', etc. Max 15 words.),
  "hook_alt": (completely different angle/approach for the same video — NOT a rephrasing, a totally different hook strategy),
  "script": (FULL narration script, 50-60 seconds when read aloud at natural pace, 130-160 words. Structure: HOOK (0-3s) → CONTEXT (3-10s) → CORE CONTENT with 2-3 key reveals (10-45s) → PAYOFF/TWIST (45-55s) → CTA (55-60s). Include [PAUSE 1s] for dramatic beats. Include tone directions like [whisper], [intense], [slow down], [speed up].),
  "scenes": [
    {
      "timestamp": "0:00-0:03",
      "narration": (exact words spoken during this scene),
      "visual": (EXTREMELY detailed shot description — camera angle, subject position, background elements, colors, motion/animation, text overlays if any, transition from previous scene),
      "image_prompt": (complete, ready-to-paste AI image generation prompt for this exact scene, including style, lighting, composition, and the tool-specific formatting),
      "negative_prompt": (what to exclude from the image — bad quality markers, unwanted elements)
    }
  ],
  "thumbnail": {
    "text_overlay": (2-5 BOLD words that create maximum curiosity — use CAPS, numbers, or power words),
    "text_color": (hex color for the text),
    "text_position": (where text goes: 'center', 'top-left', 'bottom-right', etc.),
    "image_prompt": (DETAILED thumbnail background prompt — must be eye-catching, high contrast, emotional. 16:9 ratio.),
    "negative_prompt": (what to avoid in thumbnail image),
    "design_notes": (brief notes on thumbnail composition — e.g. 'red arrow pointing at subject', 'shocked face expression', 'before/after split')
  },
  "cta": {
    "spoken": (exact CTA words in the script — e.g. 'Follow for Part 2 tomorrow'),
    "text_overlay": (on-screen text CTA — e.g. 'FOLLOW + LIKE for more'),
    "strategy": (why this CTA works — e.g. 'Creates anticipation for series continuation')
  },
  "seo": {
    "description": (2-3 keyword-rich sentences for YouTube description + relevant links/CTAs),
    "hashtags": ["#shorts", plus 4 more niche-specific trending hashtags],
    "tags": [10 YouTube search tags/keywords for discoverability],
    "best_posting_time": (suggested posting time in EST/UTC based on niche audience)
  }${isSeries ? `,
  "series_meta": {
    "episode_number": (number),
    "recap": (1 sentence connecting to previous episode — skip for ep 1),
    "cliffhanger": (teaser line for next episode),
    "character_note": (any character development or new detail introduced this episode)
  }` : ''}
}

## CRITICAL RULES
1. Each video must be COMPLETELY unique — different angles, facts, stories. No overlap.
2. Scripts must sound NATURAL when read aloud — conversational, punchy, no robotic language.
3. EVERY scene image_prompt must be detailed enough to generate a consistent, high-quality image with NO ambiguity.
4. Hooks must use PROVEN viral patterns: curiosity gaps, challenges to beliefs, shocking reveals, emotional triggers.
5. Negative prompts must be thorough — always include: blurry, low quality, watermark, text, bad anatomy, extra limbs, deformed, ugly, duplicate, cropped, out of frame.
6. Scenes array should have 4-6 scenes per video covering the full duration.
7. Thumbnail must be DRAMATICALLY different from scene images — designed to maximize CTR.
8. ALL content must be factually accurate and not misleading.
9. SEO tags must include a mix of high-volume and long-tail keywords.
10. Each CTA must feel natural, not forced — integrate it into the narrative.`;

  return prompt;
}

// ─── API Calls ───
async function callAPI(prompt, key, model) {
  if (AP === 'anthropic') {
    const r = await fetch('https://api.anthropic.com/v1/messages', {
      method:'POST', headers:{'Content-Type':'application/json','x-api-key':key,'anthropic-version':'2023-06-01','anthropic-dangerous-direct-browser-access':'true'},
      body: JSON.stringify({model, max_tokens:16000, messages:[{role:'user',content:prompt}]})
    });
    if(!r.ok){const e=await r.json().catch(()=>({}));throw new Error(e.error?.message||'API error '+r.status);}
    const d=await r.json(); return d.content.map(c=>c.text||'').join('');
  } else if (AP === 'openai') {
    const r = await fetch('https://api.openai.com/v1/chat/completions', {
      method:'POST', headers:{'Content-Type':'application/json','Authorization':'Bearer '+key},
      body: JSON.stringify({model, max_tokens:16000, messages:[{role:'system',content:'You are AutoTube, an elite content strategist. Return only valid JSON arrays.'},{role:'user',content:prompt}]})
    });
    if(!r.ok){const e=await r.json().catch(()=>({}));throw new Error(e.error?.message||'API error '+r.status);}
    const d=await r.json(); return d.choices[0].message.content;
  } else {
    const url=`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${key}`;
    const r = await fetch(url, {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({contents:[{parts:[{text:prompt}]}], generationConfig:{maxOutputTokens:16000}})
    });
    if(!r.ok){const e=await r.json().catch(()=>({}));throw new Error(e.error?.message||'API error '+r.status);}
    const d=await r.json(); return d.candidates[0].content.parts.map(p=>p.text||'').join('');
  }
}

// ─── Generate ───
async function generate() {
  const key=gK(AP); if(!key){st(AP,'Enter key first.','err');document.getElementById('key-'+AP).focus();return;}
  localStorage.setItem('at2_k_'+AP,key); localStorage.setItem('at2_m_'+AP,gM(AP));
  const nk=document.getElementById('nicheSelect').value;
  let niche=NICHES[nk]; if(nk==='custom'){niche=document.getElementById('customNiche').value.trim();if(!niche){alert('Enter niche.');return;}}
  const num=Math.min(Math.max(parseInt(document.getElementById('numVids').value)||7,1),30);
  const model=gM(AP);

  const btn=document.getElementById('genBtn'),bt=document.getElementById('btnTxt'),sp=document.getElementById('btnSpin');
  btn.disabled=true; bt.textContent='Generating...'; sp.style.display='block';
  const names={anthropic:'Claude',openai:'ChatGPT',gemini:'Gemini'};
  prog(true,10,`Building content strategy...`);

  try {
    prog(true,20,`Sending to ${names[AP]} (${model})...`);
    const prompt=buildPrompt(niche,num);
    prog(true,40,`Generating ${num} video packages — this takes 30-60s...`);
    const raw=await callAPI(prompt,key,model);
    prog(true,80,'Parsing content...');

    let clean=raw.replace(/```json\s*/g,'').replace(/```\s*/g,'').trim();
    const s=clean.indexOf('['),e=clean.lastIndexOf(']');
    if(s!==-1&&e!==-1) clean=clean.slice(s,e+1);
    results=JSON.parse(clean);

    prog(true,100,'Done!');
    setTimeout(()=>prog(false),500);
    st(AP,`${results.length} videos generated with ${model}.`,'ok');
    render(results);
  } catch(err) {
    console.error(err); prog(false);
    if(err.message.includes('401')||err.message.includes('auth')) st(AP,'Invalid API key.','err');
    else if(err instanceof SyntaxError) st(AP,'Parse error — try again or switch model.','err');
    else st(AP,err.message,'err');
  } finally { btn.disabled=false; bt.textContent='Generate Content'; sp.style.display='none'; }
}

// ─── Render ───
function render(vids) {
  const isSeries = document.getElementById('seriesTog').classList.contains('on');
  const charDesc = document.getElementById('charDesc').value.trim();

  let h = `<div class="rhead"><h2>${vids.length} Videos Generated</h2><div class="ractions"><button class="rbtn" onclick="expCSV()">&#128196; CSV</button><button class="rbtn" onclick="cpAll()">&#128203; Copy All</button></div></div>`;

  if (isSeries && charDesc) {
    h += `<div class="char-ref"><div class="char-ref-title">&#127912; Series Character Reference</div><div class="char-ref-text">${esc(charDesc)}</div></div>`;
  }

  vids.forEach((v, i) => {
    const ep = v.series_meta?.episode_number || v.day || i+1;
    const dayLabel = isSeries ? `EP ${ep}` : `Day ${v.day||i+1}`;

    h += `<div class="vcard${i===0?' open':''}" id="c${i}">
      <div class="vhead" onclick="document.getElementById('c${i}').classList.toggle('open')">
        <div style="display:flex;align-items:center;flex:1;min-width:0;">
          <span class="vday">${dayLabel}</span>
          <span class="vtitle">${esc(v.title)}</span>
        </div>
        <span class="vtog">+</span>
      </div>
      <div class="vbody">`;

    // Hooks
    h += `<div class="sb"><div class="sbl">&#127907; HOOKS</div><div class="sbc" id="hk${i}"><button class="cbtn" onclick="cp(this,'hk${i}')">Copy</button>
      <div style="margin-bottom:8px"><strong style="color:var(--accent)">PRIMARY:</strong> ${esc(v.hook_primary||v.hook_1||'')}</div>
      <div><strong style="color:var(--muted)">ALT:</strong> ${esc(v.hook_alt||v.hook_2||'')}</div>
    </div></div>`;

    // Script
    h += `<div class="sb"><div class="sbl">&#128221; FULL SCRIPT</div><div class="sbc" id="sc${i}"><button class="cbtn" onclick="cp(this,'sc${i}')">Copy</button>${fmtScript(v.script)}</div></div>`;

    // Scenes
    if (v.scenes && v.scenes.length) {
      h += `<div class="sb"><div class="sbl">&#127916; SCENE-BY-SCENE BREAKDOWN</div>`;
      v.scenes.forEach((sc, si) => {
        h += `<div class="sbc" id="sn${i}_${si}" style="margin-bottom:10px;">
          <button class="cbtn" onclick="cp(this,'sn${i}_${si}')">Copy</button>
          <div style="color:var(--accent);font-weight:800;font-size:11px;letter-spacing:1px;margin-bottom:6px;">SCENE ${si+1} ${sc.timestamp?'— '+esc(sc.timestamp):''}</div>
          ${sc.narration?`<div style="margin-bottom:8px;"><strong style="color:#7b8cff">Narration:</strong> "${esc(sc.narration)}"</div>`:''}
          ${sc.visual?`<div class="visual-cue">${esc(sc.visual)}</div>`:''}
          ${sc.image_prompt?`<div style="margin-top:8px;"><strong style="color:var(--muted)">Image Prompt:</strong><br><span style="color:rgba(255,255,255,0.55);font-size:13px;">${esc(sc.image_prompt)}</span></div>`:''}
          ${sc.negative_prompt?`<div class="neg-prompt">&#10060; Negative: ${esc(sc.negative_prompt)}</div>`:''}
        </div>`;
      });
      h += `</div>`;
    }

    // Thumbnail
    const th = v.thumbnail || {};
    h += `<div class="sb"><div class="sbl">&#128444;&#65039; THUMBNAIL</div><div class="sbc" id="th${i}"><button class="cbtn" onclick="cp(this,'th${i}')">Copy</button>
      <div style="margin-bottom:6px"><strong style="color:var(--accent)">Text:</strong> ${esc(th.text_overlay||v.thumbnail_text||'')}</div>
      ${th.text_color?`<div style="margin-bottom:6px"><strong style="color:var(--muted)">Color:</strong> <span style="background:${esc(th.text_color)};padding:1px 8px;border-radius:4px;">${esc(th.text_color)}</span></div>`:''}
      ${th.text_position?`<div style="margin-bottom:6px"><strong style="color:var(--muted)">Position:</strong> ${esc(th.text_position)}</div>`:''}
      ${th.design_notes?`<div style="margin-bottom:8px;font-size:12px;color:rgba(255,255,255,0.5);">Design: ${esc(th.design_notes)}</div>`:''}
      <div style="margin-top:8px"><strong style="color:var(--muted)">Image Prompt:</strong><br><span style="color:rgba(255,255,255,0.55);font-size:13px;">${esc(th.image_prompt||v.thumbnail_prompt||'')}</span></div>
      ${th.negative_prompt?`<div class="neg-prompt">&#10060; Negative: ${esc(th.negative_prompt)}</div>`:''}
    </div></div>`;

    // CTA
    const cta = v.cta || {};
    if (cta.spoken || cta.text_overlay) {
      h += `<div class="sb"><div class="sbl">&#128226; CALL TO ACTION</div><div class="cta-block">
        ${cta.spoken?`<div style="margin-bottom:6px"><strong style="color:var(--accent)">Spoken:</strong> "${esc(cta.spoken)}"</div>`:''}
        ${cta.text_overlay?`<div style="margin-bottom:6px"><strong style="color:var(--muted)">On-Screen:</strong> ${esc(cta.text_overlay)}</div>`:''}
        ${cta.strategy?`<div style="font-size:12px;color:rgba(255,255,255,0.4);font-style:italic;">Strategy: ${esc(cta.strategy)}</div>`:''}
      </div></div>`;
    }

    // SEO
    const seo = v.seo || {};
    h += `<div class="sb"><div class="sbl">&#128269; SEO</div><div class="sbc" id="se${i}"><button class="cbtn" onclick="cp(this,'se${i}')">Copy</button>
      ${seo.description?`<div style="margin-bottom:10px">${esc(seo.description||v.seo_description||'')}</div>`:''}
      ${seo.best_posting_time?`<div style="margin-bottom:10px;font-size:12px;color:var(--accent);">Best time: ${esc(seo.best_posting_time)}</div>`:''}
      <div class="tags" style="margin-bottom:8px;">${(seo.hashtags||v.hashtags||[]).map(x=>`<span class="tag">${esc(x)}</span>`).join('')}</div>
      ${seo.tags?`<div style="font-size:12px;color:var(--muted);">Tags: ${(seo.tags||[]).map(x=>esc(x)).join(', ')}</div>`:''}
    </div></div>`;

    // Series meta
    if (isSeries && v.series_meta) {
      const sm = v.series_meta;
      h += `<div class="sb"><div class="sbl">&#128279; SERIES</div><div class="sbc" id="sm${i}"><button class="cbtn" onclick="cp(this,'sm${i}')">Copy</button>
        ${sm.recap?`<div style="margin-bottom:6px"><strong style="color:var(--muted)">Recap:</strong> ${esc(sm.recap)}</div>`:''}
        ${sm.cliffhanger?`<div style="margin-bottom:6px"><strong style="color:var(--accent)">Cliffhanger:</strong> "${esc(sm.cliffhanger)}"</div>`:''}
        ${sm.character_note?`<div style="font-size:12px;color:rgba(255,255,255,0.4)">Character: ${esc(sm.character_note)}</div>`:''}
      </div></div>`;
    }

    h += `</div></div>`;
  });
  document.getElementById('resultsArea').innerHTML = h;
}

function fmtScript(s) {
  if(!s)return'';
  return esc(s)
    .replace(/\[VISUAL:\s*(.*?)\]/g,'<span class="visual-cue">[VISUAL: $1]</span>')
    .replace(/\[PAUSE\s*(.*?)\]/g,'<span style="color:#ff6b35;font-size:12px;font-weight:700;">[PAUSE $1]</span>')
    .replace(/\[(whisper|intense|slow down|speed up|dramatic)\]/gi,'<span style="color:#a36bfd;font-size:12px;font-weight:600;font-style:italic;">[$1]</span>')
    .replace(/\n/g,'<br>');
}

function cp(btn,id){navigator.clipboard.writeText(document.getElementById(id).innerText).then(()=>{btn.textContent='Copied!';btn.classList.add('done');setTimeout(()=>{btn.textContent='Copy';btn.classList.remove('done');},1500);});}
function cpAll(){if(!results.length)return;navigator.clipboard.writeText(JSON.stringify(results,null,2)).then(()=>alert('Full JSON copied!'));}
function prog(on,p,m){const b=document.getElementById('pbar'),f=document.getElementById('pfill'),t=document.getElementById('ptxt');if(on){b.classList.add('active');t.classList.add('active');f.style.width=p+'%';t.textContent=m||'';}else{b.classList.remove('active');t.classList.remove('active');f.style.width='0%';}}
function esc(s){return!s?'':String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
function expCSV(){if(!results.length)return;const hd=['Day','Title','Hook','Script','Thumbnail Text','Thumbnail Prompt','Neg Prompt','SEO','Hashtags','Tags'];let c=hd.map(h=>'"'+h+'"').join(',')+'\n';results.forEach(v=>{const th=v.thumbnail||{};const seo=v.seo||{};c+=[v.day,v.title,v.hook_primary||v.hook_1,v.script,th.text_overlay||v.thumbnail_text,th.image_prompt||v.thumbnail_prompt,th.negative_prompt||'',seo.description||v.seo_description,(seo.hashtags||v.hashtags||[]).join(' '),(seo.tags||[]).join(', ')].map(x=>'"'+String(x||'').replace(/"/g,'""')+'"').join(',')+'\n';});const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([c],{type:'text/csv'}));a.download='autotube_'+new Date().toISOString().slice(0,10)+'.csv';a.click();}
</script>
</body>
</html>