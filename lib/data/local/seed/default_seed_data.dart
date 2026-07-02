import 'package:drift/drift.dart';

import '../database/app_database.dart';

class DefaultSeedData {
  DefaultSeedData._();

  static List<WalletEntriesCompanion> wallets(DateTime now) {
    return [
      _wallet('Tunai', 'cash', now),
      _wallet('E-Wallet', 'ewallet', now),
      _wallet('Rekening', 'bank', now),
      _wallet('Tabungan', 'savings', now),
    ];
  }

  static List<CategoryEntriesCompanion> categories(DateTime now) {
    final expense = <({String group, String name, int color})>[
      ..._group('Kebutuhan Harian', 0xFFDC2626, [
        'Makanan',
        'Minuman',
        'Belanja Harian',
        'Transportasi',
        'Bahan Bakar',
        'Parkir',
        'Pulsa & Internet',
        'Laundry',
        'Kebutuhan Rumah',
      ]),
      ..._group('Tagihan & Langganan', 0xFFF97316, [
        'Listrik',
        'Air',
        'WiFi',
        'Sewa',
        'Cicilan',
        'Asuransi',
        'Pajak',
        'Langganan Aplikasi',
        'Software Kerja',
        'Cloud Storage',
        'Streaming',
        'Design Tools',
        'Domain & Hosting',
      ]),
      ..._group('Kesehatan', 0xFF0F766E, [
        'Obat',
        'Dokter',
        'Rumah Sakit',
        'Vitamin',
        'Perawatan Diri',
        'Olahraga',
      ]),
      ..._group('Pendidikan & Produktivitas', 0xFF2563EB, [
        'Buku',
        'Kursus',
        'Sertifikasi',
        'Alat Tulis',
        'Print',
        'Peralatan Kerja',
        'Aplikasi Produktivitas',
      ]),
      ..._group('Hiburan & Gaya Hidup', 0xFFF97316, [
        'Hiburan',
        'Nongkrong',
        'Bioskop',
        'Game',
        'Liburan',
        'Hobi',
        'Fashion',
        'Hadiah',
      ]),
      ..._group('Keuangan', 0xFF2563EB, [
        'Tabungan',
        'Investasi',
        'Dana Darurat',
        'Transfer Keluar',
        'Biaya Admin',
        'Donasi',
        'Hutang Dibayar',
      ]),
      ..._group('Lainnya', 0xFF6B7280, ['Lainnya']),
    ];

    final income = <({String group, String name, int color})>[
      ..._group('Penghasilan', 0xFF16A34A, [
        'Gaji',
        'Upah',
        'Bonus',
        'Komisi',
        'Tunjangan',
        'Lembur',
      ]),
      ..._group('Usaha & Jasa', 0xFF0F766E, [
        'Penjualan',
        'Jasa',
        'Project',
        'Freelance',
        'Konsultasi',
        'Royalti',
        'Affiliate',
      ]),
      ..._group('Keuangan', 0xFF2563EB, [
        'Cashback',
        'Refund',
        'Bunga',
        'Dividen',
        'Investasi Cair',
        'Tabungan Dicairkan',
      ]),
      ..._group('Dukungan & Lainnya', 0xFF16A34A, [
        'Uang Saku',
        'Hadiah',
        'Bantuan',
        'Pinjaman Masuk',
        'Lainnya',
      ]),
    ];

    return [
      for (final item in expense) _category(item, 'expense', now),
      for (final item in income) _category(item, 'income', now),
    ];
  }

  static AppSettingEntriesCompanion settings(DateTime now) {
    return AppSettingEntriesCompanion.insert(
      currency: const Value('IDR'),
      themeMode: const Value('system'),
      hideBalance: const Value(false),
      onboardingCompleted: const Value(false),
      createdAt: now,
      updatedAt: now,
    );
  }

  static WalletEntriesCompanion _wallet(
    String name,
    String type,
    DateTime now,
  ) {
    return WalletEntriesCompanion.insert(
      name: name,
      type: type,
      initialBalance: const Value(0),
      createdAt: now,
      updatedAt: now,
    );
  }

  static CategoryEntriesCompanion _category(
    ({String group, String name, int color}) item,
    String type,
    DateTime now,
  ) {
    return CategoryEntriesCompanion.insert(
      name: item.name,
      type: type,
      groupName: item.group,
      iconKey: _iconKey(item.name),
      colorValue: item.color,
      isDefault: const Value(true),
      createdAt: now,
      updatedAt: now,
    );
  }

  static List<({String group, String name, int color})> _group(
    String group,
    int color,
    List<String> names,
  ) {
    return [for (final name in names) (group: group, name: name, color: color)];
  }

  static String _iconKey(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('makan') || lower.contains('minuman')) return 'food';
    if (lower.contains('transport') || lower.contains('bahan bakar')) {
      return 'transport';
    }
    if (lower.contains('gaji') || lower.contains('upah')) return 'income';
    if (lower.contains('tagihan') || lower.contains('listrik')) return 'bill';
    if (lower.contains('tabungan') || lower.contains('investasi')) {
      return 'savings';
    }
    return 'category';
  }
}
