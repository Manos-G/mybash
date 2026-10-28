// Pull the SCRIPT array out of the published page so the video and the page share one script.
const fs = require('fs');
const html = fs.readFileSync(process.argv[2], 'utf8');
const m = html.match(/const SCRIPT = (\[[\s\S]*?\n\]);/);
if (!m) throw new Error('SCRIPT not found');
const SCRIPT = new Function('return ' + m[1])();
const say = t => t
  .replace(/(\d)\s?mm\b/g, '$1 millimetres').replace(/(\d)\s?cm\b/g, '$1 centimetres')
  .replace(/\bSIMAs\b/g, 'seemas').replace(/\bSIMA\b/g, 'seema').replace(/\bArUco\b/g, 'aruco')
  .replace(/\bLVL\b/g, 'level').replace(/\bHE\b/g, 'he').replace(/\bAND\b/g, 'and').replace(/\bALL\b/g, 'all');
const lines = [];
SCRIPT.forEach((ch, c) => ch.lines.forEach(l => lines.push({ c, s: l[0], t: l[1], pop: l[2] || null, say: say(l[1]) })));
fs.writeFileSync(process.argv[3], JSON.stringify({ chapters: SCRIPT.map(c => c.t), lines }, null, 1));
console.log(lines.length, 'lines');
