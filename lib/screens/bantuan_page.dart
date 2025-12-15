// TODO Implement this library.

import 'package:flutter/material.dart';

class BantuanPage extends StatefulWidget {
  const BantuanPage({Key? key}) : super(key: key);

  @override
  State<BantuanPage> createState() => _BantuanPageState();
}

class _BantuanPageState extends State<BantuanPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        'Halo! 👋 Saya Bot Asisten Travel Wisata Lokal.\n\nAda yang bisa saya bantu?');
    _addBotMessage(
        'Anda bisa bertanya tentang:\n• Cara menggunakan aplikasi\n• Menambah destinasi\n• Fitur peta\n• Dan lainnya');
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
    _generateBotResponse(text);
  }

  void _generateBotResponse(String userMessage) {
    String response = '';
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('halo') ||
        lowerMessage.contains('hai') ||
        lowerMessage.contains('hi')) {
      response =
          'Halo! Senang bisa membantu Anda. Ada yang bisa saya bantu? 😊';
    } else if (lowerMessage.contains('tambah') ||
        lowerMessage.contains('destinasi')) {
      response =
          '📍 Untuk menambah destinasi:\n\n1. Tap menu "Tambah" di bottom navigation\n2. Pilih foto/video destinasi\n3. Isi nama, deskripsi, dan lokasi\n4. Klik "Simpan"\n\nAtau bisa langsung dari peta dengan tap lokasi yang diinginkan! 🗺️';
    } else if (lowerMessage.contains('peta') || lowerMessage.contains('map')) {
      response =
          '🗺️ Fitur Peta:\n\n• Lihat semua destinasi dengan marker\n• Tap marker untuk info detail\n• Tap lokasi di peta untuk tambah destinasi baru\n• Tombol "Rute" untuk navigasi\n\nSangat mudah digunakan!';
    } else if (lowerMessage.contains('foto') ||
        lowerMessage.contains('gambar')) {
      response =
          '📸 Upload Foto:\n\n1. Buka menu "Tambah Destinasi"\n2. Tap area foto\n3. Pilih "Ambil Foto" atau "Pilih dari Galeri"\n4. Foto langsung ditambahkan!\n\nUkuran foto akan otomatis dioptimalkan.';
    } else if (lowerMessage.contains('video')) {
      response =
          '🎥 Upload Video:\n\n1. Tap area media di "Tambah Destinasi"\n2. Pilih "Rekam Video" atau "Pilih Video dari Galeri"\n3. Video akan muncul dengan thumbnail\n4. Tap untuk memutar video\n\nMaksimal durasi 5 menit.';
    } else if (lowerMessage.contains('edit') || lowerMessage.contains('ubah')) {
      response =
          '✏️ Edit Destinasi:\n\n1. Buka detail destinasi\n2. Tap icon edit di pojok kanan atas\n3. Ubah informasi yang diinginkan\n4. Klik "Update"\n\nSemua perubahan langsung tersimpan!';
    } else if (lowerMessage.contains('hapus') ||
        lowerMessage.contains('delete')) {
      response =
          '🗑️ Hapus Destinasi:\n\n1. Buka detail destinasi\n2. Tap icon delete (tempat sampah)\n3. Konfirmasi penghapusan\n\n⚠️ Data yang dihapus tidak bisa dikembalikan!';
    } else if (lowerMessage.contains('login') ||
        lowerMessage.contains('masuk')) {
      response =
          '🔐 Login Aplikasi:\n\nUsername: kelompokkita123\nPassword: kelompokkita123\n\nSemua user dengan kredensial sama akan berbagi data destinasi.';
    } else if (lowerMessage.contains('error') ||
        lowerMessage.contains('bug') ||
        lowerMessage.contains('masalah')) {
      response =
          '⚠️ Mengalami masalah?\n\n1. Coba restart aplikasi\n2. Clear cache (Pengaturan > Apps > Clear Cache)\n3. Update ke versi terbaru\n\nJika masih ada masalah, hubungi tim developer kami.';
    } else if (lowerMessage.contains('terima kasih') ||
        lowerMessage.contains('thanks')) {
      response = 'Sama-sama! 😊 Senang bisa membantu. Ada yang lain?';
    } else {
      response =
          'Maaf, saya belum mengerti pertanyaan Anda. 🤔\n\nCoba tanyakan tentang:\n• Cara menambah destinasi\n• Cara menggunakan peta\n• Upload foto/video\n• Edit atau hapus destinasi\n\nAtau ketik "bantuan" untuk info lengkap.';
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      _addBotMessage(response);
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();
    _addUserMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.support_agent, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bot Asisten', style: TextStyle(fontSize: 16)),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF2196F3) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onSubmitted: _handleSubmit,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _handleSubmit(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
