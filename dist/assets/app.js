// assets/app.js
'use strict';

(function () {
  // Message console
  console.log('%c✅ MyApp chargée avec succès!', 'color: #c74634; font-weight: bold; font-size: 14px;');

  // Mise à jour dynamique de l'année dans le footer
  var footerYear = document.getElementById('footer-year');
  if (footerYear) {
    footerYear.textContent = '© ' + new Date().getFullYear() + ' MyApp – Déployé sur GitHub Pages';
  }

  // Animation fade-in sur les cartes et tech-items
  var animated = document.querySelectorAll('.card, .tech-item');
  animated.forEach(function (el, i) {
    el.style.animationDelay = (i * 0.1) + 's';
    el.classList.add('fade-in');
  });

  // Lien actif dans la nav : détection automatique par URL
  var currentPage = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('nav a').forEach(function (link) {
    var href = link.getAttribute('href');
    if (href && href !== '#contact' && href.split('/').pop() === currentPage) {
      link.classList.add('active');
    } else {
      link.classList.remove('active');
    }
  });
})();

// Gestionnaire du formulaire de contact
function handleContact(e) {
  e.preventDefault();
  var confirm = document.getElementById('contact-confirm');
  if (confirm) {
    confirm.textContent = '✅ Message envoyé avec succès ! Nous vous répondrons rapidement.';
    e.target.reset();
  }
}
