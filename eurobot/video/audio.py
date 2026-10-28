"""Synthesize every line with Piper, apply character voice effects, build one timeline + mouth envelope."""
import json, subprocess, sys, wave, os
import numpy as np

V = sys.argv[1]
FPS, SR = 30, 44100
INTRO, GAP, OUTRO = 1.2, 0.22, 6.0
VOICE = {
    "P": (f"{V}/en-us-ryan-high/en-us-ryan-high.onnx", 22050, "asetrate=22050*0.92,aresample=44100,atempo=1.17"),
    "S": (f"{V}/en-gb-alan-low/en-gb-alan-low.onnx", 16000, "asetrate=16000*1.27,aresample=44100,atempo=0.87"),
}
data = json.load(open("lines.json"))
os.makedirs("wav", exist_ok=True)

def read(path):
    with wave.open(path) as w:
        return np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(np.float32) / 32768

chunks, t = [np.zeros(int(INTRO * SR), np.float32)], INTRO
for i, ln in enumerate(data["lines"]):
    model, _, fx = VOICE[ln["s"]]
    raw, out = f"wav/{i:03d}_raw.wav", f"wav/{i:03d}.wav"
    subprocess.run([sys.executable, "-m", "piper", "-m", model, "-f", raw, "--sentence-silence", "0.12"],
                   input=ln["say"].encode(), check=True, capture_output=True)
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", raw, "-af", fx, "-ac", "1", "-ar", str(SR), out], check=True)
    a = read(out)
    a = a / max(1e-4, np.abs(a).max()) * 0.89
    loud = np.where(np.abs(a) > 0.03)[0]
    s0, s1 = (loud[0] / SR, loud[-1] / SR) if len(loud) else (0, len(a) / SR)
    ln.update(start=t, dur=len(a) / SR, speech=[t + s0, t + s1])
    chunks += [a, np.zeros(int(GAP * SR), np.float32)]
    t += len(a) / SR + GAP
    print(f"{i:02d} {ln['s']} {len(a)/SR:5.2f}s", flush=True)

chunks.append(np.zeros(int(OUTRO * SR), np.float32))
full = np.concatenate(chunks)
with wave.open("full.wav", "w") as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((np.clip(full, -1, 1) * 32767).astype(np.int16).tobytes())

hop = SR // FPS
n = len(full) // hop
rms = np.sqrt(np.mean(full[: n * hop].reshape(n, hop) ** 2, axis=1))
env = np.clip(rms / (np.percentile(rms[rms > 0.01], 90) + 1e-6), 0, 1)
data.update(fps=FPS, frames=int(n), total=len(full) / SR, intro=INTRO, outroStart=t, env=[round(float(x), 3) for x in env])
json.dump(data, open("timeline.json", "w"))
print(f"total {len(full)/SR:.1f}s, {n} frames")
