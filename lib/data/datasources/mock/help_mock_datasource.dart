// lib/data/datasources/mock/help_mock_datasource.dart
//
// Sumber data mock Pusat Bantuan (Phase A).
//
// Topik dan artikel mengikuti contoh pada frame Figma `546:5647` dan
// `546:5686`. Phase B cukup mengganti datasource ini dengan endpoint bantuan.

import '../interfaces/help_datasource.dart';

/// Mock datasource topik dan artikel bantuan.
class HelpMockDataSource implements HelpDataSource {
  const HelpMockDataSource();

  static const List<Map<String, Object?>> _topics = <Map<String, Object?>>[
    <String, Object?>{
      'id': 'topik-transaksi',
      'judul': 'Bagaimana cara mencatat transaksi di Buku Dapur?',
      'deskripsi':
          'Anda dapat mencatat transaksi pemasukan maupun pengeluaran secara '
              'langsung, dan tambah data langsung.',
      'jumlah_artikel': 5,
      'unggulan': true,
    },
    <String, Object?>{
      'id': 'topik-jenis-transaksi',
      'judul': 'Bagaimana cara membuat jenis transaksi baru?',
      'deskripsi': 'Anda dapat membuat Master Transaksi baru, menentukan arah '
          '(Pemasukan/Pengeluaran), serta menambahkan kolom kustom sendiri '
          'lewat aplikasi.',
      'jumlah_artikel': 3,
      'unggulan': true,
    },
    <String, Object?>{
      'id': 'topik-order',
      'judul': 'Bagaimana cara mencatat order atau penjualan?',
      'deskripsi':
          'Order dari berbagai kanal (WhatsApp, DM Instagram, GrabFood) dapat '
              'dicatat sebagai entri Pemasukan langsung di Master Transaksi.',
      'jumlah_artikel': 4,
      'unggulan': false,
    },
    <String, Object?>{
      'id': 'topik-hutang-piutang',
      'judul': 'Bagaimana cara mencatat dan memantau hutang piutang?',
      'deskripsi':
          'Anda dapat mengelola data pelanggan (piutang) dan pemasok (hutang) '
              'serta mencatat pembayaran cicilan yang terhubung otomatis.',
      'jumlah_artikel': 2,
      'unggulan': false,
    },
    <String, Object?>{
      'id': 'topik-stok',
      'judul': 'Bagaimana cara mengatur peringatan stok menipis?',
      'deskripsi':
          'Tentukan batas stok minimum agar Buku Dapur mengingatkan Anda '
              'sebelum bahan atau produk habis.',
      'jumlah_artikel': 2,
      'unggulan': false,
    },
    <String, Object?>{
      'id': 'topik-laporan',
      'judul': 'Bagaimana cara mengunduh laporan keuangan?',
      'deskripsi':
          'Laporan pemasukan, pengeluaran, dan laba bersih dapat dilihat per '
              'periode lalu dibagikan ke tim atau akuntan.',
      'jumlah_artikel': 3,
      'unggulan': false,
    },
  ];

  static const Map<String, Map<String, Object?>> _articles =
      <String, Map<String, Object?>>{
    'topik-transaksi': <String, Object?>{
      'id': 'topik-transaksi',
      'topik_id': 'topik-transaksi',
      'judul':
          'Bagaimana cara mencatat dan menyesuaikan transaksi di Buku Kita?',
      'paragraf': <String>[
        'Anda dapat mencatat berbagai jenis transaksi pemasukan dan '
            'pengeluaran usaha secara praktis melalui Master Transaksi. '
            'Setiap jenis transaksi dapat disesuaikan dengan kolom kustom '
            '(teks, angka, tanggal, atau dropdown) sesuai kebutuhan '
            'pencatatan usaha Anda.',
        'Buku Dapur juga memungkinkan Anda mencatat transaksi order dari '
            'berbagai kanal penjualan, pembayaran cicilan hutang, hingga '
            'mengelola saldo piutang pelanggan dan hutang pemasok secara '
            'terpusat.',
      ],
    },
    'topik-jenis-transaksi': <String, Object?>{
      'id': 'topik-jenis-transaksi',
      'topik_id': 'topik-jenis-transaksi',
      'judul': 'Bagaimana cara membuat jenis transaksi baru?',
      'paragraf': <String>[
        'Buka menu Master Transaksi, lalu pilih tambah jenis transaksi. '
            'Tentukan nama, arah arus kas (Pemasukan atau Pengeluaran), dan '
            'kolom yang ingin dipakai.',
        'Kolom kustom dapat berupa teks, angka, tanggal, atau pilihan ganda. '
            'Setelah disimpan, jenis transaksi langsung tersedia saat Anda '
            'mencatat transaksi baru.',
      ],
    },
    'topik-order': <String, Object?>{
      'id': 'topik-order',
      'topik_id': 'topik-order',
      'judul': 'Bagaimana cara mencatat order atau penjualan?',
      'paragraf': <String>[
        'Order dari berbagai kanal seperti WhatsApp, DM Instagram, atau '
            'GrabFood dapat dicatat sebagai entri Pemasukan langsung di '
            'Master Transaksi.',
        'Isi nama pelanggan, daftar item, total pembayaran, dan metode '
            'pembayaran. Jika pembayaran dilakukan bertahap, catat sisanya '
            'sebagai piutang pelanggan.',
      ],
    },
    'topik-hutang-piutang': <String, Object?>{
      'id': 'topik-hutang-piutang',
      'topik_id': 'topik-hutang-piutang',
      'judul': 'Bagaimana cara mencatat dan memantau hutang piutang?',
      'paragraf': <String>[
        'Buku Dapur menyimpan data pelanggan (piutang) dan pemasok (hutang) '
            'beserta riwayat pembayaran cicilan.',
        'Gunakan menu hutang piutang untuk melihat sisa tagihan, jatuh tempo, '
            'dan mencatat pembayaran. Setiap pembayaran otomatis mengurangi '
            'saldo terkait.',
      ],
    },
    'topik-stok': <String, Object?>{
      'id': 'topik-stok',
      'topik_id': 'topik-stok',
      'judul': 'Bagaimana cara mengatur peringatan stok menipis?',
      'paragraf': <String>[
        'Buka pengaturan produk atau bahan, lalu tentukan batas stok minimum. '
            'Buku Dapur akan menampilkan peringatan ketika jumlah stok '
            'mencapai batas tersebut.',
        'Peringatan stok menipis dapat diaktifkan atau dimatikan dari menu '
            'Pengaturan > Pemberitahuan.',
      ],
    },
    'topik-laporan': <String, Object?>{
      'id': 'topik-laporan',
      'topik_id': 'topik-laporan',
      'judul': 'Bagaimana cara mengunduh laporan keuangan?',
      'paragraf': <String>[
        'Laporan pemasukan, pengeluaran, dan laba bersih tersedia pada menu '
            'Analytics. Pilih rentang tanggal yang ingin dilihat.',
        'Gunakan tombol unduh atau bagikan untuk menyimpan laporan sebagai '
            'berkas yang dapat dikirim ke tim atau akuntan.',
      ],
    },
  };

  @override
  Future<Map<String, Object?>> fetchTopicsRaw() async {
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'topics': _topics,
      },
    };
  }

  @override
  Future<Map<String, Object?>> fetchArticleRaw(String id) async {
    final Map<String, Object?>? article = _articles[id];
    if (article == null) {
      return <String, Object?>{
        'success': false,
        'message': 'Artikel bantuan tidak ditemukan.',
      };
    }
    return <String, Object?>{
      'success': true,
      'data': article,
    };
  }
}
