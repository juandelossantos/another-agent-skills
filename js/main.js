(function() {
  'use strict';

  var doc = document.documentElement;

  /* -----------------------------------------
     Theme toggle
     ----------------------------------------- */

  function setTheme(theme) {
    doc.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);
    var btn = document.querySelector('[data-action="theme"]');
    if (btn) btn.textContent = theme === 'dark' ? '☾' : '☀';
  }

  function toggleTheme() {
    var current = doc.getAttribute('data-theme');
    setTheme(current === 'dark' ? 'light' : 'dark');
  }

  /* -----------------------------------------
     Language toggle
     ----------------------------------------- */

  var currentLang = doc.getAttribute('lang') || 'en';
  var translations = {};

  function loadLang(lang) {
    var path = 'i18n/' + lang + '.json?v=' + Date.now();
    fetch(path, { cache: 'no-store' })
      .then(function(r) { return r.json(); })
      .then(function(data) {
        translations = data;
        applyLang(lang);
      })
      .catch(function() {
        if (lang !== 'en') {
          loadLang('en');
        }
      });
  }

  function applyLang(lang) {
    doc.setAttribute('lang', lang);
    localStorage.setItem('lang', lang);
    currentLang = lang;

    var btn = document.querySelector('[data-action="lang"]');
    if (btn) btn.textContent = lang === 'en' ? 'ES' : 'EN';

    var els = document.querySelectorAll('[data-i18n]');
    Array.prototype.forEach.call(els, function(el) {
      var key = el.getAttribute('data-i18n');
      var val = getNested(translations, key);
      if (val) {
        if (el.hasAttribute('data-i18n-html')) {
          el.innerHTML = val;
        } else {
          el.textContent = val;
        }
      }
    });
  }

  function toggleLang() {
    var next = currentLang === 'en' ? 'es' : 'en';
    loadLang(next);
  }

  function getNested(obj, path) {
    return path.split('.').reduce(function(o, k) { return o && o[k] !== undefined ? o[k] : null; }, obj);
  }

  /* -----------------------------------------
     Terminal typing animation
     ----------------------------------------- */

  function initTerminal() {
    var terminal = document.querySelector('[data-terminal]');
    if (!terminal) return;

    var linesContainer = terminal.querySelector('[data-terminal-lines]');
    var outputEl = terminal.querySelector('[data-terminal-output]');
    var outLines = outputEl.querySelectorAll('.terminal__out-line');

    var commands = [
      'git clone https://github.com/juandelossantos/another-agent-skills.git',
      'cd another-agent-skills',
      'bash install.sh'
    ];

    var cmdIndex = 0;
    var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    function showOutput() {
      outputEl.style.display = 'block';
      var totalLines = outLines.length;
      Array.prototype.forEach.call(outLines, function(line, i) {
        setTimeout(function() {
          line.style.opacity = '1';
          if (i === totalLines - 1) {
            setTimeout(function() {
              document.dispatchEvent(new CustomEvent('lifecycle-start'));
            }, 400);
          }
        }, (i + 1) * 400);
      });
    }

    function typeCommand(index) {
      if (index >= commands.length) { showOutput(); return; }

      var line = document.createElement('div');
      line.className = 'terminal__tline';
      line.innerHTML = '<span class="terminal__prompt">~ $</span><span class="terminal__typing"></span><span class="terminal__cursor">▊</span>';
      linesContainer.appendChild(line);

      var typing = line.querySelector('.terminal__typing');
      var cursor = line.querySelector('.terminal__cursor');
      var text = commands[index];
      var charIndex = 0;

      function typeChar() {
        if (charIndex < text.length) {
          typing.textContent += text[charIndex];
          charIndex++;
          setTimeout(typeChar, reduced ? 0 : 40);
        } else {
          cursor.style.display = 'none';
          setTimeout(function() { typeCommand(index + 1); }, reduced ? 50 : 300);
        }
      }

      typeChar();
    }

    // Remove static initial line, JS creates all lines
    linesContainer.innerHTML = '';

    if (reduced) {
      commands.forEach(function(cmd) {
        var l = document.createElement('div');
        l.className = 'terminal__tline';
        l.innerHTML = '<span class="terminal__prompt">~ $</span><span class="terminal__typing"></span>';
        l.querySelector('.terminal__typing').textContent = cmd;
        linesContainer.appendChild(l);
      });
      showOutput();
      return;
    }

    if ('IntersectionObserver' in window) {
      var observer = new IntersectionObserver(function(entries) {
        if (entries[0].isIntersecting) {
          setTimeout(function() { typeCommand(0); }, 600);
          observer.unobserve(terminal);
        }
      }, { threshold: 0.3 });
      observer.observe(terminal);
    } else {
      setTimeout(function() { typeCommand(0); }, 600);
    }
  }

  function copyCommand(btn) {
    var code = btn.parentElement.querySelector('.hero__code, code');
    if (!code) return;

    var text = code.textContent.replace('❯ ', '');

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(function() {
        flashCopied(btn);
      });
    } else {
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
      flashCopied(btn);
    }
  }

  function flashCopied(btn) {
    btn.setAttribute('data-copied', 'true');
    setTimeout(function() {
      btn.removeAttribute('data-copied');
    }, 2000);
  }

  /* -----------------------------------------
     Mobile menu
     ----------------------------------------- */

  function toggleMenu(btn) {
    var menu = document.querySelector('[data-mobile-menu]');
    if (!menu) return;
    var open = menu.getAttribute('aria-hidden') === 'true';
    menu.setAttribute('aria-hidden', open ? 'false' : 'true');
    btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    btn.textContent = open ? '✕' : '☰';
    document.body.style.overflow = open ? 'hidden' : '';
    if (open) {
      var first = menu.querySelector('a');
      if (first) setTimeout(function() { first.focus(); }, 100);
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
    btn.textContent = '☰';
    document.body.style.overflow = '';
    btn.focus();
  }

  /* -----------------------------------------
     Init
     ----------------------------------------- */

  function init() {
    loadLang(currentLang);
    initTerminal();

    document.addEventListener('click', function(e) {
      var target = e.target.closest('[data-action]');
      if (!target) return;

      var action = target.getAttribute('data-action');

      switch (action) {
        case 'theme':
          toggleTheme();
          break;
        case 'lang':
          toggleLang();
          break;
        case 'copy':
          copyCommand(target);
          break;
        case 'menu':
          toggleMenu(target);
          break;
      }
    });

    // Close menu on nav link click
    document.addEventListener('click', function(e) {
      var link = e.target.closest('.header__mobile-links a');
      if (link) closeMenu();
    });

    // Focus trap in mobile menu
    document.addEventListener('keydown', function(e) {
      if (e.key !== 'Tab') return;
      var menu = document.querySelector('[data-mobile-menu]');
      if (!menu || menu.getAttribute('aria-hidden') !== 'false') return;
      var links = menu.querySelectorAll('a');
      if (!links.length) return;
      var first = links[0];
      var last = links[links.length - 1];
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
