# Audit Keamanan Awal — Poktan Sri Mulyo

Tanggal audit: 9 November 2026
Branch pemeriksaan: feat/openai-smart-farming-agent

## Temuan prioritas tinggi

### 1. NIK petani tertanam pada HTML publik

File `panduan-tani.html` berisi konstanta `SEED_PETANI_ERDKK` yang menanamkan daftar petani beserta NIK lengkap ke JavaScript sisi klien. Karena HTML dikirim ke browser, data tersebut dapat dibaca siapa pun yang membuka situs atau mengambil source file dari repository publik.

### 2. Endpoint daftar petani Apps Script mengembalikan NIK lengkap

Fungsi `getDaftarPetaniPublik_()` pada `Code.gs` mengembalikan objek petani yang berisi `nik`, nama, luas lahan, dan alokasi pupuk. Aksi `getDaftarPetaniPublik` dipanggil dari frontend tanpa sesi pengurus. Karena itu, menghapus konstanta dari HTML saja belum cukup: endpoint publik juga harus diperbaiki.

### Status perbaikan dalam branch ini

- Endpoint OpenAI baru tidak menerima atau meneruskan NIK.
- Konteks AI dibatasi pada komoditas, varietas, luas lahan, musim, tanggal tanam, dan catatan gejala.
- API Key hanya dibaca dari environment variable server.
- Riwayat chat lokal tidak menyimpan NIK secara sengaja.
- Temuan NIK di database e-RDKK belum diubah dalam branch ini karena frontend saat ini memakai NIK untuk pencarian/pencocokan dan penyimpanan rencana tanam. Mengubah kontrak tersebut tanpa migrasi lookup yang sesuai berisiko merusak e-RDKK dan penyimpanan rencana.

## Remediasi lanjutan wajib sebelum portal dinyatakan aman untuk data petani

1. Ganti daftar publik penuh dengan pencarian server-side. Jangan kirim daftar NIK lengkap ke browser.
2. Gunakan pencarian berdasarkan nama dan/atau verifikasi input NIK di server. Server hanya mengembalikan metadata minimum yang diperlukan; jangan mengembalikan NIK lengkap.
3. Pindahkan seed data NIK dari `panduan-tani.html` ke penyimpanan privat dan bersihkan riwayat Git bila data tersebut sudah terpublikasi dan kebijakan organisasi mengharuskannya. Menghapus dari commit terbaru tidak menghapus salinan di riwayat Git atau cache.
4. Tinjau akses publik Google Visualization/Google Sheets dan Apps Script deployment; batasi akses sesuai kebutuhan.
5. Bila NIK telah terekspos ke publik, lakukan penilaian insiden internal dan beri tahu pihak yang berwenang sesuai kebijakan perlindungan data.

## Catatan diagnosa AI

Hasil analisis foto adalah dugaan awal berbasis gejala visual, bukan diagnosis laboratorium. Rekomendasi pestisida/dosis harus merujuk label produk terdaftar dan arahan PPL/BPP. AI tidak boleh menggantikan pemeriksaan lapangan.
