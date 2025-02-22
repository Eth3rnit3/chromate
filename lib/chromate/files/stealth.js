/**
 * Script de Stealth pour masquer l'automatisation
 *
 * Ce script est destiné à être injecté via la commande
 * Page.addScriptToEvaluateOnNewDocument afin qu'il s'exécute
 * avant le chargement du contenu de la page.
 *
 * Il redéfinit plusieurs propriétés du navigateur pour
 * réduire les indices susceptibles d'indiquer qu'une automatisation est en cours.
 */
(() => {
  'use strict';

  // 1) Masquer navigator.webdriver
  (function removeWebDriverProperty() {
    // 1) Récupérer le prototype de Navigator
    const proto = Object.getPrototypeOf(navigator);

    // Vérifier si la propriété webdriver existe sur le prototype
    if ('webdriver' in proto) {
      try {
        // 2) Tenter de supprimer la propriété si elle est configurable
        const webdriverDescriptor = Object.getOwnPropertyDescriptor(proto, 'webdriver');
        if (webdriverDescriptor && webdriverDescriptor.configurable) {
          delete proto.webdriver;
        } else {
          // 3) Sinon, on essaye de la redéfinir pour qu'elle retourne undefined et ne soit pas énumérable
          Object.defineProperty(proto, 'webdriver', {
            get: () => undefined,
            configurable: false, // on la rend non-configurable pour éviter d'autres re-déclarations
            enumerable: false
          });
        }
      } catch (err) {
        // 4) En cas d'échec (non-configurable), on peut tenter un hack sur l'opérateur 'in'
        //    => ATTENTION : ceci peut avoir des effets de bord dans d'autres scripts
        patchInOperatorForNavigator('webdriver');
      }
    } else {
      // Si la propriété n'existe pas sur le prototype, vérifier si elle existe directement sur navigator
      if ('webdriver' in navigator) {
        try {
          delete navigator.webdriver;
        } catch (err) {
          patchInOperatorForNavigator('webdriver');
        }
      }
    }

    /**
     * Hack optionnel pour empêcher `'webdriver' in navigator` de renvoyer true.
     * On redéfinit la méthode hasOwnProperty / l'opérateur in pour l'objet navigator.
     * Cette approche peut avoir des effets de bord, donc à utiliser en dernier recours.
     */
    function patchInOperatorForNavigator(propName) {
      const originalHasOwn = Object.prototype.hasOwnProperty;
      Object.prototype.hasOwnProperty = function (property) {
        // Si c'est navigator et qu'on teste la propriété 'webdriver', on la cache
        if (this === navigator && property === propName) {
          return false;
        }
        return originalHasOwn.call(this, property);
      };

      // Variante plus radicale : proxyfier l'objet navigator pour intercepter l'opérateur 'in'.
      // (Non présenté ici, car encore plus invasif.)
    }
  })();

  // 2) Surcharger navigator.permissions.query (pour ne pas renvoyer "default")
  if (navigator.permissions && navigator.permissions.query) {
    const originalQuery = navigator.permissions.query;
    navigator.permissions.query = (params) => {
      // Ex. : si on interroge les notifications, on renvoie "granted"
      if (params.name === 'notifications') {
        return Promise.resolve({ state: 'granted' });
      }
      // Pour les autres, on tente la requête d'origine, sinon "granted"
      return originalQuery(params).catch(() => ({ state: 'granted' }));
    };
  }

  // 3) Créer un PluginArray réaliste
  //    - On réutilise le prototype existant pour ne pas éveiller de soupçons
  const pluginArrayProto = Object.getPrototypeOf(navigator.plugins);
  function FakePlugin(name, description, filename) {
    this.name = name;
    this.description = description;
    this.filename = filename;
  }
  // On pointe vers Plugin.prototype pour se comporter comme un plugin "réel"
  FakePlugin.prototype = Plugin.prototype;

  const fakePlugins = [
    new FakePlugin('Chrome PDF Plugin', 'Portable Document Format', 'internal-pdf-viewer'),
    new FakePlugin('Chrome PDF Viewer', '', 'mhjfbmdgcfjbbpaeojofohoefgiehjai')
  ];

  Object.defineProperty(navigator, 'plugins', {
    get() {
      const pluginArray = Object.create(pluginArrayProto);
      // On copie les faux plugins dans l’objet
      for (let i = 0; i < fakePlugins.length; i++) {
        pluginArray[i] = fakePlugins[i];
      }
      pluginArray.length = fakePlugins.length;
      return pluginArray;
    }
  });

  // 4) Aligner navigator.languages avec vos entêtes Accept-Language
  Object.defineProperty(navigator, 'languages', {
    get: () => ['en-US', 'en'],
    configurable: true
  });

  // 5) Override de getContext pour forcer un contexte WebGL factice
  const originalGetContext = HTMLCanvasElement.prototype.getContext;
  HTMLCanvasElement.prototype.getContext = function (type, ...args) {
    if (['webgl', 'experimental-webgl', 'webgl2'].includes(type)) {
      // Tenter d'obtenir le contexte natif (au cas où)
      let ctx = originalGetContext.apply(this, [type, ...args]);
      if (ctx) {
        // Si un contexte natif est obtenu, retourner ce contexte
        return ctx;
      }
      console.log("No native WebGL context found, returning fake context");
      // Forcer la création d'un contexte factice
      const proto = (window.WebGLRenderingContext && window.WebGLRenderingContext.prototype) || {};
      const fakeContext = Object.create(proto);

      fakeContext.getParameter = function (param) {
        if (param === 37445) return 'Intel Inc.';
        if (param === 37446) return 'Intel Iris OpenGL Engine';
        return null;
      };
      fakeContext.getSupportedExtensions = function () {
        return ['WEBGL_debug_renderer_info'];
      };
      fakeContext.getExtension = function (name) {
        if (name === 'WEBGL_debug_renderer_info') {
          return { UNMASKED_VENDOR_WEBGL: 37445, UNMASKED_RENDERER_WEBGL: 37446 };
        }
        return null;
      };

      // Ajout de stubs pour d'autres méthodes WebGL essentielles
      fakeContext.clear = function () { };
      fakeContext.clearColor = function () { };
      fakeContext.viewport = function () { };
      fakeContext.createShader = function () { return {}; };
      fakeContext.shaderSource = function () { };
      fakeContext.compileShader = function () { };
      fakeContext.createProgram = function () { return {}; };
      fakeContext.attachShader = function () { };
      fakeContext.linkProgram = function () { };
      fakeContext.useProgram = function () { };

      return fakeContext;
    }
    return originalGetContext.apply(this, [type, ...args]);
  };

  // 6) Optionnel : Override de toDataURL pour renvoyer une image fixe
  const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;
  HTMLCanvasElement.prototype.toDataURL = function (...args) {
    const gl = this.getContext('webgl') || this.getContext('experimental-webgl') || this.getContext('webgl2');
    if (gl) {
      return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVQYV2NgAAIAAAUAAarVyFEAAAAASUVORK5CYII=";
    }
    return originalToDataURL.apply(this, args);
  };

  // 7) Correction des dimensions d’images
  Object.defineProperty(HTMLImageElement.prototype, 'naturalWidth', {
    get() { return 128; }
  });
  Object.defineProperty(HTMLImageElement.prototype, 'naturalHeight', {
    get() { return 128; }
  });

  // 8) Randomisation pour varier l'injection
  (function () {
    const randomSuffix = Math.random().toString(36).substring(2);
    document.documentElement.setAttribute('data-stealth', randomSuffix);
  })();

  // 9) Masquer la modification des fonctions natives
  (function () {
    const originalToString = Function.prototype.toString;
    Function.prototype.toString = function () {
      if (this === navigator.permissions.query) {
        return "function query() { [native code] }";
      }
      return originalToString.apply(this, arguments);
    };
  })();

})();
