'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"favicon-16x16.png": "249f55b5dca679ce56d7767b6a9fbdef",
"flutter_bootstrap.js": "b03914c358920a4e57cf517c7da70797",
"version.json": "22cda490c90639abe9f73094da4a2dec",
"favicon.ico": "a5a0de80cd1421f11fba89b17987d461",
"index.html": "7aa23d40c6625629c605f8913b50975a",
"/": "7aa23d40c6625629c605f8913b50975a",
"main.dart.js": "e96a12fe7db9fc5558c33ff7237d2bd6",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "6906fc1804d444eb11794c3cd30a1ad0",
"icons/Icon-192.png": "ffe922aba7f0a939e9db1d4759899c6f",
"icons/Icon-maskable-192.png": "ffe922aba7f0a939e9db1d4759899c6f",
"icons/Icon-maskable-512.png": "bd4c2ec5bcdd10dac1974926cc18302e",
"icons/Icon-512.png": "bd4c2ec5bcdd10dac1974926cc18302e",
"manifest.json": "573cb89e5d4d986eae5c0ec6bf4a65cb",
"assets/NOTICES": "ffa9b7b71416e816944f11a1244b9eec",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "96c82e9a48e8ec5c36fa9c3f5bee10b1",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "1f83ee82486b4ee4de1b78256560ce6c",
"assets/fonts/MaterialIcons-Regular.otf": "5dda78dd08d298cd181469611a46c916",
"assets/assets/images/home_background_wide.jpg": "687cdb3f7413626293f771f269f94769",
"assets/assets/images/home_background.jpg": "f283909af6ae70b0c3f65d81a3572a63",
"assets/assets/images/dungeon_treasure.jpg": "8e24328754553aed44053b7d1806b136",
"assets/assets/images/dungeon_aqueduct.jpg": "2aa41b6204b3f1ce8c37a41772380f8f",
"assets/assets/images/wizard_alchemy_lab.jpg": "11e0e7dca53a949c8f4584aaa808fa83",
"assets/assets/images/dragon_gem_lair.jpg": "558841368527c14790db20c9bbe05988",
"assets/assets/images/fantasy_crystal_cave.jpg": "708b48dfe412cc29cda8869ae8d854c4",
"assets/assets/voices/a-scor-cle-un-piaser-low.ogg": "8d2cd85e6127343ecac2d21555a70299",
"assets/assets/voices/mo-va-che-tubatura.mp3": "51fa674b5a372f39e4c48eb027c86bf4",
"assets/assets/voices/mayal-akdubal.mp3": "ee0a8d9ec148e9f5fe13547644ee614f",
"assets/assets/voices/a-scor-cle-un-piaser.ogg": "400b59e80782a3a9b06f7c27de1168c9",
"assets/assets/voices/mayal-ac-du-bal.ogg": "480e784bb1a749c5adb00f93eccaafef",
"assets/assets/voices/ac-giurnadaza.mp3": "c0bf9e1cc8d460bd5d9c63169340adf7",
"assets/assets/voices/non-capisci-proprio-un-tubo.ogg": "be0b5ed2571c0d7790c2cab16695409d",
"assets/assets/voices/non-capisci-un-tubo.mp3": "bb7715572d61909c4bb9ee63e9dc6bba",
"assets/assets/voices/README.md": "dd1234d55571b3bc635f2aea218c5b85",
"assets/assets/voices/a-scor-cle-un-piaser-low.mp3": "f3eb4ed6e9dc55f61faf34803b39ce75",
"assets/assets/voices/ac-giurnadaza.ogg": "503609d000448bb99b322c73344749a4",
"assets/assets/voices/non-capisci-un-tubo.ogg": "93f4a602266739647d0ac9aa1532c774",
"assets/assets/voices/non-capisci-proprio-un-tubo.mp3": "0baed8c6e07a79e22cbd3c6efd86b97f",
"assets/assets/voices/mayal-akdubal.ogg": "480e784bb1a749c5adb00f93eccaafef",
"assets/assets/voices/mo-va-che-tubatura.ogg": "88d82b0409a6c2384c6383fe5571e355",
"assets/assets/voices/a-scor-cle-un-piaser.mp3": "cef88347bf760dd3e44e01e7a2b3a6a8",
"assets/assets/voices/voices.json": "84caa68292e989292f72fec49e09d932",
"assets/assets/voices/mayal-ac-du-bal.mp3": "ee0a8d9ec148e9f5fe13547644ee614f",
"assets/assets/voices/generate_voices.py": "8b2da2d49d17d5a0133b112d5d3db274",
"favicon-32x32.png": "b043c6aaf0931ac6094d7d80196f8a35",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01"};
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
