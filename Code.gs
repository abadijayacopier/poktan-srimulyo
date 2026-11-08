/**
 * ============================================================================
 * BACKEND GOOGLE APPS SCRIPT - POKTAN "SRI MULYO"
 * Autentikasi server-side + role admin/read-only.
 * ============================================================================
 */

const SESSION_TTL_SECONDS = 21600; // 6 jam

function doGet(e) {
  const action = (e && e.parameter && e.parameter.action) ? String(e.parameter.action) : '';
  if (action === 'getData' || action === 'tambahKloter' || (e && e.parameter && e.parameter.format === 'json')) {
    return createJsonResponse({ sukses: false, pesan: 'Akses API wajib melalui sesi login.' });
  }
  try {
    return HtmlService.createTemplateFromFile('Index')
      .evaluate()
      .setTitle('Dashboard RDKK MT3 2026 - POKTAN SRI MULYO')
      .addMetaTag('viewport', 'width=device-width, initial-scale=1')
      .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
  } catch (err) {
    return createJsonResponse({ sukses: false, pesan: 'Dashboard tersedia melalui portal Vercel.' });
  }
}

function doPost(e) {
  try {
    const payload = JSON.parse((e && e.postData && e.postData.contents) || '{}');
    const action = String(payload.action || '');

    if (action === 'login') {
      return createJsonResponse(loginUser_(payload.username, payload.password));
    }

    if (action === 'validateSession') {
      const role = getSessionRole_(payload.token);
      return createJsonResponse(role
        ? { sukses: true, role: role }
        : { sukses: false, pesan: 'Sesi login sudah berakhir.' });
    }

    if (action === 'logout') {
      if (payload.token) CacheService.getScriptCache().remove('poktan_session_' + payload.token);
      return createJsonResponse({ sukses: true });
    }

    const role = getSessionRole_(payload.token);
    if (!role) return createJsonResponse({ sukses: false, pesan: 'Sesi login tidak valid atau sudah berakhir. Silakan login kembali.' });

    if (action === 'getData') {
      return createJsonResponse({ sukses: true, role: role, data: getDashboardData() });
    }

    if (action === 'getAlokasi') {
      if (role !== 'admin') return createJsonResponse({ sukses: false, pesan: 'Akses ditolak. Halaman Alokasi khusus administrator.' });
      return createJsonResponse(getAlokasiPembagian_());
    }
    if (action === 'saveAlokasi') {
      if (role !== 'admin') return createJsonResponse({ sukses: false, pesan: 'Akses ditolak. Hanya administrator dapat mengubah alokasi.' });
      return createJsonResponse(saveAlokasiPembagian_(payload.row, payload.values));
    }
    if (action === 'addAlokasi') {
      if (role !== 'admin') return createJsonResponse({ sukses: false, pesan: 'Akses ditolak. Hanya administrator dapat menambah alokasi.' });
      return createJsonResponse(addAlokasi(payload));
    }

    if (action === 'tambahKloter') {
      if (role !== 'admin') return createJsonResponse({ sukses: false, pesan: 'Akses ditolak. Hanya administrator yang dapat mengubah data.' });
      return createJsonResponse(tambahPetaniKeKloter(payload.nik, payload.kloterTujuan));
    }

    if (action === 'getLogs') {
      if (role !== 'admin') return createJsonResponse({ sukses: false, pesan: 'Akses ditolak. Log sistem hanya untuk administrator.' });
      return createJsonResponse(getSystemLogs_());
    }

    if (action === 'recordLog') {
      const logData = payload.logData || {};
      const username = payload.username || (role ? (role === 'admin' ? 'admin' : 'giarno') : 'Pengunjung');
      logToSheet_(
        logData.aktivitas,
        logData.detail,
        logData.ip,
        logData.lokasi,
        logData.perangkat,
        logData.status,
        username,
        role || '-'
      );
      return createJsonResponse({ sukses: true });
    }

    return createJsonResponse({ sukses: false, pesan: 'Action tidak dikenali.' });
  } catch (err) {
    return createJsonResponse({ sukses: false, pesan: err.message || String(err) });
  }
}

function createJsonResponse(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

// ========================================================
// FUNGSI TAMBAH PETANI NON-eRDKK (DI BAWAH TRI WAHYUNI)
// ========================================================
function addAlokasi(payload) {
  const lock = LockService.getScriptLock();
  lock.waitLock(10000);
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName("ALOKASI PEMBAGIAN");
    if (!sheet) throw new Error("Tab 'ALOKASI PEMBAGIAN' tidak ditemukan.");
    const values = payload.values || [];
    if (!Array.isArray(values) || values.length !== 14) throw new Error('Format data harus 14 kolom.');

    // Cari posisi baris nama "TRI WAHYUNI" di Kolom C
    const lastRow = Math.max(sheet.getLastRow(), 240);
    const colC = sheet.getRange(1, 3, lastRow, 1).getValues();
    let triWahyuniRow = -1;
    for (let i = 0; i < colC.length; i++) {
      const val = String(colC[i][0] || "").toUpperCase().trim();
      if (val.includes("TRI WAHYUNI")) {
        triWahyuniRow = i + 1;
        break;
      }
    }

    // Jika tidak terdeteksi, gunakan baris 215/223
    if (triWahyuniRow === -1) {
      triWahyuniRow = 215;
    }

    const insertRowIndex = triWahyuniRow + 1;

    // Sisipkan baris baru tepat di bawah TRI WAHYUNI
    sheet.insertRowAfter(triWahyuniRow);

    // Pastikan NIK disimpan sebagai teks dengan petik awal jika ada
    const safe = values.map((v, i) => i === 1 ? (v ? "'" + String(v).trim() : '') : (v == null ? '' : v));

    // Tulis data input petani baru ke baris yang baru disisipkan
    const targetRange = sheet.getRange(insertRowIndex, 1, 1, 14);
    targetRange.setValues([safe]);
    SpreadsheetApp.flush();

    return {
      sukses: true,
      pesan: "Data petani Non-eRDKK berhasil disisipkan tepat di bawah TRI WAHYUNI",
      insertedRow: insertRowIndex
    };
  } finally {
    lock.releaseLock();
  }
}

/**
 * Jalankan SATU KALI dari Apps Script editor jika perlu reset login.
 */
function setupLoginCredentials() {
  const ui = SpreadsheetApp.getUi();
  const adminPrompt = ui.prompt('Setup akun administrator', 'Masukkan password untuk username admin:', ui.ButtonSet.OK_CANCEL);
  if (adminPrompt.getSelectedButton() !== ui.Button.OK) return;
  const adminPassword = adminPrompt.getResponseText();
  if (!adminPassword || adminPassword.length < 8) throw new Error('Password admin minimal 8 karakter.');

  const readPrompt = ui.prompt('Setup akun read-only', 'Masukkan password untuk username giarno:', ui.ButtonSet.OK_CANCEL);
  if (readPrompt.getSelectedButton() !== ui.Button.OK) return;
  const readPassword = readPrompt.getResponseText();
  if (!readPassword || readPassword.length < 8) throw new Error('Password giarno minimal 8 karakter.');

  const props = PropertiesService.getScriptProperties();
  savePasswordHash_(props, 'ADMIN', adminPassword);
  savePasswordHash_(props, 'GIARNO', readPassword);
  CacheService.getScriptCache().removeAll(['poktan_login_fail_admin', 'poktan_login_fail_giarno']);
  ui.alert('Berhasil', 'Hash password admin dan giarno sudah tersimpan. Silakan deploy ulang Web App.', ui.ButtonSet.OK);
}

function savePasswordHash_(props, key, password) {
  const salt = Utilities.getUuid() + Utilities.getUuid();
  const digest = Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, salt + ':' + password, Utilities.Charset.UTF_8);
  props.setProperties({
    ['POKTAN_' + key + '_SALT']: salt,
    ['POKTAN_' + key + '_HASH']: Utilities.base64Encode(digest)
  }, false);
}

function loginUser_(username, password) {
  const user = String(username || '').trim().toLowerCase();
  const pass = String(password || '');
  const config = {
    admin: { key: 'ADMIN', role: 'admin' },
    giarno: { key: 'GIARNO', role: 'readonly' }
  }[user];
  if (!config || !pass) return { sukses: false, pesan: 'Username atau password salah.' };

  const cache = CacheService.getScriptCache();
  const failKey = 'poktan_login_fail_' + user;
  const failures = Number(cache.get(failKey) || 0);
  if (failures >= 8) return { sukses: false, pesan: 'Terlalu banyak percobaan. Coba lagi setelah 10 menit.' };

  const props = PropertiesService.getScriptProperties();
  const salt = props.getProperty('POKTAN_' + config.key + '_SALT');
  const expected = props.getProperty('POKTAN_' + config.key + '_HASH');
  if (!salt || !expected) return { sukses: false, pesan: 'Akun belum diaktifkan. Administrator perlu menjalankan setupLoginCredentials() di Apps Script.' };

  const digest = Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, salt + ':' + pass, Utilities.Charset.UTF_8);
  const actual = Utilities.base64Encode(digest);
  if (actual !== expected) {
    cache.put(failKey, String(failures + 1), 600);
    return { sukses: false, pesan: 'Username atau password salah.' };
  }

  cache.remove(failKey);
  const token = Utilities.getUuid() + '-' + Utilities.getUuid();
  cache.put('poktan_session_' + token, config.role, SESSION_TTL_SECONDS);
  return { sukses: true, token: token, username: user, role: config.role, expiresIn: SESSION_TTL_SECONDS };
}

function getSessionRole_(token) {
  if (!token || String(token).length > 100) return null;
  const role = CacheService.getScriptCache().get('poktan_session_' + token);
  return role === 'admin' || role === 'readonly' ? role : null;
}

/**
 * Mengambil seluruh data Dashboard secara dinamis dari sheet REKAP_KLOTER_CETAK
 */
function getDashboardData() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName('REKAP_KLOTER_CETAK');

  if (!sheet) {
    throw new Error("Sheet 'REKAP_KLOTER_CETAK' tidak ditemukan.");
  }

  const kloterRange = sheet.getRange("B14:I23").getValues();
  const lastRow = Math.max(sheet.getLastRow(), 230);
  const numRows = lastRow - 36;
  const petaniRange = sheet.getRange(37, 2, numRows, 8).getValues();

  const listPetani = [];
  let totalUreaKg = 0, totalNpkKg = 0, totalOrganikKg = 0;
  let totalMasukKloter = 0, totalMandiri = 0;

  const hitungKloter = {};

  petaniRange.forEach((row, index) => {
    const nik = String(row[1] || '').trim();
    const nama = String(row[2] || '').trim();

    if (nik && nama) {
      const status = String(row[3] || 'Mandiri / Belum').trim();
      const penerimaKuasa = String(row[4] || '-').trim();
      const urea = Number(row[5]) || 0;
      const npk = Number(row[6]) || 0;
      const organik = Number(row[7]) || 0;

      const keyKloter = status.toUpperCase();
      if (!hitungKloter[keyKloter]) {
        hitungKloter[keyKloter] = { jumlahPetani: 0, urea: 0, npk: 0, organik: 0 };
      }
      hitungKloter[keyKloter].jumlahPetani += 1;
      hitungKloter[keyKloter].urea += urea;
      hitungKloter[keyKloter].npk += npk;
      hitungKloter[keyKloter].organik += organik;

      if (status.toLowerCase().includes('kloter')) {
        totalMasukKloter++;
      } else {
        totalMandiri++;
      }

      totalUreaKg += urea;
      totalNpkKg += npk;
      totalOrganikKg += organik;

      listPetani.push({
        barisSheet: 37 + index,
        no: row[0],
        nik: nik,
        nama: nama,
        status: status,
        penerimaKuasa: penerimaKuasa,
        urea: urea,
        npk: npk,
        organik: organik
      });
    }
  });

  const listKloter = kloterRange.map(row => {
    const namaKloter = String(row[1] || '').trim();
    const key = namaKloter.toUpperCase();
    const dataHitung = hitungKloter[key];

    const jumlahPetani = dataHitung ? dataHitung.jumlahPetani : (Number(row[4]) || 0);
    const urea = dataHitung ? dataHitung.urea : (Number(row[5]) || 0);
    const npk = dataHitung ? dataHitung.npk : (Number(row[6]) || 0);
    const organik = dataHitung ? dataHitung.organik : (Number(row[7]) || 0);

    return {
      no: row[0],
      kloter: namaKloter,
      pemberiKuasa: String(row[2] || '-'),
      penerimaKuasa: String(row[3] || 'SUPRIYANTO'),
      jumlahPetani: jumlahPetani,
      urea: urea,
      npk: npk,
      organik: organik
    };
  });

  const ureaAlokasi = Math.ceil(Number(sheet.getRange("D28").getValue()) || 286.7);
  const ureaTerkirim = Number(sheet.getRange("E28").getValue()) || 210;
  const ureaSisa = ureaAlokasi - ureaTerkirim;

  const npkAlokasi = Math.ceil(Number(sheet.getRange("D29").getValue()) || 260.62);
  const npkTerkirim = Number(sheet.getRange("E29").getValue()) || 195;
  const npkSisa = npkAlokasi - npkTerkirim;

  const orgAlokasi = Math.ceil(Number(sheet.getRange("D30").getValue()) || 254.975);
  const orgTerkirim = Number(sheet.getRange("E30").getValue()) || 220;
  const orgSisa = orgAlokasi - orgTerkirim;

  const dropGudang = [
    {
      jenis: 'Urea',
      alokasiSak: ureaAlokasi,
      terkirimSak: ureaTerkirim,
      sisaSak: ureaSisa,
      statusDrop: sheet.getRange("G28").getValue() || (ureaSisa > 0 ? `Kurang ${ureaSisa} Sak` : 'Lengkap'),
      harga: Number(sheet.getRange("H28").getValue()) || 95000,
      total: Number(sheet.getRange("I28").getValue()) || (ureaTerkirim * 95000)
    },
    {
      jenis: 'NPK Phonska',
      alokasiSak: npkAlokasi,
      terkirimSak: npkTerkirim,
      sisaSak: npkSisa,
      statusDrop: sheet.getRange("G29").getValue() || (npkSisa > 0 ? `Kurang ${npkSisa} Sak` : 'Lengkap'),
      harga: Number(sheet.getRange("H29").getValue()) || 97000,
      total: Number(sheet.getRange("I29").getValue()) || (npkTerkirim * 97000)
    },
    {
      jenis: 'Organik',
      alokasiSak: orgAlokasi,
      terkirimSak: orgTerkirim,
      sisaSak: orgSisa,
      statusDrop: sheet.getRange("G30").getValue() || (orgSisa > 0 ? `Kurang ${orgSisa} Sak` : 'Lengkap'),
      harga: Number(sheet.getRange("H30").getValue()) || 30000,
      total: Number(sheet.getRange("I30").getValue()) || (orgTerkirim * 30000)
    }
  ];

  const totalAlokasiSak = ureaAlokasi + npkAlokasi + orgAlokasi;
  const totalTerkirimSak = ureaTerkirim + npkTerkirim + orgTerkirim;
  const totalSisaSak = ureaSisa + npkSisa + orgSisa;

  const valTagihan = sheet.getRange("I31").getValue();
  const totalTagihan = (valTagihan !== "" && !isNaN(valTagihan))
    ? Number(valTagihan)
    : dropGudang.reduce((sum, item) => sum + item.total, 0);

  const valDp = sheet.getRange("I32").getValue();
  const dpDisetor = (valDp !== "" && !isNaN(valDp)) ? Number(valDp) : 45000000;

  const sisaBayar = totalTagihan - dpDisetor;

  return {
    ringkasan: {
      totalPetani: listPetani.length,
      totalMasukKloter: totalMasukKloter,
      totalMandiri: totalMandiri,
      persenKloter: listPetani.length > 0 ? Math.round((totalMasukKloter / listPetani.length) * 100) : 0,
      totalUreaKg: totalUreaKg,
      totalNpkKg: totalNpkKg,
      totalOrganikKg: totalOrganikKg,
      totalAlokasiSak: totalAlokasiSak,
      totalTerkirimSak: totalTerkirimSak,
      totalSisaSak: totalSisaSak,
      totalTagihan: totalTagihan,
      dpDisetor: dpDisetor,
      sisaBayar: sisaBayar
    },
    kloter: listKloter,
    dropGudang: dropGudang,
    petani: listPetani
  };
}

/**
 * Menambahkan petani ke Kloter tertentu
 */
function tambahPetaniKeKloter(nik, kloterTujuan) {
  const lock = LockService.getScriptLock();
  lock.waitLock(10000);

  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheetRekap = ss.getSheetByName('REKAP_KLOTER_CETAK');
    if (!sheetRekap) throw new Error("Sheet 'REKAP_KLOTER_CETAK' tidak ditemukan.");

    const targetNik = String(nik || '').trim();
    const targetKloter = String(kloterTujuan || '').trim();

    if (!targetNik || !targetKloter) throw new Error("NIK dan Kloter tujuan wajib diisi.");

    // Format target kloter, misal "Kloter 8" -> nama sheet "KLOTER 8"
    const namaSheetKloter = targetKloter.toUpperCase();
    const sheetKloter = ss.getSheetByName(namaSheetKloter) || ss.getSheetByName(targetKloter);
    if (!sheetKloter) {
      throw new Error("Sheet tab untuk '" + targetKloter + "' tidak ditemukan di spreadsheet.");
    }

    // Ambil metadata ketua kloter (penerima kuasa)
    const kloterMeta = sheetRekap.getRange("B14:E23").getValues();
    let penerimaKuasaDefault = 'SUPRIYANTO';
    kloterMeta.forEach(r => {
      if (String(r[1] || '').trim().toUpperCase() === targetKloter.toUpperCase()) {
        penerimaKuasaDefault = String(r[3] || 'SUPRIYANTO').trim();
      }
    });

    // Validasi data petani dari REKAP_KLOTER_CETAK
    const lastRow = Math.max(sheetRekap.getLastRow(), 230);
    const numRows = lastRow - 36;
    const petaniRange = sheetRekap.getRange(37, 2, numRows, 8).getValues();

    let foundRowIndex = -1;
    let foundPetani = null;

    petaniRange.forEach((row, idx) => {
      const rowNik = String(row[1] || '').trim();
      const rowNama = String(row[2] || '').trim();
      const rowStatus = String(row[3] || '').trim();

      if (rowNik === targetNik) {
        foundRowIndex = 37 + idx;
        foundPetani = { nik: rowNik, nama: rowNama, status: rowStatus };
      }
    });

    if (!foundPetani) throw new Error("NIK " + targetNik + " tidak ditemukan di daftar e-RDKK.");

    if (foundPetani.status.toLowerCase().includes('kloter')) {
      throw new Error("DITOLAK! Petani " + foundPetani.nama + " sudah terdaftar di " + foundPetani.status);
    }

    // Periksa slot anggota di sheet Kloter tujuan (C23:C42, maksimal 20 orang)
    const slotValues = sheetKloter.getRange("C23:C42").getValues();
    let slotKosongIndex = -1;
    let jumlahTerisi = 0;

    for (let i = 0; i < slotValues.length; i++) {
      const val = String(slotValues[i][0] || '').trim();
      if (val === targetNik) {
        throw new Error("Petani " + foundPetani.nama + " sudah terdaftar di " + targetKloter + ".");
      }
      if (val !== '') {
        jumlahTerisi++;
      } else if (slotKosongIndex === -1) {
        slotKosongIndex = i; // indeks 0-19 relatif terhadap C23
      }
    }

    if (slotKosongIndex === -1 || jumlahTerisi >= 20) {
      throw new Error("DITOLAK! " + targetKloter + " sudah penuh (maksimal 20 petani).");
    }

    // Tulis NIK ke baris kosong yang ditemukan di sheet Kloter tujuan
    const targetRowKloter = 23 + slotKosongIndex;
    sheetKloter.getRange(targetRowKloter, 3).setValue("'" + targetNik);

    // Jika di REKAP_KLOTER_CETAK kolom status bukan formula (misal data statis), perbarui juga nilainya
    if (foundRowIndex > 0) {
      const cellStatus = sheetRekap.getRange(foundRowIndex, 5);
      const cellPenerima = sheetRekap.getRange(foundRowIndex, 6);
      if (!cellStatus.getFormula()) cellStatus.setValue(targetKloter);
      if (!cellPenerima.getFormula()) cellPenerima.setValue(penerimaKuasaDefault);
    }

    SpreadsheetApp.flush();
    logToSheet_('Tambah Kloter', 'Menambahkan ' + foundPetani.nama + ' ke ' + targetKloter + ' (Urutan ke-' + (slotKosongIndex + 1) + ')', '-', 'Sistem', 'Dashboard', 'Sukses', 'admin', 'admin');

    return {
      sukses: true,
      pesan: "Berhasil menambahkan " + foundPetani.nama + " ke " + targetKloter + " (Urutan ke-" + (slotKosongIndex + 1) + ")!",
      dataTerbaru: getDashboardData()
    };
  } finally {
    lock.releaseLock();
  }
}

/**
 * Modul Alokasi Pembagian
 */
function getAlokasiPembagian_() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('ALOKASI PEMBAGIAN');
  if (!sheet) throw new Error("Tab 'ALOKASI PEMBAGIAN' tidak ditemukan.");
  const lastRow = sheet.getLastRow();
  if (lastRow < 2) return { sukses: true, rows: [] };
  const values = sheet.getRange(2, 1, lastRow - 1, 14).getDisplayValues();
  const rows = values.map((row, i) => ({ row: i + 2, values: row })).filter(item => item.values.some(v => String(v).trim() !== ''));
  return { sukses: true, rows: rows };
}

function saveAlokasiPembagian_(rowNumber, values) {
  const lock = LockService.getScriptLock();
  lock.waitLock(10000);
  try {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('ALOKASI PEMBAGIAN');
    if (!sheet) throw new Error("Tab 'ALOKASI PEMBAGIAN' tidak ditemukan.");
    const row = Number(rowNumber);
    if (!Number.isInteger(row) || row < 2 || row > sheet.getLastRow()) throw new Error('Nomor baris tidak valid.');
    if (!Array.isArray(values) || values.length !== 14) throw new Error('Format data harus 14 kolom (A:N).');
    const safe = values.map((v, i) => {
      const value = String(v == null ? '' : v).trim();
      return i === 1 ? (value ? "'" + value : '') : value;
    });
    sheet.getRange(row, 1, 1, 14).setValues([safe]);
    SpreadsheetApp.flush();
    logToSheet_('Ubah Alokasi', 'Memperbarui baris ke-' + rowNumber, '-', 'Sistem', 'Dashboard', 'Sukses', 'admin', 'admin');
    return { sukses: true, pesan: 'Data alokasi berhasil diperbarui.', row: row };
  } finally { lock.releaseLock(); }
}

/**
 * Modul Audit Log Aktivitas Sistem
 */
function logToSheet_(aktivitas, detail, ip, lokasi, perangkat, status, username, role) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    let sheet = ss.getSheetByName('LOG_AKTIVITAS');
    if (!sheet) {
      sheet = ss.insertSheet('LOG_AKTIVITAS');
      sheet.appendRow(['Timestamp', 'Username', 'Role', 'Aktivitas', 'Detail', 'IP Address', 'Lokasi', 'Perangkat', 'Status']);
      sheet.getRange(1, 1, 1, 9).setFontWeight('bold').setBackground('#065f46').setFontColor('#ffffff');
      sheet.setFrozenRows(1);
    }
    const now = Utilities.formatDate(new Date(), 'Asia/Jakarta', 'yyyy-MM-dd HH:mm:ss') + ' WIB';
    sheet.appendRow([
      now,
      String(username || 'Anonim'),
      String(role || '-'),
      String(aktivitas || '-'),
      String(detail || '-'),
      String(ip || '-'),
      String(lokasi || '-'),
      String(perangkat || '-'),
      String(status || 'Sukses')
    ]);
  } catch (err) {
    console.error('Gagal mencatat log aktivitas:', err);
  }
}

function getSystemLogs_() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName('LOG_AKTIVITAS');
  if (!sheet) return { sukses: true, logs: [] };
  const lastRow = sheet.getLastRow();
  if (lastRow < 2) return { sukses: true, logs: [] };
  const startRow = Math.max(2, lastRow - 299);
  const numRows = lastRow - startRow + 1;
  const values = sheet.getRange(startRow, 1, numRows, 9).getDisplayValues();
  const logs = values.map((r, idx) => ({
    id: startRow + idx,
    timestamp: r[0],
    username: r[1],
    role: r[2],
    aktivitas: r[3],
    detail: r[4],
    ip: r[5],
    lokasi: r[6],
    perangkat: r[7],
    status: r[8]
  })).reverse();
  return { sukses: true, logs: logs };
}
