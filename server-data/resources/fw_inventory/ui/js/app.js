/* ============================================================
   fw_inventory | ui/js/app.js
   Cerveau de l'UI : réception NUI, rendu slots, actions
   ============================================================ */

'use strict';

// ─── ÉTAT GLOBAL ───────────────────────────────────────────
let STATE = {
    open:           false,
    player:         null,   // { slots, maxSlots, weight, maxWeight, cash }
    context:        null,   // { type, slots, label, maxSlots, dropId, vehicleId }
    itemsCatalog:   {},     // catalogue complet { [name]: itemData }
    selectedSlot:   null,   // { invType, slotIndex, itemName, slotData }
    hotbarCount:    5,
    actionMode:     null,   // 'give' | 'drop' | 'use'
};

// Variables globales partagées avec dragdrop.js
window.INV_PLAYER_ID      = 'player';
window.INV_CONTEXT_OWNER  = 'context';
window.INV_CONTEXT_TYPE   = 'drop';

// ─── RÉCEPTION DES MESSAGES NUI ────────────────────────────
window.addEventListener('message', e => {
    const { action } = e.data;

    switch (action) {

        case 'openInventory':
            openInventory(e.data);
            break;

        case 'closeInventory':
            closeInventoryUI();
            break;

        case 'syncPlayer':
            if (STATE.player) {
                STATE.player.slots  = e.data.slots  || {};
                STATE.player.weight = e.data.weight || 0;
                renderPlayerSlots();
                renderWeightBar();
                refreshHotbarFromPlayer(STATE.player.slots, STATE.itemsCatalog);
            }
            break;

        case 'syncContext':
            if (STATE.context) {
                STATE.context.slots = e.data.slots || {};
                renderContextSlots();
            }
            break;

        case 'notify':
            const d = e.data.data || {};
            showNotification(d.type, d.message, d.icon);
            break;

        case 'updateWeaponDurability':
            updateSlotDurability('player', e.data.slot, e.data.durability);
            break;
    }
});

// ─── OUVRIR L'INVENTAIRE ───────────────────────────────────
function openInventory(data) {
    STATE.open          = true;
    STATE.player        = data.player;
    STATE.context       = data.context  || null;
    STATE.itemsCatalog  = data.items    || {};
    STATE.hotbarCount   = data.hotbarSlots || 5;
    STATE.selectedSlot  = null;
    STATE.actionMode    = null;

    // Identifiants pour dragdrop.js
    window.INV_PLAYER_ID = STATE.player ? 'player' : 'player';
    if (STATE.context) {
        window.INV_CONTEXT_OWNER = STATE.context.type === 'drop'
            ? STATE.context.dropId
            : `vehicle_${STATE.context.vehicleId}`;
        window.INV_CONTEXT_TYPE = STATE.context.type;
    }

    // Cash
    document.getElementById('cash-amount').textContent = formatCash(STATE.player?.cash || 0);

    // Rendu
    initHotbar(STATE.hotbarCount);
    renderPlayerSlots();
    renderWeightBar();
    renderContextPanel();

    // Afficher
    const root = document.getElementById('inventory-root');
    root.classList.remove('hidden');
    root.classList.add('open');
    clearActionMode();
}

// ─── FERMER L'INVENTAIRE ───────────────────────────────────
function closeInventoryUI() {
    STATE.open         = false;
    STATE.selectedSlot = null;
    STATE.actionMode   = null;
    clearActionMode();

    const root = document.getElementById('inventory-root');
    root.classList.add('hidden');
    root.classList.remove('open');
    hideTooltip();
}

// Fermeture depuis touche ESC
document.addEventListener('keydown', e => {
    if (e.key === 'Escape' && STATE.open) {
        nuiPost('close');
    }
});

// ─── POIDS ─────────────────────────────────────────────────
function renderWeightBar() {
    if (!STATE.player) return;

    const current  = STATE.player.weight   || 0;
    const max      = STATE.player.maxWeight || 30000;
    const pct      = clamp((current / max) * 100, 0, 100);

    const fill     = document.getElementById('weight-fill');
    const label    = document.getElementById('weight-text');

    fill.style.width = pct + '%';
    fill.className   = 'weight-fill' + (pct >= 100 ? ' full' : pct >= 80 ? ' warn' : '');
    label.textContent = `${formatWeight(current)} / ${formatWeight(max)}`;
}

// ─── RENDU PANNEAU JOUEUR ──────────────────────────────────
function renderPlayerSlots() {
    const container = document.getElementById('player-slots');
    const slots     = STATE.player?.slots     || {};
    const maxSlots  = STATE.player?.maxSlots  || 40;

    container.innerHTML = '';

    for (let i = 1; i <= maxSlots; i++) {
        const slotData = slots[String(i)] || null;
        const el       = buildSlotElement(i, 'player', slotData);
        container.appendChild(el);
    }
}

// ─── RENDU PANNEAU CONTEXTE ────────────────────────────────
function renderContextPanel() {
    const ctx        = STATE.context;
    const icon       = document.getElementById('context-icon');
    const label      = document.getElementById('context-label');
    const tag        = document.getElementById('context-tag');

    if (!ctx) {
        // Pas de contexte : panneau vide
        icon.innerHTML  = '<i class="fa-solid fa-ban"></i>';
        label.textContent = 'Rien à proximité';
        tag.textContent   = '—';
        document.getElementById('context-slots').innerHTML = `
            <div style="grid-column:1/-1; display:flex; flex-direction:column;
                        align-items:center; justify-content:center; padding:40px 20px;
                        color:var(--text-dim); gap:12px;">
                <i class="fa-solid fa-magnifying-glass" style="font-size:28px;"></i>
                <span style="font-size:10px; text-transform:uppercase; letter-spacing:1px;">
                    Aucun item à proximité
                </span>
            </div>`;
        return;
    }

    // Icône & label selon le type
    const icons = { drop: 'fa-box-open', glovebox: 'fa-car-side', trunk: 'fa-car-rear' };
    const tags  = { drop: 'SOL', glovebox: 'GLOVEBOX', trunk: 'COFFRE' };

    icon.innerHTML    = `<i class="fa-solid ${icons[ctx.type] || 'fa-box'}"></i>`;
    label.textContent = ctx.label || 'Items';
    tag.textContent   = tags[ctx.type] || ctx.type.toUpperCase();

    renderContextSlots();
}

function renderContextSlots() {
    const ctx       = STATE.context;
    if (!ctx) return;

    const container = document.getElementById('context-slots');
    const slots     = ctx.slots    || {};
    const maxSlots  = ctx.maxSlots || 20;

    container.innerHTML = '';

    for (let i = 1; i <= maxSlots; i++) {
        const slotData = slots[String(i)] || null;
        const el       = buildSlotElement(i, 'context', slotData);
        container.appendChild(el);
    }
}

// ─── CONSTRUCTION D'UN SLOT ────────────────────────────────
function buildSlotElement(slotIndex, invType, slotData) {
    const el       = document.createElement('div');
    const hasItem  = slotData && slotData.name;
    const itemData = hasItem ? (STATE.itemsCatalog[slotData.name] || null) : null;

    el.className    = 'inv-slot' + (hasItem ? ' has-item' : '');
    el.dataset.slot = slotIndex;
    el.dataset.inv  = invType;

    // Numéro de slot
    const numSpan = document.createElement('span');
    numSpan.className   = 'slot-number';
    numSpan.textContent = slotIndex;
    el.appendChild(numSpan);

    if (hasItem) {
        // Image
        const img = document.createElement('img');
        img.className = 'slot-img';
        img.src       = getItemImage(itemData?.image || slotData.name);
        img.alt       = itemData?.label || slotData.name;
        img.onerror   = function() {
            this.style.display = 'none';
            iconFallback.style.display = 'block';
        };
        el.appendChild(img);

        // Icône fallback
        const iconFallback = document.createElement('i');
        iconFallback.className = 'fa-solid fa-box slot-icon';
        iconFallback.style.display = 'none';
        el.appendChild(iconFallback);

        // Badge arme
        if (itemData?.type === 'weapon') {
            const badge = document.createElement('i');
            badge.className = 'fa-solid fa-gun slot-weapon-badge';
            el.appendChild(badge);
        }

        // Quantité
        if ((slotData.amount || 1) > 1) {
            const amtSpan = document.createElement('span');
            amtSpan.className   = 'slot-amount';
            amtSpan.textContent = slotData.amount;
            el.appendChild(amtSpan);
        }

        // Barre de durabilité
        if (itemData?.durability && slotData.metadata?.durability !== undefined) {
            const dur     = clamp(slotData.metadata.durability, 0, 100);
            const barWrap = document.createElement('div');
            barWrap.className = 'slot-durability';
            const barFill = document.createElement('div');
            barFill.className = 'slot-durability-fill' +
                (dur <= 20 ? ' low' : dur <= 50 ? ' medium' : '');
            barFill.style.width = dur + '%';
            barWrap.appendChild(barFill);
            el.appendChild(barWrap);
        }

        // Surbrillance si sélectionné
        if (STATE.selectedSlot &&
            STATE.selectedSlot.invType    === invType &&
            STATE.selectedSlot.slotIndex  === slotIndex) {
            el.classList.add('selected');
        }

        // ── ÉVÉNEMENTS ─────────────────────────────────────

        // Tooltip
        el.addEventListener('mouseenter', ev => {
            showTooltip(itemData, slotData, ev.clientX, ev.clientY);
        });
        el.addEventListener('mousemove', ev => positionTooltip(ev.clientX, ev.clientY));
        el.addEventListener('mouseleave', hideTooltip);

        // Clic gauche → sélectionner
        el.addEventListener('click', ev => {
            ev.stopPropagation();
            selectSlot(invType, slotIndex, slotData.name, itemData, slotData);
        });

        // Clic droit → menu contextuel rapide
        el.addEventListener('contextmenu', ev => {
            ev.preventDefault();
            selectSlot(invType, slotIndex, slotData.name, itemData, slotData);
            if (invType === 'player') {
                handleActionUse();
            }
        });

        // Double clic → utiliser / équiper directement
        el.addEventListener('dblclick', ev => {
            ev.preventDefault();
            selectSlot(invType, slotIndex, slotData.name, itemData, slotData);
            if (invType === 'player') handleActionUse();
            else if (invType === 'context') handlePickup(slotIndex, slotData);
        });

        // Drag
        const newEl = attachSlotDragListeners(el, invType, slotIndex, slotData.name, itemData, slotData);

        // Drop sur ce slot → gérer la hotbar si applicable
        newEl.addEventListener('mouseup', ev => {
            if (!dragState) return;

            // Si on drop sur la hotbar depuis l'inventaire joueur
            if (newEl.dataset.inv === 'hotbar' && dragState.invType === 'player') {
                const hIndex = parseInt(newEl.dataset.slot) - 1;
                handleDropOnHotbar(
                    hIndex,
                    dragState.slotIndex,
                    dragState.itemName,
                    dragState.itemData,
                    dragState.slotData
                );
            }
        });

        return newEl;
    }

    // Slot vide : zone de drop
    el.addEventListener('mouseup', () => {
        if (!dragState) return;
        if (el.dataset.inv === 'hotbar') {
            const hIndex = parseInt(el.dataset.slot) - 1;
            if (dragState.invType === 'player') {
                handleDropOnHotbar(
                    hIndex,
                    dragState.slotIndex,
                    dragState.itemName,
                    dragState.itemData,
                    dragState.slotData
                );
            }
        }
    });

    return el;
}

// ─── SÉLECTION D'UN SLOT ───────────────────────────────────
function selectSlot(invType, slotIndex, itemName, itemData, slotData) {
    // Désélectionner si on reclique le même
    if (STATE.selectedSlot &&
        STATE.selectedSlot.invType   === invType &&
        STATE.selectedSlot.slotIndex === slotIndex) {
        STATE.selectedSlot = null;
        clearActionMode();
        reRenderSlot(invType, slotIndex, slotData);
        return;
    }

    // Désélectionner l'ancien
    if (STATE.selectedSlot) {
        const old = STATE.selectedSlot;
        reRenderSlot(old.invType, old.slotIndex, old.slotData);
    }

    STATE.selectedSlot = { invType, slotIndex, itemName, itemData, slotData };
    reRenderSlot(invType, slotIndex, slotData);
}

// Re-rend un seul slot (mise à jour légère)
function reRenderSlot(invType, slotIndex, slotData) {
    let container;
    if (invType === 'player')  container = document.getElementById('player-slots');
    else                        container = document.getElementById('context-slots');

    if (!container) return;

    const existing = container.querySelector(`[data-slot="${slotIndex}"]`);
    if (!existing) return;

    const newEl = buildSlotElement(slotIndex, invType, slotData);
    container.replaceChild(newEl, existing);
}

// Clic hors des slots → désélectionner
document.addEventListener('click', e => {
    if (!e.target.closest('.inv-slot') &&
        !e.target.closest('.action-btn') &&
        !e.target.closest('#qty-modal')) {
        if (STATE.selectedSlot) {
            const old = STATE.selectedSlot;
            STATE.selectedSlot = null;
            clearActionMode();
            reRenderSlot(old.invType, old.slotIndex, old.slotData);
        }
    }
});

// ─── ACTIONS : DONNER / JETER / UTILISER ───────────────────
const btnGive = document.getElementById('btn-give');
const btnDrop = document.getElementById('btn-drop');
const btnUse  = document.getElementById('btn-use');

btnGive.addEventListener('click', () => handleActionGive());
btnDrop.addEventListener('click', () => handleActionDrop());
btnUse.addEventListener('click',  () => handleActionUse());

function setActionMode(mode) {
    STATE.actionMode = mode;
    btnGive.classList.toggle('active', mode === 'give');
    btnDrop.classList.toggle('active', mode === 'drop');
    btnUse.classList.toggle('active',  mode === 'use');
}

function clearActionMode() {
    STATE.actionMode = null;
    btnGive.classList.remove('active');
    btnDrop.classList.remove('active');
    btnUse.classList.remove('active');
}

// ── DONNER ─────────────────────────────────────────────────
async function handleActionGive() {
    if (!STATE.selectedSlot || STATE.selectedSlot.invType !== 'player') {
        showNotification('info', 'Sélectionnez d\'abord un item dans votre inventaire.', 'fa-hand-pointer');
        return;
    }

    setActionMode('give');

    const slotData = STATE.selectedSlot.slotData;
    const maxAmt   = slotData.amount || 1;
    let   amount   = maxAmt;

    if (maxAmt > 1) {
        amount = await openQtyModal(`Donner ${STATE.selectedSlot.itemData?.label || STATE.selectedSlot.itemName}`, maxAmt);
        if (!amount) { clearActionMode(); return; }
    }

    nuiPost('giveItem', {
        slot:   STATE.selectedSlot.slotIndex,
        amount: amount,
    });

    clearActionMode();
    STATE.selectedSlot = null;
}

// ── JETER ──────────────────────────────────────────────────
async function handleActionDrop() {
    if (!STATE.selectedSlot || STATE.selectedSlot.invType !== 'player') {
        showNotification('info', 'Sélectionnez d\'abord un item dans votre inventaire.', 'fa-hand-pointer');
        return;
    }

    setActionMode('drop');

    const slotData = STATE.selectedSlot.slotData;
    const maxAmt   = slotData.amount || 1;
    let   amount   = maxAmt;

    if (maxAmt > 1) {
        amount = await openQtyModal(`Jeter ${STATE.selectedSlot.itemData?.label || STATE.selectedSlot.itemName}`, maxAmt);
        if (!amount) { clearActionMode(); return; }
    }

    nuiPost('dropItem', {
        slot:   STATE.selectedSlot.slotIndex,
        amount: amount,
    });

    clearActionMode();
    STATE.selectedSlot = null;
}

// ── UTILISER / ÉQUIPER ─────────────────────────────────────
function handleActionUse() {
    if (!STATE.selectedSlot) {
        showNotification('info', 'Sélectionnez d\'abord un item.', 'fa-hand-pointer');
        return;
    }

    const { invType, slotIndex, itemData, slotData } = STATE.selectedSlot;

    if (invType === 'player') {
        setActionMode('use');
        nuiPost('useItem', { slot: slotIndex });
        clearActionMode();
        STATE.selectedSlot = null;
    } else if (invType === 'context') {
        // Depuis le contexte → ramasser
        handlePickup(slotIndex, slotData);
    }
}

// ── RAMASSER UN ITEM DU CONTEXTE ───────────────────────────
async function handlePickup(slotIndex, slotData) {
    if (!STATE.context) return;

    const maxAmt = slotData.amount || 1;
    let   amount = maxAmt;

    if (maxAmt > 1) {
        const itemData = STATE.itemsCatalog[slotData.name];
        amount = await openQtyModal(`Ramasser ${itemData?.label || slotData.name}`, maxAmt);
        if (!amount) return;
    }

    nuiPost('pickupDrop', {
        dropId: STATE.context.dropId || STATE.context.vehicleId,
        slot:   slotIndex,
        amount: amount,
    });

    STATE.selectedSlot = null;
}

// ─── MISE À JOUR DURABILITÉ D'UN SLOT ──────────────────────
function updateSlotDurability(invType, slotIndex, durability) {
    const container = invType === 'player'
        ? document.getElementById('player-slots')
        : document.getElementById('context-slots');
    if (!container) return;

    const slotEl = container.querySelector(`[data-slot="${slotIndex}"]`);
    if (!slotEl) return;

    const fill = slotEl.querySelector('.slot-durability-fill');
    if (!fill) return;

    const dur = clamp(durability, 0, 100);
    fill.style.width = dur + '%';
    fill.className   = 'slot-durability-fill' +
        (dur <= 20 ? ' low' : dur <= 50 ? ' medium' : '');

    // Mettre à jour dans l'état
    const slots = STATE.player?.slots;
    if (slots && slots[String(slotIndex)]?.metadata) {
        slots[String(slotIndex)].metadata.durability = dur;
    }
}

// ─── DRAG VERS LA HOTBAR ───────────────────────────────────
// Écouter les drops sur la hotbar (override du mouseup vide)
document.getElementById('hotbar').addEventListener('mouseup', e => {
    const targetSlot = e.target.closest('.hotbar-slot');
    if (!targetSlot || !dragState) return;

    if (dragState.invType !== 'player') return;

    const hIndex = parseInt(targetSlot.dataset.slot) - 1;
    handleDropOnHotbar(
        hIndex,
        dragState.slotIndex,
        dragState.itemName,
        dragState.itemData,
        dragState.slotData
    );
});
