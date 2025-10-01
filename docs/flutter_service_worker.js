'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "eb0622d73e164f7124292cd5092b1bf5",
"assets/AssetManifest.bin.json": "42818cb22094429eb663a92285890b58",
"assets/AssetManifest.json": "dcca7bd4df3c7e2bdb8c8ce0c42e4d74",
"assets/assets/fonts/OFL.txt": "d3a33274724c324a62011883f31026ec",
"assets/assets/fonts/Sarabun-Bold.ttf": "6173018c235bfd6b90a727faf1201a15",
"assets/assets/fonts/Sarabun-ExtraBold.ttf": "c6db3de516099e8c64e2abc55a376a97",
"assets/assets/fonts/Sarabun-Light.ttf": "5860e622485a9f0a9b1919c49a8fa89a",
"assets/assets/fonts/Sarabun-Medium.ttf": "c0ee849b8f11b1c69b555c67bd70b690",
"assets/assets/fonts/Sarabun-Regular.ttf": "56c5f9d4ecfb8c7ccf8a105e0c8de9f7",
"assets/assets/json/10SLC.json": "5efc64e39b9309c0a427dabd0e9c0ee1",
"assets/assets/json/12TXM.json": "a75ddcaacf85d5834513e851e1b70b6d",
"assets/assets/json/15HA.json": "ffc57a4c009e28b87d909aabfa76bd9b",
"assets/assets/json/15SPN.json": "abad2383475bbf56fe849673a808cd90",
"assets/assets/json/20LPB.json": "c91e2dd31ba875f0c3e4b6cb801198a2",
"assets/assets/json/20SLPA.json": "41e70e0581c207f774664097c5444b4e",
"assets/assets/json/24TXN.json": "8d988dc99030dfe094b1941cde5ae970",
"assets/assets/json/5SLC.json": "9ef18acbd46a761786bdba67c8332cf2",
"assets/assets/json/7SM.json": "4176db283a654ef5689726143aafc733",
"assets/assets/json/AR5N.json": "2bd7b472da7cc9d54ab0a2b5e8d1aac7",
"assets/assets/json/AR60N.json": "4ac564ce1e5327cc1f45ff329310d21c",
"assets/assets/json/AR65.json": "036a01a82bc121d4818ee8fbc29527f3",
"assets/assets/json/AS10.json": "630ae2dafd18114e67fae64e0fcdc5d8",
"assets/assets/json/AS60.json": "4a10caa369d230462fa0a091c2d7ee98",
"assets/assets/json/CX10.json": "8a21cdf71914427950a84cf463657ee5",
"assets/assets/json/CX20.json": "2c991a4f92b7006b29a1ddf2adfba7ce",
"assets/assets/json/DD50.json": "0c3ce04b2a0259f32169d4b640ba09c0",
"assets/assets/json/DDN.json": "a73d9bcf0595112b4172358b3bae0aab",
"assets/assets/json/HA55.json": "b33280b93e47b9e8daf30dfa7ffdd327",
"assets/assets/json/TLA.json": "dce7d3320e6f2a43b27a521f64717429",
"assets/assets/json/WXN10.json": "a64c8664dd4ffe2f04113b759e930dfd",
"assets/assets/json/WXN15.json": "d3daf96faba7720e8795840c327a5adc",
"assets/FontManifest.json": "fe1743f4a771d6a3f7e2631fb6ce2612",
"assets/fonts/MaterialIcons-Regular.otf": "a43351e8054336c1a4520331280b3fd2",
"assets/NOTICES": "df59260b3b1db8a2a0f2ac7e809b00ae",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "f953f9239a61973cfc73117ea36243a7",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "3e63f2d88580774149367a7c92eb9d66",
"/": "3e63f2d88580774149367a7c92eb9d66",
"main.dart.js": "efb9e242f374c8eff493b59c5998bdaf",
"manifest.json": "170b3bb21290f72c9e8d59a270dddaef",
"version.json": "6bdb5a81c15bf5f59990564d7f774a25"};
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
