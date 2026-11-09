// Vercel Serverless Function: /api/chat.js
// Penghubung Langsung ke OpenAI API & Google Gemini AI dengan Auto-Detection Environment Variable

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

  // 1. Scan cerdas semua kemungkinan penamaan environment variable di Vercel
  let openaiApiKey = null;
  let geminiApiKey = null;

  for (const [key, val] of Object.entries(process.env)) {
    if (!val || typeof val !== 'string' || !val.trim()) continue;
    const cleanKey = key.toUpperCase().replace(/[^A-Z0-9]/g, '');

    // Cek OpenAI: OPENAI_API_KEY, OPENAI_KEY, OPEN_AI, KEY_OPEN_AI, OPENAI, KEYOPENAI, dsb.
    if (!openaiApiKey && (
      cleanKey.includes('OPENAI') ||
      cleanKey.includes('CHATGPT') ||
      (cleanKey.includes('KEY') && cleanKey.includes('OPEN')) ||
      (cleanKey.startsWith('OPEN') && cleanKey.includes('AI'))
    )) {
      openaiApiKey = val.trim();
    }

    // Cek Gemini: GEMINI_API_KEY, GOOGLE_API_KEY, GEMINI_KEY, dsb.
    if (!geminiApiKey && (
      cleanKey.includes('GEMINI') ||
      cleanKey === 'GOOGLEAPIKEY' ||
      cleanKey === 'APIKEY'
    )) {
      geminiApiKey = val.trim();
    }
  }

  const { prompt, context, history } = req.body || {};

  if (!prompt || typeof prompt !== 'string' || !prompt.trim()) {
    return res.status(400).json({ error: 'Pertanyaan tidak boleh kosong.' });
  }

  // Siapkan konteks spesifik petani Poktan Sri Mulyo
  const farmerName = context?.nama || 'Petani Mandiri';
  const komoditas = context?.komoditas || 'Padi Sawah';
  const varietas = context?.varietas || 'Standar';
  const luas = context?.luas || '0.35';
  const musim = context?.musim || 'MT 3';
  const catatan = context?.catatan || '-';

  const systemPrompt = `Anda adalah "Mantri Tani" & pakar budidaya pertanian resmi untuk Kelompok Tani "Sri Mulyo", Desa Kediren, Kecamatan Lembeyan, Kabupaten Magetan, Jawa Timur.

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

  let openAiErr = null;
  let geminiErr = null;

  // 1. Prioritaskan OpenAI jika API Key tersedia
  if (openaiApiKey) {
    const aiResult = await callOpenAI(openaiApiKey, systemPrompt, prompt, history);
    if (aiResult.success) {
      return res.status(200).json({
        success: true,
        text: aiResult.text,
        source: 'openai',
        model: aiResult.model
      });
    }
    openAiErr = aiResult.modelErrors ? JSON.stringify(aiResult.modelErrors) : aiResult.error;
  }

  // 2. Jika OpenAI tidak ada atau gagal, coba Gemini AI
  if (geminiApiKey) {
    const geminiResult = await callGemini(geminiApiKey, systemPrompt, prompt, history);
    if (geminiResult.success) {
      return res.status(200).json({
        success: true,
        text: geminiResult.text,
        source: 'gemini',
        model: geminiResult.model
      });
    }
    geminiErr = geminiResult.error;
  }

  // Filter daftar env key yang aman untuk diagnosa (tanpa membocorkan nilai)
  const safeEnvKeys = Object.keys(process.env).filter(
    k => !k.startsWith('VERCEL') && !k.startsWith('AWS') && !k.startsWith('npm_') && !k.startsWith('_') && !k.includes('PASS') && !k.includes('SECRET')
  );

  // 3. Jika API key belum terisi atau keduanya gagal, kirim sinyal fallback ke sistem pakar
  return res.status(200).json({
    success: false,
    isFallback: true,
    pesan: 'API key OpenAI / Gemini belum aktif di environment variable Vercel atau kuota sedang habis.',
    error: openAiErr || geminiErr || (openaiApiKey ? 'OpenAI call failed' : 'OpenAI key not found in env'),
    debugEnvKeys: safeEnvKeys,
    text: null
  });
};

// Pemanggil API OpenAI
async function callOpenAI(apiKey, systemPrompt, prompt, history) {
  const preferredModel = (process.env.OPENAI_MODEL || '').trim();
  const candidateModels = [];
  if (preferredModel) candidateModels.push(preferredModel);
  candidateModels.push('gpt-4o-mini', 'gpt-4o', 'chatgpt-4o-latest');

  // Hilangkan duplikat dan model usang
  const models = [...new Set(candidateModels)].filter(m => m && !m.includes('3.5'));

  let lastError = null;
  const modelErrors = {};

  const messages = [
    { role: 'system', content: systemPrompt }
  ];

  if (Array.isArray(history) && history.length > 0) {
    history.slice(-8).forEach(item => {
      messages.push({
        role: item.sender === 'user' ? 'user' : 'assistant',
        content: String(item.text || '')
      });
    });
  }

  messages.push({
    role: 'user',
    content: prompt
  });

  for (const model of models) {
    try {
      const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey.trim()}`
        },
        body: JSON.stringify({
          model: model,
          messages: messages,
          temperature: 0.7,
          max_tokens: 1200
        })
      });

      if (!response.ok) {
        const errJson = await response.json().catch(() => ({}));
        lastError = errJson?.error?.message || `HTTP ${response.status}`;
        modelErrors[model] = lastError;
        continue;
      }

      const data = await response.json();
      const reply = data?.choices?.[0]?.message?.content;
      if (reply) {
        return { success: true, text: reply, model: model };
      }
    } catch (err) {
      lastError = err.message || String(err);
      modelErrors[model] = lastError;
    }
  }

  return { success: false, error: lastError, modelErrors: modelErrors };
}

// Pemanggil API Google Gemini
async function callGemini(apiKey, systemPrompt, prompt, history) {
  const models = [
    'gemini-1.5-flash',
    'gemini-2.0-flash',
    'gemini-2.5-flash',
    'gemini-1.5-pro'
  ];
  let lastError = null;

  const contents = [];
  if (Array.isArray(history) && history.length > 0) {
    history.slice(-6).forEach(item => {
      contents.push({
        role: item.sender === 'user' ? 'user' : 'model',
        parts: [{ text: String(item.text || '') }]
      });
    });
  }
  contents.push({
    role: 'user',
    parts: [{ text: prompt }]
  });

  for (const model of models) {
    try {
      const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey.trim()}`;
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: systemPrompt }] },
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
        return { success: true, text: text, model: model };
      }
    } catch (err) {
      lastError = err.message || String(err);
    }
  }

  return { success: false, error: lastError };
}
