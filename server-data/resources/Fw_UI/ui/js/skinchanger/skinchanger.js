let currentGender = "male";
let isCreatingNew = false;
let currentSkinData = {
    genetic: { shapeMother: 21, shapeFather: 0, skinMother: 21, skinFather: 0, shapeMix: 0.5, skinMix: 0.5 },
    features: {}, overlays: {}, colors: {}, outfit: 'caleçon'
};
let activeSubCategory = { id: 0, isComp: false };

const parentsList = [
    "Benjamin", "Daniel", "Joshua", "Noah", "Andrew", "Juan", "Alex", "Isaac", "Evan", "Ethan",
    "Vincent", "Angel", "Diego", "Adrian", "Gabriel", "Michael", "Santiago", "Kevin", "Louis", "Samuel",
    "Anthony", "Hannah", "Audrey", "Jasmine", "Giselle", "Amelia", "Isabella", "Zoe", "Ava", "Camila",
    "Violet", "Sophia", "Evelyn", "Nicole", "Ashley", "Grace", "Brianna", "Natalie", "Olivia", "Elizabeth",
    "Charlotte", "Emma", "Claude", "Niko", "John", "Misty"
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
    document.getElementById('global-color-box').classList.add('hidden');
    document.getElementById('global-opacity-box').classList.add('hidden');
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
        wrapper.innerHTML = `
            <div class="sub-tabs">
                <button class="sub-btn active" onclick="loadGrid(2, 'Cheveux', true, true, this)">Cheveux</button>
                <button class="sub-btn" onclick="loadGrid('eye', 'Yeux', false, false, this)">Yeux</button>
                <button class="sub-btn" onclick="loadGrid(1, 'Barbe', false, true, this)">Barbe</button>
                <button class="sub-btn" onclick="loadGrid(22, 'Sourcils', false, true, this)">Sourcils</button>
                <button class="sub-btn" onclick="loadGrid(10, 'Torse', false, true, this)">Pilosité</button>
                <button class="sub-btn" onclick="loadGrid(4, 'Maquillage', false, true, this)">Maquillage</button>
                <button class="sub-btn" onclick="loadGrid(8, 'Lèvres', false, true, this)">Lèvres</button>
                <button class="sub-btn" onclick="loadGrid(5, 'Blush', false, true, this)">Blush</button>
                <button class="sub-btn" onclick="loadGrid(3, 'Vieillissement', false, false, this)">Rides</button>
                <button class="sub-btn" onclick="loadGrid(6, 'Teint / Pâleur', false, false, this)">Teint</button>
                <button class="sub-btn" onclick="loadGrid(7, 'Soleil', false, false, this)">Soleil</button>
                <button class="sub-btn" onclick="loadGrid(9, 'Grains', false, false, this)">Grains</button>
            </div>
            <div id="grid-container"></div>
        `;
        loadGrid(2, 'Cheveux', true, true, document.querySelector('.sub-btn')); 
    }
    else if (tabId === 'outfit') {
        wrapper.innerHTML = `
            <h3 class="section-title">Paquetage de départ</h3>
            <div class="outfit-selector">
                ${createOutfitCard("basique", "Style Basique")}
                ${createOutfitCard("classe", "Style Classe")}
                ${createOutfitCard("rue", "Style Rue")}
            </div>
        `;
    }
}

function changeParent(type, dir) {
    if (type === 'mother') {
        currentSkinData.genetic.shapeMother += dir;
        if (currentSkinData.genetic.shapeMother > 45) currentSkinData.genetic.shapeMother = 0;
        if (currentSkinData.genetic.shapeMother < 0) currentSkinData.genetic.shapeMother = 45;
        currentSkinData.genetic.skinMother = currentSkinData.genetic.shapeMother;
        
        let mName = parentsList[currentSkinData.genetic.shapeMother];
        document.getElementById('name-mother').innerText = mName;
        document.getElementById('img-mother').src = `assets/skinchanger/parents/${mName}.webp`;
    } else {
        currentSkinData.genetic.shapeFather += dir;
        if (currentSkinData.genetic.shapeFather > 45) currentSkinData.genetic.shapeFather = 0;
        if (currentSkinData.genetic.shapeFather < 0) currentSkinData.genetic.shapeFather = 45;
        currentSkinData.genetic.skinFather = currentSkinData.genetic.shapeFather;

        let fName = parentsList[currentSkinData.genetic.shapeFather];
        document.getElementById('name-father').innerText = fName;
        document.getElementById('img-father').src = `assets/skinchanger/parents/${fName}.webp`;
    }
    updateGeneticFetch();
}

function updateGenetic() {
    currentSkinData.genetic.shapeMix = parseFloat(document.getElementById('gene-shape-mix').value) / 100;
    currentSkinData.genetic.skinMix = parseFloat(document.getElementById('gene-skin-mix').value) / 100;
    updateGeneticFetch();
}

function updateGeneticFetch() { req('updateSkinParents', currentSkinData.genetic); }

function createSlider(label, id, min, max, val, func) { return `<div class="input-group"><label>${label}</label><input type="range" id="${id}" min="${min}" max="${max}" value="${val}" oninput="${func}"></div>`; }
function createFaceSlider(label, index) { let val = currentSkinData.features[index] || 0.0; return `<div class="input-group"><label>${label}</label><input type="range" min="-100" max="100" value="${val * 100}" oninput="updateFace(${index}, this.value)"></div>`; }
function createOutfitCard(id, name) { let active = currentSkinData.outfit === id ? 'active' : ''; return `<div class="outfit-card ${active}" onclick="selectOutfit('${id}', this)"><img src="assets/default.png"><span>${name}</span></div>`; }

function updateFace(index, value) {
    let floatVal = parseFloat(value) / 100;
    currentSkinData.features[index] = floatVal;
    req('updateFaceFeature', { index: index, value: floatVal });
}

function loadGrid(id, name, isComponent, hasColors, btnElement) {
    activeSubCategory = { id: id, isComp: isComponent };
    if (btnElement) { document.querySelectorAll('.sub-btn').forEach(b => b.classList.remove('active')); btnElement.classList.add('active'); }

    // 1. Gestion des couleurs (Bloc fixe du bas)
    let colorBox = document.getElementById('global-color-box');
    if (hasColors) {
        colorBox.classList.remove('hidden');
        document.getElementById('global-color-p').value = currentSkinData.colors[id]?.primary || 0;
        document.getElementById('global-color-s').value = currentSkinData.colors[id]?.secondary || 0;
    } else {
        colorBox.classList.add('hidden');
    }

    // 2. Gestion de l'opacité (Bloc fixe du bas juste au-dessus des couleurs)
    let opacityContainer = document.getElementById('global-opacity-box');
    if (!isComponent && id !== 'eye') {
        opacityContainer.classList.remove('hidden');
        let op = (currentSkinData.overlays[id]?.op !== undefined) ? currentSkinData.overlays[id].op * 100 : 100;
        opacityContainer.innerHTML = createSlider(`Opacité du ${name}`, `opacity-${id}`, 0, 100, op, `updateOpacity('${id}')`);
    } else {
        opacityContainer.innerHTML = '';
        opacityContainer.classList.add('hidden');
    }

    // 3. Génération de la grille d'images (Zone du milieu uniquement)
    let gridHTML = `<div class="skin-grid">`;
    let currentVal = (id === 'eye') ? (currentSkinData.colors.eye || 0) : (currentSkinData.overlays[id]?.val || 0);
    let maxItems = (id === 2) ? 75 : (id === 'eye' ? 32 : 45); 

    for(let i = 0; i < maxItems; i++) {
        let active = (i === currentVal) ? 'active' : '';
        let imgPath = (id === 'eye') ? `assets/skinchanger/eye_${i}.png` : `assets/skinchanger/${currentGender}_${id}_${i}.png`;
        
        gridHTML += `<div class="skin-item ${active}" id="item-${id}-${i}" onclick="selectGridItem('${id}', ${i}, ${isComponent})">
            <img src="${imgPath}" onerror="this.src='assets/default.png'"><span>#${i}</span></div>`;
    }
    gridHTML += `</div>`;
    
    document.getElementById('grid-container').innerHTML = gridHTML;
}

function selectGridItem(id, val, isComponent) {
    document.querySelectorAll('.skin-item').forEach(el => el.classList.remove('active'));
    let activeItem = document.getElementById(`item-${id}-${val}`);
    if (activeItem) activeItem.classList.add('active');

    if (id === 'eye') {
        currentSkinData.colors.eye = val;
        req('updateEyeColor', { value: val });
        return;
    }

    // FIX ANTI-CRASH 'op' : On initialise l'objet s'il n'existe pas encore en mémoire
    if (!currentSkinData.overlays[id]) {
        currentSkinData.overlays[id] = { val: 0, op: 1.0 };
    }
    currentSkinData.overlays[id].val = val;
    req('updateHeadOverlay', { id: id, value: val, opacity: currentSkinData.overlays[id].op, isComponent: isComponent });
}

function updateOpacity(id) {
    let op = parseFloat(document.getElementById(`opacity-${id}`).value) / 100;
    
    // FIX ANTI-CRASH : Sécurité au cas où on touche au slider d'opacité avant de cliquer sur un item
    if (!currentSkinData.overlays[id]) {
        currentSkinData.overlays[id] = { val: 0, op: 1.0 };
    }
    currentSkinData.overlays[id].op = op;
    req('updateHeadOverlay', { id: id, value: currentSkinData.overlays[id].val, opacity: op, isComponent: false });
}

function applySkinColor() {
    let p = parseInt(document.getElementById('global-color-p').value);
    let s = parseInt(document.getElementById('global-color-s').value);
    currentSkinData.colors[activeSubCategory.id] = { primary: p, secondary: s };
    req('updateSkinColor', { id: activeSubCategory.id, isComponent: activeSubCategory.isComp, primary: p, secondary: s });
}

function selectOutfit(style, cardElement) {
    currentSkinData.outfit = style;
    document.querySelectorAll('.outfit-card').forEach(c => c.classList.remove('active'));
    if (cardElement) cardElement.classList.add('active');
    req('applyPresetOutfit', { style: style, gender: currentGender });
}

function changeCam(type) { req('changeSkinCam', { camType: type }); }
function rotateCam(dir) { req('rotateCam', { dir: dir }); }
function saveSkin() {
    document.getElementById('skinchanger-container').classList.add('hidden');
    req('saveSkinFinal', { skin: currentSkinData, isNewCharacter: isCreatingNew });
}