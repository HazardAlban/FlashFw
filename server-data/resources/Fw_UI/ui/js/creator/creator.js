// Fw_UI/src/web/js/creator.js

let selectedGender = "m";

// Écouteur de message pour ouvrir l'interface depuis le Lua
window.addEventListener('message', function(event) {
    print("Message reçu dans creator.js :", event.data);
    if (event.data.action === "openCreatorIdentity") {
        document.getElementById('creator-container').classList.remove('hidden');
        resetCreatorForm();
    }
});

function setGender(gender) {
    selectedGender = gender;
    document.getElementById('gender-m').classList.remove('active');
    document.getElementById('gender-f').classList.remove('active');

    if (gender === 'm') {
        document.getElementById('gender-m').classList.add('active');
    } else {
        document.getElementById('gender-f').classList.add('active');
    }
}

function resetCreatorForm() {
    document.getElementById('creator-form').reset();
    setGender('m');
}

function submitIdentity(event) {
    event.preventDefault(); // Empêche le refresh HTML

    const firstname = document.getElementById('char-firstname').value.trim();
    const lastname = document.getElementById('char-lastname').value.trim();
    const dob = document.getElementById('char-dob').value;
    const nationality = document.getElementById('char-nationality').value.trim();

    // Envoi des données d'identité au client Lua de Fw_UI
    fetch(`https://${GetParentResourceName()}/submitCharacterIdentity`, {
        method: 'POST',
        body: JSON.stringify({
            firstname: firstname,
            lastname: lastname,
            dateofbirth: dob,
            nationality: nationality,
            sex: selectedGender
        })
    });

    // On cache l'interface une fois validée
    document.getElementById('creator-container').classList.add('hidden');
}