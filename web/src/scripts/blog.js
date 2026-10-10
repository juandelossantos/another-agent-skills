/*
 * Another Agent Skills — blog enhancements.
 *
 * Progressive enhancement only: the article is fully readable without JS. This
 * adds a reading-progress bar and the "copy link" share button.
 */
(function () {
  'use strict';

  /* Reading progress: a thin bar that fills as the article scrolls. */
  function initProgress() {
    var bar = document.querySelector('[data-reading-progress]');
    var article = document.querySelector('.blog-prose');
    if (!bar || !article) return;

    function update() {
      var rect = article.getBoundingClientRect();
      var start = rect.top + window.scrollY;
      var total = article.offsetHeight - window.innerHeight;
      var p = total > 0 ? (window.scrollY - start + window.innerHeight * 0.2) / total : 0;
      p = Math.max(0, Math.min(1, p));
      bar.style.transform = 'scaleX(' + p + ')';
    }

    window.addEventListener('scroll', update, { passive: true });
    window.addEventListener('resize', update);
    update();
  }

  /* Share: copy the current URL, reporting success or falling back. */
  function initShare() {
    var buttons = document.querySelectorAll('[data-share-copy]');
    Array.prototype.forEach.call(buttons, function (btn) {
      var label = btn.querySelector('[data-share-label]');
      var original = label ? label.textContent : '';
      var copied = btn.getAttribute('data-copied-label') || 'Copied';

      function done() {
        btn.setAttribute('data-copied', 'true');
        if (label) label.textContent = copied;
        setTimeout(function () {
          btn.removeAttribute('data-copied');
          if (label) label.textContent = original;
        }, 2000);
      }

      function fallback() {
        var ta = document.createElement('textarea');
        ta.value = location.href;
        ta.style.position = 'fixed';
        ta.style.opacity = '0';
        document.body.appendChild(ta);
        ta.select();
        try { document.execCommand('copy'); } catch (e) {}
        document.body.removeChild(ta);
        done();
      }

      btn.addEventListener('click', function () {
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(location.href).then(done, fallback);
        } else {
          fallback();
        }
      });
    });
  }

  function init() {
    initProgress();
    initShare();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
