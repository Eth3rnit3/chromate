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
(function () {
  'use strict';

  // 1. Masquer la présence du webdriver
  Object.defineProperty(navigator, 'webdriver', {
    get: function () { return false; },
    configurable: true,
  });

  // 2. Simuler la présence de plugins (souvent utilisés pour détecter l'automatisation)
  Object.defineProperty(navigator, 'plugins', {
    get: function () { return [1, 2, 3, 4, 5]; },
    configurable: true,
  });

  // 3. Fournir des langues crédibles
  Object.defineProperty(navigator, 'languages', {
    get: function () { return ['en-US']; },
    configurable: true,
  });

  // 4. Créer ou modifier l'objet window.chrome pour simuler un environnement Chrome authentique
  if (!window.chrome) {
    window.chrome = {};
  }
  if (!window.chrome.runtime) {
    window.chrome.runtime = {};
  }
  if (!window.chrome.csi) {
    // La méthode chrome.csi est parfois utilisée pour vérifier l'authenticité du navigateur
    window.chrome.csi = function () { return { startE: Date.now() }; };
  }
  if (!window.chrome.loadTimes) {
    // La méthode loadTimes est utilisée par certains scripts pour obtenir des informations sur le chargement
    window.chrome.loadTimes = function () { return {}; };
  }

  // 5. Override de navigator.permissions.query pour éviter certaines détections
  if (window.navigator.permissions && window.navigator.permissions.query) {
    const originalQuery = window.navigator.permissions.query;
    window.navigator.permissions.query = function (parameters) {
      // Pour la permission "notifications", retourner la permission réelle
      if (parameters.name === 'notifications') {
        return Promise.resolve({ state: Notification.permission });
      }
      // Pour les autres, renvoyer un état générique (ici 'granted')
      return originalQuery(parameters).catch(function () {
        return { state: 'granted' };
      });
    };
  }

  // 6. Randomisation pour varier l'injection et rendre la détection plus difficile
  (function () {
    const randomSuffix = Math.random().toString(36).substring(2);
    // Par exemple, ajouter un attribut personnalisé au document
    document.documentElement.setAttribute('data-stealth', randomSuffix);
  })();

  // 7. Masquer la modification des fonctions natives (exemple avec toString)
  (function () {
    const originalToString = Function.prototype.toString;
    Function.prototype.toString = function () {
      if (this === window.navigator.permissions.query) {
        return "function query() { [native code] }";
      }
      return originalToString.apply(this, arguments);
    };
  })();
})();
