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
    switch (name) {
      case 'Makanan':
        return 'food';
      case 'Minuman':
        return 'drink';
      case 'Belanja Harian':
        return 'daily-shopping';
      case 'Transportasi':
        return 'transport';
      case 'Bahan Bakar':
        return 'fuel';
      case 'Parkir':
        return 'parking';
      case 'Pulsa & Internet':
        return 'internet';
      case 'Laundry':
        return 'laundry';
      case 'Kebutuhan Rumah':
        return 'home-needs';
      case 'Listrik':
        return 'electricity';
      case 'Air':
        return 'water';
      case 'WiFi':
        return 'wifi';
      case 'Sewa':
        return 'rent';
      case 'Cicilan':
        return 'installment';
      case 'Asuransi':
        return 'insurance';
      case 'Pajak':
        return 'tax';
      case 'Langganan Aplikasi':
        return 'subscription';
      case 'Software Kerja':
        return 'work-software';
      case 'Cloud Storage':
        return 'cloud';
      case 'Streaming':
        return 'streaming';
      case 'Design Tools':
        return 'design-tools';
      case 'Domain & Hosting':
        return 'domain-hosting';
      case 'Obat':
        return 'medicine';
      case 'Dokter':
        return 'doctor';
      case 'Rumah Sakit':
        return 'hospital';
      case 'Vitamin':
        return 'vitamin';
      case 'Perawatan Diri':
        return 'self-care';
      case 'Olahraga':
        return 'sport';
      case 'Buku':
        return 'book';
      case 'Kursus':
        return 'course';
      case 'Sertifikasi':
        return 'certificate';
      case 'Alat Tulis':
        return 'stationery';
      case 'Print':
        return 'print';
      case 'Peralatan Kerja':
        return 'work-tools';
      case 'Aplikasi Produktivitas':
        return 'productivity';
      case 'Hiburan':
        return 'entertainment';
      case 'Nongkrong':
        return 'hangout';
      case 'Bioskop':
        return 'cinema';
      case 'Game':
        return 'game';
      case 'Liburan':
        return 'vacation';
      case 'Hobi':
        return 'hobby';
      case 'Fashion':
        return 'fashion';
      case 'Hadiah':
        return 'gift';
      case 'Tabungan':
        return 'savings';
      case 'Investasi':
        return 'investment';
      case 'Dana Darurat':
        return 'emergency-fund';
      case 'Transfer Keluar':
        return 'transfer-out';
      case 'Biaya Admin':
        return 'admin-fee';
      case 'Donasi':
        return 'donation';
      case 'Hutang Dibayar':
        return 'debt-paid';
      case 'Gaji':
        return 'salary';
      case 'Upah':
        return 'wage';
      case 'Bonus':
        return 'bonus';
      case 'Komisi':
        return 'commission';
      case 'Tunjangan':
        return 'allowance';
      case 'Lembur':
        return 'overtime';
      case 'Penjualan':
        return 'sales';
      case 'Jasa':
        return 'service';
      case 'Project':
        return 'project';
      case 'Freelance':
        return 'freelance';
      case 'Konsultasi':
        return 'consulting';
      case 'Royalti':
        return 'royalty';
      case 'Affiliate':
        return 'affiliate';
      case 'Cashback':
        return 'cashback';
      case 'Refund':
        return 'refund';
      case 'Bunga':
        return 'interest';
      case 'Dividen':
        return 'dividend';
      case 'Investasi Cair':
        return 'investment-liquid';
      case 'Tabungan Dicairkan':
        return 'savings-withdrawal';
      case 'Uang Saku':
        return 'pocket-money';
      case 'Bantuan':
        return 'aid';
      case 'Pinjaman Masuk':
        return 'loan-in';
      default:
        return 'category';
    }
  }
}
