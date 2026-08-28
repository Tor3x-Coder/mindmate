// MindMate landing site behaviour: reads config.js and renders the
// config-dependent parts (APK download card, deletion-request actions).
// Deliberately tiny — no frameworks.
(function () {
  'use strict';

  var cfg = window.MINDMATE_LANDING || {};
  var identity = cfg.identity || { app: 'MindMate', team: 'Junior Achievers — FG Enugu (JA FGCE)' };

  // Footer identity on every page.
  var footers = document.querySelectorAll('[data-identity]');
  for (var i = 0; i < footers.length; i++) {
    footers[i].textContent = identity.app + ' by ' + identity.team;
  }

  // ---- APK download card -------------------------------------------------
  var downloadCard = document.getElementById('apk-card');
  if (downloadCard) {
    var apk = cfg.apk;
    if (apk && apk.url) {
      downloadCard.innerHTML =
        '<h2 class="card-title">Download the Android demo</h2>' +
        '<p class="card-body">Version ' + escapeHtml(apk.version || '') +
        (apk.sizeLabel ? ' · ' + escapeHtml(apk.sizeLabel) : '') +
        (apk.minAndroid ? ' · ' + escapeHtml(apk.minAndroid) : '') + '</p>' +
        '<p class="card-body">This is a direct APK download (sideload), not a ' +
        'Google Play listing. To install: download the file, open it on your ' +
        'phone, and allow "Install unknown apps" for your browser when asked.</p>' +
        '<p class="card-sha">SHA-256: <code>' + escapeHtml(apk.sha256 || 'not published yet') + '</code></p>' +
        '<a class="btn btn-primary" href="' + escapeHtml(apk.url) + '" rel="noopener">Download APK</a>';
    } else {
      downloadCard.innerHTML =
        '<h2 class="card-title">Download the Android demo</h2>' +
        '<p class="card-body">The signed release build is being prepared. ' +
        'This page will link the versioned release APK (with size and ' +
        'SHA-256 checksum) as soon as it is ready — it will never point to a ' +
        'debug build.</p>' +
        '<p class="card-body muted">Want early access to the competition demo? ' +
        'Ask the Junior Achievers team directly.</p>';
    }
  }

  // ---- Deletion-request actions ------------------------------------------
  var formAction = document.getElementById('delete-form-action');
  var mailAction = document.getElementById('delete-mail-action');
  var formNote = document.getElementById('delete-form-note');

  if (formAction) {
    if (cfg.deleteRequestFormUrl) {
      formAction.href = cfg.deleteRequestFormUrl;
      formAction.setAttribute('target', '_blank');
      formAction.setAttribute('rel', 'noopener');
    } else {
      // Until the hosted form URL is published, do not show a dead button.
      formAction.classList.add('is-hidden');
    }
  }

  if (mailAction) {
    if (cfg.supportEmail) {
      mailAction.href =
        'mailto:' + encodeURIComponent(cfg.supportEmail) +
        '?subject=' + encodeURIComponent('MindMate account deletion request');
    } else {
      mailAction.classList.add('is-hidden');
    }
  }

  if (formNote) {
    var ready = Boolean(cfg.deleteRequestFormUrl || cfg.supportEmail);
    formNote.classList.toggle('is-hidden', ready);
    if (!ready) {
      formNote.textContent =
        'The request form is being finalised. In the meantime, the team can be ' +
        'reached through the competition contact channels.';
    }
  }

  // ---- FAQ details (progressive enhancement) ------------------------------
  // <details> works without JS; nothing to do.

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }
})();
