// Generator BPMN 2.0 untuk alur aplikasi Soju.
// Jalankan:  node docs/bpmn/generate.mjs
// Output:    docs/bpmn/soju_flow.bpmn
//
// Sumber alur: file Figma "UI/UX Soju"
//  - Onboarding 1-3        : node 798:1765 / 798:1882 / 798:1991
//  - Login                 : node 798:2122
//  - Lupa Password         : node 798:2239
//  - Kode OTP              : node 798:2334
//  - Alur tambah transaksi : node 332:5, 354:2, 355:838, 358:962, 358:1081
//  - Menu utama            : Dashboard, Data, Asisten AI, Riwayat & Audit

import { writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));

/* ------------------------------------------------------------------ */
/*  Layout                                                              */
/* ------------------------------------------------------------------ */
const POOL_X = 160;
const POOL_Y = 60;
const LANE_H = 220;
const AI_H = 200;
const LANES = [
  { id: 'Lane_User', name: 'Pengguna', y: POOL_Y, h: LANE_H, cy: POOL_Y + LANE_H / 2 },
  { id: 'Lane_System', name: 'Sistem Soju', y: POOL_Y + LANE_H, h: LANE_H, cy: POOL_Y + LANE_H + LANE_H / 2 },
  { id: 'Lane_AI', name: 'Asisten AI', y: POOL_Y + LANE_H * 2, h: AI_H, cy: POOL_Y + LANE_H * 2 + AI_H / 2 },
];
const POOL_H = LANE_H * 2 + AI_H;
const COL_W = 195;
const START_X = POOL_X + 60;

const SIZE = {
  start: { w: 36, h: 36 },
  end: { w: 36, h: 36 },
  task: { w: 150, h: 80 },
  gateway: { w: 50, h: 50 },
};

/* ------------------------------------------------------------------ */
/*  Nodes: [id, type, name, lane(index), column, tag]                   */
/*  tag: BPMN element (task | userTask | serviceTask)                   */
/* ------------------------------------------------------------------ */
const N = (id, type, name, lane, col, tag = 'task') => ({ id, type, name, lane, col, tag });

const nodes = [
  // ---------- Onboarding ----------
  N('Start', 'start', 'Buka Aplikasi', 0, 0),
  N('Init', 'task', 'Inisialisasi & cek sesi', 1, 1),
  N('GwOnboard', 'gateway', 'Pertama kali?', 0, 2),
  N('Onb1', 'task', 'Onboarding 1\nKelola Keuangan', 0, 3, 'userTask'),
  N('Onb2', 'task', 'Onboarding 2\nAsisten AI', 0, 4, 'userTask'),
  N('Onb3', 'task', 'Onboarding 3\nTumbuh Percaya Diri', 0, 5, 'userTask'),
  N('Onb4', 'task', 'Onboarding 4\nChat AI', 0, 6, 'userTask'),
  N('Onb5', 'task', 'Onboarding 5\nKontrol Stok', 0, 7, 'userTask'),
  N('Onb6', 'task', 'Onboarding 6\nLaporan', 0, 8, 'userTask'),
  N('MarkDone', 'task', 'Simpan status onboarding', 1, 9),

  // ---------- Autentikasi ----------
  N('LoginPage', 'task', 'Halaman Login', 0, 11, 'userTask'),
  N('GwAction', 'gateway', 'Pilih aksi', 0, 12),

  // Masuk
  N('InputCred', 'task', 'Input email & password', 0, 13, 'userTask'),
  N('Validate', 'task', 'Validasi kredensial', 1, 14),
  N('GwValid', 'gateway', 'Valid?', 1, 15),

  // Daftar
  N('Register', 'task', 'Registrasi akun', 0, 16, 'userTask'),
  N('SendOtpReg', 'task', 'Kirim kode OTP', 1, 17),
  N('InputOtpReg', 'task', 'Input & verifikasi OTP', 0, 18, 'userTask'),
  N('GwOtpReg', 'gateway', 'OTP valid?', 1, 19),

  // Lupa password
  N('ForgotInput', 'task', 'Input email pemulihan', 0, 13, 'userTask'), // kolom khusus (baris lain)
  N('SendOtpReset', 'task', 'Kirim OTP reset', 1, 14),
  N('InputOtpReset', 'task', 'Input OTP reset', 1, 15),
  N('ResetPw', 'task', 'Atur ulang password', 2, 16, 'userTask'),

  // ---------- Menu utama ----------
  N('Dashboard', 'task', 'Dashboard Soju', 0, 21, 'userTask'),
  N('GwMenu', 'gateway', 'Pilih menu', 0, 22),
  N('MenuAI', 'task', 'Menu Asisten AI', 0, 23, 'userTask'),
  N('MenuRiwayat', 'task', 'Menu Riwayat & Audit', 0, 24, 'userTask'),

  // ---------- Data / transaksi ----------
  N('MenuData', 'task', 'Menu Data', 0, 23, 'userTask'), // baris lain (kolom 23)
  N('AddTxn', 'task', 'Klik "+ Tambah Transaksi"', 0, 24, 'userTask'),
  N('GwMethod', 'gateway', 'Metode input?', 0, 25),

  N('FormManual', 'task', 'Isi form transaksi\n(tanggal, deskripsi,\njenis, nominal)', 1, 26, 'userTask'),
  N('Chat', 'task', 'Chat / unggah struk', 0, 26, 'userTask'),
  N('AiParse', 'task', 'AI parsing &\nkategorisasi otomatis', 2, 27),
  N('ShowDraft', 'task', 'Tampilkan draf transaksi', 1, 28),
  N('Confirm', 'task', 'Konfirmasi draf', 0, 28, 'userTask'),
  N('GwApprove', 'gateway', 'Disetujui?', 0, 29),

  N('Save', 'task', 'Simpan ke pembukuan', 1, 30),
  N('UpdateReport', 'task', 'Update dashboard & laporan', 1, 31),
  N('End', 'end', 'Selesai', 0, 32),
];

/* ------------------------------------------------------------------ */
/*  Flows: [from, to, label]                                            */
/* ------------------------------------------------------------------ */
const flows = [
  ['Start', 'Init', ''],
  ['Init', 'GwOnboard', ''],
  ['GwOnboard', 'Onb1', 'Belum pernah'],
  ['GwOnboard', 'LoginPage', 'Sudah pernah'],
  ['Onb1', 'Onb2', ''],
  ['Onb2', 'Onb3', ''],
  ['Onb3', 'Onb4', ''],
  ['Onb4', 'Onb5', ''],
  ['Onb5', 'Onb6', ''],
  ['Onb6', 'MarkDone', ''],
  ['MarkDone', 'LoginPage', ''],

  ['LoginPage', 'GwAction', ''],
  ['GwAction', 'InputCred', 'Masuk'],
  ['InputCred', 'Validate', ''],
  ['Validate', 'GwValid', ''],
  ['GwValid', 'Dashboard', 'Ya'],
  ['GwValid', 'LoginPage', 'Tidak'],

  ['GwAction', 'Register', 'Daftar'],
  ['Register', 'SendOtpReg', ''],
  ['SendOtpReg', 'InputOtpReg', ''],
  ['InputOtpReg', 'GwOtpReg', ''],
  ['GwOtpReg', 'Dashboard', 'Ya'],
  ['GwOtpReg', 'InputOtpReg', 'Tidak'],

  ['GwAction', 'ForgotInput', 'Lupa password'],
  ['ForgotInput', 'SendOtpReset', ''],
  ['SendOtpReset', 'InputOtpReset', ''],
  ['InputOtpReset', 'ResetPw', ''],
  ['ResetPw', 'LoginPage', ''],

  ['Dashboard', 'GwMenu', ''],
  ['GwMenu', 'MenuData', 'Data'],
  ['GwMenu', 'MenuAI', 'Asisten AI'],
  ['GwMenu', 'MenuRiwayat', 'Riwayat'],
  ['MenuRiwayat', 'Dashboard', 'kembali'],

  ['MenuData', 'AddTxn', ''],
  ['AddTxn', 'GwMethod', ''],
  ['GwMethod', 'FormManual', 'Manual'],
  ['GwMethod', 'Chat', 'Chat AI'],
  ['Chat', 'AiParse', ''],
  ['AiParse', 'ShowDraft', ''],
  ['ShowDraft', 'Confirm', ''],
  ['Confirm', 'GwApprove', ''],
  ['GwApprove', 'Save', 'Ya'],
  ['GwApprove', 'Chat', 'Revisi'],
  ['FormManual', 'Save', ''],
  ['MenuAI', 'Chat', ''],
  ['Save', 'UpdateReport', ''],
  ['UpdateReport', 'End', ''],
];

/* ------------------------------------------------------------------ */
/*  Hitung koordinat                                                    */
/* ------------------------------------------------------------------ */
const byId = new Map(nodes.map((n) => [n.id, n]));
const geom = new Map();
let maxCol = 0;
for (const n of nodes) {
  const s = SIZE[n.type];
  const lane = LANES[n.lane];
  const x = START_X + n.col * COL_W;
  const y = Math.round(lane.cy - s.h / 2);
  geom.set(n.id, { x, y, w: s.w, h: s.h, cx: x + s.w / 2, cy: y + s.h / 2 });
  if (n.col > maxCol) maxCol = n.col;
}
const POOL_W = START_X + (maxCol + 1) * COL_W + 40;
const LANE_X = POOL_X + 30;
const LANE_W = POOL_W - 30;

/* ------------------------------------------------------------------ */
/*  Emit BPMN                                                           */
/* ------------------------------------------------------------------ */
const esc = (s) =>
  String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const nl = (s) => esc(s).replace(/\n/g, '&#10;');

const nodeTag = {
  start: 'startEvent',
  end: 'endEvent',
  task: 'task',
  userTask: 'userTask',
  serviceTask: 'serviceTask',
  gateway: 'exclusiveGateway',
};

let processXml = '';
let diXml = '';

// Lane set
processXml += `    <bpmn:laneSet id="LaneSet_1">\n`;
for (const lane of LANES) {
  processXml += `      <bpmn:lane id="${lane.id}" name="${esc(lane.name)}">\n`;
  for (const n of nodes.filter((x) => x.lane === LANES.indexOf(lane))) {
    processXml += `        <bpmn:flowNodeRef>${n.id}</bpmn:flowNodeRef>\n`;
  }
  processXml += `      </bpmn:lane>\n`;
}
processXml += `    </bpmn:laneSet>\n`;

// Nodes
for (const n of nodes) {
  const t = nodeTag[n.type === 'task' ? n.tag : n.type] ?? 'task';
  const name = n.type === 'task' && n.tag === 'userTask' ? ` name="${nl(n.name)}"` : ` name="${nl(n.name)}"`;
  if (n.type === 'gateway') {
    processXml += `    <bpmn:${t} id="${n.id}" name="${nl(n.name)}" />\n`;
  } else if (n.type === 'start' || n.type === 'end') {
    processXml += `    <bpmn:${t} id="${n.id}" name="${nl(n.name)}" />\n`;
  } else {
    processXml += `    <bpmn:${t} id="${n.id}" name="${nl(n.name)}" />\n`;
  }
}

// Flows
flows.forEach((f, i) => {
  const id = `Flow_${i + 1}`;
  const label = f[2] ? ` name="${esc(f[2])}"` : '';
  processXml += `    <bpmn:sequenceFlow id="${id}" sourceRef="${f[0]}" targetRef="${f[1]}"${label} />\n`;
});

// DI shapes
diXml += `      <bpmndi:BPMNShape id="Shape_Participant_1" bpmnElement="Participant_1" isHorizontal="true">\n`;
diXml += `        <dc:Bounds x="${POOL_X}" y="${POOL_Y}" width="${POOL_W}" height="${POOL_H}" />\n      </bpmndi:BPMNShape>\n`;
for (const lane of LANES) {
  diXml += `      <bpmndi:BPMNShape id="Shape_${lane.id}" bpmnElement="${lane.id}" isHorizontal="true">\n`;
  diXml += `        <dc:Bounds x="${LANE_X}" y="${lane.y}" width="${LANE_W}" height="${lane.h}" />\n`;
  diXml += `      </bpmndi:BPMNShape>\n`;
}
for (const n of nodes) {
  const g = geom.get(n.id);
  if (n.type === 'gateway') {
    diXml += `      <bpmndi:BPMNShape id="Shape_${n.id}" bpmnElement="${n.id}" isMarkerVisible="true">\n`;
  } else {
    diXml += `      <bpmndi:BPMNShape id="Shape_${n.id}" bpmnElement="${n.id}">\n`;
  }
  diXml += `        <dc:Bounds x="${g.x}" y="${g.y}" width="${g.w}" height="${g.h}" />\n      </bpmndi:BPMNShape>\n`;
}

// DI edges
const routeY = POOL_Y + POOL_H + 34;
flows.forEach((f, i) => {
  const id = `Flow_${i + 1}`;
  const s = geom.get(f[0]);
  const t = geom.get(f[1]);
  const pts = [];
  if (t.col <= s.col) {
    // alur mundur: lewat bawah diagram
    pts.push([s.cx, s.y + s.h]);
    pts.push([s.cx, routeY]);
    pts.push([t.cx, routeY]);
    pts.push([t.cx, t.y + t.h]);
  } else if (s.cy === t.cy) {
    pts.push([s.x + s.w, s.cy]);
    pts.push([t.x, t.cy]);
  } else {
    const mx = s.x + s.w + 24;
    pts.push([s.x + s.w, s.cy]);
    pts.push([mx, s.cy]);
    pts.push([mx, t.cy]);
    pts.push([t.x, t.cy]);
  }
  diXml += `      <bpmndi:BPMNEdge id="Edge_${id}" bpmnElement="${id}">\n`;
  for (const [x, y] of pts) diXml += `        <di:waypoint x="${x}" y="${y}" />\n`;
  diXml += `      </bpmndi:BPMNEdge>\n`;
});

const bpmn = `<?xml version="1.0" encoding="UTF-8"?>
<bpmn:definitions xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL"
                  xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI"
                  xmlns:dc="http://www.omg.org/spec/DD/20100524/DC"
                  xmlns:di="http://www.omg.org/spec/DD/20100524/DI"
                  id="Definitions_Soju" targetNamespace="http://soju.app/bpmn">
  <bpmn:collaboration id="Collaboration_1">
    <bpmn:participant id="Participant_1" name="Aplikasi Soju" processRef="Process_1" />
  </bpmn:collaboration>
  <bpmn:process id="Process_1" name="Alur Onboarding, Autentikasi &amp; Pencatatan Transaksi" isExecutable="false">
${processXml}  </bpmn:process>
  <bpmndi:BPMNDiagram id="BPMNDiagram_1">
    <bpmndi:BPMNPlane id="BPMNPlane_1" bpmnElement="Collaboration_1">
${diXml}    </bpmndi:BPMNPlane>
  </bpmndi:BPMNDiagram>
</bpmn:definitions>
`;

mkdirSync(__dirname, { recursive: true });
const out = resolve(__dirname, 'soju_flow.bpmn');
writeFileSync(out, bpmn, 'utf8');
console.log('BPMN ditulis ke:', out);
console.log('Nodes:', nodes.length, '| Flows:', flows.length, '| Pool:', POOL_W + 'x' + POOL_H);