'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"favicon-16x16.png": "249f55b5dca679ce56d7767b6a9fbdef",
"flutter_bootstrap.js": "a26bba0a2cac9d3375ce5fecc46ca5fa",
"version.json": "696cf3c5867ea468589a6a0ee3b920a2",
"favicon.ico": "a5a0de80cd1421f11fba89b17987d461",
"index.html": "06660fb4a63d0ce3160311447c75e63e",
"/": "06660fb4a63d0ce3160311447c75e63e",
"main.dart.js": "437a65300c07c86f61c931f9bf22dc4f",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "6906fc1804d444eb11794c3cd30a1ad0",
"icons/Icon-192.png": "ffe922aba7f0a939e9db1d4759899c6f",
"icons/Icon-maskable-192.png": "ffe922aba7f0a939e9db1d4759899c6f",
"icons/Icon-maskable-512.png": "bd4c2ec5bcdd10dac1974926cc18302e",
"icons/Icon-512.png": "bd4c2ec5bcdd10dac1974926cc18302e",
"manifest.json": "573cb89e5d4d986eae5c0ec6bf4a65cb",
"assets/NOTICES": "ffa9b7b71416e816944f11a1244b9eec",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "fa4a4ad1fc7b9fd4a1352fa84fd696a7",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "a4ad0d97620ec476b0de12d70f9dc913",
"assets/fonts/MaterialIcons-Regular.otf": "bbd1fb63e3f6472176b5e0977a0346a3",
"assets/assets/images/home_background_wide.jpg": "687cdb3f7413626293f771f269f94769",
"assets/assets/images/home_background.jpg": "f283909af6ae70b0c3f65d81a3572a63",
"assets/assets/images/dungeon_treasure.jpg": "8e24328754553aed44053b7d1806b136",
"assets/assets/images/dungeon_aqueduct.jpg": "2aa41b6204b3f1ce8c37a41772380f8f",
"assets/assets/images/wizard_alchemy_lab.jpg": "11e0e7dca53a949c8f4584aaa808fa83",
"assets/assets/images/dragon_gem_lair.jpg": "558841368527c14790db20c9bbe05988",
"assets/assets/images/fantasy_crystal_cave.jpg": "708b48dfe412cc29cda8869ae8d854c4",
"assets/assets/voices/a-scor-cle-un-piaser-low.ogg": "19f62f867d9abac877436401a05e6c5b",
"assets/assets/voices/mo-va-che-tubatura.mp3": "4f66ba482984cb68841b4e708e506eb6",
"assets/assets/voices/mayal-akdubal.mp3": "ee0a8d9ec148e9f5fe13547644ee614f",
"assets/assets/voices/a-scor-cle-un-piaser.ogg": "f516fbc9a6642e31a2dc7bbb3614f63a",
"assets/assets/voices/bad/ac-giurnadaza.mp3": "2854b701242bbec08a3cf20723e10462",
"assets/assets/voices/bad/non-capisci-proprio-un-tubo.ogg": "aefb2c44e96cd10bdba54421b45df1ec",
"assets/assets/voices/bad/non-capisci-un-tubo.mp3": "e62b85fbf2565186b26ceffd8974a4cf",
"assets/assets/voices/bad/ac-giurnadaza.ogg": "25eef165224c86b6a025c197f46a0dcf",
"assets/assets/voices/bad/non-capisci-un-tubo.ogg": "0cbfb0ea47065ca995494575d3e1cc96",
"assets/assets/voices/bad/non-capisci-proprio-un-tubo.mp3": "97dbd2e33ac882a83cb757088f5b3dab",
"assets/assets/voices/mayal-ac-du-bal.ogg": "e3df33d3f06ab554c9f8dc463b12d9d5",
"assets/assets/voices/ac-giurnadaza.mp3": "2854b701242bbec08a3cf20723e10462",
"assets/assets/voices/non-capisci-proprio-un-tubo.ogg": "aefb2c44e96cd10bdba54421b45df1ec",
"assets/assets/voices/non-capisci-un-tubo.mp3": "e62b85fbf2565186b26ceffd8974a4cf",
"assets/assets/voices/README.md": "dd1234d55571b3bc635f2aea218c5b85",
"assets/assets/voices/good/a-scor-cle-un-piaser-low.ogg": "19f62f867d9abac877436401a05e6c5b",
"assets/assets/voices/good/mo-va-che-tubatura.mp3": "4f66ba482984cb68841b4e708e506eb6",
"assets/assets/voices/good/mayal-akdubal.mp3": "ee0a8d9ec148e9f5fe13547644ee614f",
"assets/assets/voices/good/a-scor-cle-un-piaser.ogg": "f516fbc9a6642e31a2dc7bbb3614f63a",
"assets/assets/voices/good/mayal-ac-du-bal.ogg": "e3df33d3f06ab554c9f8dc463b12d9d5",
"assets/assets/voices/good/a-scor-cle-un-piaser-low.mp3": "018c3473d11daa1f3a09531c2f7d2467",
"assets/assets/voices/good/mayal-akdubal.ogg": "480e784bb1a749c5adb00f93eccaafef",
"assets/assets/voices/good/mo-va-che-tubatura.ogg": "4abbd5ea617c3907ec5fbc89801cdbc7",
"assets/assets/voices/good/a-scor-cle-un-piaser.mp3": "3f6c3943bffc33b6f1246a56bfb7b7ad",
"assets/assets/voices/good/mayal-ac-du-bal.mp3": "f79f59e594ad0530b8812e00a5742e2d",
"assets/assets/voices/a-scor-cle-un-piaser-low.mp3": "018c3473d11daa1f3a09531c2f7d2467",
"assets/assets/voices/ac-giurnadaza.ogg": "25eef165224c86b6a025c197f46a0dcf",
"assets/assets/voices/non-capisci-un-tubo.ogg": "0cbfb0ea47065ca995494575d3e1cc96",
"assets/assets/voices/non-capisci-proprio-un-tubo.mp3": "97dbd2e33ac882a83cb757088f5b3dab",
"assets/assets/voices/mayal-akdubal.ogg": "480e784bb1a749c5adb00f93eccaafef",
"assets/assets/voices/mo-va-che-tubatura.ogg": "4abbd5ea617c3907ec5fbc89801cdbc7",
"assets/assets/voices/a-scor-cle-un-piaser.mp3": "3f6c3943bffc33b6f1246a56bfb7b7ad",
"assets/assets/voices/voices.json": "cbd16fbd1a73cf707b99c63174f57f31",
"assets/assets/voices/mayal-ac-du-bal.mp3": "f79f59e594ad0530b8812e00a5742e2d",
"assets/assets/voices/generate_voices.py": "918acb7a5420b19915f77b88142593f5",
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
