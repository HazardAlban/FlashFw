/* ============================================================
   fw_inventory | ui/js/utils.js
   Fonctions utilitaires partagées
   ============================================================ */

'use strict';

// ─── COMMUNICATION NUI ─────────────────────────────────────
function nuiPost(action, data = {}) {
    return fetch(`https://fw_inventory/${action}`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body:    JSON.stringify(data),
    }).catch(() => {});
}

// ─── FORMATAGE POIDS ───────────────────────────────────────
function formatWeight(grams) {
    if (grams >= 1000) return (grams / 1000).toFixed(1) + ' kg';
    return grams + ' g';
}

// ─── FORMATAGE ARGENT ──────────────────────────────────────
function formatCash(amount) {
    return new Intl.NumberFormat('fr-FR').format(amount) + ' $';
}

// ─── CLAMP ─────────────────────────────────────────────────
function clamp(val, min, max) {
    return Math.min(Math.max(val, min), max);
}

// ─── PROFONDEUR D'OBJET (copie) ────────────────────────────
function deepClone(obj) {
    return JSON.parse(JSON.stringify(obj));
}

// ─── GET IMAGE URL ─────────────────────────────────────────
function getItemImage(imageName) {
    return `img/${imageName}.png`;
}

// ─── NOTIFICATIONS ─────────────────────────────────────────
const notifContainer = document.getElementById('notifications');

function showNotification(type = 'info', message = '', icon = '') {
    const notif = document.createElement('div');
    notif.className = `notif ${type}`;

    const iconClass = icon || defaultIconForType(type);

    notif.innerHTML = `
        <i class="fa-solid ${iconClass}"></i>
        <span class="notif-msg">${message}</span>
    `;

    notifContainer.prepend(notif);

    setTimeout(() => {
        notif.classList.add('removing');
        setTimeout(() => notif.remove(), 300);
    }, 3500);
}

function defaultIconForType(type) {
    const icons = {
        success: 'fa-check-circle',
        error:   'fa-circle-xmark',
        warning: 'fa-triangle-exclamation',
        info:    'fa-circle-info',
    };
    return icons[type] || 'fa-circle-info';
}

// ─── TOOLTIP ───────────────────────────────────────────────
const tooltip = document.getElementById('inv-tooltip');
const ttName  = document.getElementById('tt-name');
const ttDesc  = document.getElementById('tt-desc');
const ttMeta  = document.getElementById('tt-meta');
const ttDur   = document.getElementById('tt-durability');
const ttDurFill = document.getElementById('tt-durability-fill');

let tooltipTimeout = null;

function showTooltip(itemData, slotData, x, y) {
    if (!itemData) { hideTooltip(); return; }

    ttName.textContent = itemData.label || slotData.name;
    ttDesc.textContent = itemData.description || '';
    ttMeta.innerHTML   = '';

    // Métadonnées clés
    const meta = slotData.metadata || {};

    appendMetaRow('Poids',    formatWeight(itemData.weight || 0));
    if (slotData.amount > 1) appendMetaRow('Quantité', slotData.amount);
    if (meta.serial)          appendMetaRow('Série', meta.serial);
    if (meta.ammo !== undefined) appendMetaRow('Munitions', meta.ammo);
    if (meta.uses !== undefined) appendMetaRow('Utilisations', meta.uses);
    if (meta.channel !== undefined) appendMetaRow('Canal', meta.channel);

    // Barre de durabilité
    if (meta.durability !== undefined) {
        const dur = clamp(meta.durability, 0, 100);
        ttDur.classList.remove('hidden');
        ttDurFill.style.width = dur + '%';
        ttDurFill.style.background = dur > 50 ? 'var(--accent)' : dur > 20 ? 'var(--warning)' : 'var(--danger)';
        appendMetaRow('Durabilité', dur + '%');
    } else {
        ttDur.classList.add('hidden');
    }

    positionTooltip(x, y);
    tooltip.classList.add('show');
}

function appendMetaRow(label, value) {
    const row = document.createElement('div');
    row.className = 'tooltip-meta-row';
    row.innerHTML = `<span>${label}</span><span>${value}</span>`;
    ttMeta.appendChild(row);
}

function hideTooltip() {
    tooltip.classList.remove('show');
}

function positionTooltip(x, y) {
    const tw = 240, th = 200;
    const wx = window.innerWidth, wy = window.innerHeight;

    let tx = x + 14;
    let ty = y + 14;

    if (tx + tw > wx) tx = x - tw - 14;
    if (ty + th > wy) ty = y - th - 14;

    tooltip.style.left = tx + 'px';
    tooltip.style.top  = ty + 'px';
}

// ─── MODAL QUANTITÉ ────────────────────────────────────────
const qtyModal    = document.getElementById('qty-modal');
const qtyTitle    = document.getElementById('qty-title');
const qtyValue    = document.getElementById('qty-value');
const qtyMaxLabel = document.getElementById('qty-max-label');
const qtyConfirm  = document.getElementById('qty-confirm');
const qtyCancel   = document.getElementById('qty-cancel');
const qtyPlus     = document.getElementById('qty-plus');
const qtyMinus    = document.getElementById('qty-minus');

let qtyResolve = null;

function openQtyModal(title, max) {
    return new Promise(resolve => {
        qtyResolve     = resolve;
        qtyTitle.textContent    = title;
        qtyMaxLabel.textContent = `Max : ${max}`;
        qtyValue.max            = max;
        qtyValue.value          = 1;
        qtyModal.classList.remove('hidden');
        qtyValue.focus();
    });
}

function closeQtyModal(confirmed) {
    const val = parseInt(qtyValue.value) || 1;
    qtyModal.classList.add('hidden');
    if (qtyResolve) qtyResolve(confirmed ? clamp(val, 1, parseInt(qtyValue.max)) : null);
    qtyResolve = null;
}

qtyConfirm.addEventListener('click', () => closeQtyModal(true));
qtyCancel.addEventListener('click',  () => closeQtyModal(false));
qtyPlus.addEventListener('click',    () => { qtyValue.value = clamp(parseInt(qtyValue.value) + 1, 1, parseInt(qtyValue.max)); });
qtyMinus.addEventListener('click',   () => { qtyValue.value = clamp(parseInt(qtyValue.value) - 1, 1, parseInt(qtyValue.max)); });
qtyValue.addEventListener('keydown', e => {
    if (e.key === 'Enter')  closeQtyModal(true);
    if (e.key === 'Escape') closeQtyModal(false);
});
