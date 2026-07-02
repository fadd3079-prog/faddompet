# FadDompet Final Improvement Prompt

You are working on the Flutter repository `faddompet`.

This may be the last large implementation pass for a while, so work carefully and comprehensively. Do not do a shallow patch. Treat this as a full product-quality improvement pass for **FadDompet v1.1**.

## Required reading before editing

Read and understand these files first:

- `PRD.md`
- `DESIGN_SYSTEM.md`
- `ARCHITECTURE.md`
- `README.md`
- `pubspec.yaml`
- `lib/main.dart`
- `lib/app/app.dart`
- all files under `lib/data/`
- all files under `lib/features/`
- all files under `lib/shared/`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`

Before coding, inspect the current implementation deeply:

- app architecture
- database schema
- repositories/DAOs
- Riverpod providers
- dashboard logic
- transaction form logic
- transaction history logic
- wallet CRUD
- category CRUD
- budget CRUD
- settings page
- backup/export/import flow
- bottom navigation
- toast/snackbar/feedback system
- Android release config
- UI performance hotspots

Do not rewrite working systems unnecessarily. Improve the existing implementation.

---

# Product identity

The correct product name is:

```txt
FadDompet
```

User-facing strings must use **FadDompet** exactly.

Do not use:

```txt
Faddompet
faddompet
Faddompet App
```

Exceptions:

- package name may stay `faddompet`
- folder/repo name may stay `faddompet`
- Android applicationId may stay `com.faddgraphics.faddompet`
- database filename may stay technical lowercase
- backup file slug may stay lowercase if needed

But all UI, README, release text, Android label, app title, about page, onboarding, and visible copy must use:

```txt
FadDompet
```

---

# Current state

FadDompet is already a working offline Android money management app using:

- Flutter
- Drift
- SQLite
- Riverpod
- premium iOS-like Android UI
- local/offline-first data
- dashboard
- transaction input
- transaction history
- wallets
- categories
- budget/analytics
- backup/export/import
- GitHub release APK

The app runs on Redmi 13 Android 16 HyperOS 3.0.3.

The app is visually good, but still needs product-level completion:

- CRUD flexibility is incomplete
- app security is not implemented
- UX writing needs major cleanup
- nominal formatting is not readable enough
- bottom nav is too crowded and the plus button is not centered
- input forms need clearer borders/placeholders/helper text
- snackbar appears too low and covers navbar
- reset data is missing or not safely designed
- performance must be improved for low-end devices
- Google Play Protect warning/release hygiene needs improvement
- naming is not fully consistent
- app must become usable for both tech-savvy users and gaptek/orang tua

---

# Main goal

Make FadDompet feel like a complete, safe, lightweight, beginner-friendly daily finance app.

The app must be:

- clear for all users
- comfortable for older/gaptek users
- fast on low-end Android devices
- secure enough for local finance data
- visually premium but not over-animated
- consistent in Bahasa Indonesia
- offline-first
- free from unnecessary dependencies
- stable after updates

---

# Global rules

Follow these strictly:

- Clean code.
- No code comments.
- Keep Bahasa Indonesia UI.
- Keep premium iOS-like Android UI.
- Do not redesign from scratch.
- Do not add backend.
- Do not add login/register account.
- Do not add cloud sync.
- Do not add ads.
- Do not add tracking/analytics.
- Do not add unnecessary dependencies.
- Keep the app lightweight and fast.
- Offline-first only.
- Focus on IDR only for now.
- USD/US currency is only a future/planned setting, not active implementation.
- Keep generic wallets: Tunai, E-Wallet, Rekening, Tabungan.
- Do not use specific bank/e-wallet brand defaults.
- Modify only needed files.
- Keep feature-first architecture.
- Keep database access in repositories/DAOs, not directly in UI.
- Keep UI components reusable.
- Avoid overengineering.
- Preserve existing data via safe migrations.
- Keep `flutter analyze`, `flutter test`, and release build passing.

---

# Priority order

Work in this order:

1. Branding consistency
2. Database migration safety
3. UX writing cleanup
4. IDR nominal formatting
5. Navigation simplification
6. Input form clarity
7. Top floating toast system
8. CRUD completion
9. Reset data with danger confirmation
10. App lock security
11. Interaction feedback
12. Low-end performance pass
13. Release hygiene
14. Documentation update
15. Tests
16. Final build/report

---

# 1. Branding consistency

Audit the entire repo for:

```txt
Faddompet
faddompet
FADDOMPET
```

Replace user-facing occurrences with:

```txt
FadDompet
```

Update at minimum:

- Android app label
- Flutter app title
- onboarding copy
- dashboard copy
- settings copy
- about page
- backup/export share text
- README
- release-oriented text if present
- documentation where user-facing

Android label should be:

```xml
android:label="FadDompet"
```

Keep technical slugs lowercase where appropriate.

---

# 2. Database migration safety

Before changing tables, inspect `AppDatabase`.

If adding or changing schema, bump schema version safely.

Likely needed new fields:

## wallets

Add if not present:

```txt
isArchived
updatedAt
```

## categories

Add if not present:

```txt
isArchived
updatedAt
```

## app settings

Add if needed, or store via secure storage/settings repository:

```txt
appLockEnabled
biometricEnabled
autoLockMinutes
lastUnlockedAt
preferredCurrency
```

Important:

- Do not break users who already installed v1.0/v1.0.1.
- Do not wipe data on upgrade.
- Add `MigrationStrategy`.
- Use `addColumn` migrations where possible.
- Preserve existing transactions, wallets, categories, budgets, and settings.
- If a column already exists, do not duplicate it.
- Keep migration simple and safe.

---

# 3. UX writing cleanup

Perform a full UX writing pass.

Principles:

- short
- clear
- friendly
- not technical
- not childish
- not finance-jargon-heavy
- understandable for older/gaptek users
- Bahasa Indonesia first
- avoid unnecessary English

Replace unclear texts.

Examples:

```txt
Wallet -> Dompet
Settings -> Pengaturan
Backup -> Cadangan
Export -> Ekspor
Import -> Impor
No data -> Belum ada data
No transaction -> Belum ada transaksi
Status -> Kondisi
Save -> Simpan
Delete -> Hapus
Edit -> Edit
```

Avoid vague copy:

```txt
Status perlu dicek
No data available
Wallet selected
Operation failed
```

Use clear copy:

```txt
Cek ringkasan bulan ini
Belum ada transaksi
Pilih dompet terlebih dahulu.
Data berhasil disimpan.
Data berhasil diperbarui.
Data berhasil dihapus.
Masukkan nominal terlebih dahulu.
Pilih kategori terlebih dahulu.
Pilih dompet terlebih dahulu.
Dompet ini masih memiliki transaksi.
Kategori ini masih digunakan oleh transaksi.
Budget untuk periode ini sudah ada.
```

Make all error messages user-friendly. Do not expose technical exceptions directly.

---

# 4. IDR nominal formatting

Focus on IDR only.

All money display must use readable Indonesian format:

```txt
Rp2.500.000
Rp25.000
Rp100.000
```

Not:

```txt
2500000
Rp2500000
IDR 2500000
```

Apply consistently to:

- dashboard
- transaction history
- transaction detail
- transaction form amount preview
- wallet balances
- budget cards
- analytics
- backup/export user-facing labels if needed
- onboarding initial balance
- forms/dialogs/sheets

Input amount should be readable while typing.

If keypad uses internal digits, the preview must format with dots immediately.

Add/adjust helper utility if needed:

```txt
formatRupiah()
parseRupiah()
```

Add tests for this formatter.

Keep currently active currency as IDR.

In Settings, add a planned/future currency row if appropriate:

```txt
Mata uang
IDR - Rupiah
```

And optionally show:

```txt
USD akan tersedia di pembaruan mendatang.
```

Do not implement full multi-currency now.

---

# 5. Navigation simplification

Bottom navigation must become 5 items with the plus button exactly centered.

Use this structure:

```txt
Beranda | Transaksi | + | Dompet | Pengaturan
```

Rules:

- Remove the 6-item nav layout.
- The plus button must be visually and mathematically centered.
- The plus button is the main action to add transaction.
- Navbar must not be too small.
- Navbar height must feel comfortable on mobile.
- Icons and labels must be readable.
- Touch targets must be large enough.
- Bottom nav must respect Android navigation bar.
- Bottom nav must not cover page content.
- Avoid tiny premium UI.

Analytics can be:

- part of Beranda
- accessible from a dashboard card
- accessible as a subpage
- or placed inside Pengaturan/overview if needed

Do not keep Analytics as a nav item if it causes 6 items.

---

# 6. Touch target and button sizing

Make buttons comfortable for all users.

Rules:

- Do not make buttons too small.
- Do not make navbar too small.
- Minimum practical touch target should feel around 44-48 px.
- Chips must not be too short.
- Keypad buttons must be big and responsive.
- Wallet/category chips must be easy to tap.
- Settings tiles must have enough height.
- Primary buttons must be visually clear.
- Avoid compact UI that looks nice but is hard to use.

Important target users:

- tech-savvy users
- beginner users
- gaptek users
- older users

FadDompet must be easy to use without explanation.

---

# 7. Input form clarity

Forms must look like forms.

Improve input fields with:

- clear label
- placeholder
- subtle border/box
- focus state
- helper text if needed
- error text where useful

Do this for:

- onboarding name
- onboarding initial balances
- add/edit transaction note
- wallet name
- wallet initial balance
- category name
- budget amount
- PIN input
- reset confirmation input if used

Onboarding name must be clear:

```txt
Label: Nama pengguna
Placeholder: Contoh: Rina
Helper: Nama ini hanya dipakai untuk menyapa kamu di FadDompet.
```

Do not let users think the name field means category name, wallet name, or money source.

For note field:

```txt
Label: Catatan
Placeholder: Contoh: makan siang, bayar listrik
Helper: Opsional, boleh dikosongkan.
```

---

# 8. Transaction input order

Change the transaction form order for Pengeluaran, Pemasukan, and Transfer.

For Pengeluaran/Pemasukan:

```txt
1. Nominal
2. Waktu
3. Kategori
4. Dompet
5. Catatan
6. Simpan
```

For Transfer:

```txt
1. Nominal
2. Waktu
3. Dari dompet
4. Ke dompet
5. Catatan
6. Simpan
```

Do not put category before time anymore.

Reasoning:

- users usually think amount first
- then date/time
- then purpose/category
- then wallet/source
- then optional note

The UI must follow this natural flow.

Waktu section should be clear and visible:

```txt
Hari ini
Kemarin
Pilih tanggal
```

If current app supports date but not time, call it `Tanggal` instead of `Waktu`. If it supports both date and time, use `Waktu`.

---

# 9. Top floating toast / dynamic island style

Replace bottom snackbar behavior for app feedback.

Problem:

- snackbar appears too low
- it covers bottom navbar
- it feels default/less premium

Create a lightweight top floating toast system.

Requirements:

- appears near top, under status bar/safe area
- floating rounded pill/card
- short message
- success/error/warning style
- auto dismiss
- does not cover bottom nav
- works across pages/sheets
- no heavy blur
- no expensive animation
- fast and smooth
- usable with keyboard open

Example messages:

```txt
Data berhasil disimpan.
Data berhasil diperbarui.
Data berhasil dihapus.
Transaksi berhasil disimpan.
Transaksi berhasil diperbarui.
Transaksi berhasil dihapus.
Masukkan nominal terlebih dahulu.
Pilih dompet terlebih dahulu.
Pilih kategori terlebih dahulu.
Dompet ini masih memiliki transaksi.
Kategori ini masih digunakan oleh transaksi.
Budget untuk periode ini sudah ada.
```

Use it consistently instead of default bottom snackbar where possible.

---

# 10. Clickable/status cards

Any card/status/tile that looks tappable must actually be tappable.

Audit dashboard/status cards such as:

```txt
Perlu dicek
Cek ringkasan
Budget
Dompet
Analitik
```

Rules:

- If it is actionable, make it navigate/open detail.
- If it is only decorative, make it clearly non-clickable or remove it.
- Do not leave confusing UI that users tap but nothing happens.

Examples:

- Wallet summary card taps to Dompet.
- Budget status taps to budget detail/analytics section.
- Recent transaction taps to transaction detail.
- Category spending taps to filtered history if reasonable.

---

# 11. Complete transaction CRUD

Transactions must be fully usable.

Requirements:

## Create

- existing add flow should remain
- improve validation and UX
- amount must be > 0
- wallet required
- category required for income/expense
- source and destination wallet required for transfer
- transfer cannot use same source and destination wallet

## Read/detail

- tapping a transaction tile should open a detail sheet/page
- show amount, type, date/time, category, wallet, note
- for transfer show source and destination wallets

## Update/edit

- edit transaction with prefilled data
- keep current transaction type correctly
- edit amount/category/wallet/date/note
- update dashboard/history/wallet/budget immediately
- do not change `createdAt` during edit
- update only `updatedAt` during edit

## Delete

- delete with clear confirmation
- show consequence in simple language
- update dashboard/history/wallet/budget immediately
- show top toast success/error

Suggested delete copy:

```txt
Hapus transaksi?
Transaksi yang sudah dihapus tidak bisa dikembalikan.
```

Buttons:

```txt
Batal
Hapus
```

Make delete action visually dangerous.

---

# 12. Complete wallet CRUD

Wallets/dompet must be complete and safe.

Requirements:

## Create

- add wallet
- name required
- type required
- initial balance allowed
- format IDR with dots
- avoid duplicate wallet name if possible

## Read/detail

- tap wallet card opens wallet detail
- show balance, type, transaction count, recent transactions

## Update/edit

- edit name
- edit type
- edit initial balance if safe
- if wallet has transactions, warn that changing initial balance affects balance
- update dashboard and wallet list immediately

## Delete/archive

- delete wallet only if safe
- if wallet has transactions, prevent delete
- show clear message:

```txt
Dompet ini masih memiliki transaksi.
```

- add archive/nonaktif wallet
- archived wallet should not appear in new transaction wallet picker
- archived wallet should remain visible in old transactions
- allow restore/unarchive if appropriate

Do not use specific bank/e-wallet brands as default.

Keep default generic wallet set:

```txt
Tunai
E-Wallet
Rekening
Tabungan
```

---

# 13. Complete category CRUD

Categories must be complete and safe.

Requirements:

## Show

- grouped categories
- clear group labels
- simple UI, not crowded
- category picker must use real categories
- show frequently used categories if possible
- add category search if possible

## Create

- add category
- name required
- type required: pemasukan/pengeluaran
- group required or selected
- icon/color if already supported
- prevent duplicate category name within same type/group if possible

## Update/edit

- edit category name
- edit category group
- edit icon/color if available
- preserve transaction history

## Delete/archive

- default category should not be deleted if it breaks app/history
- if category has transactions, prevent delete
- show clear message:

```txt
Kategori ini masih digunakan oleh transaksi.
```

- add archive/nonaktif category
- archived category should not appear in new transaction picker
- archived category should remain visible in old transactions
- allow restore/unarchive if appropriate

Keep category UI beginner-friendly. Do not show too many categories at once without grouping/search.

---

# 14. Complete budget CRUD

Budgets must be clear and usable.

Requirements:

## Create

- add monthly total budget
- add category budget
- amount must be > 0
- month required
- category required for category budget
- prevent duplicate budget for same month/category
- show friendly duplicate message:

```txt
Budget untuk periode ini sudah ada.
```

## Read

- show progress from real expense data
- transfer must not count as expense
- status must be clear:

```txt
Aman
Mendekati batas
Terlampaui
```

## Update/edit

- edit budget amount
- edit month/category only if safe, or keep it simple and edit amount only
- update progress immediately

## Delete

- delete budget with confirmation
- show top toast

## Reset

- reset budget safely if meaningful
- define reset clearly in UI
- if reset means delete/recreate, write copy clearly

Month selector must be easy to understand.

---

# 15. Settings as control center

Make Settings a real control center.

Recommended sections:

```txt
Tampilan
Keamanan
Data & Cadangan
Kategori
Mata Uang
Zona Bahaya
Tentang FadDompet
```

Requirements:

## Tampilan

- hide balance toggle works
- simple UI

## Keamanan

- PIN lock
- biometric unlock
- auto-lock setting
- change PIN
- disable PIN

## Data & Cadangan

- export/backup data
- import/restore data
- clear explanation
- no technical jargon where possible

## Kategori

- manage categories
- add/edit/archive categories

## Mata Uang

- current active currency: IDR - Rupiah
- USD/US as future feature only
- do not implement full multi-currency now
- show planned status clearly if present

Example:

```txt
Mata uang
IDR - Rupiah
Pilihan mata uang lain akan tersedia di pembaruan mendatang.
```

## Zona Bahaya

- reset all data
- dangerous copy
- two-step confirmation

## Tentang FadDompet

- app name
- version
- offline/local data note
- open-source/GitHub if already present
- simple explanation

All settings tiles should be tappable or clearly show planned status.

---

# 16. Reset all data with danger confirmation

Implement reset all data if missing.

This is high priority.

Requirements:

- put inside `Zona Bahaya`
- danger visual styling
- not easy to trigger accidentally
- clear warning
- two-step confirmation
- recommend backup first
- reset should clear transactions, wallets, categories, budgets, app data as intended
- after reset, app should return to clean onboarding/default state
- no crash
- show top toast or success screen

Suggested copy:

```txt
Reset Semua Data
Tindakan ini akan menghapus semua transaksi, dompet, kategori, budget, dan pengaturan. Data yang sudah dihapus tidak bisa dikembalikan kecuali kamu punya file cadangan.
```

Confirmation button:

```txt
Saya mengerti, hapus data
```

Optional stronger confirmation:

- require typing `RESET`
- or require press-and-hold
- choose a simple safe implementation

Do not make reset data available as a casual one-tap action.

---

# 17. Security: local app lock

Implement local app lock.

Allowed dependencies if needed:

```yaml
local_auth
flutter_secure_storage
crypto
```

Only add these if needed.

Do not add online auth.

Security requirements:

## PIN

- Create PIN
- Confirm PIN
- Change PIN
- Disable PIN
- PIN app lock
- PIN must not be stored raw
- store salted hash securely
- use secure storage for sensitive values
- friendly validation
- fallback to PIN if biometric fails/cancels

PIN UX copy:

```txt
Buat PIN
Konfirmasi PIN
Ubah PIN
Nonaktifkan PIN
Masukkan PIN untuk membuka FadDompet
PIN berhasil diperbarui.
PIN tidak sesuai.
```

## Biometric

- optional biometric unlock
- only available if device supports it
- biometric requires PIN fallback
- if unavailable show:

```txt
Biometrik tidak tersedia di perangkat ini.
```

- if user cancels biometric, allow PIN fallback
- do not force biometric

## Auto-lock

Auto-lock when app resumes from background.

Options:

```txt
Langsung
1 menit
5 menit
15 menit
```

Behavior:

- if app lock enabled and auto-lock condition is met, show lock screen on resume
- do not block first onboarding if PIN not created
- hide sensitive balance/data if locked
- after successful unlock return to previous screen

Keep this lightweight.

---

# 18. Interaction feedback

Do not implement heavy desktop hover.

This is mobile-first.

Implement lightweight tap/pressed feedback:

- cards subtle press state
- buttons elegant pressed feedback
- chips clear selected state
- transaction tiles feel tappable
- wallet cards feel tappable
- settings tiles feel tappable
- add transaction keypad buttons feel responsive
- bottom nav items feel responsive

Use simple:

- `InkWell`
- `GestureDetector`
- `AnimatedScale`
- `AnimatedOpacity`
- `AnimatedContainer`

Guidelines:

```txt
duration: 80-140ms
scale: subtle, e.g. 0.98
opacity: subtle
no heavy shadows
no excessive animation
no expensive blur
no janky rebuilds
```

Create reusable components if useful:

```txt
PressableSurface
PressableCard
PressableTile
```

Use consistently but do not overengineer.

---

# 19. Performance and low-end stability

Optimize for Android devices with:

```txt
RAM < 4 GB
chipset around Helio G75 class
```

Performance targets:

- smooth navigation
- smooth transaction sheet
- fast keypad input
- fast note typing
- no horizontal overflow
- no bottom nav covering content
- no excessive shadows/blur
- no large unnecessary rebuilds

Specific tasks:

## AddTransactionSheet

This is likely a hotspot.

Fix:

- keyboard opening for note field must be fast
- typing in TextField must not rebuild the whole sheet
- split large widgets into smaller widgets
- move static category/wallet lists to const or providers where appropriate
- avoid rebuilding category grid when only note text changes
- avoid excessive `setState`
- avoid expensive `ClipRRect`
- avoid `BackdropFilter` unless essential
- avoid huge shadow stacks
- keep category list efficient
- consider showing popular categories first and grouped categories below

## Large pages

Audit and optimize:

- dashboard
- analytics
- settings
- add transaction sheet
- transaction history
- wallet page

Use:

- const constructors
- smaller widgets
- efficient lists
- stable providers
- selective watching with Riverpod if appropriate
- avoid recomputing heavy analytics repeatedly in UI

## Charts

- avoid rebuilding charts unnecessarily
- use simple chart config
- no overly complex animations on low-end devices

## Drift queries

- keep queries efficient
- avoid full scans where easy to optimize
- do not prematurely rewrite all queries, but fix obvious inefficiencies
- keep transfer excluded from expense calculations

---

# 20. Backup/import/export improvements

Keep backup/export/import working.

Improve if needed:

- user-facing text says FadDompet
- backup copy is understandable for normal users
- import validates file before destructive restore
- invalid backup must not corrupt current data
- reset data should suggest backup first
- avoid technical JSON terms unless necessary
- show friendly errors

Possible messages:

```txt
File cadangan tidak valid.
Data berhasil dicadangkan.
Data berhasil dipulihkan.
Buat cadangan dulu agar data bisa dikembalikan nanti.
```

Do not add cloud backup.

---

# 21. Release hygiene and Play Protect trust

Google Play Protect warning can happen for sideloaded GitHub APKs, but improve release hygiene.

Check Android config.

Important:

- do not request unnecessary permissions
- do not add tracking/ads permissions
- Android label must be FadDompet
- release build should not rely on debug signing for serious releases if possible

If release signing is not yet configured, implement a proper local release signing setup safely.

Rules:

- create/update Gradle signing config to read from `key.properties`
- update `.gitignore` to ignore:
  - `android/key.properties`
  - `*.jks`
  - `*.keystore`
- do not commit secret key files
- if no local keystore is available, document exact steps instead of breaking build
- do not require committed secrets for CI/build

If implementing signing config would break the current developer build, keep it safe and documented.

Optional but useful:

- generate SHA256 checksum command/documentation for release APK
- add release notes guidance

---

# 22. README and documentation update

Update README so it presents FadDompet as a universal app, not only for one personal use case.

README should say:

```txt
FadDompet adalah aplikasi pencatat keuangan pribadi offline untuk mengelola pemasukan, pengeluaran, dompet, budget, dan ringkasan keuangan secara lokal di perangkat.
```

Avoid positioning it only as:

```txt
mahasiswa
anak kos
freelancer
desainer
```

Those can be examples, not the core identity.

Update docs only where needed:

- PRD if user-facing direction changed
- DESIGN_SYSTEM if new toast/pressable/input/nav patterns added
- ARCHITECTURE if security/migration/repository changes added

Do not create many new markdown files unless necessary.

---

# 23. Testing

Add or improve tests where practical.

Required minimum tests if feasible:

- Rupiah formatter
- parse Rupiah input
- wallet balance calculation
- transaction edit preserves createdAt
- transfer does not count as expense
- budget status: Aman/Mendekati batas/Terlampaui
- duplicate budget prevention
- invalid backup does not destroy data
- basic widget smoke test still passes

Do not overbuild tests, but cover calculation/data integrity risk.

---

# 24. Specific UX priorities from user testing

A non-technical tester gave these findings. Treat them as high-signal user feedback.

Implement fixes:

## Nominal

Problem:

```txt
Tidak ada tanda titik, susah dibaca.
```

Fix:

```txt
Rp2.500.000
```

## Onboarding name

Problem:

```txt
User mengira nama yang dimasukkan adalah nama kategori/uang, padahal nama pengguna.
```

Fix:

```txt
Nama pengguna
Contoh: Rina
Nama ini hanya dipakai untuk menyapa kamu di FadDompet.
```

## Status/card

Problem:

```txt
Status terlihat seperti bisa dicek, tapi tidak jelas bisa dipencet atau tidak.
```

Fix:

- make actionable cards tappable
- or remove decorative confusing status

## Language

Problem:

```txt
Masih ada bahasa yang kurang/bercampur.
```

Fix:

- Bahasa Indonesia cleanup
- clear beginner-friendly terms

## Older/gaptek users

Problem:

```txt
Untuk orang tua masih terasa rumit.
```

Fix:

- simpler nav
- clearer labels
- bigger buttons
- less crowded category UI
- direct action flow

## Plus button

Problem:

```txt
Tombol + tidak di tengah.
```

Fix:

- 5-item navbar
- plus button exactly centered

## Input form

Problem:

```txt
Input belum terasa seperti input.
```

Fix:

- border
- placeholder
- label
- helper text
- focus state

## Toast

Problem:

```txt
Notifikasi berhasil input muncul terlalu bawah dan menutupi navbar.
```

Fix:

- top floating toast/dynamic-island style

## Reset data

Problem:

```txt
Belum bisa reset data.
```

Fix:

- reset data in danger zone
- two-step confirmation
- strong warning

---

# 25. Do not implement these now

Do not implement:

- full multi-currency
- USD active transactions
- cloud sync
- login/register
- subscription
- ads
- analytics tracking
- OCR receipt scanning
- AI categorization
- bank account integration
- Play Store publishing workflow
- complex desktop hover effects
- heavy animations
- massive redesign

Mention as future only if useful.

---

# 26. Acceptance criteria

The implementation is successful only if:

## Branding

- All user-facing text says FadDompet.
- Android label says FadDompet.

## UX

- Nominal display uses Indonesian Rupiah dot formatting everywhere.
- Onboarding name is clear.
- Bottom nav has 5 items and + centered.
- Buttons/nav are not too small.
- Transaction input order is:
  - Nominal
  - Waktu/Tanggal
  - Kategori
  - Dompet
  - Catatan
- Transfer input order is:
  - Nominal
  - Waktu/Tanggal
  - Dari dompet
  - Ke dompet
  - Catatan
- Input fields have clear label/placeholder/border/helper where needed.
- Top floating toast replaces bottom snackbar for key actions.
- Settings is a real control center.
- Reset data is present and safely confirmed.

## CRUD

- Transactions can be created, viewed, edited, deleted.
- Wallets can be created, viewed, edited, deleted/archived safely.
- Categories can be created, edited, deleted/archived safely.
- Budgets can be created, edited, deleted/reset safely.
- Dashboard/history/wallet/budget update immediately after changes.
- Transfer is not counted as expense.

## Security

- PIN app lock works.
- Change PIN works.
- Disable PIN works.
- Biometric unlock optional if available.
- PIN fallback works.
- Raw PIN is not stored.
- Auto-lock works on app resume.

## Performance

- No horizontal overflow.
- Bottom nav does not cover content.
- AddTransactionSheet is smoother.
- Note field typing is not janky.
- No expensive unnecessary blur/shadow.
- Comfortable on low-end Android.

## Stability

- Existing data is preserved with migration.
- Import invalid backup does not destroy data.
- Reset data returns app to usable clean state.
- Analyze/test/release build pass.

---

# 27. Required commands

Run all:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release --split-per-abi
```

If device is available, also run:

```bash
flutter run -d 6pnjzh5phq6d5dvs
```

If `adb` is not in PATH on Windows, use:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices
```

---

# 28. Final report format

After finishing, report in this exact structure:

```md
# FadDompet v1.1 Final Improvement Report

## 1. Summary
Brief summary.

## 2. Completed UX improvements
- ...

## 3. Completed CRUD improvements
- ...

## 4. Security features
- ...

## 5. Performance improvements
- ...

## 6. Database/migration changes
- ...

## 7. Branding changes
- ...

## 8. Changed files
- ...

## 9. New dependencies
- dependency name and reason
- or "None"

## 10. Tests/build
- flutter analyze: pass/fail
- flutter test: pass/fail
- release build: pass/fail
- device run: pass/fail/not run

## 11. APK sizes
- armeabi-v7a:
- arm64-v8a:
- x86_64:

## 12. Known limitations
- ...

## 13. Next recommended release version
Example: v1.1.0
```

---

# 29. Implementation warning

Do not stop after only changing visuals.

The most important items are:

1. FadDompet naming consistency
2. IDR nominal formatting with dots
3. navbar 5 items with centered +
4. clearer onboarding and forms
5. top floating toast
6. full CRUD
7. reset data danger flow
8. PIN/biometric app lock
9. migration safety
10. low-end performance

If time is limited, complete those first.

Work carefully and preserve the app.
