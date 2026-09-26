# LauncherOS — Liquid Glass

Android launcher dengan tema Liquid Glass / Glassmorphism.

## Build APK otomatis di GitHub

Project ini sudah dilengkapi GitHub Actions. Setelah folder project di-upload ke repository GitHub:

1. Pastikan branch utama bernama `main` atau `master`.
2. Push/upload seluruh isi project ini ke repository.
3. Buka tab **Actions** di repository.
4. Workflow **Build LauncherOS APK** akan berjalan otomatis.
5. Setelah selesai, buka hasil workflow dan ambil artifact **LauncherOS-debug-apk**.
6. Di dalam artifact terdapat `app-debug.apk` yang dapat dipindahkan ke HP Android untuk instalasi.

Anda juga dapat menjalankan build secara manual dari **Actions → Build LauncherOS APK → Run workflow**.

## Catatan

- APK yang dihasilkan adalah **debug APK**, cocok untuk instalasi pribadi dan pengujian.
- Untuk publikasi Play Store atau distribusi produksi, gunakan APK/AAB yang ditandatangani dengan release keystore.
- Setelah terpasang, pilih LauncherOS sebagai aplikasi Home/default launcher jika Android meminta pilihan launcher.


<!-- APK build workflow enabled -->
