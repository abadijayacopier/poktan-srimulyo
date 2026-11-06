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

    if (action === 'tambahKloter') {
      if (role !== 'admin') return createJsonResponse({ sukses: false, pesan: 'Akses ditolak. Hanya administrator yang dapat mengubah data.' });
      return createJsonResponse(tambahPetaniKeKloter(payload.nik, payload.kloterTujuan));
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

/**
 * Jalankan SATU KALI dari Apps Script editor.
 * Masukkan admin123 dan giarno123 saat diminta.
 * Password disimpan sebagai salted SHA-256 hash di Script Properties,
 * bukan ditanam di HTML atau source code.
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

  // 1. Ambil daftar Penerima Kuasa & Perwakilan per Kloter (Baris 14 - 23)
  const kloterRange = sheet.getRange("B14:I23").getValues();

  // 2. Ambil Data Petani secara dinamis (Baris 37 sampai baris terakhir)
  const lastRow = Math.max(sheet.getLastRow(), 230);
  const numRows = lastRow - 36;
  const petaniRange = sheet.getRange(37, 2, numRows, 8).getValues(); // Kolom B s/d I

  const listPetani = [];
  let totalUreaKg = 0, totalNpkKg = 0, totalOrganikKg = 0;
  let totalMasukKloter = 0, totalMandiri = 0;

  // Penampung hitungan otomatis per kloter dari daftar petani
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

  // 3. Susun Rekapitulasi 10 Kloter (otomatis terhitung dari status petani)
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

  // 4. Drop Gudang (Pembulatan ke Atas / Sak Fisik Utuh)
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

  // 5. Keuangan Kios Otomatis (Aman jika sisa bayar = 0 / Lunas)
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
 * Menambahkan petani ke Kloter tertentu dengan validasi anti-duplikat NIK
 */
function tambahPetaniKeKloter(nik, kloterTujuan) {
  const lock = LockService.getScriptLock();
  lock.waitLock(10000);

  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName('REKAP_KLOTER_CETAK');
    if (!sheet) {
      throw new Error("Sheet 'REKAP_KLOTER_CETAK' tidak ditemukan.");
    }

    const targetNik = String(nik || '').trim();
    const targetKloter = String(kloterTujuan || '').trim();

    if (!targetNik || !targetKloter) {
      throw new Error("NIK dan Kloter tujuan wajib diisi.");
    }

    // Cari penerima kuasa default dari tabel Rekap Kloter (Baris 14-23)
    const kloterMeta = sheet.getRange("B14:E23").getValues();
    let penerimaKuasaDefault = 'SUPRIYANTO';
    kloterMeta.forEach(r => {
      if (String(r[1] || '').trim().toUpperCase() === targetKloter.toUpperCase()) {
        penerimaKuasaDefault = String(r[3] || 'SUPRIYANTO').trim();
      }
    });

    // Baca daftar petani di baris 37 s/d baris terakhir
    const lastRow = Math.max(sheet.getLastRow(), 230);
    const numRows = lastRow - 36;
    const petaniRange = sheet.getRange(37, 2, numRows, 8).getValues();

    let foundRowIndex = -1;
    let foundPetani = null;
    let jumlahAnggotaKloterTujuan = 0;

    petaniRange.forEach((row, idx) => {
      const rowNik = String(row[1] || '').trim();
      const rowNama = String(row[2] || '').trim();
      const rowStatus = String(row[3] || '').trim();

      if (rowStatus.toUpperCase() === targetKloter.toUpperCase()) {
        jumlahAnggotaKloterTujuan++;
      }

      if (rowNik === targetNik) {
        foundRowIndex = 37 + idx;
        foundPetani = {
          nik: rowNik,
          nama: rowNama,
          status: rowStatus
        };
      }
    });

    if (!foundPetani) {
      throw new Error("NIK " + targetNik + " tidak ditemukan di daftar e-RDKK.");
    }

    if (foundPetani.status.toLowerCase().includes('kloter')) {
      throw new Error(
        "DITOLAK! Petani " + foundPetani.nama + " (NIK: " + foundPetani.nik + ") " +
        "sudah terdaftar di " + foundPetani.status + ". Tidak bisa dimasukkan ke " + targetKloter + "."
      );
    }

    if (jumlahAnggotaKloterTujuan >= 20) {
      throw new Error(
        "DITOLAK! " + targetKloter + " sudah penuh (" + jumlahAnggotaKloterTujuan + "/20 petani)."
      );
    }

    // Update kolom E (Status) dan kolom F (Penerima Kuasa) di REKAP_KLOTER_CETAK
    const cellStatus = sheet.getRange(foundRowIndex, 5); // Kolom E
    const cellPenerima = sheet.getRange(foundRowIndex, 6); // Kolom F

    if (!cellStatus.getFormula()) {
      cellStatus.setValue(targetKloter);
    }
    if (!cellPenerima.getFormula()) {
      cellPenerima.setValue(penerimaKuasaDefault);
    }

    // Jika ada sheet Surat Kuasa untuk kloter tersebut, tambahkan ke baris kosong (B23:C42)
    const possibleSheetNames = [
      targetKloter,
      targetKloter.toUpperCase(),
      targetKloter.replace(/\s+/g, '_').toUpperCase(),
      'SURAT_KUASA_' + targetKloter.replace(/\D/g, '')
    ];

    for (let i = 0; i < possibleSheetNames.length; i++) {
      const skSheet = ss.getSheetByName(possibleSheetNames[i]);
      if (skSheet) {
        const skRange = skSheet.getRange("B23:C42").getValues();
        for (let r = 0; r < skRange.length; r++) {
          const existingNama = String(skRange[r][0] || '').trim();
          const existingNik = String(skRange[r][1] || '').trim();
          if (!existingNama && !existingNik) {
            skSheet.getRange(23 + r, 2).setValue(foundPetani.nama);
            if (!skSheet.getRange(23 + r, 3).getFormula()) {
              skSheet.getRange(23 + r, 3).setValue(foundPetani.nik);
            }
            break;
          }
        }
        break;
      }
    }

    SpreadsheetApp.flush();

    return {
      sukses: true,
      pesan: "Berhasil menambahkan " + foundPetani.nama + " ke " + targetKloter + "!",
      dataTerbaru: getDashboardData()
    };
  } finally {
    lock.releaseLock();
  }
}