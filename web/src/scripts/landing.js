/*
 * Another Agent Skills — landing enhancements.
 * Progressive enhancement only: all content is visible by default; this script
 * adds motion and the theme toggle. It never hides content when JS is off or
 * when `prefers-reduced-motion` is set.
 *
 * Ported from docs/mockups/phase10/js/mockup.js (approved Phase 10 mockup).
 * i18n is handled by real EN/ES routes, so there is no client-side text swap.
 */
(function () {
  'use strict';

  var doc = document.documentElement;
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* =========================================================
     Theme
     ========================================================= */

  function updateThemeLabel() {
    var btn = document.querySelector('[data-action="theme"]');
    if (!btn) return;
    var theme = doc.getAttribute('data-theme') || 'dark';
    var text = btn.querySelector('[data-theme-text]');
    var dark = btn.getAttribute('data-theme-dark') || 'Dark';
    var light = btn.getAttribute('data-theme-light') || 'Light';
    // The label names the mode you would switch TO, not the current one.
    if (text) text.textContent = theme === 'dark' ? light : dark;
    // aria-pressed reflects the actual current state (light theme active).
    btn.setAttribute('aria-pressed', theme === 'light' ? 'true' : 'false');
  }

  function toggleTheme() {
    var next = doc.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    doc.setAttribute('data-theme', next);
    try { localStorage.setItem('aas-theme', next); } catch (e) {}
    updateThemeLabel();
  }

  /* =========================================================
     Terminal animation (hero)
     ========================================================= */

  function initTerminal() {
    var terminal = document.querySelector('[data-terminal]');
    if (!terminal) return;

    var lines = terminal.querySelector('[data-terminal-lines]');
    var output = terminal.querySelector('[data-terminal-output]');
    if (!lines || !output) return;

    if (reduceMotion) { terminal.setAttribute('data-done', 'true'); return; }

    // Read the localized commands from the static markup (single source of truth),
    // then re-type them for the animation.
    var commands = Array.prototype.map.call(lines.querySelectorAll('.terminal__tline'), function (line) {
      var typing = line.querySelector('.terminal__typing');
      return { text: typing ? typing.textContent : '', soon: !!line.querySelector('.terminal__soon') };
    });
    if (!commands.length) return;

    var outLines = output.querySelectorAll('.terminal__out-line');
    var soonLabel = (terminal.querySelector('.terminal__soon') || {}).textContent || 'soon';

    function showOutput() {
      output.hidden = false;
      Array.prototype.forEach.call(outLines, function (line, i) {
        line.style.opacity = '0';
        setTimeout(function () {
          line.style.opacity = '1';
          if (i === outLines.length - 1) terminal.setAttribute('data-done', 'true');
        }, (i + 1) * 360);
      });
    }

    function typeCommand(index) {
      if (index >= commands.length) { showOutput(); return; }
      var cmd = commands[index];
      var line = document.createElement('div');
      line.className = 'terminal__tline';
      line.innerHTML = '<span class="terminal__prompt">~ $</span><span class="terminal__typing" tabindex="0"></span>' +
        (cmd.soon ? '<span class="terminal__soon">' + soonLabel + '</span>' : '') +
        '<span class="terminal__cursor">\u258a</span>';
      lines.appendChild(line);

      var typing = line.querySelector('.terminal__typing');
      var cursor = line.querySelector('.terminal__cursor');
      var i = 0;
      (function typeChar() {
        if (i < cmd.text.length) {
          typing.textContent += cmd.text.charAt(i);
          i++;
          setTimeout(typeChar, 16);
        } else {
          cursor.remove();
          setTimeout(function () { typeCommand(index + 1); }, 420);
        }
      })();
    }

    lines.innerHTML = '';
    output.hidden = true;

    whenVisible(terminal, function () {
      setTimeout(function () { typeCommand(0); }, 400);
    });
  }

  /* =========================================================
     Flow animation
     ========================================================= */

  function initFlow() {
    var flow = document.querySelector('[data-flow]');
    if (!flow) return;
    var nodes = flow.querySelectorAll('.flow__node');

    function finish() {
      flow.setAttribute('data-state', 'run');
      Array.prototype.forEach.call(nodes, function (n) { n.classList.add('is-lit'); });
    }

    if (reduceMotion) { finish(); return; }

    flow.setAttribute('data-state', 'ready');

    whenVisible(flow, function () {
      flow.setAttribute('data-state', 'run');
      Array.prototype.forEach.call(nodes, function (node, i) {
        setTimeout(function () { node.classList.add('is-lit'); }, i * 170 + 90);
      });
    });
  }

  /* =========================================================
     Harness animation
     ========================================================= */

  function initHarness() {
    var harness = document.querySelector('[data-harness]');
    if (!harness) return;
    if (reduceMotion) return; // static state already shows the block

    var packet = harness.querySelector('[data-packet]');
    var guardrails = harness.querySelector('[data-guardrails]');
    var layers = harness.querySelectorAll('.harness__layer');
    if (!packet || !guardrails || !layers.length) return;

    harness.setAttribute('data-state', 'ready');

    function sleep(ms) { return new Promise(function (r) { setTimeout(r, ms); }); }

    function packetY(layer) {
      var y = layer.offsetTop + layer.offsetHeight / 2 - packet.offsetHeight / 2;
      return Math.max(0, y);
    }

    function moveTo(layer) {
      packet.style.transform = 'translate(-50%, ' + packetY(layer) + 'px)';
    }

    whenVisible(harness, function () {
      requestAnimationFrame(function () {
        moveTo(layers[0]);
        (async function run() {
          await sleep(500);
          for (var i = 1; i <= 4; i++) {
            moveTo(layers[i]);
            await sleep(620);
          }
          packet.classList.add('is-blocked');
          guardrails.classList.add('is-caught');
          await sleep(500);
          harness.setAttribute('data-state', 'run');
        })();
      });
    });
  }

  /* =========================================================
     Loop animation
     ========================================================= */

  function initLoop() {
    var ring = document.querySelector('[data-loop-ring]');
    if (!ring) return;
    if (reduceMotion) return; // counters stay at final values

    var found = document.querySelector('[data-loop-found]');
    var fixed = document.querySelector('[data-loop-fixed]');
    var stops = ring.querySelectorAll('[data-loop-stop]');
    var steps = document.querySelectorAll('.step');

    function setActive(i) {
      Array.prototype.forEach.call(stops, function (s, j) { s.classList.toggle('is-active', j === i); });
      Array.prototype.forEach.call(steps, function (s, j) { s.classList.toggle('is-active', j === i); });
    }

    whenVisible(ring, function () {
      ring.classList.add('is-running');
      var target = 12, dur = 9000, start = null;
      function tick(now) {
        if (start === null) start = now;
        var p = Math.min((now - start) / dur, 1);
        var v = Math.round(p * target);
        if (found) found.textContent = String(v);
        if (fixed) fixed.textContent = String(v);
        setActive(Math.floor(p * 10) % 5);
        if (p < 1) {
          requestAnimationFrame(tick);
        } else {
          if (found) found.textContent = String(target);
          if (fixed) fixed.textContent = String(target);
          setActive(-1);
        }
      }
      requestAnimationFrame(tick);
    });
  }

  /* =========================================================
     Shared: run once when an element scrolls into view
     ========================================================= */

  function whenVisible(el, cb) {
    if (!('IntersectionObserver' in window)) { cb(); return; }
    var obs = new IntersectionObserver(function (entries) {
      if (entries[0].isIntersecting) {
        obs.disconnect();
        cb();
      }
    }, { threshold: 0.25 });
    obs.observe(el);
  }

  /* =========================================================
     Scroll reveals
     ========================================================= */

  function initReveals() {
    var els = document.querySelectorAll('[data-reveal]');
    if (!els.length) return;
    if (reduceMotion || !('IntersectionObserver' in window)) {
      Array.prototype.forEach.call(els, function (el) { el.setAttribute('data-revealed', 'true'); });
      return;
    }
    var obs = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.setAttribute('data-revealed', 'true');
          obs.unobserve(entry.target);
        }
      });
    }, { rootMargin: '0px 0px -10% 0px' });
    Array.prototype.forEach.call(els, function (el) { obs.observe(el); });
  }

  /* =========================================================
     Copy command
     ========================================================= */

  function copyCommand(btn) {
    var wrap = btn.closest('.command');
    var code = wrap ? wrap.querySelector('.command__code') : null;
    if (!code) return;
    var text = code.textContent.trim();

    function done() {
      btn.setAttribute('data-copied', 'true');
      setTimeout(function () { btn.removeAttribute('data-copied'); }, 2000);
    }

    function fallback() {
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

    if (navigator.clipboard && navigator.clipboard.writeText) {
      // Only show "copied" on success; on failure fall back to execCommand
      // instead of reporting a false success.
      navigator.clipboard.writeText(text).then(done, fallback);
    } else {
      fallback();
    }
  }

  /* =========================================================
     Mobile menu
     ========================================================= */

  function toggleMenu(btn) {
    var menu = document.querySelector('[data-mobile-menu]');
    if (!menu) return;
    var open = menu.getAttribute('aria-hidden') === 'true';
    menu.setAttribute('aria-hidden', open ? 'false' : 'true');
    btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    if (open) {
      var first = menu.querySelector('a');
      if (first) setTimeout(function () { first.focus(); }, 60);
    } else {
      btn.focus();
    }
  }

  function closeMenu() {
    var menu = document.querySelector('[data-mobile-menu]');
    var btn = document.querySelector('[data-action="menu"]');
    if (!menu || !btn) return;
    menu.setAttribute('aria-hidden', 'true');
    btn.setAttribute('aria-expanded', 'false');
  }

  /* =========================================================
     Init
     ========================================================= */

  function init() {
    doc.setAttribute('data-anim', 'on');
    updateThemeLabel();

    initTerminal();
    initFlow();
    initHarness();
    initLoop();
    initReveals();

    document.addEventListener('click', function (e) {
      var target = e.target.closest('[data-action]');
      if (!target) return;
      switch (target.getAttribute('data-action')) {
        case 'theme': toggleTheme(); break;
        case 'copy': copyCommand(target); break;
        case 'menu': toggleMenu(target); break;
      }
    });

    document.addEventListener('click', function (e) {
      if (e.target.closest('.header__mobile-links a')) closeMenu();
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') {
        var menu = document.querySelector('[data-mobile-menu]');
        if (menu && menu.getAttribute('aria-hidden') === 'false') closeMenu();
      }
      if (e.key !== 'Tab') return;
      var menu = document.querySelector('[data-mobile-menu]');
      if (!menu || menu.getAttribute('aria-hidden') !== 'false') return;
      var links = menu.querySelectorAll('a');
      if (!links.length) return;
      var first = links[0], last = links[links.length - 1];
      if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
      else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
