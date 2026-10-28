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
  await p.evaluate(([d, a, s]) => window.init(d, a, s), [data, fs.readFileSync('peter.svg', 'utf8'), fs.readFileSync('stewie.svg', 'utf8')]);
  const toBuf = u => Buffer.from(u.slice(u.indexOf(',') + 1), 'base64');
  if (mode === 'test') {
    const pick = [15, ...[3, 30, 34, 45, 60].map(i => Math.round((data.lines[i].popAt ?? data.lines[i].speech[0] + 1.2) * 30)), Math.round((data.outroStart + 2) * 30)];
    const L = data.lines; pick.splice(2, 0, Math.round((L[29].speech[0] + 2) * 30));
    for (const n of pick.sort((a, b) => a - b)) { fs.writeFileSync(`still_${n}.jpg`, toBuf(await p.evaluate(n => window.frame(n, .85), n))); console.log('still', n); }
  } else {
    const ff = spawn('ffmpeg', ['-y', '-v', 'error', '-f', 'image2pipe', '-framerate', String(data.fps), '-c:v', 'mjpeg', '-i', '-',
      '-i', 'full.wav', '-c:v', 'libx264', '-preset', 'medium', '-crf', '21', '-pix_fmt', 'yuv420p', '-r', String(data.fps),
      '-c:a', 'aac', '-b:a', '160k', '-shortest', '-movflags', '+faststart', 'eurobot2027-rules.mp4'], { stdio: ['pipe', 'inherit', 'inherit'] });
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
