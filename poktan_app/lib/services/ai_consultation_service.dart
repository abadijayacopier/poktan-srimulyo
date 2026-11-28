class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AIConsultationService {
  static final AIConsultationService _instance = AIConsultationService._internal();
  factory AIConsultationService() => _instance;
  AIConsultationService._internal();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Halo Sedulur Petani Sri Mulyo! 👋\n\nSaya Kang Sri, asisten pertanian digital Poktan Sri Mulyo Desa Kediren. Ada yang bisa saya bantu seputar kuota pupuk subsidi MT3 2026, takaran dosis pemupukan berimbang, pengendalian hama padi, atau syarat surat kuasa penggarap?',
      isUser: false,
    ),
  ];

  List<ChatMessage> get messages => _messages;

  Future<String> ask(String question) async {
    // Add user message
    _messages.add(ChatMessage(text: question, isUser: true));

    // Simulate thinking delay
    await Future.delayed(const Duration(milliseconds: 500));

    final reply = _generateResponse(question.toLowerCase().trim());
    _messages.add(ChatMessage(text: reply, isUser: false));
    return reply;
  }

  String _generateResponse(String q) {
    if (q.contains('dosis') || q.contains('takaran') || q.contains('lep') || q.contains('pupuk berapa')) {
      return '🌾 **Rekomendasi Dosis Pemupukan Berimbang Padi (Kec. Lembeyan):**\n\n'
          '• **Luas 1 Hektar (10.000 m²):**\n'
          '  - Urea: 250 - 300 kg (5 - 6 Sak)\n'
          '  - NPK Phonska: 250 - 300 kg (5 - 6 Sak)\n'
          '  - Organik: 500 kg (12 - 13 Sak)\n\n'
          '• **Untuk Luas Ru Jawa (1 Ru = 14 m²):**\n'
          '  - Contoh 50 Ru (700 m²): Butuh ~18-20 kg Urea dan ~18-20 kg NPK.\n'
          '  - Gunakan menu **GoLEP** di beranda untuk menghitung otomatis per petak sawah Anda!';
    }

    if (q.contains('wereng') || q.contains('coklat') || q.contains('wereng batang')) {
      return '🐛 **Penanganan Wereng Batang Coklat (WBC):**\n\n'
          '1. **Gejala:** Daun menguning dari bawah, tanaman kering seperti terbakar (*hopperburn*).\n'
          '2. **Tindakan Cepat:**\n'
          '   • Keringkan sawah secara berkala (irigasi berselang / intermitten).\n'
          '   • Semprot insektisida berbahan aktif Pimetrozin, Buprofezin, atau Dinotefuran tepat pada pangkal batang padi saat pagi hari (pukul 06.00 - 09.00).\n'
          '   • Hindari pupuk Urea berlebih karena membuat batang lunak dan disukai wereng!';
    }

    if (q.contains('sundep') || q.contains('penggerek') || q.contains('beluk')) {
      return '🦗 **Pengendalian Penggerek Batang (Sundep/Beluk):**\n\n'
          '• **Fase Vegetatif (Sundep):** Pucuk daun mati dan mudah dicabut.\n'
          '• **Fase Generatif (Beluk):** Malai padi hampa dan berwarna putih tegak.\n'
          '• **Solusi:**\n'
          '  - Taburkan insektisida butiran Karbofuran / Fipronil pada persemaian & saat tanam.\n'
          '  - Aplikasi semprot sistemik Dimehipo atau Klorantraniliprol saat terlihat penerbangan kupu-kupu ngengat putih.';
    }

    if (q.contains('syarat') || q.contains('ambil') || q.contains('ktp') || q.contains('tebus')) {
      return '📄 **Syarat Penebusan Pupuk Bersubsidi Poktan Sri Mulyo:**\n\n'
          '1. **Petani Sendiri:** Membawa **KTP Asli** & fotokopi KTP yang masih berlaku.\n'
          '2. **Diwakilkan Penggarap/Keluarga:**\n'
          '   - Surat Kuasa Penggarap bermaterai Rp 10.000 (template ada di menu **GoKuasa**).\n'
          '   - Fotokopi KTP Pemilik Lahan + Fotokopi KTP Penggarap.\n'
          '3. **Foto di Kios:** Petani / penggarap wajib difoto bersama pupuk sebagai bukti e-Verifikasi kementerian.';
    }

    if (q.contains('harga') || q.contains('het') || q.contains('biaya')) {
      return '💰 **Harga Eceran Tertinggi (HET) Pupuk Subsidi 2026:**\n\n'
          '• **Urea:** Rp 2.250 / kg  👉  **Rp 112.500 / Sak (50 kg)**\n'
          '• **NPK Phonska:** Rp 2.300 / kg  👉  **Rp 115.000 / Sak (50 kg)**\n'
          '• **Organik Petroganik:** Rp 800 / kg  👉  **Rp 32.000 / Sak (40 kg)**\n\n'
          'Harga resmi sesuai ketetapan pemerintah dan tidak ada biaya pungli tambahan.';
    }

    if (q.contains('kontak') || q.contains('wa') || q.contains('pengurus') || q.contains('telepon') || q.contains('ppl')) {
      return '📞 **Layanan Informasi Poktan Sri Mulyo:**\n\n'
          '• **Ketua / Pengurus Poktan:**\n'
          '  WhatsApp: **0856-5562-0979** (Desa Kediren, Kec. Lembeyan)\n'
          '• **Balai Penyuluhan Pertanian (BPP):**\n'
          '  PPL Wilayah Binaan Desa Kediren, Kec. Lembeyan, Kab. Magetan.\n'
          '• Anda dapat menekan tombol hijau "Hubungi Pengurus WA" di menu Profil atau Detail Petani.';
    }

    if (q.contains('jadwal') || q.contains('kloter') || q.contains('kapan')) {
      return '📅 **Jadwal Distribusi Kloter MT3 2026:**\n\n'
          'Pembagian pupuk dibagi menjadi **10 Kloter** untuk menghindari kerumunan di kios:\n'
          '• Lokasi: Kios Resmi Poktan Sri Mulyo / Balai Desa Kediren.\n'
          '• Jam Pelayanan: 08.00 - 14.00 WIB.\n'
          '• Buka menu **GoKloter** untuk melihat nomor kloter Anda dan jadwal hari pembagian.';
    }

    if (q.contains('ru') || q.contains('konversi') || q.contains('luas') || q.contains('bata')) {
      return '📐 **Satuan Luas Tanah Jawa (Kec. Lembeyan, Magetan):**\n\n'
          '• 1 Ru (atau Bata) = **14 m²** (3,75 m × 3,75 m)\n'
          '• 100 Ru = 1.400 m² (0,14 Hektar)\n'
          '• 1 Hektar = 10.000 m² = **~714 Ru**\n\n'
          'Hitung kebutuhan pupuk per Ru secara tepat di kalkulator **GoLEP**!';
    }

    return 'Terima kasih atas pertanyaannya! 🙏\n\n'
        'Untuk pertanyaan spesifik mengenai NIK Anda, silakan cari di menu **GoTani** (Cek Petani). '
        'Atau bila butuh verifikasi berkas dan konsultasi lapangan, silakan hubungi Pengurus Poktan Sri Mulyo di nomor WhatsApp: **0856-5562-0979**. Ada hal lain yang ingin Anda ketahui?';
  }
}
