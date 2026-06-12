let currentGender = "male";
let isCreatingNew = false;
let currentSkinData = {
    genetic: { shapeMother: 21, shapeFather: 0, skinMother: 21, skinFather: 0, shapeMix: 0.5, skinMix: 0.5 },
    features: {}, overlays: {}, colors: {}, outfit: 'caleçon'
};

const parentsList = [
    "Benjamin", "Daniel", "Joshua", "Noah", "Andrew", "Juan", "Alex", "Isaac", "Evan", "Ethan",
    "Vincent", "Angel", "Diego", "Adrian", "Gabriel", "Michael", "Santiago", "Kevin", "Louis", "Samuel",
    "Anthony", "Hannah", "Audrey", "Jasmine", "Giselle", "Amelia", "Isabella", "Zoe", "Ava", "Camila",
    "Violet", "Sophia", "Evelyn", "Nicole", "Ashley", "Grace", "Brianna", "Natalie", "Olivia", "Elizabeth",
    "Charlotte", "Emma", "Claude", "Niko", "John", "Misty"
];

const appearanceList = [
    { id: 2, name: 'Coupe de Cheveux', isComp: true, hasColor: true, hasOp: false, max: 74, type: 'hair' },
    { id: 'eye', name: 'Couleur des Yeux', isComp: false, hasColor: false, hasOp: false, max: 31, type: 'eye' },
    { id: 1, name: 'Barbe', isComp: false, hasColor: true, hasOp: true, max: 28, type: 'overlay' },
    { id: 22, name: 'Sourcils', isComp: false, hasColor: true, hasOp: true, max: 33, type: 'overlay' },
    { id: 10, name: 'Pilosité Torse', isComp: false, hasColor: true, hasOp: true, max: 16, type: 'overlay' },
    { id: 4, name: 'Maquillage', isComp: false, hasColor: true, hasOp: true, max: 74, type: 'overlay' },
    { id: 8, name: 'Rouge à lèvres', isComp: false, hasColor: true, hasOp: true, max: 9, type: 'overlay' },
    { id: 5, name: 'Blush', isComp: false, hasColor: true, hasOp: true, max: 6, type: 'overlay' },
    { id: 3, name: 'Rides & Vieillesse', isComp: false, hasColor: false, hasOp: true, max: 14, type: 'overlay' },
    { id: 6, name: 'Teint / Pâleur', isComp: false, hasColor: false, hasOp: true, max: 11, type: 'overlay' },
    { id: 7, name: 'Dégâts du Soleil', isComp: false, hasColor: false, hasOp: true, max: 10, type: 'overlay' },
    { id: 9, name: 'Grains de beauté', isComp: false, hasColor: false, hasOp: true, max: 17, type: 'overlay' },
    { id: 0, name: 'Taches cutanées', isComp: false, hasColor: false, hasOp: true, max: 23, type: 'overlay' }
];

window.addEventListener('message', function(event) {
    if (event.data.action === "openSkinChanger") {
        let creatorUI = document.getElementById('creator-container');
        if (creatorUI) creatorUI.classList.add('hidden');
        
        currentGender = event.data.gender;
        isCreatingNew = event.data.isNewCharacter;
        document.getElementById('skinchanger-container').classList.remove('hidden');
        renderTab('genetic');
    }
});

document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        e.target.classList.add('active');
        renderTab(e.target.dataset.tab);
    });
});

function req(endpoint, data) { fetch(`https://${GetParentResourceName()}/${endpoint}`, { method: 'POST', body: JSON.stringify(data) }).catch(()=>{}); }

function renderTab(tabId) {
    const wrapper = document.getElementById('dynamic-content');
    wrapper.innerHTML = ""; 

    if (tabId === 'genetic') {
        let mIdx = currentSkinData.genetic.shapeMother;
        let fIdx = currentSkinData.genetic.shapeFather;
        wrapper.innerHTML = `
            <div class="parents-preview">
                <div class="parent-card">
                    <img id="img-mother" src="assets/skinchanger/parents/${parentsList[mIdx]}.webp" onerror="this.src='assets/default.png'">
                    <div class="arrow-selector">
                        <button onclick="changeParent('mother', -1)"><i class="fa-solid fa-chevron-left"></i></button>
                        <span id="name-mother">${parentsList[mIdx]}</span>
                        <button onclick="changeParent('mother', 1)"><i class="fa-solid fa-chevron-right"></i></button>
                    </div>
                </div>
                <div class="parent-card">
                    <img id="img-father" src="assets/skinchanger/parents/${parentsList[fIdx]}.webp" onerror="this.src='assets/default.png'">
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

// === FONCTIONS ===
function changeParent(type, dir) {
    if (type === 'mother') {
        currentSkinData.genetic.shapeMother += dir;
        if (currentSkinData.genetic.shapeMother > 45) currentSkinData.genetic.shapeMother = 0;
        if (currentSkinData.genetic.shapeMother < 0) currentSkinData.genetic.shapeMother = 45;
        currentSkinData.genetic.skinMother = currentSkinData.genetic.shapeMother;
        document.getElementById('name-mother').innerText = parentsList[currentSkinData.genetic.shapeMother];
        document.getElementById('img-mother').src = `assets/skinchanger/parents/${parentsList[currentSkinData.genetic.shapeMother]}.webp`;
    } else {
        currentSkinData.genetic.shapeFather += dir;
        if (currentSkinData.genetic.shapeFather > 45) currentSkinData.genetic.shapeFather = 0;
        if (currentSkinData.genetic.shapeFather < 0) currentSkinData.genetic.shapeFather = 45;
        currentSkinData.genetic.skinFather = currentSkinData.genetic.shapeFather;
        document.getElementById('name-father').innerText = parentsList[currentSkinData.genetic.shapeFather];
        document.getElementById('img-father').src = `assets/skinchanger/parents/${parentsList[currentSkinData.genetic.shapeFather]}.webp`;
    }
    updateGeneticFetch();
}

function updateGenetic() {
    currentSkinData.genetic.shapeMix = parseFloat(document.getElementById('gene-shape-mix').value) / 100;
    currentSkinData.genetic.skinMix = parseFloat(document.getElementById('gene-skin-mix').value) / 100;
    updateGeneticFetch();
}
function updateGeneticFetch() { req('updateSkinParents', currentSkinData.genetic); }

function createSlider(label, id, min, max, val, func) { return `<div class="input-group"><label><span>${label}</span></label><input type="range" id="${id}" min="${min}" max="${max}" value="${val}" oninput="${func}"></div>`; }
function createFaceSlider(label, index) { let val = currentSkinData.features[index] || 0.0; return `<div class="input-group"><label><span>${label}</span></label><input type="range" min="-100" max="100" value="${val * 100}" oninput="updateFace(${index}, this.value)"></div>`; }
function createOutfitCard(id, name) { let active = currentSkinData.outfit === id ? 'active' : ''; return `<div class="outfit-card ${active}" onclick="selectOutfit('${id}', this)"><img src="assets/default.png"><span>${name}</span></div>`; }

function updateFace(index, value) {
    let floatVal = parseFloat(value) / 100;
    currentSkinData.features[index] = floatVal;
    req('updateFaceFeature', { index: index, value: floatVal });
}

function changeAppItem(id, dir, max, type) {
    let val = 0;
    if (type === 'eye') {
        val = (currentSkinData.colors.eye || 0) + dir;
        if (val > max) val = 0; if (val < 0) val = max;
        currentSkinData.colors.eye = val;
        document.getElementById(`val-app-${id}`).innerText = `${val} / ${max}`;
        req('updateEyeColor', { value: val });
        return;
    }

    if (!currentSkinData.overlays[id]) currentSkinData.overlays[id] = { val: 0, op: 1.0 };
    val = currentSkinData.overlays[id].val + dir;
    if (val > max) val = 0; if (val < 0) val = max;

    currentSkinData.overlays[id].val = val;
    document.getElementById(`val-app-${id}`).innerText = `${val} / ${max}`;
    let isComp = (type === 'hair');
    req('updateHeadOverlay', { id: id, value: val, opacity: currentSkinData.overlays[id].op, isComponent: isComp });
}

function updateOp(id) {
    let op = parseFloat(document.getElementById(`op-${id}`).value) / 100;
    if (!currentSkinData.overlays[id]) currentSkinData.overlays[id] = { val: 0, op: 1.0 };
    currentSkinData.overlays[id].op = op;
    req('updateHeadOverlay', { id: id, value: currentSkinData.overlays[id].val, opacity: op, isComponent: false });
}

function updateCol(id, isComp) {
    let p = parseInt(document.getElementById(`col-p-${id}`).value);
    let s = parseInt(document.getElementById(`col-s-${id}`).value);
    currentSkinData.colors[id] = { primary: p, secondary: s };
    req('updateSkinColor', { id: id, isComponent: isComp, primary: p, secondary: s });
}

function selectOutfit(style, cardElement) {
    currentSkinData.outfit = style;
    document.querySelectorAll('.outfit-card').forEach(c => c.classList.remove('active'));
    if (cardElement) cardElement.classList.add('active');
    req('applyPresetOutfit', { style: style, gender: currentGender });
}

function changeCam(type) { req('changeSkinCam', { camType: type }); }
function zoomCam(dir) { req('zoomCam', { dir: dir }); }
function rotateCam(dir) { req('rotateCam', { dir: dir }); }
function saveSkin() {
    document.getElementById('skinchanger-container').classList.add('hidden');
    req('saveSkinFinal', { skin: currentSkinData, isNewCharacter: isCreatingNew });
}