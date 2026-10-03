/*
 * Another Agent Skills - Phase 10 docs-view MOCKUP
 * docs/mockups/phase10/js/docs-mockup.js
 *
 * Self-contained docs interactions: inline EN/ES i18n, theme + lang toggles,
 * the mobile sidebar drawer, the header search overlay, the "On this page" TOC
 * scroll-spy, and code copy. No libraries. Progressive enhancement: without JS
 * the sidebar and content are visible and the search input stays a plain input.
 */
(function () {
  'use strict';

  var doc = document.documentElement;
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* =========================================================
     i18n
     ========================================================= */

  var I18N = {
    en: {
      a11y: {
        skip: 'Skip to content',
        theme: 'Toggle color theme',
        langToEs: 'Switch to Spanish',
        langToEn: 'Switch to English',
        menu: 'Open documentation navigation',
        menuClose: 'Close documentation navigation',
        copy: 'Copy code'
      },
      theme: { dark: 'Dark', light: 'Light' },
      nav: {
        github: 'GitHub', docs: 'Docs',
        getStarted: 'Get started', overview: 'Overview', gettingStarted: 'Getting Started', quickstart: 'Quick Start',
        concepts: 'Concepts', lifecycle: 'Lifecycle', skills: 'Skills', loop: 'Universal Loop',
        enforcement: 'Enforcement', designReview: 'Design Review',
        reference: 'Reference', rules: 'Rules', agents: 'Agents', customization: 'Customization',
        evaluation: 'Evaluation', branch: 'Branch Protection', distribution: 'Distribution'
      },
      version: 'v6.4.0',
      versionLabel: 'current docs',
      search: {
        placeholder: 'Search docs',
        label: 'Search documentation',
        hints: '\u2191\u2193 navigate \u00b7 Enter open \u00b7 Esc close',
        results: 'results',
        result: 'result',
        noResults: 'No results for',
        r1Title: 'Enforcement (L1/L2/L3)', r1Section: 'Concepts',
        r1Snippet: 'A code change with no matching test is blocked locally by L1 and remotely by the gates check.',
        r2Title: 'Getting Started', r2Section: 'Get started',
        r2Snippet: 'Install with git clone or the pinned curl bootstrap, then run init-agents.',
        r3Title: 'Branch Protection', r3Section: 'Reference',
        r3Snippet: 'How the remote gates check and CODEOWNERS become the authority layer.',
        r4Title: 'Distribution & Upgrades', r4Section: 'Reference',
        r4Snippet: 'Channels, pinned releases, and how the upgrade command works.',
        r5Title: 'Lifecycle', r5Section: 'Concepts',
        r5Snippet: 'Six phases: Define, Plan, Build, Verify, Review, Ship.',
        r6Title: 'Universal Loop', r6Section: 'Concepts',
        r6Snippet: 'Audit, diagnose, fix, record an ADR, and repeat.'
      },
      toc: { title: 'On this page' },
      page: {
        title: 'Enforcement (L1/L2/L3)',
        tldr: 'L1 is fast local feedback, L2 is the remote authority, L3 protects the gate config. A code change with no matching test is blocked, locally and remotely.'
      },
      sections: {
        layersTitle: 'The three layers',
        layersIntro: 'Most frameworks stop at rules in a file, and a rule in a file is a suggestion. Enforcement is a mechanism: a change that breaks the process cannot reach main. Three layers answer three different questions.',
        l1Title: 'Local feedback',
        l1Desc: 'Fails fast, informs, and leaves a trace. Ergonomics for a cooperative agent. Not security.',
        l2Title: 'Remote authority',
        l2Desc: 'GitHub branch protection plus a required status check. Nothing reaches main without passing the gates. The committer cannot skip it.',
        l3Title: 'Config integrity',
        l3Desc: 'CODEOWNERS plus required code-owner review. Another owner must approve changes to the gate configuration. GitHub only.',
        ruleTitle: 'The rule: no code without a test',
        ruleBody1: 'The commit-msg hook (v6) runs a single TDD gate. A code file staged for commit must have a matching test file staged in the same commit. Name-pairing is checked, and at least one staged test must be new.',
        ruleBody2: 'There is no override mechanism. Pre-commit Gate 0 blocks until the decision token is fresh, but that is a prompt, not the approval authority.',
        calloutTitle: 'Why a hook is not a gate',
        calloutBody: 'The hooks directory is writable by whoever is committing, including an agent. A single git config command silences every hook at once. That is why L1 is feedback, not authority. If the gate that decides can be edited by the change it judges, it is not a gate.',
        blockedTitle: 'A blocked commit',
        blockedIntro: 'This is real output, not a mock. The commit stops before it exists.',
        blockedNote1: 'The same check runs remotely as the required ',
        blockedNote2: ' status, so it cannot be bypassed by the committer.',
        copy: 'Copy', copied: 'Copied',
        gatesTitle: 'The gates at a glance',
        gatesIntro: 'Each layer lives in a different place and guarantees a different thing. Local checks keep the process visible; remote checks are the authority.',
        thLayer: 'Layer', thWhere: 'Where it lives', thGuarantee: 'What it guarantees',
        g1Where: 'Working tree, .git/hooks',
        g1Guarantee: 'Fast feedback and a visible decision point. Not security.',
        g2Where: 'GitHub branch protection',
        g2Guarantee: 'Nothing reaches main without passing the required gates check.',
        g3Where: 'CODEOWNERS',
        g3Guarantee: "Changes to the gate config need another owner's approval.",
        turnOnTitle: 'Turn it on',
        turnOnIntro: 'The setup script detects the repository shape and picks a safe profile. Preview first, then apply.',
        step1a: 'Preview the exact payload without writing anything:',
        step2a: 'Apply it. The script auto-detects solo versus team and refuses a configuration that could lock you out:',
        step3a: 'Verify that the remote authority is live:',
        step4a: 'After git init or adding a remote, re-run the installer so the missing layers install:',
        limitsTitle: 'Honest limitations',
        limitsBody: 'These gates create friction, not guarantees. L1 hooks can be bypassed by editing the hook or changing the hooks path. On a solo repository the admin can still bypass the remote rules by design, so the gates remain mandatory for everyone without admin rights. The human stays in the loop, and the human stays alert.'
      },
      pager: { prevLabel: 'Previous', nextLabel: 'Next', prev: 'Universal Loop', next: 'Design Review' },
      edit: 'Edit this page'
    },

    es: {
      a11y: {
        skip: 'Saltar al contenido',
        theme: 'Cambiar tema de color',
        langToEs: 'Cambiar a espa\u00f1ol',
        langToEn: 'Cambiar a ingl\u00e9s',
        menu: 'Abrir la navegaci\u00f3n de documentaci\u00f3n',
        menuClose: 'Cerrar la navegaci\u00f3n de documentaci\u00f3n',
        copy: 'Copiar c\u00f3digo'
      },
      theme: { dark: 'Oscuro', light: 'Claro' },
      nav: {
        github: 'GitHub', docs: 'Documentaci\u00f3n',
        getStarted: 'Empezar', overview: 'Resumen', gettingStarted: 'Primeros pasos', quickstart: 'Inicio r\u00e1pido',
        concepts: 'Conceptos', lifecycle: 'Ciclo de vida', skills: 'Skills', loop: 'Bucle universal',
        enforcement: 'Enforcement', designReview: 'Revisi\u00f3n de dise\u00f1o',
        reference: 'Referencia', rules: 'Reglas', agents: 'Agentes', customization: 'Personalizaci\u00f3n',
        evaluation: 'Evaluaci\u00f3n', branch: 'Protecci\u00f3n de ramas', distribution: 'Distribuci\u00f3n'
      },
      version: 'v6.4.0',
      versionLabel: 'docs actuales',
      search: {
        placeholder: 'Buscar en la documentaci\u00f3n',
        label: 'Buscar en la documentaci\u00f3n',
        hints: '\u2191\u2193 navegar \u00b7 Enter abrir \u00b7 Esc cerrar',
        results: 'resultados',
        result: 'resultado',
        noResults: 'Sin resultados para',
        r1Title: 'Enforcement (L1/L2/L3)', r1Section: 'Conceptos',
        r1Snippet: 'Un cambio de c\u00f3digo sin test que lo cubra se bloquea localmente por L1 y en remoto por el check gates.',
        r2Title: 'Primeros pasos', r2Section: 'Empezar',
        r2Snippet: 'Instala con git clone o el bootstrap curl fijado, y despu\u00e9s ejecuta init-agents.',
        r3Title: 'Protecci\u00f3n de ramas', r3Section: 'Referencia',
        r3Snippet: 'C\u00f3mo el check remoto gates y CODEOWNERS se convierten en la capa de autoridad.',
        r4Title: 'Distribuci\u00f3n y actualizaciones', r4Section: 'Referencia',
        r4Snippet: 'Canales, releases fijados y c\u00f3mo funciona el comando de actualizaci\u00f3n.',
        r5Title: 'Ciclo de vida', r5Section: 'Conceptos',
        r5Snippet: 'Seis fases: Definir, Planear, Construir, Verificar, Revisar y Entregar.',
        r6Title: 'Bucle universal', r6Section: 'Conceptos',
        r6Snippet: 'Auditar, diagnosticar, arreglar, registrar un ADR y repetir.'
      },
      toc: { title: 'En esta p\u00e1gina' },
      page: {
        title: 'Enforcement (L1/L2/L3)',
        tldr: 'L1 es feedback local r\u00e1pido, L2 es la autoridad remota y L3 protege la configuraci\u00f3n de las puertas. Un cambio de c\u00f3digo sin test que lo cubra se bloquea, local y remotamente.'
      },
      sections: {
        layersTitle: 'Las tres capas',
        layersIntro: 'La mayor\u00eda de los frameworks se detiene en reglas dentro de un archivo, y una regla en un archivo es una sugerencia. El enforcement es un mecanismo: un cambio que rompe el proceso no puede llegar a main. Tres capas responden a tres preguntas distintas.',
        l1Title: 'Feedback local',
        l1Desc: 'Falla r\u00e1pido, informa y deja un rastro. Ergonom\u00eda para un agente cooperativo. No es seguridad.',
        l2Title: 'Autoridad remota',
        l2Desc: 'Protecci\u00f3n de ramas de GitHub m\u00e1s un status check requerido. Nada llega a main sin pasar las puertas. El committer no puede saltarlo.',
        l3Title: 'Integridad de la configuraci\u00f3n',
        l3Desc: 'CODEOWNERS m\u00e1s review requerido de un code owner. Otro owner debe aprobar los cambios en la configuraci\u00f3n de las puertas. Solo GitHub.',
        ruleTitle: 'La regla: sin c\u00f3digo sin test',
        ruleBody1: 'El hook commit-msg (v6) ejecuta una \u00fanica puerta TDD. Un archivo de c\u00f3digo en stage debe tener un archivo de test correspondiente en el mismo commit. Se verifica el emparejamiento por nombre y al menos un test en stage debe ser nuevo.',
        ruleBody2: 'No existe ning\u00fan mecanismo de override. La puerta 0 de pre-commit bloquea hasta que el token de decisi\u00f3n est\u00e9 vigente, pero eso es un aviso, no la autoridad de aprobaci\u00f3n.',
        calloutTitle: 'Por qu\u00e9 un hook no es una puerta',
        calloutBody: 'El directorio de hooks lo puede escribir quien hace el commit, incluido un agente. Un solo comando de configuraci\u00f3n de git silencia todos los hooks a la vez. Por eso L1 es feedback y no autoridad. Si la puerta que decide puede ser editada por el cambio que juzga, no es una puerta.',
        blockedTitle: 'Un commit bloqueado',
        blockedIntro: 'Esto es salida real, no un mock. El commit se detiene antes de existir.',
        blockedNote1: 'El mismo check corre en remoto como el status requerido ',
        blockedNote2: ', as\u00ed que el committer no puede saltearlo.',
        copy: 'Copiar', copied: 'Copiado',
        gatesTitle: 'Las puertas de un vistazo',
        gatesIntro: 'Cada capa vive en un lugar distinto y garantiza algo distinto. Los checks locales mantienen el proceso visible; los remotos son la autoridad.',
        thLayer: 'Capa', thWhere: 'D\u00f3nde vive', thGuarantee: 'Qu\u00e9 garantiza',
        g1Where: '\u00c1rbol de trabajo, .git/hooks',
        g1Guarantee: 'Feedback r\u00e1pido y un punto de decisi\u00f3n visible. No es seguridad.',
        g2Where: 'Protecci\u00f3n de ramas de GitHub',
        g2Guarantee: 'Nada llega a main sin pasar el check gates requerido.',
        g3Where: 'CODEOWNERS',
        g3Guarantee: 'Los cambios en la configuraci\u00f3n de las puertas necesitan la aprobaci\u00f3n de otro owner.',
        turnOnTitle: 'C\u00f3mo activarlo',
        turnOnIntro: 'El script de configuraci\u00f3n detecta la forma del repositorio y elige un perfil seguro. Primero previsualiza y despu\u00e9s aplica.',
        step1a: 'Previsualiza el payload exacto sin escribir nada:',
        step2a: 'Apl\u00edcalo. El script detecta autom\u00e1ticamente solo o equipo y rechaza una configuraci\u00f3n que podr\u00eda dejarte fuera:',
        step3a: 'Verifica que la autoridad remota est\u00e9 activa:',
        step4a: 'Despu\u00e9s de git init o de agregar un remoto, vuelve a ejecutar el instalador para que se instalen las capas faltantes:',
        limitsTitle: 'Limitaciones honestas',
        limitsBody: 'Estas puertas crean fricci\u00f3n, no garant\u00edas. Los hooks L1 se pueden saltar editando el hook o cambiando la ruta de hooks. En un repositorio solo, el admin todav\u00eda puede saltarse las reglas remotas por dise\u00f1o, as\u00ed que las puertas siguen siendo obligatorias para todos los que no tienen permisos de admin. La persona sigue en el loop, y la persona sigue atenta.'
      },
      pager: { prevLabel: 'Anterior', nextLabel: 'Siguiente', prev: 'Bucle universal', next: 'Revisi\u00f3n de dise\u00f1o' },
      edit: 'Editar esta p\u00e1gina'
    }
  };

  function getNested(obj, path) {
    return path.split('.').reduce(function (o, k) {
      return o && o[k] !== undefined ? o[k] : null;
    }, obj);
  }

  var currentLang = 'en';

  function t() { return I18N[currentLang] || I18N.en; }

  /* =========================================================
     Element references (script runs at end of body)
     ========================================================= */

  var langBtn = document.querySelector('[data-action="lang"]');
  var themeBtn = document.querySelector('[data-action="theme"]');
  var menuBtn = document.querySelector('[data-action="sidebar"]');
  var sidebar = document.querySelector('[data-sidebar]');
  var backdrop = document.querySelector('[data-backdrop]');

  var searchWrap = document.querySelector('[data-search]');
  var searchInput = document.querySelector('[data-search-input]');
  var searchPanel = document.querySelector('[data-search-panel]');
  var searchItems = Array.prototype.slice.call(document.querySelectorAll('[data-search-item]'));
  var searchCount = document.querySelector('[data-search-count]');
  var searchEmpty = document.querySelector('[data-search-empty]');
  var searchQuery = document.querySelector('[data-search-query]');
  var searchKbd = document.querySelector('[data-search-kbd]');
  var searchActiveIndex = -1;

  var tocLinks = Array.prototype.slice.call(document.querySelectorAll('[data-toc-list] .docs-toc__link'));

  /* =========================================================
     Language
     ========================================================= */

  function applyLang(lang) {
    currentLang = I18N[lang] ? lang : 'en';
    var tr = t();
    doc.setAttribute('lang', currentLang);
    try { localStorage.setItem('aas-lang', currentLang); } catch (e) {}

    Array.prototype.forEach.call(document.querySelectorAll('[data-i18n]'), function (el) {
      var val = getNested(tr, el.getAttribute('data-i18n'));
      if (val !== null) el.textContent = val;
    });
    Array.prototype.forEach.call(document.querySelectorAll('[data-i18n-html]'), function (el) {
      var val = getNested(tr, el.getAttribute('data-i18n-html'));
      if (val !== null) el.innerHTML = val;
    });

    if (langBtn) {
      var langText = langBtn.querySelector('[data-lang-text]');
      if (langText) langText.textContent = currentLang === 'en' ? 'ES' : 'EN';
      langBtn.setAttribute('aria-label', currentLang === 'en' ? tr.a11y.langToEs : tr.a11y.langToEn);
    }
    if (themeBtn) {
      themeBtn.setAttribute('aria-label', tr.a11y.theme);
      updateThemeLabel();
    }
    if (menuBtn) {
      var expanded = menuBtn.getAttribute('aria-expanded') === 'true';
      menuBtn.setAttribute('aria-label', expanded ? tr.a11y.menuClose : tr.a11y.menu);
    }
    Array.prototype.forEach.call(document.querySelectorAll('[data-action="copy"]'), function (b) {
      b.setAttribute('aria-label', tr.a11y.copy);
    });
    if (searchInput) {
      searchInput.setAttribute('placeholder', tr.search.placeholder);
      searchInput.setAttribute('aria-label', tr.search.label);
    }
    refreshSearch();
  }

  function toggleLang() {
    applyLang(currentLang === 'en' ? 'es' : 'en');
  }

  /* =========================================================
     Theme
     ========================================================= */

  function updateThemeLabel() {
    var theme = doc.getAttribute('data-theme') || 'dark';
    var tr = t().theme;
    var text = document.querySelector('[data-theme-text]');
    if (text) text.textContent = theme === 'dark' ? tr.dark : tr.light;
    if (themeBtn) themeBtn.setAttribute('aria-pressed', theme === 'light' ? 'true' : 'false');
  }

  function toggleTheme() {
    var next = doc.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    doc.setAttribute('data-theme', next);
    try { localStorage.setItem('aas-theme', next); } catch (e) {}
    updateThemeLabel();
  }

  /* =========================================================
     Sidebar drawer
     ========================================================= */

  function isMobile() {
    return window.matchMedia && window.matchMedia('(max-width: 1000px)').matches;
  }

  function openSidebar() {
    if (!sidebar || !menuBtn) return;
    sidebar.classList.add('is-open');
    document.body.classList.add('is-sidebar-open');
    if (backdrop) backdrop.hidden = false;
    menuBtn.setAttribute('aria-expanded', 'true');
    menuBtn.setAttribute('aria-label', t().a11y.menuClose);
    var first = sidebar.querySelector('.docs-nav__link');
    if (first && isMobile()) setTimeout(function () { first.focus(); }, reduceMotion ? 0 : 180);
  }

  function closeSidebar(silent) {
    if (!sidebar || !menuBtn) return;
    sidebar.classList.remove('is-open');
    document.body.classList.remove('is-sidebar-open');
    if (backdrop) backdrop.hidden = true;
    menuBtn.setAttribute('aria-expanded', 'false');
    menuBtn.setAttribute('aria-label', t().a11y.menu);
    if (!silent && isMobile()) menuBtn.focus();
  }

  function toggleSidebar() {
    if (!sidebar) return;
    if (sidebar.classList.contains('is-open')) closeSidebar();
    else openSidebar();
  }

  /* =========================================================
     Search overlay
     ========================================================= */

  function escapeHtml(s) {
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function highlight(text, q) {
    var safe = escapeHtml(text);
    if (!q) return safe;
    var lower = safe.toLowerCase();
    var ql = q.toLowerCase();
    var out = '';
    var i = 0;
    while (true) {
      var j = lower.indexOf(ql, i);
      if (j === -1) { out += safe.slice(i); break; }
      out += safe.slice(i, j) + '<mark>' + safe.slice(j, j + ql.length) + '</mark>';
      i = j + ql.length;
      if (i >= safe.length) break;
    }
    return out;
  }

  function visibleItems() {
    return searchItems.filter(function (el) { return !el.hidden; });
  }

  function setActiveSearch(index) {
    var vis = visibleItems();
    if (!vis.length) { searchActiveIndex = -1; return; }
    if (index < 0) index = vis.length - 1;
    if (index >= vis.length) index = 0;
    searchActiveIndex = index;
    searchItems.forEach(function (el) {
      el.classList.remove('is-active');
      el.setAttribute('aria-selected', 'false');
    });
    var active = vis[index];
    active.classList.add('is-active');
    active.setAttribute('aria-selected', 'true');
    if (searchInput) searchInput.setAttribute('aria-activedescendant', active.id);
    if (active.scrollIntoView) active.scrollIntoView({ block: 'nearest' });
  }

  function refreshSearch() {
    if (!searchInput) return;
    var q = searchInput.value.trim();
    var ql = q.toLowerCase();
    var visible = 0;

    searchItems.forEach(function (el) {
      var title = el.querySelector('.docs-search__result-title');
      var section = el.querySelector('.docs-search__result-section');
      var snippet = el.querySelector('.docs-search__result-snippet');
      var raw = [title, section, snippet].map(function (n) { return n ? n.textContent : ''; }).join(' ').toLowerCase();
      var match = !ql || raw.indexOf(ql) !== -1;
      el.hidden = !match;
      if (match) visible++;
      if (title) title.innerHTML = highlight(title.textContent, ql);
      if (section) section.innerHTML = highlight(section.textContent, ql);
      if (snippet) snippet.innerHTML = highlight(snippet.textContent, ql);
    });

    if (searchCount) {
      searchCount.textContent = visible + ' ' + (visible === 1 ? t().search.result : t().search.results);
    }
    if (searchEmpty) searchEmpty.hidden = visible !== 0;
    if (searchQuery) searchQuery.textContent = q;

    // Keep a valid active option while open.
    if (searchPanel && !searchPanel.hidden) {
      if (!visible) searchActiveIndex = -1;
      else setActiveSearch(searchActiveIndex < 0 ? 0 : searchActiveIndex);
    }
  }

  function openSearch() {
    if (!searchPanel || !searchInput) return;
    searchPanel.hidden = false;
    searchWrap.classList.add('is-open');
    searchInput.setAttribute('aria-expanded', 'true');
    refreshSearch();
  }

  function closeSearch() {
    if (!searchPanel || !searchInput) return;
    searchPanel.hidden = true;
    searchWrap.classList.remove('is-open');
    searchInput.setAttribute('aria-expanded', 'false');
    searchInput.removeAttribute('aria-activedescendant');
    searchItems.forEach(function (el) {
      el.classList.remove('is-active');
      el.setAttribute('aria-selected', 'false');
    });
    searchActiveIndex = -1;
  }

  function searchIsOpen() {
    return searchPanel && !searchPanel.hidden;
  }

  function initSearch() {
    if (!searchInput || !searchPanel) return;

    var isMac = /Mac|iPhone|iPad/.test(navigator.platform || navigator.userAgent || '');
    if (searchKbd) searchKbd.textContent = isMac ? '\u2318K' : 'Ctrl K';

    searchInput.addEventListener('focus', function () { openSearch(); });
    searchInput.addEventListener('input', function () { openSearch(); refreshSearch(); });

    searchInput.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (!searchIsOpen()) openSearch();
        setActiveSearch(searchActiveIndex + 1);
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (!searchIsOpen()) openSearch();
        setActiveSearch(searchActiveIndex - 1);
      } else if (e.key === 'Enter') {
        var vis = visibleItems();
        if (searchIsOpen() && vis.length) {
          e.preventDefault();
          var target = searchActiveIndex >= 0 && vis[searchActiveIndex] ? vis[searchActiveIndex] : vis[0];
          if (target && target.href) window.location.href = target.href;
        }
      } else if (e.key === 'Escape') {
        if (searchIsOpen()) {
          e.preventDefault();
          closeSearch();
        } else if (searchInput.value) {
          searchInput.value = '';
          refreshSearch();
        }
      } else if (e.key === 'Tab') {
        closeSearch();
      }
    });

    searchItems.forEach(function (el) {
      el.addEventListener('click', function () { closeSearch(); });
      el.addEventListener('mouseenter', function () {
        var vis = visibleItems();
        var i = vis.indexOf(el);
        if (i !== -1) setActiveSearch(i);
      });
    });

    document.addEventListener('click', function (e) {
      if (searchIsOpen() && searchWrap && !searchWrap.contains(e.target)) closeSearch();
    });

    document.addEventListener('keydown', function (e) {
      var key = e.key ? e.key.toLowerCase() : '';
      if ((e.metaKey || e.ctrlKey) && key === 'k') {
        e.preventDefault();
        searchInput.focus();
        searchInput.select();
        openSearch();
      }
    });
  }

  /* =========================================================
     TOC scroll-spy
     ========================================================= */

  function setTocActive(id) {
    tocLinks.forEach(function (a) {
      var on = a.getAttribute('href') === '#' + id;
      a.classList.toggle('is-active', on);
      if (on) a.setAttribute('aria-current', 'true');
      else a.removeAttribute('aria-current');
    });
  }

  function initToc() {
    if (!tocLinks.length) return;
    var headings = [];
    tocLinks.forEach(function (a) {
      var id = a.getAttribute('href').slice(1);
      var h = document.getElementById(id);
      if (h) headings.push(h);
    });
    if (!headings.length) return;

    tocLinks.forEach(function (a) {
      a.addEventListener('click', function () { setTocActive(a.getAttribute('href').slice(1)); });
    });

    function headerOffset() {
      var raw = getComputedStyle(document.documentElement).getPropertyValue('--docs-header-h');
      var n = parseFloat(raw);
      return (isNaN(n) ? 96 : n) + 24;
    }

    function update() {
      var line = headerOffset();
      var current = headings[0].id;
      for (var i = 0; i < headings.length; i++) {
        if (headings[i].getBoundingClientRect().top - line <= 0) current = headings[i].id;
        else break;
      }
      setTocActive(current);
    }

    var ticking = false;
    function onScroll() {
      if (ticking) return;
      ticking = true;
      window.requestAnimationFrame(function () { ticking = false; update(); });
    }

    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', onScroll);
    update();
  }

  /* =========================================================
     Copy
     ========================================================= */

  function copyCode(btn) {
    var scope = btn.closest('[data-codeblock]') || btn.closest('.command');
    var code = scope ? scope.querySelector('.command__code, .codeblock__pre code, pre code') : null;
    if (!code) return;
    var text = code.textContent.replace(/\s+$/, '');

    var textEl = btn.querySelector('.command__copy-text');
    var prevText = textEl ? textEl.textContent : null;

    function done() {
      btn.setAttribute('data-copied', 'true');
      if (textEl) textEl.textContent = t().sections.copied;
      setTimeout(function () {
        btn.removeAttribute('data-copied');
        if (textEl) textEl.textContent = prevText || t().sections.copy;
      }, 2000);
    }

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(done, done);
    } else {
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      try { document.execCommand('copy'); } catch (e) {}
      document.body.removeChild(ta);
      done();
    }
  }

  /* =========================================================
     Init
     ========================================================= */

  function init() {
    var lang;
    try { lang = localStorage.getItem('aas-lang'); } catch (e) {}
    if (lang !== 'en' && lang !== 'es') {
      lang = (navigator.language || 'en').toLowerCase().indexOf('es') === 0 ? 'es' : 'en';
    }
    applyLang(lang);
    updateThemeLabel();
    initSearch();
    initToc();

    document.addEventListener('click', function (e) {
      var target = e.target.closest('[data-action]');
      if (!target) return;
      switch (target.getAttribute('data-action')) {
        case 'theme': toggleTheme(); break;
        case 'lang': toggleLang(); break;
        case 'sidebar': toggleSidebar(); break;
        case 'copy': copyCode(target); break;
      }
    });

    if (backdrop) backdrop.addEventListener('click', function () { closeSidebar(); });

    // Close the drawer after choosing a link on mobile.
    if (sidebar) {
      sidebar.addEventListener('click', function (e) {
        if (e.target.closest('a') && isMobile()) closeSidebar(true);
      });
    }

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && sidebar && sidebar.classList.contains('is-open')) {
        closeSidebar();
      }
    });

    window.addEventListener('resize', function () {
      if (!isMobile() && sidebar && sidebar.classList.contains('is-open')) closeSidebar(true);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
