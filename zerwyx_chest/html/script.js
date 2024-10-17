window.addEventListener('message', function(event) {
    if (event.data.action === 'openMainMenu') {
        document.getElementById('adminMenu').style.display = 'block';  
        document.getElementById('actionsMenu').style.display = 'none';
        document.getElementById('changeCodeMenu').style.display = 'none';
        document.getElementById('chestList').innerHTML = '';

        window.cachedChests = event.data.chests;

        event.data.chests.forEach(chest => {
            let li = document.createElement('li');
            li.innerHTML = `
                Coffre (${chest.distance.toFixed(2)}m)
                <button onclick="openActionMenu('${chest.identifier}', ${chest.x}, ${chest.y}, ${chest.z}, '${chest.code}')">
                    <i class="fas fa-tools"></i>
                </button>
            `;
            document.getElementById('chestList').appendChild(li);
        });
    } else if (event.data.action === 'closeMenu') {
        closeMenu();
    } else if (event.data.action === 'showNotification') {
        showNotification(event.data.id, event.data.message, event.data.icon, event.data.type);
    }
});

function showMainMenu(chests) {
    document.getElementById('adminMenu').style.display = 'block';
    document.getElementById('actionsMenu').style.display = 'none';
    document.getElementById('changeCodeMenu').style.display = 'none';
    document.getElementById('chestList').innerHTML = '';

    chests.forEach(chest => {
        let li = document.createElement('li');
        li.innerHTML = `
            Coffre (${chest.distance.toFixed(2)}m)
            <button onclick="openActionMenu('${chest.identifier}', ${chest.x}, ${chest.y}, ${chest.z}, '${chest.code}')">
                <i class="fas fa-tools"></i>
            </button>
        `;
        document.getElementById('chestList').appendChild(li);
    });
}

function openActionMenu(identifier, x, y, z, code) {
    document.getElementById('actionsList').innerHTML = `
        <li onclick="triggerAction('view_inventory', '${identifier}')">🔍 Voir l'inventaire</li>
        <li onclick="triggerAction('tp_to_chest', '${identifier}', ${x}, ${y}, ${z})">📍 Se téléporter</li>
        <li onclick="openChangeCodeMenu('${identifier}', ${x}, ${y}, ${z})">🔑 Modifier le code</li>
        <li onclick="triggerAction('view_code', '${identifier}', '${code}')">👁️ Voir le code</li>
       <li onclick="openConfirmDeleteMenu('${identifier}', ${x}, ${y}, ${z})">🗑️ Supprimer le coffre</li>
    `;
    document.getElementById('adminMenu').style.display = 'none';
    document.getElementById('actionsMenu').style.display = 'block';
}

function confirmDeleteChest(identifier, x, y, z) {
    const confirmDelete = confirm("Êtes-vous sûr de vouloir supprimer ce coffre ?");
    
    if (confirmDelete) {
        triggerAction('delete_chest', identifier, x, y, z);
    } else {
        console.log("Suppression annulée.");
    }
}

function openChangeCodeMenu(identifier, x, y, z) {
    document.getElementById('adminMenu').style.display = 'none';
    document.getElementById('actionsMenu').style.display = 'none';
    document.getElementById('changeCodeMenu').style.display = 'block';

    document.getElementById('changeCodeForm').onsubmit = function(event) {
        event.preventDefault();

        let newCode = document.getElementById('newCodeInput').value.trim();

        if (newCode) {
            console.log(`Nouveau code saisi : ${newCode}`);

            fetch(`https://zerwyx_chest/submitNewCode`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    action: 'submitNewCode',
                    identifier: identifier,
                    newCode: newCode,
                    coords: { x: x, y: y, z: z }
                })
            });
        } else {
            alert("Veuillez entrer un code valide.");
        }
    };

    document.getElementById('cancelButton').onclick = function() {
        document.getElementById('changeCodeMenu').style.display = 'none';
        document.getElementById('actionsMenu').style.display = 'block';
    };
}

function openConfirmDeleteMenu(identifier, x, y, z) {
    document.getElementById('confirmDeletionMenu').style.display = 'block';
    document.getElementById('actionsMenu').style.display = 'none';

    document.getElementById('confirmDeleteButton').onclick = function() {
        fetch(`https://zerwyx_chest/confirmDelete`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                confirmed: true,
                identifier: identifier,
                coords: { x: x, y: y, z: z }
            })
        });
        closeConfirmDeleteMenu();
        closeMenu();
    };

    document.getElementById('cancelDeleteButton').onclick = function() {
        fetch(`https://zerwyx_chest/confirmDelete`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                confirmed: false,
                identifier: identifier
            })
        });
        closeConfirmDeleteMenu();
        document.getElementById('actionsMenu').style.display = 'block';
    };
}

function closeConfirmDeleteMenu() {
    document.getElementById('confirmDeletionMenu').style.display = 'none';
}

const notificationCounter = {};

function createNotificationContainer() {
    const container = document.createElement('div');
    container.id = 'notificationContainer';
    container.style.position = 'fixed';
    container.style.top = '10px';
    container.style.right = '10px';
    container.style.zIndex = '1000';
    document.body.appendChild(container);
    return container;
}

function showNotification(id, message, icon, type = "info") {
    const notificationContainer = document.getElementById('notificationContainer') || createNotificationContainer();

    if (notificationCounter[id]) {
        notificationCounter[id]++;
        document.getElementById(`notif-${id}`).querySelector('.counter').textContent = notificationCounter[id];
    } else {
        let notification = document.createElement('div');
        notification.classList.add('notification', type, 'show');
        notification.id = `notif-${id}`;
        notification.style.display = 'flex';
        notification.style.alignItems = 'center';
        notification.style.backgroundColor = type === 'success' ? '#28a745' : (type === 'error' ? '#dc3545' : '#17a2b8');
        notification.style.color = '#fff';
        notification.style.padding = '10px';
        notification.style.marginBottom = '10px';
        notification.style.borderRadius = '5px';
        notification.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.2)';
        notification.innerHTML = `
            <i class="fas ${icon}" style="margin-right: 10px;"></i>
            <span style="flex: 1;">${message}</span>
            <div class="counter" style="background-color: #333; border-radius: 50%; width: 20px; height: 20px; display: flex; justify-content: center; align-items: center;">1</div>
        `;

        notificationContainer.appendChild(notification);

        notificationCounter[id] = 1;

        setTimeout(() => {
            notification.remove();
            delete notificationCounter[id];
        }, 5000);
    }
}

document.getElementById('backButton').addEventListener('click', function() {
    if (window.cachedChests) {
        showMainMenu(window.cachedChests);
    }
});

document.getElementById('closeButtonAdmin').addEventListener('click', function() {
    closeMenu();
});

document.getElementById('closeButtonActions').addEventListener('click', function() {
    closeMenu();
});

document.addEventListener('keydown', function(event) {
    if (event.key === "Escape") {
        closeMenu();
    }
});

function closeMenu() {
    console.log("Menu fermé");
    document.getElementById('adminMenu').style.display = 'none';
    document.getElementById('actionsMenu').style.display = 'none';
    document.getElementById('changeCodeMenu').style.display = 'none';

    fetch(`https://zerwyx_chest/closeMenu`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function confirmDeleteChest(identifier, x, y, z) {
    const confirmDelete = confirm("Êtes-vous sûr de vouloir supprimer ce coffre ?");
    if (confirmDelete) {
        triggerAction('delete_chest', identifier, x, y, z);
    }
}

function triggerAction(action, identifier, x, y, z, code) {
    console.log("[CLIENT] Action envoyée : " + action + " avec l'identifiant : " + identifier);

    fetch(`https://zerwyx_chest/action`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            action: action,
            identifier: identifier,
            coords: { x: x, y: y, z: z },
            code: code
        })
    }).then(response => response.json())
      .then(data => {
          console.log("Réponse du serveur :", data);
      }).catch(error => {
          console.error("Erreur lors de l'envoi de l'action :", error);
      });
}
