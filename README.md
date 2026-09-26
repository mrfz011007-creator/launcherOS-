# LauncherOS V2 — Liquid Glass

LauncherOS adalah launcher Android pribadi tanpa iklan, dengan fokus pada Liquid Glass, motion halus, dan interaksi cepat.

## Target perangkat

- TECNO SPARK Go 2024 / BG6
- Android 13
- T606
- Layar 720x1612
- RAM fisik 4 GB + hingga 4 GB extended RAM
- Penyimpanan 128 GB

## Arsitektur

```
com.launcher.os
├── data/
│   ├── AppItem.kt
│   └── AppRepository.kt
├── feature/
│   └── home/
│       └── HomeScreen.kt
├── ui/
│   ├── components/
│   │   ├── AppIconView.kt
│   │   ├── GlassBackground.kt
│   │   └── GlassSurface.kt
│   ├── motion/
│   │   └── LauncherMotion.kt
│   └── theme/
│       └── LauncherTheme.kt
└── MainActivity.kt
```

## Prinsip V2

1. Liquid Glass menjadi bahasa visual utama.
2. Motion dibuat sebagai sistem yang konsisten.
3. Blur dipakai hemat karena target perangkat adalah kelas entry-level.
4. Tidak ada iklan.
5. Fitur harus tetap responsif pada layar 720x1612 dan RAM fisik 4 GB.

Android mendukung blur melalui Compose pada Android 12+, tetapi efek blur membuat layer grafis tambahan. Karena target kita Android 13/T606, V2 menggunakan blur terutama pada elemen latar dan bukan blur berat pada setiap panel.

## Roadmap

### V2.0 — Foundation
- [x] Struktur arsitektur modular
- [x] GlassSurface reusable
- [x] Glass background
- [x] Motion system
- [x] App drawer + search
- [x] Request default launcher role

### V2.1 — Home interaction
- [ ] Folder glass
- [ ] Favorite/pinned apps
- [ ] Drag & drop layout
- [ ] Wallpaper-aware background

### V2.2 — Widgets
- [ ] AppWidgetHost
- [ ] Widget page
- [ ] Weather card
- [ ] Widget placement persistence

### V2.3 — Intelligence & navigation
- [ ] Gesture navigation
- [ ] App library categories
- [ ] Search contacts/settings
- [ ] Recent apps integration
- [ ] Performance tuning

### V2.4 — Personalization & security
- [ ] Customization panel
- [ ] App lock
- [ ] Hidden apps
- [ ] Backup/import layout

### V2.5 — Stable personal build
- [ ] Persistent signing key
- [ ] Release APK
- [ ] Final performance pass on BG6
- [ ] Install/update workflow

## Build

GitHub Actions menghasilkan debug APK untuk pengujian pribadi.
