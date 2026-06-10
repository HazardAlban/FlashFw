// Fw_UI/ui/js/skinchanger/skinchanger.js

let currentGender = "male";
let currentSkinData = {};
let isCreatingNew = false;

window.addEventListener('message', function(event) {
    let data = event.data;
    
    if (data.action === "openSkinChanger") {
        currentGender = data.gender;
        isCreatingNew = data.isNewCharacter;
        document.getElementById('skinchanger-container').classList.remove('hidden');
        loadSkinCategory(0, 'Visage'); // Lancement par défaut
    }
});

function loadSkinCategory(componentId, catName) {
    // 1. On nettoie la classe "active" de tous les boutons
    document.querySelectorAll('.cat-btn').forEach(btn => btn.classList.remove('active'));

    // 2. CORRECTION DU BUG ICI : On vérifie l'origine de l'action
    if (window.event && window.event.target && window.event.target.classList && window.event.target.classList.contains('cat-btn')) {
        // C'est un vrai clic de souris du joueur
        window.event.target.classList.add('active');
    } else {
        // C'est l'ouverture automatique du menu : on active le premier bouton (Visage)
        let defaultBtn = document.querySelector('.cat-btn');
        if (defaultBtn) defaultBtn.classList.add('active');
    }

    // 3. Génération de la grille d'images
    const container = document.getElementById('skin-items-list');
    container.innerHTML = "";

    let maxItems = 45; // Nombre max de déclinaisons
    let html = "";
    
    for(let i = 0; i < maxItems; i++) {
        let imgPath = `../assets/skinchanger/${currentGender}_${componentId}_${i}.png`;

        html += `
            <div class="skin-item" onclick="applyComponent(${componentId}, ${i})">
                <img src="${imgPath}" onerror="this.src='../assets/skinchanger/default.png'">
                <span>${catName} #${i}</span>
            </div>
        `;
    }
    container.innerHTML = html;
}

function applyComponent(componentId, drawableId) {
    currentSkinData[componentId] = drawableId;

    fetch(`https://${GetParentResourceName()}/updateSkinPreview`, {
        method: 'POST',
        body: JSON.stringify({
            component: componentId,
            drawable: drawableId,
            texture: 0
        })
    });
}

function changeCam(type) {
    fetch(`https://${GetParentResourceName()}/changeSkinCam`, {
        method: 'POST',
        body: JSON.stringify({ camType: type })
    });
}

function saveSkin() {
    document.getElementById('skinchanger-container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/saveSkinFinal`, {
        method: 'POST',
        body: JSON.stringify({ skin: currentSkinData, isNewCharacter: isCreatingNew })
    });
}