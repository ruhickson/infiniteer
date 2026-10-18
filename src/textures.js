import * as THREE from 'three';

const cache = new Map();

export function canvasTexture(key, width, height, draw) {
  if (cache.has(key)) return cache.get(key);
  const canvas = document.createElement('canvas');
  canvas.width = width;
  canvas.height = height;
  const ctx = canvas.getContext('2d');
  draw(ctx, width, height);
  const texture = new THREE.CanvasTexture(canvas);
  texture.colorSpace = THREE.SRGBColorSpace;
  texture.anisotropy = 8;
  cache.set(key, texture);
  return texture;
}

export function panelTexture(hex, lineHex, scale = 8) {
  return canvasTexture(`panel-${hex}-${lineHex}-${scale}`, 256, 256, (ctx, w, h) => {
    ctx.fillStyle = hex;
    ctx.fillRect(0, 0, w, h);
    ctx.strokeStyle = lineHex;
    ctx.lineWidth = 2;
    const step = w / scale;
    for (let i = 0; i <= scale; i += 1) {
      ctx.beginPath();
      ctx.moveTo(i * step, 0);
      ctx.lineTo(i * step, h);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(0, i * step);
      ctx.lineTo(w, i * step);
      ctx.stroke();
    }
    ctx.fillStyle = lineHex;
    for (let x = 0; x < scale; x += 1) {
      for (let y = 0; y < scale; y += 1) {
        if ((x + y) % 7 === 0) ctx.fillRect(x * step + 4, y * step + 4, 6, 6);
      }
    }
  });
}

export function stripeTexture() {
  return canvasTexture('hazard', 256, 64, (ctx, w, h) => {
    ctx.fillStyle = '#111111';
    ctx.fillRect(0, 0, w, h);
    ctx.fillStyle = '#f1c40f';
    ctx.beginPath();
    for (let i = -h; i < w; i += 28) {
      ctx.moveTo(i, 0);
      ctx.lineTo(i + h, 0);
      ctx.lineTo(i + h + 14, h);
      ctx.lineTo(i + 14, h);
      ctx.closePath();
    }
    ctx.fill();
  });
}

export function signTexture(title, subtitle, bg, fg) {
  return canvasTexture(`sign-${title}-${subtitle}`, 512, 160, (ctx, w, h) => {
    ctx.fillStyle = bg;
    ctx.fillRect(0, 0, w, h);
    ctx.strokeStyle = fg;
    ctx.lineWidth = 8;
    ctx.strokeRect(8, 8, w - 16, h - 16);
    ctx.fillStyle = fg;
    ctx.font = 'bold 48px Segoe UI, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(title, w / 2, subtitle ? 78 : 100);
    if (subtitle) {
      ctx.font = '22px Segoe UI, sans-serif';
      ctx.globalAlpha = 0.8;
      ctx.fillText(subtitle, w / 2, 122);
    }
  });
}

export function makeMonitor() {
  const canvas = document.createElement('canvas');
  canvas.width = 1280;
  canvas.height = 640;
  const ctx = canvas.getContext('2d');
  const texture = new THREE.CanvasTexture(canvas);
  texture.colorSpace = THREE.SRGBColorSpace;
  return { canvas, ctx, texture };
}

export function drawMonitor(ctx, w, h, time) {
  ctx.fillStyle = '#061018';
  ctx.fillRect(0, 0, w, h);

  const viewX = 690;
  const viewW = 560;
  const viewH = 560;
  const viewY = 40;
  ctx.fillStyle = '#02050c';
  ctx.fillRect(viewX, viewY, viewW, viewH);

  ctx.fillStyle = '#ffffff';
  for (let i = 0; i < 90; i += 1) {
    const drift = (time * 18 + i * 37) % viewW;
    const y = (Math.sin(i * 1.7) * 0.5 + 0.5) * viewH;
    ctx.globalAlpha = 0.55 + (i % 5) * 0.08;
    ctx.fillRect(viewX + drift, viewY + y, 2, 2);
  }
  ctx.globalAlpha = 1;
  ctx.fillStyle = '#7fb3d8';
  ctx.beginPath();
  ctx.arc(viewX + 430, viewY + 150, 26, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = '#c39b6e';
  ctx.beginPath();
  ctx.arc(viewX + 140, viewY + 380, 10, 0, Math.PI * 2);
  ctx.fill();

  ctx.strokeStyle = '#2d6a8a';
  ctx.lineWidth = 4;
  ctx.strokeRect(viewX, viewY, viewW, viewH);

  ctx.fillStyle = '#9ad8ff';
  ctx.font = 'bold 42px Segoe UI, sans-serif';
  ctx.textAlign = 'left';
  ctx.fillText('S.F. SHANNON', 48, 72);
  ctx.font = '20px Segoe UI, sans-serif';
  ctx.fillStyle = '#6fa8c9';
  ctx.fillText('SOLAR FLYER  ·  REGISTRY SF-7714', 50, 108);

  const rows = [
    ['PROPULSION', 'NOMINAL'],
    ['LIFE SUPPORT', 'NOMINAL'],
    ['NAVIGATION', 'PLOTTING'],
    ['COMMS', 'LISTENING'],
    ['WEAPONS', 'SAFE'],
    ['HULL', 'INTACT'],
    ['ATTOM', 'REBOOTED'],
    ['CLEARANCE', 'CONDITIONAL'],
  ];
  ctx.font = '22px Consolas, monospace';
  rows.forEach((row, i) => {
    const y = 170 + i * 46;
    ctx.fillStyle = '#7ea4b8';
    ctx.fillText(row[0], 52, y);
    ctx.fillStyle = i === 7 ? '#f0c36a' : '#8ee0b0';
    ctx.fillText(row[1], 320, y);
  });

  ctx.fillStyle = '#4d7388';
  ctx.font = '16px Segoe UI, sans-serif';
  ctx.fillText('FORWARD OPTICAL  ·  JUPITER TRAFFIC LANE', 50, 600);
}
