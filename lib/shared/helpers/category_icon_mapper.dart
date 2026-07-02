import 'package:flutter/material.dart';

import '../../data/local/database/app_database.dart';

IconData categoryIconForEntry(CategoryEntry? category) {
  return categoryIconFromKey(
    category?.iconKey ?? 'category',
    name: category?.name,
    groupName: category?.groupName,
  );
}

IconData categoryIconFromKey(String key, {String? name, String? groupName}) {
  final normalizedKey = _normalizeKey(key);
  if (normalizedKey.isNotEmpty && normalizedKey != 'category') {
    final icon = _iconByKey(normalizedKey);
    if (icon != null) return icon;
  }

  final normalizedName = _normalizeName(name);
  if (normalizedName.isNotEmpty) {
    final icon = _iconByName(normalizedName);
    if (icon != null) return icon;
  }

  final normalizedGroup = _normalizeName(groupName);
  if (normalizedGroup.contains('tagihan')) {
    return Icons.receipt_long_rounded;
  }
  if (normalizedGroup.contains('kesehatan')) {
    return Icons.health_and_safety_rounded;
  }
  if (normalizedGroup.contains('pendidikan')) {
    return Icons.school_rounded;
  }
  if (normalizedGroup.contains('hiburan')) {
    return Icons.celebration_rounded;
  }
  if (normalizedGroup.contains('keuangan')) {
    return Icons.account_balance_wallet_rounded;
  }

  return Icons.category_rounded;
}

IconData? _iconByKey(String key) {
  switch (key) {
    case 'food':
      return Icons.restaurant_rounded;
    case 'drink':
      return Icons.local_cafe_rounded;
    case 'daily-shopping':
      return Icons.shopping_bag_rounded;
    case 'transport':
      return Icons.directions_car_rounded;
    case 'fuel':
      return Icons.local_gas_station_rounded;
    case 'parking':
      return Icons.local_parking_rounded;
    case 'internet':
      return Icons.wifi_rounded;
    case 'laundry':
      return Icons.local_laundry_service_rounded;
    case 'home-needs':
      return Icons.home_rounded;
    case 'electricity':
      return Icons.electric_bolt_rounded;
    case 'water':
      return Icons.water_drop_rounded;
    case 'wifi':
      return Icons.router_rounded;
    case 'rent':
      return Icons.apartment_rounded;
    case 'installment':
      return Icons.credit_card_rounded;
    case 'insurance':
      return Icons.health_and_safety_rounded;
    case 'tax':
      return Icons.receipt_long_rounded;
    case 'subscription':
    case 'bill':
      return Icons.subscriptions_rounded;
    case 'work-software':
      return Icons.devices_rounded;
    case 'cloud':
      return Icons.cloud_rounded;
    case 'streaming':
      return Icons.live_tv_rounded;
    case 'design-tools':
      return Icons.design_services_rounded;
    case 'domain-hosting':
      return Icons.dns_rounded;
    case 'medicine':
      return Icons.medication_rounded;
    case 'doctor':
      return Icons.medical_services_rounded;
    case 'hospital':
      return Icons.local_hospital_rounded;
    case 'vitamin':
      return Icons.spa_rounded;
    case 'self-care':
      return Icons.face_retouching_natural_rounded;
    case 'sport':
      return Icons.fitness_center_rounded;
    case 'book':
      return Icons.menu_book_rounded;
    case 'course':
      return Icons.school_rounded;
    case 'certificate':
      return Icons.workspace_premium_rounded;
    case 'stationery':
      return Icons.edit_note_rounded;
    case 'print':
      return Icons.print_rounded;
    case 'work-tools':
      return Icons.business_center_rounded;
    case 'productivity':
      return Icons.task_alt_rounded;
    case 'entertainment':
      return Icons.celebration_rounded;
    case 'hangout':
      return Icons.groups_rounded;
    case 'cinema':
      return Icons.movie_rounded;
    case 'game':
      return Icons.sports_esports_rounded;
    case 'vacation':
      return Icons.flight_takeoff_rounded;
    case 'hobby':
      return Icons.palette_rounded;
    case 'fashion':
      return Icons.checkroom_rounded;
    case 'gift':
      return Icons.card_giftcard_rounded;
    case 'savings':
      return Icons.savings_rounded;
    case 'investment':
      return Icons.trending_up_rounded;
    case 'emergency-fund':
      return Icons.emergency_rounded;
    case 'transfer-out':
      return Icons.outbound_rounded;
    case 'admin-fee':
      return Icons.account_balance_wallet_rounded;
    case 'donation':
      return Icons.volunteer_activism_rounded;
    case 'debt-paid':
      return Icons.payments_rounded;
    case 'income':
    case 'salary':
      return Icons.work_rounded;
    case 'wage':
      return Icons.payments_rounded;
    case 'bonus':
      return Icons.stars_rounded;
    case 'commission':
      return Icons.handshake_rounded;
    case 'allowance':
      return Icons.wallet_rounded;
    case 'overtime':
      return Icons.schedule_rounded;
    case 'sales':
      return Icons.storefront_rounded;
    case 'service':
      return Icons.handyman_rounded;
    case 'project':
      return Icons.assignment_turned_in_rounded;
    case 'freelance':
      return Icons.laptop_mac_rounded;
    case 'consulting':
      return Icons.forum_rounded;
    case 'royalty':
      return Icons.copyright_rounded;
    case 'affiliate':
      return Icons.link_rounded;
    case 'cashback':
      return Icons.redeem_rounded;
    case 'refund':
      return Icons.assignment_return_rounded;
    case 'interest':
      return Icons.percent_rounded;
    case 'dividend':
      return Icons.show_chart_rounded;
    case 'investment-liquid':
      return Icons.trending_up_rounded;
    case 'savings-withdrawal':
      return Icons.savings_rounded;
    case 'pocket-money':
      return Icons.account_balance_wallet_rounded;
    case 'aid':
      return Icons.diversity_1_rounded;
    case 'loan-in':
      return Icons.account_balance_rounded;
  }
  return null;
}

IconData? _iconByName(String name) {
  switch (name) {
    case 'makanan':
      return Icons.restaurant_rounded;
    case 'minuman':
      return Icons.local_cafe_rounded;
    case 'belanja harian':
      return Icons.shopping_bag_rounded;
    case 'transportasi':
      return Icons.directions_car_rounded;
    case 'bahan bakar':
      return Icons.local_gas_station_rounded;
    case 'parkir':
      return Icons.local_parking_rounded;
    case 'pulsa internet':
      return Icons.wifi_rounded;
    case 'laundry':
      return Icons.local_laundry_service_rounded;
    case 'kebutuhan rumah':
      return Icons.home_rounded;
    case 'listrik':
      return Icons.electric_bolt_rounded;
    case 'air':
      return Icons.water_drop_rounded;
    case 'wifi':
      return Icons.router_rounded;
    case 'sewa':
      return Icons.apartment_rounded;
    case 'cicilan':
      return Icons.credit_card_rounded;
    case 'asuransi':
      return Icons.health_and_safety_rounded;
    case 'pajak':
      return Icons.receipt_long_rounded;
    case 'langganan aplikasi':
      return Icons.subscriptions_rounded;
    case 'software kerja':
      return Icons.devices_rounded;
    case 'cloud storage':
      return Icons.cloud_rounded;
    case 'streaming':
      return Icons.live_tv_rounded;
    case 'design tools':
      return Icons.design_services_rounded;
    case 'domain hosting':
      return Icons.dns_rounded;
    case 'obat':
      return Icons.medication_rounded;
    case 'dokter':
      return Icons.medical_services_rounded;
    case 'rumah sakit':
      return Icons.local_hospital_rounded;
    case 'vitamin':
      return Icons.spa_rounded;
    case 'perawatan diri':
      return Icons.face_retouching_natural_rounded;
    case 'olahraga':
      return Icons.fitness_center_rounded;
    case 'buku':
      return Icons.menu_book_rounded;
    case 'kursus':
      return Icons.school_rounded;
    case 'sertifikasi':
      return Icons.workspace_premium_rounded;
    case 'alat tulis':
      return Icons.edit_note_rounded;
    case 'print':
      return Icons.print_rounded;
    case 'peralatan kerja':
      return Icons.business_center_rounded;
    case 'aplikasi produktivitas':
      return Icons.task_alt_rounded;
    case 'hiburan':
      return Icons.celebration_rounded;
    case 'nongkrong':
      return Icons.groups_rounded;
    case 'bioskop':
      return Icons.movie_rounded;
    case 'game':
      return Icons.sports_esports_rounded;
    case 'liburan':
      return Icons.flight_takeoff_rounded;
    case 'hobi':
      return Icons.palette_rounded;
    case 'fashion':
      return Icons.checkroom_rounded;
    case 'hadiah':
      return Icons.card_giftcard_rounded;
    case 'tabungan':
      return Icons.savings_rounded;
    case 'investasi':
      return Icons.trending_up_rounded;
    case 'dana darurat':
      return Icons.emergency_rounded;
    case 'transfer keluar':
      return Icons.outbound_rounded;
    case 'biaya admin':
      return Icons.account_balance_wallet_rounded;
    case 'donasi':
      return Icons.volunteer_activism_rounded;
    case 'hutang dibayar':
      return Icons.payments_rounded;
    case 'gaji':
      return Icons.work_rounded;
    case 'upah':
      return Icons.payments_rounded;
    case 'bonus':
      return Icons.stars_rounded;
    case 'komisi':
      return Icons.handshake_rounded;
    case 'tunjangan':
      return Icons.wallet_rounded;
    case 'lembur':
      return Icons.schedule_rounded;
    case 'penjualan':
      return Icons.storefront_rounded;
    case 'jasa':
      return Icons.handyman_rounded;
    case 'project':
      return Icons.assignment_turned_in_rounded;
    case 'freelance':
      return Icons.laptop_mac_rounded;
    case 'konsultasi':
      return Icons.forum_rounded;
    case 'royalti':
      return Icons.copyright_rounded;
    case 'affiliate':
      return Icons.link_rounded;
    case 'cashback':
      return Icons.redeem_rounded;
    case 'refund':
      return Icons.assignment_return_rounded;
    case 'bunga':
      return Icons.percent_rounded;
    case 'dividen':
      return Icons.show_chart_rounded;
    case 'investasi cair':
      return Icons.trending_up_rounded;
    case 'tabungan dicairkan':
      return Icons.savings_rounded;
    case 'uang saku':
      return Icons.account_balance_wallet_rounded;
    case 'bantuan':
      return Icons.diversity_1_rounded;
    case 'pinjaman masuk':
      return Icons.account_balance_rounded;
    case 'lainnya':
      return Icons.category_rounded;
  }

  if (name.contains('pulsa') || name.contains('internet')) {
    return Icons.wifi_rounded;
  }
  if (name.contains('bahan bakar')) {
    return Icons.local_gas_station_rounded;
  }
  if (name.contains('transport')) {
    return Icons.directions_car_rounded;
  }
  if (name.contains('makan')) {
    return Icons.restaurant_rounded;
  }
  if (name.contains('hadiah')) {
    return Icons.card_giftcard_rounded;
  }

  return null;
}

String _normalizeKey(String value) {
  return value.trim().toLowerCase().replaceAll('_', '-');
}

String _normalizeName(String? value) {
  return (value ?? '')
      .trim()
      .toLowerCase()
      .replaceAll('&', ' ')
      .replaceAll('/', ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
}
