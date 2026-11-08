# Aktivasi Agent AI Poktan Sri Mulyo

## Environment Variables Vercel

Tambahkan variabel berikut di Project Settings → Environment Variables:

- `OPENAI_API_KEY`: API key OpenAI (simpan sebagai Secret; jangan masukkan ke HTML, GitHub, atau chat).
- `OPENAI_MODEL`: opsional; default saat ini `gpt-5.5`.

Pilih environment Production, Preview, dan Development sesuai kebutuhan. Setelah menyimpan variabel, lakukan redeploy agar Function membaca nilai terbaru.

## Endpoint

- `POST /api/agent`
- Body JSON: `{ "messages": [...], "context": {...}, "image": "data:image/jpeg;base64,..." }`
- Foto JPG/PNG/WebP, maksimal 2.5 MB setelah kompresi.
- Backend hanya meneruskan konteks budidaya yang diperlukan. NIK tidak dikirim ke OpenAI.
- Respons API menggunakan OpenAI Responses API dengan `store: false`.

## Riwayat konsultasi

Versi tahap awal menyimpan percakapan pada localStorage browser/perangkat. Riwayat akan muncul kembali saat portal dibuka pada browser dan perangkat yang sama. Riwayat belum tersinkron lintas perangkat atau antar pengguna.

## Pengamanan operasional

1. Jangan pernah menaruh `OPENAI_API_KEY` di file frontend.
2. Batasi penggunaan API melalui Vercel Firewall/Rate Limiting. Pembatas sederhana di dalam Function pada branch ini hanya perlindungan tambahan dan tidak menggantikan rate limit edge yang persisten.
3. Pantau pemakaian dan anggaran proyek OpenAI.
4. Uji endpoint pada Preview Deployment sebelum merge ke main.
5. Jangan mengirim NIK atau identitas pribadi petani ke endpoint AI.

## Pengujian setelah konfigurasi

1. Buka Preview Deployment.
2. Buka Konsultasi Agent Poktan Sri Mulyo.
3. Kirim pertanyaan umum tentang budidaya padi.
4. Kirim foto gejala daun/batang/malai padi dengan pertanyaan yang menjelaskan gejala.
5. Muat ulang halaman dan pastikan riwayat di perangkat yang sama tetap tampil.
6. Pastikan kalkulator, e-RDKK, kalender tanam, cetak PDF, dan portal pengurus tetap berfungsi.
