// Vercel Serverless Function: /api/chat.js
// Penghubung Langsung ke Google Gemini AI dengan Environment Variable Vercel

module.exports = async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Deteksi berbagai kemungkinan penamaan environment variable di Vercel
  const apiKey =
    process.env.GEMINI_API_KEY ||
    process.env.GOOGLE_API_KEY ||
    process.env.API_KEY ||
    process.env.GEMINI_KEY ||
    process.env.AI_API_KEY ||
    process.env.GOOGLE_GEMINI_API_KEY;

  const { prompt, context, history } = req.body || {};

  if (!prompt || typeof prompt !== 'string' || !prompt.trim()) {
    return res.status(400).json({ error: 'Pertanyaan tidak boleh kosong.' });
  }

  // Jika API key belum terpasang di Vercel, kirim sinyal fallback
  if (!apiKey) {
    return res.status(200).json({
      success: false,
      isFallback: true,
      pesan: 'API key Gemini belum terbaca di environment variable Vercel.',
      text: null
    });
  }

  // Siapkan konteks spesifik petani Poktan Sri Mulyo
  const farmerName = context?.nama || 'Petani Mandiri';
  const komoditas = context?.komoditas || 'Padi Sawah';
  const varietas = context?.varietas || 'Standar';
  const luas = context?.luas || '0.35';
  const musim = context?.musim || 'MT 3';
  const catatan = context?.catatan || '-';

  const systemPrompt = `Anda adalah "Agent Poktan Sri Mulyo", asisten agronomi dan pakar budidaya pertanian resmi untuk Kelompok Tani "Sri Mulyo", Desa Kediren, Kecamatan Lembeyan, Kabupaten Magetan, Jawa Timur.

Identitas & Karakter Komunikasi:
1. Sapaan & Karakter: Sangat ramah, bersahabat, menghargai petani (panggil Bpk/Ibu, gunakan bahasa Indonesia yang luwes dan paham istilah pertanian lokal Jawa seperti matun, suket, macak-macak, bumbun, kaper, wereng, sundep, asem-aseman, gabah mentes, dll.).
2. Data Lahan Petani yang sedang berkonsultasi saat ini:
   - Nama Petani: ${farmerName}
   - Komoditas: ${komoditas} (Varietas: ${varietas})
   - Luas Lahan: ${luas} Ha
   - Musim Tanam: ${musim}
   - Catatan Gejala Awal Lahan: ${catatan}
3. Kaidah Agronomi & Dosis Presisi:
   - Berikan rekomendasi teknis yang jelas, terukur, dan praktis di lapangan.
   - Cantumkan takaran dosis per tangki sprayer 16 Liter (contoh: 15-20 gram/tangki atau 2-3 sendok makan).
   - Sebutkan waktu semprot terbaik (pagi hari pkl 06.30 - 08.30 WIB atau sore pkl 16.00 WIB).
   - Terapkan kaidah PHT (Pengendalian Hama Terpadu) Kementan: prioritaskan agen hayati / teknis budidaya, dan jika obat kimia cantumkan nama bahan aktifnya (misal: Pimetrozin, Dimehipo, Metalaksil, Dolomit) secara proporsional.
   - Padi: perhatikan jarak tanam jajar legowo, anakan produktif, dan waktu pengeringan sawah 10-14 hari sebelum panen.
   - Jagung: perhatikan pencegahan jamur bulai (Metalaksil), ulat grayak/tongkol, dan fase pembumbunan tanah.
4. Format Jawaban:
   - Rapi, gunakan poin-poin/bullet list yang nyaman dibaca di layar HP smartphone petani.
   - Jawaban langsung pada inti solusi tanpa bertele-tele.`;

  // Model Gemini yang dicoba berurutan
  const models = [
    'gemini-1.5-flash',
    'gemini-2.0-flash',
    'gemini-2.5-flash',
    'gemini-1.5-pro'
  ];

  let replyText = null;
  let lastError = null;

  for (const model of models) {
    try {
      const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

      const contents = [];

      // Riwayat percakapan sesi ini (jika ada)
      if (Array.isArray(history) && history.length > 0) {
        history.slice(-6).forEach(item => {
          contents.push({
            role: item.sender === 'user' ? 'user' : 'model',
            parts: [{ text: String(item.text || '') }]
          });
        });
      }

      // Input pertanyaan terbaru
      contents.push({
        role: 'user',
        parts: [{ text: prompt }]
      });

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          systemInstruction: {
            parts: [{ text: systemPrompt }]
          },
          contents: contents,
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 1200
          }
        })
      });

      if (!response.ok) {
        const errJson = await response.json().catch(() => ({}));
        lastError = errJson?.error?.message || `HTTP ${response.status}`;
        continue;
      }

      const data = await response.json();
      const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
      if (text) {
        replyText = text;
        break;
      }
    } catch (err) {
      lastError = err.message || String(err);
    }
  }

  if (replyText) {
    return res.status(200).json({
      success: true,
      text: replyText,
      source: 'gemini'
    });
  } else {
    return res.status(200).json({
      success: false,
      isFallback: true,
      error: lastError,
      text: null
    });
  }
};
