# Security Policy

FadDompet dirancang sebagai aplikasi pencatat keuangan pribadi offline. Aplikasi tidak membutuhkan akun, cloud sync, iklan, analytics, atau tracking untuk fitur inti.

## Trust Model

- Data utama disimpan lokal di perangkat.
- App lock memakai PIN lokal dan biometrik opsional jika tersedia.
- PIN tidak disimpan sebagai teks asli.
- App lock bukan enkripsi penuh database.
- File cadangan berisi data keuangan dan harus disimpan di tempat yang aman.
- APK yang dipasang lewat sideload dari GitHub dapat memunculkan peringatan Play Protect.

## Permissions

FadDompet menjaga permission Android tetap minimal. Permission biometrik hanya digunakan untuk membuka app lock jika pengguna mengaktifkan biometrik.

## Backup Safety

Cadangan dibuat dan dipulihkan atas kontrol pengguna. Sebelum memulihkan data, aplikasi memvalidasi isi file cadangan. File yang tidak valid tidak boleh menghapus data yang sudah ada.

## Verifikasi APK

Gunakan checksum SHA256 untuk memeriksa file APK dari rilis resmi:

```powershell
Get-FileHash build\app\outputs\flutter-apk\app-arm64-v8a-release.apk -Algorithm SHA256
```

## Reporting Security Issues

Jika menemukan masalah keamanan, laporkan secara privat kepada maintainer. Jangan mempublikasikan detail sensitif sebelum masalah ditinjau.
