// assets/app.js
'use strict';

(function () {
  // Affiche un message de bienvenue dans la console
  console.log('%c✅ Application chargée avec succès sur OCI!', 'color: #c74634; font-weight: bold; font-size: 14px;');

  // Affichage dynamique de la date de déploiement
  const footer = document.querySelector('footer p');
  if (footer) {
    const year = new Date().getFullYear();
    footer.textContent = `© ${year} MyApp – Déployé sur OCI avec Terraform`;
  }

  // Animation légère sur les cartes
  const cards = document.querySelectorAll('.card');
  cards.forEach(function (card, i) {
    card.style.animationDelay = (i * 0.1) + 's';
    card.classList.add('fade-in');
  });
})();
