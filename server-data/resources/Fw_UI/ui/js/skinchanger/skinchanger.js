let currentGender = "male";
let currentSkinData = {};
let isCreatingNew = false; // Nouvelle variable

window.addEventListener('message', function(event) {
    let data = event.data;
    
    if (data.action === "openSkinChanger") {
        currentGender = data.gender;
        isCreatingNew = data.isNewCharacter; // On capture l'info du Lua
        document.getElementById('skinchanger-container').classList.remove('hidden');
        loadSkinCategory(0, 'Visage');
    }
});
// Génère la liste des items
function loadSkinCategory(componentId, catName) {
    // Met à jour les boutons actifs
    document.querySelectorAll('.cat-btn').forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');

    const container = document.getElementById('skin-items-list');
    container.innerHTML = "";

    // On simule 40 items maximum par catégorie pour l'exemple (tu peux adapter selon les limites GTA)
    let maxItems = 45; 
    
    let html = "";
    for(let i = 0; i < maxItems; i++) {
        // Construction dynamique du chemin de l'image (ex: male_2_15.png)
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

// Envoie l'ordre au Lua de modifier le Ped en direct
function applyComponent(componentId, drawableId) {
    // On sauvegarde en mémoire
    currentSkinData[componentId] = drawableId;

    fetch(`https://${GetParentResourceName()}/updateSkinPreview`, {
        method: 'POST',
        body: JSON.stringify({
            component: componentId,
            drawable: drawableId,
            texture: 0 // Texture 0 par défaut
        })
    });
}

function changeCam(type) {
    fetch(`https://${GetParentResourceName()}/changeSkinCam`, {
        method: 'POST',
        body: JSON.stringify({ camType: type })
    });
}

// Dans ta fonction saveSkin() :
function saveSkin() {
    document.getElementById('skinchanger-container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/saveSkinFinal`, {
        method: 'POST',
        // On inclut isNewCharacter dans l'envoi
        body: JSON.stringify({ skin: currentSkinData, isNewCharacter: isCreatingNew })
    });
}