'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"favicon-16x16.png": "249f55b5dca679ce56d7767b6a9fbdef",
"flutter_bootstrap.js": "c457084975628ff6aee0e5dc570fe941",
"version.json": "db9033fbd78e79ae623cb2d7a38ae40f",
"favicon.ico": "a5a0de80cd1421f11fba89b17987d461",
"index.html": "8ae37eaf24ee8a55d3629586e8517671",
"/": "8ae37eaf24ee8a55d3629586e8517671",
"main.dart.js": "874a385ceb2043165d7bc66961a35e73",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "6906fc1804d444eb11794c3cd30a1ad0",
"icons/Icon-192.png": "ffe922aba7f0a939e9db1d4759899c6f",
"icons/Icon-maskable-192.png": "ffe922aba7f0a939e9db1d4759899c6f",
"icons/Icon-maskable-512.png": "bd4c2ec5bcdd10dac1974926cc18302e",
"icons/Icon-512.png": "bd4c2ec5bcdd10dac1974926cc18302e",
"manifest.json": "573cb89e5d4d986eae5c0ec6bf4a65cb",
"assets/NOTICES": "ffa9b7b71416e816944f11a1244b9eec",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "7918caeecd29046531f4c6905df64632",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "c700b47cbf86f3a96b55aac4fc12537a",
"assets/fonts/MaterialIcons-Regular.otf": "b30a13aec655243f9c3a3a11b8108209",
"assets/assets/images/home_background_wide.jpg": "687cdb3f7413626293f771f269f94769",
"assets/assets/images/home_background.jpg": "f283909af6ae70b0c3f65d81a3572a63",
"assets/assets/images/dungeon_treasure.jpg": "8e24328754553aed44053b7d1806b136",
"assets/assets/images/dungeon_aqueduct.jpg": "2aa41b6204b3f1ce8c37a41772380f8f",
"assets/assets/images/wizard_alchemy_lab.jpg": "11e0e7dca53a949c8f4584aaa808fa83",
"assets/assets/images/dragon_gem_lair.jpg": "558841368527c14790db20c9bbe05988",
"assets/assets/images/fantasy_crystal_cave.jpg": "708b48dfe412cc29cda8869ae8d854c4",
"assets/assets/sounds/good-quality/ack_giurnadaza_tuned.ogg": "503609d000448bb99b322c73344749a4",
"assets/assets/sounds/good-quality/movache_mid_low_4st.mp3": "2c1e5b6f57d03db80db79d8432fb6108",
"assets/assets/sounds/good-quality/tts_20260823_161947.ogg": "6ae0af0ca9202588fd1f6ffbb4f5d8ec",
"assets/assets/sounds/good-quality/ascor_mid_low_4st.ogg": "400b59e80782a3a9b06f7c27de1168c9",
"assets/assets/sounds/good-quality/isabella_15.ogg": "89e9bcc2cfddaad6bc85dc8084c5cba5",
"assets/assets/sounds/good-quality/elsa_corto_20.mp3": "5a8a42b347be400778be5b0d755d7b41",
"assets/assets/sounds/good-quality/elsa_15.mp3": "cb43b715ea35a311ca1003fc8cf9e8af",
"assets/assets/sounds/good-quality/maial_3_raw.mp3": "fa1f9186f460eaf8df7e0292997ea829",
"assets/assets/sounds/good-quality/tts_20260823_161949.mp3": "0a6a09de996c3a02f1de6893b0befc5d",
"assets/assets/sounds/good-quality/mo-va-che-tubatura.mp3": "4f66ba482984cb68841b4e708e506eb6",
"assets/assets/sounds/good-quality/mayal-akdubal.mp3": "ee0a8d9ec148e9f5fe13547644ee614f",
"assets/assets/sounds/good-quality/maial_basso_6st.ogg": "41070c005ced038340b5c27e823295a8",
"assets/assets/sounds/good-quality/maial_basso_5st_fast_b.mp3": "31a12ca6e44ae766c0a847d8f909829a",
"assets/assets/sounds/good-quality/non-capisci-proprio-un-tubo.ogg": "be0b5ed2571c0d7790c2cab16695409d",
"assets/assets/sounds/good-quality/non-capisci-un-tubo.mp3": "e62b85fbf2565186b26ceffd8974a4cf",
"assets/assets/sounds/good-quality/maial_2_raw.mp3": "7f9b6ddfac485cf63a4a3fe5f817ac4b",
"assets/assets/sounds/good-quality/tts_20260823_163800.mp3": "c432c18421f0145a9007ac04d3b8a737",
"assets/assets/sounds/good-quality/elsa_corto_20.ogg": "0cbfb0ea47065ca995494575d3e1cc96",
"assets/assets/sounds/good-quality/isabella_15.mp3": "ec306069ff863000ff2c710fa07933f7",
"assets/assets/sounds/good-quality/maial_rel_1_raw.mp3": "a5a863187f4ebb714e4ad795f7871a7e",
"assets/assets/sounds/good-quality/tts_20260823_161947.mp3": "9a570565181574ae0c75241c52ed91b5",
"assets/assets/sounds/good-quality/ascor_mid_low_4st.mp3": "94614b38803e6b89db1486917c82f739",
"assets/assets/sounds/good-quality/ack_giurnadaza_tuned.mp3": "8eb1f41beb0dd8b3ddd4fb9da964cf79",
"assets/assets/sounds/good-quality/movache_mid_low_4st.ogg": "88d82b0409a6c2384c6383fe5571e355",
"assets/assets/sounds/good-quality/non-capisci-un-tubo.ogg": "93f4a602266739647d0ac9aa1532c774",
"assets/assets/sounds/good-quality/non-capisci-proprio-un-tubo.mp3": "97dbd2e33ac882a83cb757088f5b3dab",
"assets/assets/sounds/good-quality/tts_20260823_163800.ogg": "474318a4fe1d0cf671c889b056ef34f0",
"assets/assets/sounds/good-quality/maial_basso_6st.mp3": "11de23bf978a5608e3c863bc92aa8e51",
"assets/assets/sounds/good-quality/maial_basso_5st_fast_b.ogg": "52613fdde1a078b907d3cc79d22fca50",
"assets/assets/sounds/good-quality/mayal-akdubal.ogg": "480e784bb1a749c5adb00f93eccaafef",
"assets/assets/sounds/good-quality/mo-va-che-tubatura.ogg": "4abbd5ea617c3907ec5fbc89801cdbc7",
"assets/assets/sounds/good-quality/maial_5_raw.mp3": "2800a371dccc81fd65075edd22551e57",
"assets/assets/sounds/good-quality/elsa_15.ogg": "688a28589af214368e08d7b641665fc0",
"assets/assets/sounds/good-quality/tts_20260823_161949.ogg": "56b1727caac125ddbf309fe7de78e55a",
"assets/assets/voices/bad/giurnadaza_1.ogg": "4b884b4db1f85043eab9389751a062c3",
"assets/assets/voices/bad/giurnadaza_2.ogg": "a745a252852ecb1b4ccf5b870ca3135f",
"assets/assets/voices/bad/non-capisci-proprio-un-tubo.ogg": "aefb2c44e96cd10bdba54421b45df1ec",
"assets/assets/voices/bad/non-capisci-un-tubo.mp3": "e62b85fbf2565186b26ceffd8974a4cf",
"assets/assets/voices/bad/giurnadaza_2.mp3": "a8cec2d3e3c52882f8736a6dd2ff7e83",
"assets/assets/voices/bad/giurnadaza_1.mp3": "bdfe0afe12c7cab1246ecfa385808c7d",
"assets/assets/voices/bad/non-capisci-un-tubo.ogg": "0cbfb0ea47065ca995494575d3e1cc96",
"assets/assets/voices/bad/non-capisci-proprio-un-tubo.mp3": "97dbd2e33ac882a83cb757088f5b3dab",
"assets/assets/voices/README.md": "dd1234d55571b3bc635f2aea218c5b85",
"assets/assets/voices/good/do_bal_2.ogg": "1ff99bd33f4385145111ebaa36a5ce52",
"assets/assets/voices/good/do_bal_1.ogg": "08c1090ccfb58757a802c0401c9a46fa",
"assets/assets/voices/good/piaser_3.mp3": "fe7d954e9326a17d76b7d25d563ebdfa",
"assets/assets/voices/good/tubatura_1.ogg": "56f7d495fc4bd5dcdbea7264a354974c",
"assets/assets/voices/good/piaser_2.mp3": "efbc796b230f255b69372516fcfb6873",
"assets/assets/voices/good/mo-va-che-tubatura.mp3": "4f66ba482984cb68841b4e708e506eb6",
"assets/assets/voices/good/mayal-akdubal.mp3": "ee0a8d9ec148e9f5fe13547644ee614f",
"assets/assets/voices/good/tubatura_3.ogg": "b71e95389627522abcf84a93254c506d",
"assets/assets/voices/good/tubatura_2.ogg": "a4611bdb8d2f27d6eec8843493a45f76",
"assets/assets/voices/good/mayal-ac-du-bal.ogg": "e3df33d3f06ab554c9f8dc463b12d9d5",
"assets/assets/voices/good/piaser_1.mp3": "ef730221c3628c22d0c6386fc07796ec",
"assets/assets/voices/good/piaser_4.mp3": "e74d488739d0c49345c2a46e28cfdc43",
"assets/assets/voices/good/tubatura_4.ogg": "4f983acb332c8d01ad87a9b87d80363e",
"assets/assets/voices/good/do_bal_1.mp3": "63a76b6243c519137976ad283e7d086d",
"assets/assets/voices/good/do_bal_2.mp3": "8c256dbffff00687656ac1e89b507e97",
"assets/assets/voices/good/tubatura_4.mp3": "a66d15ba3773c85e91301979f2029f44",
"assets/assets/voices/good/piaser_4.ogg": "8ee5731e7869de05ffc530caed39d753",
"assets/assets/voices/good/mayal-akdubal.ogg": "480e784bb1a749c5adb00f93eccaafef",
"assets/assets/voices/good/mo-va-che-tubatura.ogg": "4abbd5ea617c3907ec5fbc89801cdbc7",
"assets/assets/voices/good/tubatura_3.mp3": "3aa702f98ed0d414a59140ec9fd39d2a",
"assets/assets/voices/good/tubatura_2.mp3": "d69bdf69e47794e837e9d52de52904d9",
"assets/assets/voices/good/mayal-ac-du-bal.mp3": "f79f59e594ad0530b8812e00a5742e2d",
"assets/assets/voices/good/piaser_1.ogg": "e34e2d12d5dabec1d058c5e38d00985c",
"assets/assets/voices/good/piaser_3.ogg": "b0a39d752ab9b1deb433a7c6b8a1718f",
"assets/assets/voices/good/tubatura_1.mp3": "f58e9fd46898acb379a6ddfa5a907e14",
"assets/assets/voices/good/piaser_2.ogg": "02a39a4eb013afb7b4eb11fdf522187d",
"assets/assets/voices/voices.json": "d76df947a435453f83042519829c9664",
"assets/assets/voices/generate_voices.py": "918acb7a5420b19915f77b88142593f5",
"assets/assets/goodies/sebi.png": "b6e6cf2467cd3fc99458c4ea600f65c1",
"assets/assets/goodies/unicorn.png": "e080ae9a5c6dae9c961ce18ad1893287",
"assets/assets/goodies/hotwheel.png": "fc8f51cb3e582ee90489a9c984e540b9",
"assets/assets/goodies/ruby2.png": "3a4e90a44478edfbc4a62523ad4f4878",
"assets/assets/goodies/wizard.png": "4f2fbcf48a3c34280551584f04868ecb",
"assets/assets/goodies/alessandro.png": "a1b9ec7394f2c53bae8cf921aefa436c",
"assets/assets/goodies/antigravity.png": "66788185408601d0fd0e03f3fbb4bf5f",
"assets/assets/goodies/dragon.png": "02ecd512006d8b94a4ef4540f4002bba",
"assets/assets/goodies/schmoogle.png": "2f7761b4a475323b28fcd6431d64a196",
"assets/assets/goodies/ruby_mosaic.png": "7ca636d6511a295caebc69e07b749891",
"assets/assets/goodies/pizza.png": "bc2720aaf38078b73c24b91e63f01147",
"assets/assets/goodies/papino.png": "782fafb12787692b8dfcc47a75513ed0",
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
