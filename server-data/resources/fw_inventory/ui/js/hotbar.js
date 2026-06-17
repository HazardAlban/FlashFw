/* ============================================================
   fw_inventory | ui/js/hotbar.js
   Gestion de la hotbar (5 slots raccourcis)
   ============================================================ */

'use strict';

// hotbarData[index] = { playerSlot, name, itemData, slotData } | null
let hotbarData = new Array(5).fill(null);

// ─── INITIALISER LA HOTBAR ─────────────────────────────────
function initHotbar(count) {
    const container = document.getElementById('hotbar');
    container.innerHTML = '';
    hotbarData = new Array(count).fill(null);

    for (let i = 0; i < count; i++) {
        const slot = document.createElement('div');
        slot.className    = 'hotbar-slot';
        slot.dataset.slot = i + 1;
        slot.dataset.inv  = 'hotbar';
        slot.innerHTML    = `<span class="hotbar-key">${i + 1}</span>`;
        container.appendChild(slot);
        attachHotbarListeners(slot, i);
    }
}

// ─── LISTENERS D'UN SLOT HOTBAR ────────────────────────────
function attachHotbarListeners(slotEl, index) {
    slotEl.addEventListener('contextmenu', e => {
        e.preventDefault();
        clearHotbarSlot(index);
    });

    slotEl.addEventListener('mouseenter', e => {
        const data = hotbarData[index];
        if (data) {
            showTooltip(data.itemData, data.slotData, e.clientX, e.clientY);
        }
    });

    slotEl.addEventListener('mouseleave', hideTooltip);
    slotEl.addEventListener('mousemove', e => {
        const data = hotbarData[index];
        if (data) positionTooltip(e.clientX, e.clientY);
    });
}

// ─── REMPLIR UN SLOT HOTBAR ────────────────────────────────
function setHotbarSlot(index, playerSlot, itemName, itemData, slotData) {
    if (index < 0 || index >= hotbarData.length) return;

    hotbarData[index] = { playerSlot, name: itemName, itemData, slotData };

    const container = document.getElementById('hotbar');
    const slotEl    = container.children[index];
    if (!slotEl) return;

    renderHotbarSlot(slotEl, index, itemName, itemData, slotData);
    syncHotbarToServer();
}

// ─── VIDER UN SLOT HOTBAR ──────────────────────────────────
function clearHotbarSlot(index) {
    hotbarData[index] = null;
    const container   = document.getElementById('hotbar');
    const slotEl      = container.children[index];
    if (!slotEl) return;

    slotEl.innerHTML = `<span class="hotbar-key">${index + 1}</span>`;
    slotEl.classList.remove('has-item');
    syncHotbarToServer();
}

// ─── RENDU D'UN SLOT HOTBAR ────────────────────────────────
function renderHotbarSlot(slotEl, index, itemName, itemData, slotData) {
    const imgSrc = getItemImage(itemData?.image || itemName);

    slotEl.innerHTML = `
        <span class="hotbar-key">${index + 1}</span>
        <img class="slot-img" src="${imgSrc}"
             alt="${itemData?.label || itemName}"
             onerror="this.style.display='none'; this.nextElementSibling.style.display='block';" />
        <i class="fa-solid fa-box slot-icon" style="display:none; font-size:14px;"></i>
        ${slotData?.amount > 1 ? `<span class="slot-amount">${slotData.amount}</span>` : ''}
    `;
    slotEl.classList.add('has-item');

    // Drag depuis la hotbar
    attachSlotDragListeners(slotEl, 'hotbar', slotData?.slot || index + 1, itemName, itemData, slotData);
    attachHotbarListeners(slotEl, index);
}

// ─── SYNC HOTBAR → SERVEUR ─────────────────────────────────
function syncHotbarToServer() {
    nuiPost('setHotbar', {
        hotbar: hotbarData.map(d => d ? { playerSlot: d.playerSlot, name: d.name } : null),
    });
}

// ─── METTRE À JOUR DEPUIS LES SLOTS JOUEUR ─────────────────
// Appelé après chaque sync pour maintenir les données fraîches
function refreshHotbarFromPlayer(playerSlots, itemsCatalog) {
    hotbarData.forEach((entry, index) => {
        if (!entry) return;

        // Trouver le slot joueur correspondant
        const slot = playerSlots[String(entry.playerSlot)];
        if (slot && slot.name) {
            hotbarData[index].slotData  = slot;
            hotbarData[index].itemData  = itemsCatalog[slot.name];
            hotbarData[index].name      = slot.name;

            const container = document.getElementById('hotbar');
            const slotEl    = container.children[index];
            if (slotEl) renderHotbarSlot(slotEl, index, slot.name, itemsCatalog[slot.name], slot);
        } else {
            // L'item a disparu → vider
            clearHotbarSlot(index);
        }
    });
}

// ─── DROP SUR LA HOTBAR (depuis drag) ──────────────────────
// Appelé par le système drag quand on drop sur un slot hotbar
function handleDropOnHotbar(hotbarIndex, playerSlot, itemName, itemData, slotData) {
    setHotbarSlot(hotbarIndex, playerSlot, itemName, itemData, slotData);
}
