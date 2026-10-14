// ============================================
// ✅ 1. KONFIGURASI CACHE
// ============================================
const CACHE_NAME = 'pwa-cache-v1'; // 🔧 Ganti versi jika update // Nama cache (versi bisa diubah saat update)
const OFFLINE_PAGE = '/offline.html'; // Halaman fallback offline
const ASSETS = [
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icon.png'
];
    // 🔧 Tambahkan file lain yang perlu di-cache
];

// ============================================
// ✅ 2. INSTALL SERVICE WORKER
// ============================================
self.addEventListener('install', (event) => {
  console.log('🛠 Service Worker: Proses instalasi...');
  event.waitUntil(
    caches.open(CACHE_NAME).then(async (cache) => {
      console.log('📦 Menyimpan assets ke cache:', ASSETS);
      for (const asset of ASSETS) {
        try {
          await cache.add(asset);
        } catch (err) {
          console.warn('⚠️ Gagal cache:', asset, err);
        }
      }
    })
  );
  self.skipWaiting();
});

// ============================================
// ✅ 3. STRATEGI CACHE: Network First, Fallback ke Cache
// ============================================
self.addEventListener('fetch', (event) => {
    // Abaikan request non-GET (seperti POST)
    if (event.request.method !== 'GET') return;
    
    // Handle request API berbeda dengan assets
    if (event.request.url.includes('/api/')) {
        // 🔧 Strategi untuk API: Network first, lalu cache
        event.respondWith(
            fetch(event.request)
                .then((response) => {
                    // Simpan response API ke cache
                    const clone = response.clone();
                    caches.open(CACHE_NAME)
                        .then((cache) => cache.put(event.request, clone));
                    return response;
                })
                .catch(() => {
                    // Jika offline, coba ambil dari cache
                    return caches.match(event.request);
                })
        );
    } else {
        // Untuk assets: Cache first, lalu network
        event.respondWith(
            caches.match(event.request)
                .then((cached) => {
                    // Gunakan cache jika ada
                    if (cached) return cached;
                    
                    // Jika tidak, fetch dari network
                    return fetch(event.request)
                        .catch(() => {
                            // Jika offline & request HTML, tampilkan halaman offline
                            if (event.request.headers.get('accept').includes('text/html')) {
                                return caches.match(OFFLINE_PAGE);
                            }
                        });
                })
        );
    }
});

// ============================================
// ✅ 4. AUTO UPDATE CACHE SAAT ADA VERSI BARU
// ============================================
self.addEventListener('activate', (event) => {
    console.log('♻️ Service Worker: Aktivasi...');
    
    // Hapus cache lama
    event.waitUntil(
        caches.keys().then((keys) => {
            return Promise.all(
                keys.map((key) => {
                    if (key !== CACHE_NAME) {
                        console.log('🗑 Menghapus cache lama:', key);
                        return caches.delete(key);
                    }
                })
            );
        })
        .then(() => self.clients.claim()) // Kontrol semua tab
    );
});

// ============================================
// ✅ 5. FITUR TAMBAHAN: Background Sync
// ============================================
self.addEventListener('sync', (event) => {
    if (event.tag === 'sync-data') {
        console.log('🔄 Background Sync: Menyinkronkan data...');
        // 🔧 Implementasi sync data saat koneksi kembali
    }
});
