# FadDompet

FadDompet adalah aplikasi pencatat keuangan pribadi offline untuk mengelola pemasukan, pengeluaran, transfer, dompet, budget, dan ringkasan keuangan secara lokal di perangkat.

## Status

```txt
FadDompet v1.2.0 - Offline personal money management app for Android
```

## Fitur Utama

- Pencatatan pemasukan, pengeluaran, dan transfer
- Dompet lokal: Tunai, E-Wallet, Rekening, Tabungan
- Dashboard saldo dan ringkasan bulan ini
- Riwayat transaksi dengan pencarian dan filter
- Analitik dan budget bulanan
- Kategori pemasukan dan pengeluaran yang bisa dikelola
- Cadangkan dan pulihkan data saat ganti HP
- Ekspor laporan transaksi CSV
- Reset data dengan konfirmasi aman
- PIN lock, biometrik opsional, dan hide balance
- UI Android premium yang terinspirasi iOS

## Prinsip Produk

- Offline-first
- Tanpa akun atau login online
- Tanpa cloud sync
- Tanpa iklan
- Tanpa analytics atau tracking
- Data tersimpan lokal di perangkat
- Ringan untuk penggunaan harian

## Download APK

APK rilis dapat dibagikan melalui GitHub Releases. Karena APK dari GitHub dipasang dengan sideload, Play Protect dapat menampilkan peringatan walaupun aplikasi tidak memakai permission berisiko. Verifikasi file dari sumber rilis resmi sebelum memasang.

Untuk membuat checksum SHA256 APK di PowerShell:

```powershell
Get-FileHash build\app\outputs\flutter-apk\app-arm64-v8a-release.apk -Algorithm SHA256
```

## Release Signing

APK publik harus ditandatangani dengan release keystore lokal. Buat keystore:

```powershell
keytool -genkey -v -keystore android/app/faddompet-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias faddompet
```

Buat file `android/key.properties` di mesin lokal:

```properties
storePassword=isi_password_store
keyPassword=isi_password_key
keyAlias=faddompet
storeFile=faddompet-release-key.jks
```

Jangan commit `android/key.properties`, `.jks`, atau `.keystore`.

## Backup

Fitur cadangan membantu memindahkan data ke HP baru. File cadangan berisi data keuangan dalam format lokal, jadi simpan di tempat yang aman dan jangan dibagikan sembarangan.

## Target Platform

Android adalah target utama. Flutter Web digunakan hanya untuk preview pengembangan.

## Lisensi

Lisensi: MIT.
