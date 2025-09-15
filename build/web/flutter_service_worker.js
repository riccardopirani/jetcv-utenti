'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "20f2d4c45671772fdaab631812267cff",
"version.json": "37bd136ce4a98966818c4526b0deb531",
"index.html": "5a28f03acd5a00deb335c825fed97aff",
"/": "5a28f03acd5a00deb335c825fed97aff",
"main.dart.js": "58606926caf05b25e4424c7c7c5e4241",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "d7d55afe89a23c8c04d7c45ef3fe4942",
"assets/AssetManifest.json": "313c7f7c19694fb8bc0ea0b9ce229a82",
"assets/NOTICES": "d5c37c0f2d5e6937e04ba88e3d7806d0",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "c90a199a2380e605394ff225f346abb3",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "d23d3909dce6cca8da61acd93e0dcab2",
"assets/fonts/MaterialIcons-Regular.otf": "78cd4707aeba017351a7be09aef768ca",
"assets/assets/images/polygon-logo.png": "d59e04e9a146241fc915852235a58362",
"assets/assets/images/web_light_sq_na_3x.png": "1000e349e94568367fcc43db29f4a7bb",
"assets/assets/linkedin-add-to-profile-buttons/ru_RU.png": "1b598ad5a3d56a4c7e4420ac95f212cd",
"assets/assets/linkedin-add-to-profile-buttons/tr_TR.png": "fa5af08ffcea82e5b9f5a9acf7873f5b",
"assets/assets/linkedin-add-to-profile-buttons/da_DK.png": "98bd542e627611399744b1ca0e255834",
"assets/assets/linkedin-add-to-profile-buttons/no_NO.png": "5f557e979ceecfcac7fc2600707f3b76",
"assets/assets/linkedin-add-to-profile-buttons/pt_BR.png": "6b28d8fb567857c60334f6fbbee44e55",
"assets/assets/linkedin-add-to-profile-buttons/ms_MY.png": "f79a58649ecd06fbd5466fa8b00ea22f",
"assets/assets/linkedin-add-to-profile-buttons/en_US.png": "5a5cc9aca585278b6a274ec93b00e476",
"assets/assets/linkedin-add-to-profile-buttons/sv_SE.png": "fdc89f15a41a552a70b9e14382bfd106",
"assets/assets/linkedin-add-to-profile-buttons/zh_TW.png": "d5f803f2a8a4787823a2e51d2aa061dd",
"assets/assets/linkedin-add-to-profile-buttons/de_DE.png": "ea182431399be297b7422ea90bd2e6c4",
"assets/assets/linkedin-add-to-profile-buttons/cs_CZ.png": "fd4c20113ece992e8302dd61567bdd45",
"assets/assets/linkedin-add-to-profile-buttons/ko_KR.png": "2402104a1d854531f16452128030659f",
"assets/assets/linkedin-add-to-profile-buttons/fr_FR.png": "21a1ce4e8cab001b46453aa871ca743a",
"assets/assets/linkedin-add-to-profile-buttons/ro_RO.png": "cfcde351da9911814a0bc25ef110c74f",
"assets/assets/linkedin-add-to-profile-buttons/ja_JP.png": "88e4cc52df2286b16b8a023b1a043fff",
"assets/assets/linkedin-add-to-profile-buttons/it_IT.png": "01ff7f970ce8ee1dd7dc98a9b2af4b24",
"assets/assets/linkedin-add-to-profile-buttons/nl_NL.png": "fd9e4c980e949aaeb338d6ed1b6d8a25",
"assets/assets/linkedin-add-to-profile-buttons/in_ID.png": "cdd4468bcb4ea0a396cfa0650ee6a35e",
"assets/assets/linkedin-add-to-profile-buttons/es_ES.png": "74790d4f6978ca74f37025572fed202e",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
