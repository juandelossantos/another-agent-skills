/**
 * Another Agent Skills — Documentation JS
 * Sidebar nav, search, theme/lang toggle, copy buttons
 */

(function() {
  'use strict';

  /* =========================================================
     1. THEME TOGGLE
     ========================================================= */

  const THEME_KEY = 'aas-theme';

  function getTheme() {
    return localStorage.getItem(THEME_KEY) || 'dark';
  }

  function setTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem(THEME_KEY, theme);
    const btn = document.querySelector('[data-action="theme"]');
    if (btn) btn.textContent = theme === 'dark' ? '☾' : '☀';
  }

  document.addEventListener('click', function(e) {
    const btn = e.target.closest('[data-action="theme"]');
    if (btn) {
      setTheme(getTheme() === 'dark' ? 'light' : 'dark');
    }
  });

  setTheme(getTheme());

  /* =========================================================
     2. LANGUAGE TOGGLE
     ========================================================= */

  const LANG_KEY = 'aas-lang';
  let currentLang = localStorage.getItem(LANG_KEY) || 'en';
  let translations = {};

  function loadTranslations(lang) {
    const path = 'i18n/' + lang + '.json';
    return fetch(path).then(function(r) { return r.json(); });
  }

  function applyTranslations() {
    document.querySelectorAll('[data-i18n]').forEach(function(el) {
      const key = el.getAttribute('data-i18n');
      const keys = key.split('.');
      let val = translations;
      for (let i = 0; i < keys.length; i++) {
        val = val && val[keys[i]];
      }
      if (val) el.textContent = val;
    });
  }

  function setLang(lang) {
    currentLang = lang;
    localStorage.setItem(LANG_KEY, lang);
    loadTranslations(lang).then(function(data) {
      translations = data;
      applyTranslations();
    });
    const btn = document.querySelector('[data-action="lang"]');
    if (btn) btn.textContent = lang === 'en' ? 'ES' : 'EN';
  }

  document.addEventListener('click', function(e) {
    const btn = e.target.closest('[data-action="lang"]');
    if (btn) {
      setLang(currentLang === 'en' ? 'es' : 'en');
    }
  });

  setLang(currentLang);

  /* =========================================================
     3. SIDEBAR MOBILE TOGGLE
     ========================================================= */

  document.addEventListener('click', function(e) {
    const toggle = e.target.closest('.docs__mobile-toggle');
    if (toggle) {
      document.querySelector('.docs__sidebar').classList.toggle('docs__sidebar--open');
    }
  });

  /* =========================================================
     4. SEARCH (client-side filter)
     ========================================================= */

  var searchInput = document.querySelector('.docs__search');
  if (searchInput) {
    searchInput.addEventListener('input', function() {
      var query = this.value.toLowerCase();
      var items = document.querySelectorAll('.sidebar__link');
      items.forEach(function(item) {
        var text = item.textContent.toLowerCase();
        item.style.display = text.indexOf(query) !== -1 ? '' : 'none';
      });
    });
  }

  /* =========================================================
     5. COPY BUTTON FOR CODE BLOCKS
     ========================================================= */

  document.querySelectorAll('pre').forEach(function(pre) {
    var btn = document.createElement('button');
    btn.className = 'docs__copy-btn';
    btn.textContent = 'Copy';
    btn.addEventListener('click', function() {
      var code = pre.querySelector('code');
      var text = code ? code.textContent : pre.textContent;
      navigator.clipboard.writeText(text).then(function() {
        btn.textContent = 'Copied';
        setTimeout(function() { btn.textContent = 'Copy'; }, 2000);
      });
    });
    pre.appendChild(btn);
  });

  /* =========================================================
     6. ACTIVE SIDEBAR LINK
     ========================================================= */

  var currentPath = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.sidebar__link').forEach(function(link) {
    var href = link.getAttribute('href');
    if (href && href.split('/').pop() === currentPath) {
      link.classList.add('sidebar__link--active');
    }
  });

  /* =========================================================
     7. TABLE OF CONTENTS (auto-generate from h2/h3)
     ========================================================= */

  var tocList = document.querySelector('.toc__list');
  if (tocList) {
    var headings = document.querySelectorAll('.docs__content h2, .docs__content h3');
    headings.forEach(function(heading, i) {
      if (!heading.id) heading.id = 'heading-' + i;
      var li = document.createElement('li');
      var a = document.createElement('a');
      a.className = 'toc__link' + (heading.tagName === 'H3' ? ' toc__link--h3' : '');
      a.href = '#' + heading.id;
      a.textContent = heading.textContent;
      li.appendChild(a);
      tocList.appendChild(li);
    });
  }

})();
