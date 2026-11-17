import 'package:flutter/material.dart';

import 'chat_draft.dart';

/// Pengirim pesan dalam percakapan chatbot.
enum ChatAuthor { user, assistant }

/// Satu gelembung pesan pada tampilan chat.
@immutable
class ChatMessageData {
  const ChatMessageData({
    required this.author,
    required this.text,
    this.timeLabel,
    this.draft,
  });

  final ChatAuthor author;
  final String text;
  final String? timeLabel;

  /// Draft pencatatan yang menempel pada pesan asisten.
  final ChatDraft? draft;
}

/// Satu sesi percakapan contoh.
@immutable
class ChatConversationData {
  const ChatConversationData({
    required this.title,
    required this.messages,
  });

  final String title;
  final List<ChatMessageData> messages;
}

/// Saran cepat pada percakapan baru.
@immutable
class ChatSuggestionData {
  const ChatSuggestionData({required this.label, required this.reply});

  final String label;
  final String reply;
}

/// Kartu "Alat Cepat" pada halaman utama chatbot.
@immutable
class ChatQuickActionData {
  const ChatQuickActionData({
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.icon,
    required this.conversation,
    this.primary = false,
  });

  final String title;
  final String description;
  final String ctaLabel;
  final IconData icon;
  final ChatConversationData conversation;

  /// Kartu pertama memakai tombol biru, kartu lain abu-abu (Figma).
  final bool primary;
}

/// Baris riwayat percakapan.
@immutable
class ChatHistoryEntryData {
  const ChatHistoryEntryData({
    required this.title,
    required this.conversation,
  });

  final String title;
  final ChatConversationData conversation;
}

/// Kontrak data layar Chatbot Soju (frame Figma `546:3687`).
///
/// Layar hanya merender data ini dan meneruskan aksi lewat callback. Belum ada
/// pemanggilan API: balasan asisten masih contoh statis dari [demoReply] dan
/// [suggestions].
@immutable
class ChatbotViewData {
  const ChatbotViewData({
    required this.greeting,
    required this.aiName,
    required this.aiTagline,
    required this.quickActions,
    required this.history,
    required this.suggestions,
    required this.newChatGreeting,
    required this.demoNotice,
    required this.demoReply,
    required this.confirmDemoMessage,
    required this.correctDemoMessage,
  });

  final String greeting;
  final String aiName;
  final String aiTagline;
  final List<ChatQuickActionData> quickActions;
  final List<ChatHistoryEntryData> history;
  final List<ChatSuggestionData> suggestions;

  /// Sapaan asisten saat membuka percakapan baru.
  final String newChatGreeting;

  /// Catatan bahwa AI belum terhubung ke backend.
  final String demoNotice;

  /// Balasan mock setelah pengguna mengirim pesan.
  final String demoReply;

  final String confirmDemoMessage;
  final String correctDemoMessage;

  /// Data contoh hasil slicing Figma (`546:3687`, `546:4198`, `546:4098`).
  static const ChatbotViewData sample = ChatbotViewData(
    greeting:
        'Halo! Saya siap bantu kelola dan catat keuangan bisnis kamu hari ini',
    aiName: 'Soju AI',
    aiTagline: 'Asisten dapur',
    quickActions: <ChatQuickActionData>[
      ChatQuickActionData(
        title: 'Input hasil penjualan harian',
        description: 'Input hasil penjualan harian atau penerimaan kas bisnis.',
        ctaLabel: 'Catat Sales',
        icon: Icons.account_balance_wallet_outlined,
        primary: true,
        conversation: _salesConversation,
      ),
      ChatQuickActionData(
        title: 'Catat Pengeluaran',
        description: 'Catat belanja bahan, gas, dan biaya operasional dapur.',
        ctaLabel: 'Catat Belanja',
        icon: Icons.receipt_long_outlined,
        conversation: _expenseConversation,
      ),
      ChatQuickActionData(
        title: 'Tambah Suplier',
        description: 'Simpan data pemasok, stok masuk, atau catatan utang.',
        ctaLabel: 'Kelola Suplier',
        icon: Icons.local_shipping_outlined,
        conversation: _supplierConversation,
      ),
    ],
    history: <ChatHistoryEntryData>[
      ChatHistoryEntryData(
        title: 'Input Hasil Penjualan',
        conversation: _salesConversation,
      ),
      ChatHistoryEntryData(
        title: 'Catat Pengeluaran',
        conversation: _expenseConversation,
      ),
      ChatHistoryEntryData(
        title: 'Tambah Suplier',
        conversation: _supplierConversation,
      ),
      ChatHistoryEntryData(
        title: 'Catat Laporan Kas',
        conversation: _cashReportConversation,
      ),
      ChatHistoryEntryData(
        title: 'Cek Stok Menipis',
        conversation: _lowStockConversation,
      ),
      ChatHistoryEntryData(
        title: 'Input Penjualan QRIS',
        conversation: _qrisConversation,
      ),
      ChatHistoryEntryData(
        title: 'Catat Biaya Operasional',
        conversation: _operationalConversation,
      ),
      ChatHistoryEntryData(
        title: 'Ringkasan Laba Mingguan',
        conversation: _weeklyProfitConversation,
      ),
    ],
    suggestions: <ChatSuggestionData>[
      ChatSuggestionData(
        label: 'Catat penjualan hari ini',
        reply: 'Siap! Kirim rincian menu dan jumlahnya, nanti saya buatkan '
            'draft penjualan. Untuk sekarang ini masih contoh.',
      ),
      ChatSuggestionData(
        label: 'Cek stok menipis',
        reply: 'Saya belum terhubung ke data stok (mode demo). Nanti saya bisa '
            'bantu tampilkan bahan yang hampir habis.',
      ),
      ChatSuggestionData(
        label: 'Ringkasan laba minggu ini',
        reply: 'Ringkasan laba akan tersedia setelah AI terhubung ke data. '
            'Sekarang saya hanya bisa menampilkan contoh percakapan.',
      ),
    ],
    newChatGreeting:
        'Halo Kak Rina & Mama! 👋 Saya siap bantu catat penjualan, pengeluaran, '
        'atau stok hari ini.',
    demoNotice:
        'Mode demo — AI belum terhubung ke backend dan tidak menyimpan data.',
    demoReply: 'Terima kasih! Fitur AI masih demo. Pesanmu belum diproses dan '
        'tidak ada data yang disimpan.',
    confirmDemoMessage:
        'Mode demo — draft belum disimpan. Tidak ada data yang berubah.',
    correctDemoMessage: 'Mode demo — koreksi draft belum terhubung ke data.',
  );
}

const ChatDraft _sampleDraft = ChatDraft(
  badge: 'Belum disimpan',
  dateLabel: '14 Okt 2026',
  shiftLabel: 'Shift Siang',
  totalLabel: 'TOTAL PEMASUKAN KASIR',
  breakdownTitle: 'Rincian Menu Terjual',
  items: <ChatDraftItem>[
    ChatDraftItem(
      name: 'Bento Ayam Bakar',
      quantity: 30,
      unit: 'porsi',
      unitPrice: 35000,
      method: ChatPaymentMethod.qris,
      icon: Icons.lunch_dining_outlined,
    ),
    ChatDraftItem(
      name: 'Sosis Keju',
      quantity: 15,
      unit: 'porsi',
      unitPrice: 15000,
      method: ChatPaymentMethod.cash,
    ),
    ChatDraftItem(
      name: 'Es Teh Manis',
      quantity: 20,
      unit: 'gelas',
      unitPrice: 5000,
      method: ChatPaymentMethod.cash,
      icon: Icons.local_drink_outlined,
    ),
  ],
  confirmLabel: 'Konfirmasi & Simpan',
  correctLabel: 'Koreksi Jumlah / Harga',
  note: 'Draft ini belum disimpan dan tidak mengubah data pembukuan.',
);

const ChatConversationData _salesConversation = ChatConversationData(
  title: 'Input Hasil Penjualan',
  messages: <ChatMessageData>[
    ChatMessageData(
      author: ChatAuthor.user,
      text: 'Catat penjualan hari ini ya',
      timeLabel: '14:08',
    ),
    ChatMessageData(
      author: ChatAuthor.assistant,
      text: 'Siap, Kak! Ini draft pencatatan penjualan hari ini. Belum '
          'disimpan — cek dulu sebelum dikonfirmasi ya.',
      timeLabel: '14:08',
      draft: _sampleDraft,
    ),
  ],
);

const ChatConversationData _expenseConversation = ChatConversationData(
  title: 'Catat Pengeluaran',
  messages: <ChatMessageData>[
    ChatMessageData(
      author: ChatAuthor.user,
      text: 'Catat pengeluaran bahan hari ini Rp 325.000',
      timeLabel: '13:42',
    ),
    ChatMessageData(
      author: ChatAuthor.assistant,
      text: 'Baik, pengeluaran Rp 325.000 untuk bahan sudah saya siapkan '
          'sebagai contoh catatan. Data ini belum disimpan.',
      timeLabel: '13:42',
    ),
  ],
);

const ChatConversationData _supplierConversation = ChatConversationData(
  title: 'Tambah Suplier',
  messages: <ChatMessageData>[
    ChatMessageData(
      author: ChatAuthor.user,
      text: 'Tambah suplier ayam baru',
      timeLabel: '12:10',
    ),
    ChatMessageData(
      author: ChatAuthor.assistant,
      text: 'Siap. Sebutkan nama suplier dan barang yang dipasok. Fitur ini '
          'masih demo dan belum menyimpan data suplier.',
      timeLabel: '12:10',
    ),
  ],
);

const ChatConversationData _cashReportConversation = ChatConversationData(
  title: 'Catat Laporan Kas',
  messages: <ChatMessageData>[
    ChatMessageData(
      author: ChatAuthor.user,
      text: 'Buat laporan kas hari ini',
      timeLabel: '11:24',
    ),
    ChatMessageData(
      author: ChatAuthor.assistant,
      text: 'Laporan kas belum bisa dihitung karena AI masih mode demo. Nanti '
          'ringkasan kas harian akan muncul di sini.',
      timeLabel: '11:24',
    ),
  ],
);

const ChatConversationData _lowStockConversation = ChatConversationData(
  title: 'Cek Stok Menipis',
  messages: <ChatMessageData>[
    ChatMessageData(
      author: ChatAuthor.user,
      text: 'Stok apa yang hampir habis?',
      timeLabel: '10:05',
    ),
    ChatMessageData(
      author: ChatAuthor.assistant,
      text: 'Mode demo: saya belum terhubung ke data stok. Nanti saya bisa '
          'menampilkan bahan yang tinggal sedikit.',
      timeLabel: '10:05',
    ),
  ],
);

const ChatConversationData _qrisConversation = ChatConversationData(
  title: 'Input Penjualan QRIS',
  messages: <ChatMessageData>[
    ChatMessageData(
      author: ChatAuthor.user,
      text: 'Catat penjualan QRIS Rp 750.000',
      timeLabel: '09:48',
    ),
    ChatMessageData(
      author: ChatAuthor.assistant,
      text: 'Contoh catatan QRIS Rp 750.000 sudah saya siapkan. Draft ini '
          'belum disimpan ke pembukuan.',
      timeLabel: '09:48',
    ),
  ],
);

const ChatConversationData _operationalConversation = ChatConversationData(
  title: 'Catat Biaya Operasional',
  messages: <ChatMessageData>[
    ChatMessageData(
      author: ChatAuthor.user,
      text: 'Catat biaya operasional gas dan listrik',
      timeLabel: '09:12',
    ),
    ChatMessageData(
      author: ChatAuthor.assistant,
      text: 'Siap, biaya operasional bisa dicatat lewat form pengeluaran. AI '
          'masih demo, jadi belum ada data yang tersimpan.',
      timeLabel: '09:12',
    ),
  ],
);

const ChatConversationData _weeklyProfitConversation = ChatConversationData(
  title: 'Ringkasan Laba Mingguan',
  messages: <ChatMessageData>[
    ChatMessageData(
      author: ChatAuthor.user,
      text: 'Bagaimana laba minggu ini?',
      timeLabel: '08:30',
    ),
    ChatMessageData(
      author: ChatAuthor.assistant,
      text: 'Ringkasan laba mingguan akan muncul di sini setelah AI terhubung '
          'ke data. Untuk sekarang saya hanya bisa menunjukkan contoh '
          'percakapan.',
      timeLabel: '08:30',
    ),
  ],
);
