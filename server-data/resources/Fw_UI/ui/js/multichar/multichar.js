function renderTab(tabId) {
    const wrapper = document.getElementById('dynamic-content');
    wrapper.innerHTML = ""; 

    if (tabId === 'genetic') {
        let mIdx = currentSkinData.genetic.shapeMother;
        let fIdx = currentSkinData.genetic.shapeFather;
        wrapper.innerHTML = `
            <div class="parents-preview">
                <div class="parent-card">
                    <img id="img-mother" src="assets/skinchanger/parents/${parentsList[mIdx]}.webp" onerror="this.onerror=null; this.src='assets/default.png'">
                    <div class="arrow-selector">
                        <button onclick="changeParent('mother', -1)"><i class="fa-solid fa-chevron-left"></i></button>
                        <span id="name-mother">${parentsList[mIdx]}</span>
                        <button onclick="changeParent('mother', 1)"><i class="fa-solid fa-chevron-right"></i></button>
                    </div>
                </div>
                <div class="parent-card">
                    <img id="img-father" src="assets/skinchanger/parents/${parentsList[fIdx]}.webp" onerror="this.onerror=null; this.src='assets/default.png'">
                    <div class="arrow-selector">
                        <button onclick="changeParent('father', -1)"><i class="fa-solid fa-chevron-left"></i></button>
                        <span id="name-father">${parentsList[fIdx]}</span>
                        <button onclick="changeParent('father', 1)"><i class="fa-solid fa-chevron-right"></i></button>
                    </div>
                </div>
            </div>
            ${createSlider("Dominance des traits", "gene-shape-mix", 0, 100, currentSkinData.genetic.shapeMix * 100, "updateGenetic()")}
            ${createSlider("Dominance de peau", "gene-skin-mix", 0, 100, currentSkinData.genetic.skinMix * 100, "updateGenetic()")}
        `;
    } 
    else if (tabId === 'face') {
        // (Le contenu de tabId === 'face' reste exactement identique)
        wrapper.innerHTML = `
            <h3 class="section-title">Nez</h3>
            ${createFaceSlider("Largeur", 0)} ${createFaceSlider("Hauteur", 1)} ${createFaceSlider("Taille", 2)}
            <h3 class="section-title">Mâchoire & Menton</h3>
            ${createFaceSlider("Largeur Mâchoire", 13)} ${createFaceSlider("Hauteur Menton", 15)} ${createFaceSlider("Largeur Menton", 16)} ${createFaceSlider("Profil Menton", 17)}
            <h3 class="section-title">Détails du Visage</h3>
            ${createFaceSlider("Épaisseur des Lèvres", 12)} ${createFaceSlider("Ouverture des Yeux", 11)}
            ${createFaceSlider("Largeur Pommettes", 8)} ${createFaceSlider("Hauteur Pommettes", 9)}
            ${createFaceSlider("Épaisseur du Cou", 19)}
        `;
    }
    else if (tabId === 'style') {
        let html = '';
        appearanceList.forEach(item => {
            let currentVal = (item.id === 'eye') ? (currentSkinData.colors.eye || 0) : (currentSkinData.overlays[item.id]?.val || 0);
            
            html += `<div class="app-card">
                <div class="app-row">
                    <span class="app-label">${item.name}</span>
                    <div class="app-selector">
                        <button onclick="changeAppItem('${item.id}', -1, ${item.max}, '${item.type}')"><i class="fa-solid fa-chevron-left"></i></button>
                        <span id="val-app-${item.id}">${currentVal} / ${item.max}</span>
                        <button onclick="changeAppItem('${item.id}', 1, ${item.max}, '${item.type}')"><i class="fa-solid fa-chevron-right"></i></button>
                    </div>
                </div>`;
            
            if (item.hasOp) {
                let op = (currentSkinData.overlays[item.id]?.op !== undefined) ? currentSkinData.overlays[item.id].op * 100 : 100;
                html += createSlider("Opacité", `op-${item.id}`, 0, 100, op, `updateOp('${item.id}')`);
            }
            if (item.hasColor) {
                let p = currentSkinData.colors[item.id]?.primary || 0;
                let s = currentSkinData.colors[item.id]?.secondary || 0;
                html += createSlider("Couleur Principale", `col-p-${item.id}`, 0, 63, p, `updateCol('${item.id}', ${item.isComp})`);
                html += createSlider("Reflets", `col-s-${item.id}`, 0, 63, s, `updateCol('${item.id}', ${item.isComp})`);
            }
            html += `</div>`;
        });
        wrapper.innerHTML = html;
    }
    else if (tabId === 'outfit') {
        wrapper.innerHTML = `
            <div class="outfit-selector">
                ${createOutfitCard("basique", "Style Basique")}
                ${createOutfitCard("classe", "Style Classe")}
                ${createOutfitCard("rue", "Style Rue")}
            </div>
        `;
    }
}

function createOutfitCard(id, name) { 
    let active = currentSkinData.outfit === id ? 'active' : ''; 
    // CORRECTION ICI AUSSI POUR L'IMAGE PAR DÉFAUT
    return `<div class="outfit-card ${active}" onclick="selectOutfit('${id}', this)"><img src="assets/default.png" onerror="this.onerror=null; this.src='';"><span>${name}</span></div>`; 
}