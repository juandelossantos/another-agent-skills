(function() {
  'use strict';

  var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* -----------------------------------------
     IntersectionObserver scroll reveals
     ----------------------------------------- */

  function initReveals() {
    var els = document.querySelectorAll('[data-reveal]');
    if (!els.length) return;

    if ('IntersectionObserver' in window) {
      var observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
          if (entry.isIntersecting) {
            entry.target.setAttribute('data-revealed', 'true');
            observer.unobserve(entry.target);
          }
        });
      }, {
        threshold: 0.1,
        rootMargin: '0px 0px -40px 0px'
      });

      Array.prototype.forEach.call(els, function(el) {
        observer.observe(el);
      });
    } else {
      Array.prototype.forEach.call(els, function(el) {
        el.setAttribute('data-revealed', 'true');
      });
    }
  }

  /* -----------------------------------------
      Lifecycle flow stagger
      ----------------------------------------- */

  function initLifecycleStagger() {
    var flow = document.querySelector('.lifecycle-flow');
    var items = flow ? flow.querySelectorAll('.lifecycle-flow__inner > *') : null;
    if (!items || !items.length) return;

    var done = false;

    function runStagger() {
      if (done) return;
      done = true;
      Array.prototype.forEach.call(items, function(el, i) {
        if (reduced) {
          el.setAttribute('data-visible', 'true');
        } else {
          setTimeout(function() {
            el.setAttribute('data-visible', 'true');
            if (i === items.length - 1) {
              setTimeout(revealActions, 200);
            }
          }, i * 80);
        }
      });
      if (reduced) revealActions();
    }

    document.addEventListener('lifecycle-start', runStagger);
  }

  /* -----------------------------------------
      Actions reveal (after lifecycle)
      ----------------------------------------- */

  function revealActions() {
    var label = document.querySelector('.hero__actions-label');
    var actions = document.querySelector('.hero__actions');
    var social = document.querySelector('.hero__social');
    if (label) {
      label.style.opacity = '1';
      label.style.transform = 'translateY(0)';
    }
    if (actions) {
      actions.style.opacity = '1';
      actions.style.transform = 'translateY(0)';
    }
    if (social) {
      social.style.opacity = '1';
      social.style.transform = 'translateY(0)';
    }
  }

  /* -----------------------------------------
      Terminal glow on DONE
      ----------------------------------------- */

  function initTerminalGlow() {
    document.addEventListener('lifecycle-start', function() {
      var terminal = document.querySelector('[data-terminal]');
      if (terminal) {
        terminal.setAttribute('data-done', 'true');
      }
    });
  }

  /* -----------------------------------------
     Init
     ----------------------------------------- */

  function init() {
    initReveals();
    initLifecycleStagger();
    initTerminalGlow();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
