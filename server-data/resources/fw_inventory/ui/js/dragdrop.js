/* ============================================================
   fw_inventory | ui/js/dragdrop.js
   Système drag & drop natif HTML5 + custom ghost
   Supporte : player ↔ context ↔ hotbar
   ============================================================ */

'use strict';

const ghost     = document.getElementById('drag-ghost');
const ghostImg  = document.getElementById('drag-ghost-img');

// État du drag courant
let dragState = null;
// { invType, slotIndex, itemName, itemData, slotData, amount, sourceEl }

// ─── INITIALISATION ────────────────────────────────────────
function initDragDrop() {
    document.addEventListener('mousemove', onDragMove);
    document.addEventListener('mouseup',   onDragEnd);
}

// ─── DÉMARRER UN DRAG ──────────────────────────────────────
function startDrag(el, invType, slotIndex, itemName, itemData, slotData) {
    if (!itemName) return;

    dragState = { invType, slotIndex, itemName, itemData, slotData, sourceEl: el };

    el.classList.add('dragging');

    // Afficher le ghost
    ghostImg.src = getItemImage(itemData.image || itemName);
    ghost.style.display = 'flex';

    // Curseur
    document.body.style.cursor = 'grabbing';
}

// ─── DÉPLACEMENT ───────────────────────────────────────────
function onDragMove(e) {
    if (!dragState) return;
    ghost.style.left = e.clientX + 'px';
    ghost.style.top  = e.clientY + 'px';
    highlightDropTarget(e);
}

// ─── FIN DU DRAG ───────────────────────────────────────────
function onDragEnd(e) {
    if (!dragState) return;

    const target = getDropTarget(e.clientX, e.clientY);

    ghost.style.display = 'none';
    document.body.style.cursor = '';
    dragState.sourceEl.classList.remove('dragging');
    clearDropHighlights();

    if (target) {
        processDrop(target);
    }

    dragState = null;
}

// ─── TROUVER LE SLOT DE DESTINATION ────────────────────────
function getDropTarget(x, y) {
    const elements = document.elementsFromPoint(x, y);
    for (const el of elements) {
        if (el.classList.contains('inv-slot') || el.classList.contains('hotbar-slot')) {
            return el;
        }
    }
    return null;
}

// ─── HIGHLIGHT DU SLOT CIBLE ───────────────────────────────
function highlightDropTarget(e) {
    clearDropHighlights();
    const target = getDropTarget(e.clientX, e.clientY);
    if (!target || !dragState) return;

    const toType  = target.closest('[data-inv]')?.dataset.inv;
    const toSlot  = parseInt(target.dataset.slot);

    // Vérifier si le drop est valide
    if (isValidDrop(dragState.invType, dragState.slotIndex, toType, toSlot)) {
        target.classList.add('drag-over');
    } else {
        target.classList.add('drag-over-invalid');
    }
}

function clearDropHighlights() {
    document.querySelectorAll('.drag-over, .drag-over-invalid').forEach(el => {
        el.classList.remove('drag-over', 'drag-over-invalid');
    });
}

// ─── VALIDER UN DROP ───────────────────────────────────────
function isValidDrop(fromType, fromSlot, toType, toSlot) {
    if (!toType || !toSlot) return false;
    if (fromType === toType && fromSlot === toSlot) return false;
    return true;
}

// ─── TRAITER LE DROP ───────────────────────────────────────
async function processDrop(targetEl) {
    const toType  = targetEl.closest('[data-inv]')?.dataset.inv;
    const toSlot  = parseInt(targetEl.dataset.slot);

    if (!isValidDrop(dragState.invType, dragState.slotIndex, toType, toSlot)) return;

    const fromType  = dragState.invType;
    const fromSlot  = dragState.slotIndex;
    const fromItem  = dragState.slotData;
    const maxAmount = fromItem.amount || 1;

    // Si stack > 1 → demander la quantité
    let amount = maxAmount;
    if (maxAmount > 1) {
        amount = await openQtyModal(`Déplacer ${dragState.itemData?.label || dragState.itemName}`, maxAmount);
        if (!amount) return; // Annulé
    }

    // Construire les identifiants d'inventaire
    const fromOwner = getInventoryOwner(fromType);
    const toOwner   = getInventoryOwner(toType);

    nuiPost('moveItem', {
        fromOwner,
        fromType: normalizeType(fromType),
        fromSlot,
        toOwner,
        toType: normalizeType(toType),
        toSlot,
        amount,
    });
}

// ─── MAPPING TYPE → OWNER ──────────────────────────────────
function getInventoryOwner(invType) {
    if (invType === 'player' || invType === 'hotbar') return window.INV_PLAYER_ID || 'player';
    if (invType === 'context') return window.INV_CONTEXT_OWNER || 'context';
    return invType;
}

function normalizeType(invType) {
    if (invType === 'hotbar') return 'player'; // Hotbar = sous-ensemble de l'inventaire joueur
    if (invType === 'context') return window.INV_CONTEXT_TYPE || 'drop';
    return invType;
}

// ─── ATTACHER LES LISTENERS À UN SLOT ─────────────────────
function attachSlotDragListeners(slotEl, invType, slotIndex, itemName, itemData, slotData) {
    // Nettoyer les anciens listeners
    const newEl = slotEl.cloneNode(true);
    slotEl.parentNode.replaceChild(newEl, slotEl);

    if (!itemName) return newEl;

    newEl.addEventListener('mousedown', e => {
        if (e.button !== 0) return; // Seulement clic gauche
        e.preventDefault();
        startDrag(newEl, invType, slotIndex, itemName, itemData, slotData);
    });

    return newEl;
}

initDragDrop();
