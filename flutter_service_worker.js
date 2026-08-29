'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"favicon-16x16.png": "249f55b5dca679ce56d7767b6a9fbdef",
"flutter_bootstrap.js": "c1a3b6bebe332471377b01a9c736189b",
"version.json": "8cdc9fe24f1a2e95989cd8a662438bf2",
"favicon.ico": "a5a0de80cd1421f11fba89b17987d461",
"index.html": "b2f64e287ff5177b69c0d1607ca1dd45",
"/": "b2f64e287ff5177b69c0d1607ca1dd45",
"main.dart.js": "0954aab9b62c37c1beb9456e6964f700",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "6906fc1804d444eb11794c3cd30a1ad0",
"icons/Icon-192.png": "ffe922aba7f0a939e9db1d4759899c6f",
"icons/Icon-maskable-192.png": "ffe922aba7f0a939e9db1d4759899c6f",
"icons/Icon-maskable-512.png": "bd4c2ec5bcdd10dac1974926cc18302e",
"icons/Icon-512.png": "bd4c2ec5bcdd10dac1974926cc18302e",
"manifest.json": "573cb89e5d4d986eae5c0ec6bf4a65cb",
"assets/NOTICES": "07e5c0cb54e1b0ba2df703f18c81b0ff",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "d78c66aa78e55b83181f8661c33140a3",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "32a57f7be95618226fb5b1bd8490672c",
"assets/fonts/MaterialIcons-Regular.otf": "6860730f849bba0e9cf1ee50e9a46fb8",
"assets/assets/images/home_background_wide.jpg": "687cdb3f7413626293f771f269f94769",
"assets/assets/images/home_background.jpg": "f283909af6ae70b0c3f65d81a3572a63",
"assets/assets/images/dungeon_treasure.jpg": "8e24328754553aed44053b7d1806b136",
"assets/assets/images/dungeon_aqueduct.jpg": "2aa41b6204b3f1ce8c37a41772380f8f",
"assets/assets/images/wizard_alchemy_lab.jpg": "11e0e7dca53a949c8f4584aaa808fa83",
"assets/assets/images/dragon_gem_lair.jpg": "558841368527c14790db20c9bbe05988",
"assets/assets/images/fantasy_crystal_cave.jpg": "708b48dfe412cc29cda8869ae8d854c4",
"assets/assets/cross/cross_nw_ruby.png": "502ac130c90f318f805543cb05595d48",
"assets/assets/cross/cross_sw_droplet.png": "91d24f07dad8a7d49584136cab96c4b9",
"assets/assets/cross/cross_ne_sun.png": "025fd5875c795e1605222f6c251736f4",
"assets/assets/cross/cross_se_basil.png": "e44c1e4e48e9e31677e63beae676823f",
"assets/assets/sounds/good-quality/ack_giurnadaza_tuned.ogg": "503609d000448bb99b322c73344749a4",
"assets/assets/sounds/good-quality/movache_mid_low_4st.mp3": "2c1e5b6f57d03db80db79d8432fb6108",
"assets/assets/sounds/good-quality/tts_20260823_161947.ogg": "6ae0af0ca9202588fd1f6ffbb4f5d8ec",
"assets/assets/sounds/good-quality/ascor_mid_low_4st.ogg": "400b59e80782a3a9b06f7c27de1168c9",
"assets/assets/sounds/good-quality/isabella_15.ogg": "89e9bcc2cfddaad6bc85dc8084c5cba5",
"assets/assets/sounds/good-quality/majjal-akdubal.mp3": "ee0a8d9ec148e9f5fe13547644ee614f",
"assets/assets/sounds/good-quality/elsa_corto_20.mp3": "5a8a42b347be400778be5b0d755d7b41",
"assets/assets/sounds/good-quality/elsa_15.mp3": "cb43b715ea35a311ca1003fc8cf9e8af",
"assets/assets/sounds/good-quality/maial_3_raw.mp3": "fa1f9186f460eaf8df7e0292997ea829",
"assets/assets/sounds/good-quality/tts_20260823_161949.mp3": "0a6a09de996c3a02f1de6893b0befc5d",
"assets/assets/sounds/good-quality/mo-va-che-tubatura.mp3": "4f66ba482984cb68841b4e708e506eb6",
"assets/assets/sounds/good-quality/maial_basso_6st.ogg": "41070c005ced038340b5c27e823295a8",
"assets/assets/sounds/good-quality/maial_basso_5st_fast_b.mp3": "31a12ca6e44ae766c0a847d8f909829a",
"assets/assets/sounds/good-quality/non-capisci-proprio-un-tubo.ogg": "be0b5ed2571c0d7790c2cab16695409d",
"assets/assets/sounds/good-quality/non-capisci-un-tubo.mp3": "e62b85fbf2565186b26ceffd8974a4cf",
"assets/assets/sounds/good-quality/maial_2_raw.mp3": "7f9b6ddfac485cf63a4a3fe5f817ac4b",
"assets/assets/sounds/good-quality/tts_20260823_163800.mp3": "c432c18421f0145a9007ac04d3b8a737",
"assets/assets/sounds/good-quality/majjal-akdubal.ogg": "480e784bb1a749c5adb00f93eccaafef",
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
"assets/assets/sounds/good-quality/mo-va-che-tubatura.ogg": "4abbd5ea617c3907ec5fbc89801cdbc7",
"assets/assets/sounds/good-quality/maial_5_raw.mp3": "2800a371dccc81fd65075edd22551e57",
"assets/assets/sounds/good-quality/elsa_15.ogg": "688a28589af214368e08d7b641665fc0",
"assets/assets/sounds/good-quality/tts_20260823_161949.ogg": "56b1727caac125ddbf309fe7de78e55a",
"assets/assets/videos/home_background_portrait.mp4": "17cf7c361bfcaa5d853470fb5b31ec2d",
"assets/assets/videos/home_background_portrait_v2.mp4": "17cf7c361bfcaa5d853470fb5b31ec2d",
"assets/assets/videos/home_background_portrait_v1.mp4": "325b1227ed0dbb20646ea687429c2063",
"assets/assets/videos/home_background_wide_v1.mp4": "62a777ae5c95f647ee9a5066ad80f886",
"assets/assets/videos/home_background_wide_v2.mp4": "73a2172bf87663a3deb4edd1d9470eed",
"assets/assets/videos/home_background_wide.mp4": "73a2172bf87663a3deb4edd1d9470eed",
"assets/assets/voices/bad/giurnadaza_1.ogg": "4b884b4db1f85043eab9389751a062c3",
"assets/assets/voices/bad/giurnadaza_2.ogg": "a745a252852ecb1b4ccf5b870ca3135f",
"assets/assets/voices/bad/tmp-aldamar.ogg": "45bc076cb6d58695766b6df5e348119e",
"assets/assets/voices/bad/non-capisci-proprio-un-tubo.ogg": "aefb2c44e96cd10bdba54421b45df1ec",
"assets/assets/voices/bad/non-capisci-un-tubo.mp3": "e62b85fbf2565186b26ceffd8974a4cf",
"assets/assets/voices/bad/giurnadaza_2.mp3": "a8cec2d3e3c52882f8736a6dd2ff7e83",
"assets/assets/voices/bad/giurnadaza_1.mp3": "bdfe0afe12c7cab1246ecfa385808c7d",
"assets/assets/voices/bad/non-capisci-un-tubo.ogg": "0cbfb0ea47065ca995494575d3e1cc96",
"assets/assets/voices/bad/non-capisci-proprio-un-tubo.mp3": "97dbd2e33ac882a83cb757088f5b3dab",
"assets/assets/voices/bad/tmp-aldamar.mp3": "b1d0ef0d11a589ea6f6a4ee371a4c5de",
"assets/assets/voices/README.md": "f20ef42df199e3a07a569b9611afbfdf",
"assets/assets/voices/good/do_bal_2.ogg": "1ff99bd33f4385145111ebaa36a5ce52",
"assets/assets/voices/good/do_bal_1.ogg": "08c1090ccfb58757a802c0401c9a46fa",
"assets/assets/voices/good/majjal-akdubal.mp3": "ee0a8d9ec148e9f5fe13547644ee614f",
"assets/assets/voices/good/piaser_3.mp3": "fe7d954e9326a17d76b7d25d563ebdfa",
"assets/assets/voices/good/tmp-majjal.ogg": "adb2dcbce5c14e51e19d9264d3d29dc2",
"assets/assets/voices/good/tubatura_1.ogg": "56f7d495fc4bd5dcdbea7264a354974c",
"assets/assets/voices/good/piaser_2.mp3": "efbc796b230f255b69372516fcfb6873",
"assets/assets/voices/good/mo-va-che-tubatura.mp3": "4f66ba482984cb68841b4e708e506eb6",
"assets/assets/voices/good/tubatura_3.ogg": "b71e95389627522abcf84a93254c506d",
"assets/assets/voices/good/tubatura_2.ogg": "a4611bdb8d2f27d6eec8843493a45f76",
"assets/assets/voices/good/piaser_1.mp3": "ef730221c3628c22d0c6386fc07796ec",
"assets/assets/voices/good/piaser_4.mp3": "e74d488739d0c49345c2a46e28cfdc43",
"assets/assets/voices/good/majjal-ac-du-bal.ogg": "e3df33d3f06ab554c9f8dc463b12d9d5",
"assets/assets/voices/good/tubatura_4.ogg": "4f983acb332c8d01ad87a9b87d80363e",
"assets/assets/voices/good/majjal-akdubal.ogg": "480e784bb1a749c5adb00f93eccaafef",
"assets/assets/voices/good/do_bal_1.mp3": "63a76b6243c519137976ad283e7d086d",
"assets/assets/voices/good/do_bal_2.mp3": "8c256dbffff00687656ac1e89b507e97",
"assets/assets/voices/good/tubatura_4.mp3": "a66d15ba3773c85e91301979f2029f44",
"assets/assets/voices/good/majjal-ac-du-bal.mp3": "f79f59e594ad0530b8812e00a5742e2d",
"assets/assets/voices/good/piaser_4.ogg": "8ee5731e7869de05ffc530caed39d753",
"assets/assets/voices/good/mo-va-che-tubatura.ogg": "4abbd5ea617c3907ec5fbc89801cdbc7",
"assets/assets/voices/good/tubatura_3.mp3": "3aa702f98ed0d414a59140ec9fd39d2a",
"assets/assets/voices/good/tubatura_2.mp3": "d69bdf69e47794e837e9d52de52904d9",
"assets/assets/voices/good/piaser_1.ogg": "e34e2d12d5dabec1d058c5e38d00985c",
"assets/assets/voices/good/piaser_3.ogg": "b0a39d752ab9b1deb433a7c6b8a1718f",
"assets/assets/voices/good/tmp-majjal.mp3": "0a774774f89e72214e65f59b82e95afc",
"assets/assets/voices/good/tubatura_1.mp3": "f58e9fd46898acb379a6ddfa5a907e14",
"assets/assets/voices/good/piaser_2.ogg": "02a39a4eb013afb7b4eb11fdf522187d",
"assets/assets/voices/voices.json": "41def7a93aec25083d972d3919543583",
"assets/assets/voices/generate_voices.py": "918acb7a5420b19915f77b88142593f5",
"assets/assets/goodies/sebi.png": "8c7973e13aa5683cab126899f5d48d3d",
"assets/assets/goodies/unicorn.png": "a828e51058d786646505594888cab5bb",
"assets/assets/goodies/puffin.png": "6c00a4ecaca7dc6cbf1eb271068da7c6",
"assets/assets/goodies/hotwheel.png": "72c160eac0d1e8a72436cea64ad04e5a",
"assets/assets/goodies/coccodrillo.png": "838917cfb67f4b6e3773a7615d62d29d",
"assets/assets/goodies/ruby2.png": "3206185bb8b4e766fc70afba171b970f",
"assets/assets/goodies/acquario.png": "68399c7b79253f770a49e0f503c7f43e",
"assets/assets/goodies/wizard.png": "ff9de6bce711c1d022e802ac46eb471b",
"assets/assets/goodies/alessandro.png": "e3de04632ec93a4c1210a960ce60c1d9",
"assets/assets/goodies/antigravity.png": "e25c1de4adcc7e9a9411d5c63c820e19",
"assets/assets/goodies/dragon.png": "0c4fd3129e294c8d2831d472915aa06a",
"assets/assets/goodies/motorino.png": "0ee960f5a61ea52c640160fc919a39ba",
"assets/assets/goodies/schmoogle.png": "92005c05fa13f9cb6c9e9b535de42595",
"assets/assets/goodies/rinoceronte.png": "d5ff47198fa7fa01d9612a74dcca6a3f",
"assets/assets/goodies/pizza.png": "11f96d3256549722e44a11ed1f443458",
"assets/assets/goodies/fratelli.png": "6455825be41304761d77a8bff9f3dc4f",
"assets/assets/goodies/maialino.png": "4bfef62b49f79d077d4a7bb158cbfe92",
"assets/assets/goodies/giraffa.png": "eafdc7a1db95f0157e98bd1daad1d82d",
"assets/assets/goodies/salama.png": "ebb207ad7ac482a78c87aec3e7a5d0f5",
"assets/assets/goodies/tram.png": "9b4d2cca10012ca42aea3dba74cb2e20",
"assets/assets/goodies/papino.png": "fdba7410969b6b1ca05ae37a48ddb5a9",
"assets/assets/goodies/e-le-fante.png": "d81d3b8911dd5d31270911b087ce3c73",
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
