// node capture.js test   -> a few sample stills
// node capture.js full   -> pipe every frame into ffmpeg with the voice track
const { chromium } = require('playwright');
const fs = require('fs'), { spawn } = require('child_process');
(async () => {
  const mode = process.argv[2] || 'test';
  const data = JSON.parse(fs.readFileSync('timeline.json', 'utf8'));
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1080, height: 1920 } });
  p.on('pageerror', e => console.error('PAGEERROR', e.message));
  await p.goto('file://' + __dirname + '/render.html');
  // which rulebook screenshot goes with which line (matched on caption text)
  const SHOT_FOR = [
    ['Four actions.', 'fig1'], ['No. Every action is independent', 'note'],
    ['3000 by 2000 mm', 'fig1'], ['In your throne room.', 'fig3'], ['The castle courtyard, the stables', 'fig2'],
    ['The stones are cardboard boxes', 'fig5'], ['Each stone has ArUco tag 13', 'fig5'],
    ['Grab stones and put them in your ramparts', 'fig6'], ['3 stones lying flat', 'wall'], ['1 stone standing up', 'tower'],
    ['2 stones standing up', 'gate'], ['every stone placed in a construction zone', 'e1pts'], ['So a wall is 3 stone points', 'e1pts'],
    ['Only when ALL the stone quarries', 'e1steal'],
    ['You make it. It follows', 'grailsize'], ['Before the match, on the floor', 'fig3'], ['your robot picks it up and puts it on a support', 'levels'],
    ['5 points if the Grail is in your castle', 'e2pts'], ['Level 1, one flat stone', 'levels'],
    ['your main robot must be stopped in its throne room', 'fig3'], ['Partly inside, 5 points', 'e3pts'],
    ['Your knights are SIMAs', 'fig2'], ['The attack phase is from second 85', 'e4phase'], ['They drive into the moats', 'e4moat'],
    ['If a SIMA actuator touches', 'e4moat'], ['Each team has 10 foam balls', 'fig4'], ['One ball in the enemy courtyard', 'e4pts'],
    ['Camelot. 1 point per stone', 'fpts'], ['Grail. 5 in the castle', 'fpts'], ['Return of the king. 5 partly', 'fpts'], ['Attack. 5 per moat', 'fpts'],
  ];
  for (const [txt, shot] of SHOT_FOR) {
    const hit = data.lines.filter(l => l.t.includes(txt));
    if (hit.length !== 1) throw new Error(`shot "${txt}" matched ${hit.length} lines`);
    hit[0].shot = shot;
  }
  const meta = JSON.parse(fs.readFileSync('shots/meta.json', 'utf8')), shots = {};
  for (const [k, m] of Object.entries(meta)) shots[k] = { ...m, src: 'data:image/png;base64,' + fs.readFileSync(`shots/${k}.png`).toString('base64') };
  await p.evaluate(([d, a, s, sh]) => window.init(d, a, s, sh), [data, fs.readFileSync('peter.svg', 'utf8'), fs.readFileSync('stewie.svg', 'utf8'), shots]);
  const toBuf = u => Buffer.from(u.slice(u.indexOf(',') + 1), 'base64');
  if (mode === 'test') {
    const pick = data.lines.map((l, i) => l.shot ? i : -1).filter(i => i >= 0).filter((_, j) => j % 4 === 0).map(i => Math.round((data.lines[i].speech[0] + 1.5) * 30));
    for (const n of pick.sort((a, b) => a - b)) { fs.writeFileSync(`still_${n}.jpg`, toBuf(await p.evaluate(n => window.frame(n, .85), n))); console.log('still', n); }
  } else {
    const ff = spawn('ffmpeg', ['-y', '-v', 'error', '-f', 'image2pipe', '-framerate', String(data.fps), '-c:v', 'mjpeg', '-i', '-',
      '-i', 'full.wav', '-c:v', 'libx264', '-preset', 'medium', '-crf', '21', '-pix_fmt', 'yuv420p', '-r', String(data.fps),
      '-c:a', 'aac', '-b:a', '160k', '-shortest', '-movflags', '+faststart', 'eurobot2027-rules-v2.mp4'], { stdio: ['pipe', 'inherit', 'inherit'] });
    const t0 = Date.now();
    for (let n = 0; n < data.frames; n++) {
      const buf = toBuf(await p.evaluate(n => window.frame(n, .92), n));
      if (!ff.stdin.write(buf)) await new Promise(r => ff.stdin.once('drain', r));
      if (n % 600 === 0) console.log(`frame ${n}/${data.frames}  ${((Date.now() - t0) / 1000).toFixed(0)}s`);
    }
    ff.stdin.end();
    await new Promise(r => ff.on('close', r));
    console.log('done', ((Date.now() - t0) / 1000).toFixed(0) + 's');
  }
  await b.close();
})();
