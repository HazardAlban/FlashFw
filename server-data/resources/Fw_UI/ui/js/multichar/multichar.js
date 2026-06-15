let charsData = [];
let selectedCharId = null;

window.addEventListener('message', function (event) {
    if (event.data.action === "openMultichar") {
        charsData = event.data.characters || []; // Sauvegarde les données reçues
        document.getElementById('multichar-container').classList.remove('hidden');
        document.getElementById('char-info-sidebar').style.display = "none";
        loadCharacters(charsData, event.data.maxSlots || 4);
    }
    if (event.data.action === "closeMultichar") {
        document.getElementById('multichar-container').classList.add('hidden');
    }
});

function loadCharacters(chars, maxSlots) {
    const list = document.getElementById('char-list');
    list.innerHTML = "";
    document.getElementById('btn-play-char').style.display = "none";

    for(let i = 0; i < maxSlots; i++) {
        let char = chars[i]; 

        if (char) {
            list.innerHTML += `
                <div class="char-card" onclick="selectCharacter(${char.id}, this)">
                    <div class="char-name">${char.firstname} ${char.lastname}</div>
                    <div class="char-info">Né(e) le : ${char.dateofbirth}</div>
                </div>
            `;
        } else {
            list.innerHTML += `
                <div class="char-card empty-slot" onclick="createNewCharacter()">
                    <div class="char-name"><i class="fa-solid fa-plus"></i> Créer une identité</div>
                    <div class="char-info">Emplacement #${i + 1} libre</div>
                </div>
            `;
        }
    }
}

function selectCharacter(id, element) {
    selectedCharId = id;
    document.querySelectorAll('.char-card').forEach(c => c.classList.remove('active'));
    element.classList.add('active');
    
    // Affiche le bouton "Jouer" et le menu de droite
    document.getElementById('btn-play-char').style.display = "block";
    document.getElementById('char-info-sidebar').style.display = "flex";

    // Retrouve le personnage cliqué
    let char = charsData.find(c => c.id == id);
    if (!char) return;

    let sexFormat = (char.sex === 'm' || char.sex === 'M') ? 'Masculin' : 'Féminin';
    let natFormat = char.nationality || 'Non renseignée';

    // Remplissage du menu de droite
    document.getElementById('char-info-content').innerHTML = `
        <div class="info-group">
            <label>Identité</label>
            <span>${char.firstname} ${char.lastname}</span>
        </div>
        <div class="info-group">
            <label>Date de Naissance</label>
            <span>${char.dateofbirth}</span>
        </div>
        <div class="info-group">
            <label>Nationalité / Sexe</label>
            <span>${natFormat} - ${sexFormat}</span>
        </div>
        <div class="info-group finance">
            <label>Fonds Bancaires</label>
            <span>$ 5 000</span>
        </div>
    `;

    // Envoi des infos AU LUA pour charger le visuel
    fetch(`https://${GetParentResourceName()}/previewCharacter`, { 
        method: 'POST', 
        body: JSON.stringify({ id: id, skin: char.skin, sex: char.sex }) 
    }).catch(() => { });
}

function playCharacter() {
    if (!selectedCharId) return;
    document.getElementById('multichar-container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/playCharacter`, { method: 'POST', body: JSON.stringify({ id: selectedCharId }) }).catch(() => { });
}

function createNewCharacter() {
    fetch(`https://${GetParentResourceName()}/createNewCharacter`, { method: 'POST' }).catch(() => { });
}