// assets/app.js
'use strict';

(function () {

  // ── Annee footer ──────────────────────────────────────────────────────────
  var footerYear = document.getElementById('footer-year');
  if (footerYear) {
    footerYear.textContent = '\u00a9 ' + new Date().getFullYear() + ' MyApp \u2013 D\u00e9ploy\u00e9 sur GitHub Pages';
  }

  // ── Header scroll shadow ──────────────────────────────────────────────────
  var header = document.getElementById('header');
  window.addEventListener('scroll', function () {
    if (header) header.classList.toggle('scrolled', window.scrollY > 20);
  });

  // ── Active nav link au scroll ─────────────────────────────────────────────
  var sections = document.querySelectorAll('section[id]');
  var navLinks  = document.querySelectorAll('.nav-links a');
  function setActiveNav() {
    var scrollY = window.scrollY + 100;
    sections.forEach(function (section) {
      var top    = section.offsetTop;
      var bottom = top + section.offsetHeight;
      var id     = section.getAttribute('id');
      if (scrollY >= top && scrollY < bottom) {
        navLinks.forEach(function (a) {
          a.classList.toggle('active', a.getAttribute('href') === '#' + id);
        });
      }
    });
  }
  window.addEventListener('scroll', setActiveNav);
  setActiveNav();

  // ── Smooth scroll sur les liens nav ──────────────────────────────────────
  navLinks.forEach(function (link) {
    link.addEventListener('click', function (e) {
      var href = link.getAttribute('href');
      if (href && href.startsWith('#')) {
        e.preventDefault();
        var target = document.querySelector(href);
        if (target) target.scrollIntoView({ behavior: 'smooth' });
        // Fermer le menu mobile
        document.getElementById('navLinks').classList.remove('open');
        document.getElementById('navToggle').classList.remove('open');
      }
    });
  });

  // ── Menu hamburger ────────────────────────────────────────────────────────
  var toggle   = document.getElementById('navToggle');
  var navLinksEl = document.getElementById('navLinks');
  if (toggle) {
    toggle.addEventListener('click', function () {
      toggle.classList.toggle('open');
      navLinksEl.classList.toggle('open');
    });
  }

  // ── Reveal cards au scroll (Intersection Observer) ────────────────────────
  var cards = document.querySelectorAll('.card');
  if ('IntersectionObserver' in window) {
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          var el = entry.target;
          var delay = el.dataset.delay || 0;
          setTimeout(function () { el.classList.add('visible'); }, delay);
          observer.unobserve(el);
        }
      });
    }, { threshold: 0.15 });
    cards.forEach(function (card, i) {
      card.dataset.delay = i * 100;
      observer.observe(card);
    });
  } else {
    cards.forEach(function (card) { card.classList.add('visible'); });
  }

})();

// ── Formulaire de contact ─────────────────────────────────────────────────
function handleContact(e) {
  e.preventDefault();
  var form    = document.getElementById('contactForm');
  var success = document.getElementById('contactSuccess');
  if (form && success) {
    form.classList.add('hide');
    success.classList.add('show');
  }
}

function resetForm() {
  var form    = document.getElementById('contactForm');
  var success = document.getElementById('contactSuccess');
  if (form && success) {
    form.reset();
    success.classList.remove('show');
    form.classList.remove('hide');
  }
}
