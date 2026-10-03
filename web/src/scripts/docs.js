/*
 * Another Agent Skills — docs interactions.
 *
 * Progressive enhancement only. Without JS the sidebar and content are visible
 * and the search input stays a plain input. This script adds: the theme toggle,
 * the mobile sidebar drawer, the header search overlay (fed by the
 * build-generated JSON index), the "On this page" scroll-spy, and copy buttons
 * on fenced code blocks. No libraries, no external services, no trackers.
 *
 * Ported from docs/mockups/phase10/js/docs-mockup.js (approved Phase 10 mockup).
 * Locale is a real route (EN/ES), so there is no client-side text swap.
 */
(function () {
  'use strict';

  var doc = document.documentElement;
  var body = document.body;
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  var MENU_LABEL = body.getAttribute('data-menu-label') || 'Open documentation navigation';
  var MENU_CLOSE_LABEL = body.getAttribute('data-menu-close-label') || 'Close documentation navigation';
  var COPY_LABEL = body.getAttribute('data-copy-label') || 'Copy code';
  var COPIED_LABEL = body.getAttribute('data-copied-label') || 'Copied';

  /* =========================================================
     Element references
     ========================================================= */

  var themeBtn = document.querySelector('[data-action="theme"]');
  var menuBtn = document.querySelector('[data-action="sidebar"]');
  var sidebar = document.querySelector('[data-sidebar]');
  var backdrop = document.querySelector('[data-backdrop]');

  var searchWrap = document.querySelector('[data-search]');
  var searchInput = document.querySelector('[data-search-input]');
  var searchPanel = document.querySelector('[data-search-panel]');
  var searchResults = document.querySelector('[data-search-results]');
  var searchCount = document.querySelector('[data-search-count]');
  var searchEmpty = document.querySelector('[data-search-empty]');
  var searchQuery = document.querySelector('[data-search-query]');
  var searchKbd = document.querySelector('[data-search-kbd]');

  var tocLinks = Array.prototype.slice.call(document.querySelectorAll('[data-toc-list] .docs-toc__link'));

  /* =========================================================
     Theme
     ========================================================= */

  function updateThemeLabel() {
    if (!themeBtn) return;
    var theme = doc.getAttribute('data-theme') || 'dark';
    var text = themeBtn.querySelector('[data-theme-text]');
    var dark = themeBtn.getAttribute('data-theme-dark') || 'Dark';
    var light = themeBtn.getAttribute('data-theme-light') || 'Light';
    // The label names the mode you would switch TO, not the current one.
    if (text) text.textContent = theme === 'dark' ? light : dark;
    // aria-pressed reflects the actual current state (light theme active).
    themeBtn.setAttribute('aria-pressed', theme === 'light' ? 'true' : 'false');
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
    body.classList.add('is-sidebar-open');
    if (backdrop) backdrop.hidden = false;
    menuBtn.setAttribute('aria-expanded', 'true');
    menuBtn.setAttribute('aria-label', MENU_CLOSE_LABEL);
    var first = sidebar.querySelector('.docs-nav__link');
    if (first && isMobile()) setTimeout(function () { first.focus(); }, reduceMotion ? 0 : 180);
  }

  function closeSidebar(silent) {
    if (!sidebar || !menuBtn) return;
    sidebar.classList.remove('is-open');
    body.classList.remove('is-sidebar-open');
    if (backdrop) backdrop.hidden = true;
    menuBtn.setAttribute('aria-expanded', 'false');
    menuBtn.setAttribute('aria-label', MENU_LABEL);
    if (!silent && isMobile()) menuBtn.focus();
  }

  function toggleSidebar() {
    if (!sidebar) return;
    if (sidebar.classList.contains('is-open')) closeSidebar();
    else openSidebar();
  }

  /* =========================================================
     Sidebar skill anchors
     ========================================================= */

  // Progressive enhancement: when a page opens at a `#skill-<name>` anchor,
  // reveal the collapsible group that holds the link and mark it active.
  // Without JS the groups stay native <details> and the anchor still works.
  var skillLinks = sidebar
    ? Array.prototype.slice.call(sidebar.querySelectorAll('[data-skill-link]'))
    : [];

  function revealSkillAnchor() {
    if (!skillLinks.length) return;
    var hash = window.location.hash;
    skillLinks.forEach(function (a) {
      a.classList.remove('is-active');
      a.removeAttribute('aria-current');
    });
    if (hash.indexOf('#skill-') !== 0) return;
    var name = hash.slice('#skill-'.length);
    var link = null;
    for (var i = 0; i < skillLinks.length; i += 1) {
      if (skillLinks[i].getAttribute('data-skill-link') === name) { link = skillLinks[i]; break; }
    }
    if (!link) return;
    var details = link.closest('details');
    while (details) {
      details.open = true;
      details = details.parentElement ? details.parentElement.closest('details') : null;
    }
    link.classList.add('is-active');
    link.setAttribute('aria-current', 'true');
  }

  /* =========================================================
     Search overlay
     ========================================================= */

  var searchData = null;
  var searchLoading = false;
  var searchActiveIndex = -1;

  function escapeHtml(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function highlight(text, q) {
    // Match on the raw text and escape each slice separately, so a match can
    // never split an HTML entity (`&amp;`) and corrupt the output.
    var raw = String(text);
    if (!q) return escapeHtml(raw);
    var lower = raw.toLowerCase();
    var ql = q.toLowerCase();
    var out = '';
    var i = 0;
    while (true) {
      var j = lower.indexOf(ql, i);
      if (j === -1) { out += escapeHtml(raw.slice(i)); break; }
      out += escapeHtml(raw.slice(i, j)) + '<mark>' + escapeHtml(raw.slice(j, j + ql.length)) + '</mark>';
      i = j + ql.length;
      if (i >= raw.length) break;
    }
    return out;
  }

  function resultItems() {
    if (!searchResults) return [];
    return Array.prototype.slice.call(searchResults.querySelectorAll('[data-search-item]'));
  }

  function visibleItems() {
    return resultItems().filter(function (el) { return !el.hidden; });
  }

  function setActiveSearch(index) {
    var items = resultItems();
    var vis = visibleItems();
    if (!vis.length) { searchActiveIndex = -1; return; }
    if (index < 0) index = vis.length - 1;
    if (index >= vis.length) index = 0;
    searchActiveIndex = index;
    items.forEach(function (el) {
      el.classList.remove('is-active');
      el.setAttribute('aria-selected', 'false');
    });
    var active = vis[index];
    active.classList.add('is-active');
    active.setAttribute('aria-selected', 'true');
    if (searchInput) searchInput.setAttribute('aria-activedescendant', active.id);
    if (active.scrollIntoView) active.scrollIntoView({ block: 'nearest' });
  }

  function renderResults(q) {
    if (!searchResults || !searchData) return;
    var ql = q.trim().toLowerCase();
    var resultsLabel = searchWrap.getAttribute('data-results-label') || 'results';
    var resultLabel = searchWrap.getAttribute('data-result-label') || 'result';

    var matches = searchData.filter(function (item) {
      if (!ql) return true;
      var raw = [item.title, item.section, item.snippet].join(' ').toLowerCase();
      return raw.indexOf(ql) !== -1;
    });

    searchResults.innerHTML = matches
      .map(function (item, i) {
        return (
          '<a class="docs-search__result" role="option" id="sr-' + i + '" aria-selected="false" href="' +
          escapeHtml(item.url) + '" data-search-item>' +
          '<span class="docs-search__result-head">' +
          '<span class="docs-search__result-title">' + highlight(item.title, ql) + '</span>' +
          '<span class="docs-search__result-section">' + escapeHtml(item.section) + '</span>' +
          '</span>' +
          '<span class="docs-search__result-snippet">' + highlight(item.snippet, ql) + '</span>' +
          '</a>'
        );
      })
      .join('');

    if (searchCount) {
      searchCount.textContent = matches.length + ' ' + (matches.length === 1 ? resultLabel : resultsLabel);
    }
    if (searchEmpty) searchEmpty.hidden = matches.length !== 0;
    if (searchQuery) searchQuery.textContent = q.trim();

    if (searchPanel && !searchPanel.hidden) {
      if (!matches.length) searchActiveIndex = -1;
      else setActiveSearch(searchActiveIndex < 0 ? 0 : searchActiveIndex);
    }
  }

  function loadIndex() {
    if (searchData || searchLoading || !searchWrap) return;
    var src = searchWrap.getAttribute('data-search-src');
    if (!src) return;
    searchLoading = true;
    fetch(src)
      .then(function (res) { return res.ok ? res.json() : []; })
      .then(function (data) {
        searchData = Array.isArray(data) ? data : [];
        searchLoading = false;
        if (searchPanel && !searchPanel.hidden) renderResults(searchInput ? searchInput.value : '');
      })
      .catch(function () { searchData = []; searchLoading = false; });
  }

  function openSearch() {
    if (!searchPanel || !searchInput) return;
    loadIndex();
    searchPanel.hidden = false;
    searchWrap.classList.add('is-open');
    searchInput.setAttribute('aria-expanded', 'true');
    renderResults(searchInput.value);
  }

  function closeSearch() {
    if (!searchPanel || !searchInput) return;
    searchPanel.hidden = true;
    searchWrap.classList.remove('is-open');
    searchInput.setAttribute('aria-expanded', 'false');
    searchInput.removeAttribute('aria-activedescendant');
    resultItems().forEach(function (el) {
      el.classList.remove('is-active');
      el.setAttribute('aria-selected', 'false');
    });
    searchActiveIndex = -1;
  }

  function searchIsOpen() {
    return searchPanel && !searchPanel.hidden;
  }

  function initSearch() {
    if (!searchInput || !searchPanel || !searchWrap) return;

    var isMac = /Mac|iPhone|iPad/.test(navigator.platform || navigator.userAgent || '');
    if (searchKbd) searchKbd.textContent = isMac ? '\u2318K' : 'Ctrl K';

    searchInput.addEventListener('focus', openSearch);
    searchInput.addEventListener('input', function () { openSearch(); renderResults(searchInput.value); });

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
          renderResults('');
        }
      } else if (e.key === 'Tab') {
        closeSearch();
      }
    });

    searchResults.addEventListener('click', function (e) {
      if (e.target.closest('[data-search-item]')) closeSearch();
    });
    searchResults.addEventListener('mouseover', function (e) {
      var item = e.target.closest('[data-search-item]');
      if (!item) return;
      var i = visibleItems().indexOf(item);
      if (i !== -1) setActiveSearch(i);
    });

    document.addEventListener('click', function (e) {
      if (searchIsOpen() && !searchWrap.contains(e.target)) closeSearch();
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

    // Deep link: `/docs/?q=term` opens the overlay pre-filled. This is the
    // target of the WebSite SearchAction declared in the JSON-LD.
    var initialQuery = new URLSearchParams(window.location.search).get('q');
    if (initialQuery) {
      searchInput.value = initialQuery;
      openSearch();
    }
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
     Copy buttons on fenced code blocks (progressive enhancement)
     ========================================================= */

  var COPY_ICON = '<svg class="icon icon--copy" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>';
  var CHECK_ICON = '<svg class="icon icon--check" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>';

  function copyText(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve) {
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      try { document.execCommand('copy'); } catch (e) {}
      document.body.removeChild(ta);
      resolve();
    });
  }

  function decorateCodeBlocks() {
    var blocks = document.querySelectorAll('.docs-content pre');
    Array.prototype.forEach.call(blocks, function (pre) {
      if (pre.querySelector('.docs-copy')) return;
      var code = pre.querySelector('code');
      if (!code) return;
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'docs-copy';
      btn.setAttribute('data-action', 'copy');
      btn.setAttribute('aria-label', COPY_LABEL);
      btn.innerHTML = COPY_ICON + CHECK_ICON;
      btn.addEventListener('click', function () {
        copyText(code.textContent.replace(/\s+$/, '')).then(function () {
          btn.setAttribute('data-copied', 'true');
          btn.setAttribute('aria-label', COPIED_LABEL);
          setTimeout(function () {
            btn.removeAttribute('data-copied');
            btn.setAttribute('aria-label', COPY_LABEL);
          }, 2000);
        });
      });
      pre.appendChild(btn);
    });
  }

  /* =========================================================
     Scroll container for wide tables (progressive enhancement)
     ========================================================= */

  function decorateTables() {
    var tables = document.querySelectorAll('.docs-content table');
    Array.prototype.forEach.call(tables, function (table) {
      if (table.parentElement && table.parentElement.classList.contains('docs-table-wrap')) return;
      var wrap = document.createElement('div');
      wrap.className = 'docs-table-wrap';
      // Focusable so keyboard users can scroll a wide table (WCAG 2.1.1).
      wrap.setAttribute('tabindex', '0');
      table.parentNode.insertBefore(wrap, table);
      wrap.appendChild(table);
    });
  }

  /* =========================================================
     Init
     ========================================================= */

  function init() {
    updateThemeLabel();
    initSearch();
    initToc();
    revealSkillAnchor();
    decorateCodeBlocks();
    decorateTables();

    document.addEventListener('click', function (e) {
      var target = e.target.closest('[data-action]');
      if (!target) return;
      switch (target.getAttribute('data-action')) {
        case 'theme': toggleTheme(); break;
        case 'sidebar': toggleSidebar(); break;
      }
    });

    if (backdrop) backdrop.addEventListener('click', function () { closeSidebar(); });

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

    window.addEventListener('hashchange', revealSkillAnchor);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
