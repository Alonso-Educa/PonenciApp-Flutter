/* Toggle FAQ */
function toggleFaq(btn) {
  var item = btn.parentElement;
  var wasOpen = item.classList.contains('open');
  // cierra todos
  document.querySelectorAll('.faq-item.open').forEach(function (el) {
    el.classList.remove('open');
  });
  // abre el clickado (si estaba cerrado)
  if (!wasOpen) item.classList.add('open');
}

/* Switch role tabs */
function switchRole(role) {
  // tabs
  document.querySelectorAll('.role-tab').forEach(function (tab) {
    tab.classList.remove('active');
    tab.setAttribute('aria-selected', 'false');
  });
  event.currentTarget.classList.add('active');
  event.currentTarget.setAttribute('aria-selected', 'true');

  // contenido
  document.querySelectorAll('.role-content').forEach(function (el) {
    el.classList.remove('active');
  });
  document.getElementById('role-' + role).classList.add('active');
}

/* Nav toggle mobile */
function toggleNav() {
  document.getElementById('navLinks').classList.toggle('open');
}

/* Cierra nav al hacer click en un link (mobile) */
document.querySelectorAll('.navbar-links a').forEach(function (link) {
  link.addEventListener('click', function () {
    document.getElementById('navLinks').classList.remove('open');
  });
});
