const isDev = false;

var fakeCrewData = {
    haveCrew: false,
    isLeader: false,
    crewName: "Test Crew",
    crewTag: "TC",
    crewDescription:
        "This is a test crew for demonstration purposes. We are the best crew in the server!",
    crewTotalKills: 247,
    crewTotalKillsRedzone: 89,
    crewTotalAirdrops: 15,
    crewTotalCupWins: 1,
    crewMembers: [
        {
            id: 1411,
            name: "Loris29p",
            rank: "Leader",
            rankId: "leader",
            online: true,
            lastOnline: "2025-05-30 12:00:00",
        },
        {
            id: 1412,
            name: "Player2",
            rank: "Modo",
            rankId: "recruit",
            online: false,
            lastOnline: "2025-05-30 12:00:00",
        },
        {
            id: 1413,
            name: "Player3",
            rank: "Member",
            rankId: "member",
            online: false,
            lastOnline: "2025-05-30 12:00:00",
        },
        {
            id: 1413,
            name: "Player3",
            rank: "Member",
            rankId: "member",
            online: false,
            lastOnline: "2025-05-30 12:00:00",
        },
        {
            id: 1413,
            name: "Player3",
            rank: "Member",
            rankId: "member",
            online: false,
            lastOnline: "2025-05-30 12:00:00",
        },
        {
            id: 1413,
            name: "Player3",
            rank: "Member",
            rankId: "member",
            online: false,
            lastOnline: "2025-05-30 12:00:00",
        },
        {
            id: 1413,
            name: "Player3",
            rank: "Member",
            rankId: "member",
            online: false,
            lastOnline: "2025-05-30 12:00:00",
        },
        {
            id: 1413,
            name: "Player3",
            rank: "Member",
            rankId: "member",
            online: false,
            lastOnline: "2025-05-30 12:00:00",
        },
    ],
};

window.addEventListener("message", function (event) {
    const data = event.data;
    switch (data.type) {
        case "sendCrewData":
            fakeCrewData.haveCrew = data.haveCrew;
            fakeCrewData.isLeader = data.isLeader;
            fakeCrewData.crewName = data.crewName;
            fakeCrewData.crewTag = data.crewTag;
            fakeCrewData.crewDescription = data.crewDescription;
            fakeCrewData.crewTotalKills = data.crewTotalKills || 0;
            fakeCrewData.crewTotalKillsRedzone = data.crewTotalKillsRedzone || 0;
            fakeCrewData.crewTotalAirdrops = data.crewTotalAirdrops || 0;
            fakeCrewData.crewTotalCupWins = data.crewTotalCupWins || 0;
            fakeCrewData.crewMembers = data.crewMembers;
            setupCrew();
            break;
    }
});

function leaveCrew() {
    console.log("leave crew")
    // Empêcher de quitter si l'utilisateur est leader
    if (fakeCrewData.isLeader) {

        console.log("Cant leave crew as leader")
        showNotification("Vous ne pouvez pas quitter le crew en tant que leader. Transférez d'abord la propriété à un autre membre.", "error");
        return;
    }
    
    fetch("https://gamemode/leaveCrew", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({}),
    });
    if (isDev) {
        fakeCrewData.haveCrew = false;
    }
    setupCrew();
}

$(document).ready(function () {
    setupCrew();

    $("#crew-leave-btn").click(function () {
        console.log("leave crew")
        // Empêcher de quitter si l'utilisateur est leader
        if (fakeCrewData.isLeader) {

            console.log("Cant leave crew as leader")
            showNotification("Vous ne pouvez pas quitter le crew en tant que leader. Transférez d'abord la propriété à un autre membre.", "error");
            return;
        }
        
        fetch("https://gamemode/leaveCrew", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({}),
        });
        if (isDev) {
            fakeCrewData.haveCrew = false;
        }
        setupCrew();
    });
});

function fetchCrewData() {
    fetch("https://gamemode/getCrewData", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({}),
    });
}

function InviteToCrew() {
    console.log("InviteToCrew")
    fetch("https://gamemode/inviteToCrew", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({}),
    });
    $.post("https://gamemode/Close");
}

function setupCrew() {
    if (doesHaveCrew()) {
        $(".crew-content-doesnt-have-crew").hide();
        $(".crew-content").show();

        $("#crew-title").text(fakeCrewData.crewName);
        $("#crew-leave-btn").show();

        // Griser le bouton leave si l'utilisateur est leader
        if (fakeCrewData.isLeader) {
            $("#crew-leave-btn").prop("disabled", true).addClass("disabled");
        } else {
            $("#crew-leave-btn").prop("disabled", false).removeClass("disabled");
        }

        // Gérer les boutons editCrewInfo et announcement selon le statut de leader
        if (fakeCrewData.isLeader) {
            $("#editCrewInfo-btn").prop("disabled", false).removeClass("disabled");
            $("#announcement-btn").prop("disabled", false).removeClass("disabled");
            $("#invite-btn").prop("disabled", false).removeClass("disabled");
        } else {
            $("#editCrewInfo-btn").prop("disabled", true).addClass("disabled");
            $("#announcement-btn").prop("disabled", true).addClass("disabled");
            $("#invite-btn").prop("disabled", true).addClass("disabled");
        }

        // Afficher le tag si disponible
        if (fakeCrewData.crewTag) {
            $("#crew-tag").text(`[${fakeCrewData.crewTag}]`).show();
        } else {
            $("#crew-tag").hide();
        }

        // Afficher la description si disponible
        if (fakeCrewData.crewDescription) {
            $("#crew-description-text").text(fakeCrewData.crewDescription);
            $("#crew-description-container").show();
        } else {
            $("#crew-description-container").hide();
        }

        $("#crew-content-members-count").show();
        $("#crew-members-count").text(fakeCrewData.crewMembers.length);

        // Afficher les statistiques du crew
        $("#crew-kills-count").text(fakeCrewData.crewTotalKills || 0);
        $("#crew-killsredzone-count").text(fakeCrewData.crewTotalKillsRedzone || 0);
        $("#crew-airdrops-count").text(fakeCrewData.crewTotalAirdrops || 0);
        $("#crew-cupwins-count").text(fakeCrewData.crewTotalCupWins || 0);

        // Remplir le tableau des membres
        populateMembersTable();
    } else {
        $(".crew-content-doesnt-have-crew").show();
        $(".crew-content").hide();
        $("#crew-title").text("Crew");
        $("#crew-tag").hide();
        $("#crew-description-container").hide();
        $("#crew-leave-btn").hide();
        $("#crew-content-members-count").hide();

        // Réinitialiser les statistiques
        $("#crew-kills-count").text("0");
        $("#crew-killsredzone-count").text("0");
        $("#crew-airdrops-count").text("0");
        $("#crew-cupwins-count").text("0");
    }
}

function populateMembersTable() {
    const tbody = document.getElementById("crew-members-tbody");
    tbody.innerHTML = "";

    fakeCrewData.crewMembers.forEach((member, index) => {
        console.log(member.rank, member.uuid, member.username)
        const row = document.createElement("tr");

        // Déterminer le rang
        const rankClass = member.rank === "leader" ? "leader" : "newbie";
        const rankText = member.rank || "Newbie";

        // Utiliser le statut réel du membre
        const isOnline = member.online;
        const statusClass = isOnline ? "online" : "offline";
        const statusText = isOnline ? "Online" : "Offline";

        // Utiliser la vraie date d'activité
        let lastActivity;
        if (isOnline) {
            lastActivity = "Now";
        } else {
            // Formater la date lastOnline
            if (member.lastOnline) {
                const lastOnlineDate = new Date(member.lastOnline);
                const now = new Date();
                const diffTime = Math.abs(now - lastOnlineDate);
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

                if (diffDays === 1) {
                    lastActivity = "1 day ago";
                } else if (diffDays < 7) {
                    lastActivity = `${diffDays} days ago`;
                } else {
                    lastActivity = lastOnlineDate.toLocaleDateString();
                }
            } else {
                lastActivity = "N/A";
            }
        }

        row.innerHTML = `
            <td>
                <span class="member-rank ${rankClass}">${rankText}</span>
            </td>
            <td class="member-nickname">${member.username}</td>
            <td class="member-kills">${member.kills}</td>
            <td class="member-kills-redzone">${member.killsRedzone}</td>
            <td class="member-airdrop-taken">${member.aidropTaken}</td>
            <td>
                <span class="member-status ${statusClass}">${statusText}</span>
            </td>
            <td class="member-activity">${lastActivity}</td>
            <td>
                <button class="member-action-btn" onclick="openMemberActions('${member.username}', ${member.uuid}, ${index}, event)">ACTIONS</button>
            </td>
        `;

        tbody.appendChild(row);
    });
}

function openMemberActions(memberName, memberId, memberIndex, event) {
    // Fermer tout menu existant
    closeMemberActionsMenu();

    // Trouver les informations du membre
    const member = fakeCrewData.crewMembers.find((m) => m.uuid === memberId);
    if (!member) return;

    // Créer le menu d'actions
    const actionsMenu = document.createElement("div");
    actionsMenu.className = "member-actions-menu";
    actionsMenu.id = "member-actions-menu";

    // Créer les options du menu
    const actions = [];

    // Option Kick (sauf pour le leader)

    console.log(member.rank, "rankId", memberName, "name")
    if (member.rank !== "leader" && member.rank !== "coleader") {
        actions.push({
            icon: "fa-user-xmark",
            text: "Kick",
            class: "action-kick",
            onclick: () => kickMember(memberId, memberName),
        });
    }

    // Option Promote (seulement si pas déjà leader)
    if (member.rank !== "leader" && member.rank !== "coleader") {
        actions.push({
            icon: "fa-user-tie",
            text: "Promote",
            class: "action-promote",
            onclick: () => promoteMember(memberId, memberName),
        });
    }

    // Option Demote (seulement si pas déjà membre de base)
    if (member.rank !== "newbie" && member.rank !== "leader" && member.rank !== "coleader") {
        actions.push({
            icon: "fa-user-minus",
            text: "Demote",
            class: "action-demote",
            onclick: () => demoteMember(memberId, memberName),
        });
    }

    // Option Transfer Ownership (seulement pour le leader actuel)
    const currentUserIsLeader = fakeCrewData.isLeader; // À adapter selon votre logique
    if (currentUserIsLeader && member.rank !== "leader") {
        actions.push({
            icon: "fa-money-bill-transfer",
            text: "Transfer Ownership",
            class: "action-transfer",
            onclick: () => transferOwnership(memberId, memberName),
        });
    }

    // Créer les éléments du menu
    actions.forEach((action) => {
        const actionItem = document.createElement("div");
        actionItem.className = `member-action-item ${action.class}`;
        actionItem.innerHTML = `
            <span class="action-icon"><i class="fa-solid ${action.icon}"></i></span>
            <span class="action-text">${action.text}</span>
        `;
        actionItem.onclick = () => {
            action.onclick();
            closeMemberActionsMenu();
        };
        actionsMenu.appendChild(actionItem);
    });

    // Positionner le menu près du bouton cliqué
    const button = event.target;
    const buttonRect = button.getBoundingClientRect();

    actionsMenu.style.position = "fixed";
    actionsMenu.style.left = `${buttonRect.left}px`;
    actionsMenu.style.zIndex = "1000";

    // Si l'index du joueur est supérieur à 4, afficher au-dessus, sinon en dessous
    if (memberIndex > 3) {
        actionsMenu.style.bottom = `${window.innerHeight - buttonRect.top + 5}px`;
    } else {
        actionsMenu.style.top = `${buttonRect.bottom + 5}px`;
    }

    // Ajouter le menu au DOM
    document.body.appendChild(actionsMenu);

    // Fermer le menu en cliquant ailleurs
    setTimeout(() => {
        document.addEventListener("click", closeMemberActionsMenu);
    }, 100);
}

function closeMemberActionsMenu() {
    const existingMenu = document.getElementById("member-actions-menu");
    if (existingMenu) {
        existingMenu.remove();
        document.removeEventListener("click", closeMemberActionsMenu);
    }
}

function kickMember(memberId, memberName) {
    console.log("Kicking member:", memberName, "ID:", memberId);
    fetch("https://gamemode/crewKickMember", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ memberId: memberId, memberName: memberName }),
    });

    // Retirer le membre de la liste locale (pour l'exemple)
    fakeCrewData.crewMembers = fakeCrewData.crewMembers.filter((m) => m.uuid !== memberId);
    populateMembersTable();
}

function promoteMember(memberId, memberName) {
    console.log("Promoting member:", memberName, "ID:", memberId);
    fetch("https://gamemode/crewPromoteMember", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ memberId: memberId, memberName: memberName }),
    });

    // Mettre à jour le rang localement (pour l'exemple)
    const member = fakeCrewData.crewMembers.find((m) => m.uuid === memberId);
    if (member && member.rank === "newbie") {
        member.rank = "coleader";
        member.rankId = "coleader";
        populateMembersTable();
    }
}

function demoteMember(memberId, memberName) {
    console.log("Demoting member:", memberName, "ID:", memberId);
    fetch("https://gamemode/crewDemoteMember", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ memberId: memberId, memberName: memberName }),
    });

    // Mettre à jour le rang localement (pour l'exemple)
    const member = fakeCrewData.crewMembers.find((m) => m.uuid === memberId);
    if (member && member.rank === "coleader") {
        member.rank = "newbie";
        member.rankId = "newbie";
        populateMembersTable();
    }
}

function transferOwnership(memberId, memberName) {
    console.log("Transferring ownership to:", memberName, "ID:", memberId);

    // Confirmation avant transfert
    if (confirm(`Êtes-vous sûr de vouloir transférer la propriété du crew à ${memberName} ?`)) {
        fetch("https://gamemode/crewTransferOwnership", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ memberId: memberId, memberName: memberName }),
        });

        // Mettre à jour les rangs localement (pour l'exemple)
        fakeCrewData.crewMembers.forEach((member) => {
            if (member.uuid === memberId) {
                member.rank = "leader";
                member.rankId = "leader";
            } else if (member.rank === "leader") {
                member.rank = "coleader";
                member.rankId = "coleader";
            }
        });
        populateMembersTable();
    }
}

function doesHaveCrew() {
    if (fakeCrewData.haveCrew) {
        return true;
    } else {
        return false;
    }
}

function CreateCrew() {
    // Créer la popup overlay
    const popupOverlay = document.createElement("div");
    popupOverlay.className = "crew-popup-overlay";

    // Créer le contenu de la popup
    const popupContent = document.createElement("div");
    popupContent.className = "crew-popup-content";

    // Titre de la popup
    const popupTitle = document.createElement("h3");
    popupTitle.className = "crew-popup-title";
    popupTitle.textContent = "CREATE A CREW";

    // Input pour le nom du crew
    const crewNameInput = document.createElement("input");
    crewNameInput.type = "text";
    crewNameInput.className = "crew-name-input";
    crewNameInput.placeholder = "Crew name...";
    crewNameInput.maxLength = 20;

    // Input pour le tag du crew
    const crewTagInput = document.createElement("input");
    crewTagInput.type = "text";
    crewTagInput.className = "crew-tag-input";
    crewTagInput.placeholder = "Crew tag (3-5 characters)";
    crewTagInput.maxLength = 5;

    // Textarea pour la description du crew
    const crewDescriptionInput = document.createElement("textarea");
    crewDescriptionInput.className = "crew-description-input";
    crewDescriptionInput.placeholder = "Crew description...";
    crewDescriptionInput.maxLength = 200;
    crewDescriptionInput.rows = 3;

    // Container pour les boutons
    const buttonContainer = document.createElement("div");
    buttonContainer.className = "crew-popup-buttons";

    // Bouton Créer
    const createButton = document.createElement("button");
    createButton.className = "crew-popup-btn crew-create-btn";
    createButton.textContent = "CREATE";
    createButton.onclick = function () {
        const crewName = crewNameInput.value.trim();
        const crewTag = crewTagInput.value.trim();
        const crewDescription = crewDescriptionInput.value.trim();

        // Validation
        let hasError = false;

        if (crewName.length < 3) {
            crewNameInput.style.borderColor = "#F31439";
            crewNameInput.placeholder = "The name must contain at least 3 characters";
            hasError = true;
        } else {
            crewNameInput.style.borderColor = "";
        }

        if (crewTag.length < 3 || crewTag.length > 5) {
            crewTagInput.style.borderColor = "#F31439";
            crewTagInput.placeholder = "The tag must be between 3 and 5 characters";
            hasError = true;
        } else {
            crewTagInput.style.borderColor = "";
        }

        if (crewDescription.length < 1) {
            crewDescriptionInput.style.borderColor = "#F31439";
            crewDescriptionInput.placeholder = "The description must contain at least 1 characters";
            hasError = true;
        } else {
            crewDescriptionInput.style.borderColor = "";
        }

        if (!hasError) {
            console.log(
                "Creation du crew:",
                crewName,
                "Tag:",
                crewTag,
                "Description:",
                crewDescription
            );
            // Ici vous pouvez ajouter la logique pour envoyer les données au serveur
            fetch("https://gamemode/createCrew", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    crewName: crewName,
                    crewTag: crewTag,
                    crewDescription: crewDescription,
                }),
            })
                .then((resp) => resp.json())
                .then((resp) => {
                    if (resp.success) {
                        showNotification(resp.message, "success");
                        closeCrewPopup();
                        if (isDev) {
                            fakeCrewData.haveCrew = true;
                            fakeCrewData.crewName = crewName;
                            fakeCrewData.crewTag = crewTag;
                            fakeCrewData.crewDescription = crewDescription;
                            fakeCrewData.crewMembers = [
                                {
                                    name: "John Doe",
                                    rank: "Leader",
                                    rankId: "leader",
                                    online: true,
                                    lastOnline: "2025-05-30 12:00:00",
                                },
                            ];
                            setupCrew();
                        }
                    } else {
                        showNotification(resp.message, "error");
                    }
                });
        }
    };

    // Bouton Annuler
    const cancelButton = document.createElement("button");
    cancelButton.className = "crew-popup-btn crew-cancel-btn";
    cancelButton.textContent = "CANCEL";
    cancelButton.onclick = closeCrewPopup;

    // Assembler la popup
    buttonContainer.appendChild(createButton);
    buttonContainer.appendChild(cancelButton);

    popupContent.appendChild(popupTitle);
    popupContent.appendChild(crewNameInput);
    popupContent.appendChild(crewTagInput);
    popupContent.appendChild(crewDescriptionInput);
    popupContent.appendChild(buttonContainer);

    popupOverlay.appendChild(popupContent);
    document.body.appendChild(popupOverlay);

    // Focus sur l'input
    setTimeout(() => {
        crewNameInput.focus();
    }, 100);

    // Fermer avec Escape
    document.addEventListener("keydown", function (e) {
        if (e.key === "Escape") {
            closeCrewPopup();
        }
    });

    // Créer avec Enter (seulement si pas dans la textarea)
    crewNameInput.addEventListener("keydown", function (e) {
        if (e.key === "Enter") {
            createButton.click();
        }
    });

    crewTagInput.addEventListener("keydown", function (e) {
        if (e.key === "Enter") {
            createButton.click();
        }
    });

    // Fermer en cliquant sur l'overlay
    popupOverlay.addEventListener("click", function (e) {
        if (e.target === popupOverlay) {
            closeCrewPopup();
        }
    });
}

function closeCrewPopup() {
    const popup = document.querySelector(".crew-popup-overlay");
    if (popup) {
        popup.remove();
    }
}

function editCrewInfo() {
    // Créer la popup overlay
    const popupOverlay = document.createElement("div");
    popupOverlay.className = "crew-popup-overlay";

    // Créer le contenu de la popup
    const popupContent = document.createElement("div");
    popupContent.className = "crew-popup-content";

    // Titre de la popup
    const popupTitle = document.createElement("h3");
    popupTitle.className = "crew-popup-title";
    popupTitle.textContent = "EDIT CREW INFO";

    // Input pour le tag du crew
    const crewTagInput = document.createElement("input");
    crewTagInput.type = "text";
    crewTagInput.className = "crew-tag-input";
    crewTagInput.placeholder = "Crew tag (3-5 characters)";
    crewTagInput.maxLength = 5;
    crewTagInput.value = fakeCrewData.crewTag || "";

    // Textarea pour la description du crew
    const crewDescriptionInput = document.createElement("textarea");
    crewDescriptionInput.className = "crew-description-input";
    crewDescriptionInput.placeholder = "Crew description...";
    crewDescriptionInput.maxLength = 200;
    crewDescriptionInput.rows = 3;
    crewDescriptionInput.value = fakeCrewData.crewDescription || "";

    // Container pour les boutons
    const buttonContainer = document.createElement("div");
    buttonContainer.className = "crew-popup-buttons";

    // Bouton Sauvegarder
    const saveButton = document.createElement("button");
    saveButton.className = "crew-popup-btn crew-create-btn";
    saveButton.textContent = "SAVE";
    saveButton.onclick = function () {
        const crewTag = crewTagInput.value.trim();
        const crewDescription = crewDescriptionInput.value.trim();

        // Validation
        let hasError = false;

        if (crewTag.length > 0 && (crewTag.length < 3 || crewTag.length > 5)) {
            crewTagInput.style.borderColor = "#F31439";
            crewTagInput.placeholder = "The tag must be between 3 and 5 characters";
            hasError = true;
        } else {
            crewTagInput.style.borderColor = "";
        }

        if (crewDescription.length > 0 && crewDescription.length < 1) {
            crewDescriptionInput.style.borderColor = "#F31439";
            crewDescriptionInput.placeholder =
                "The description must contain at least 10 characters";
            hasError = true;
        } else {
            crewDescriptionInput.style.borderColor = "";
        }

        if (!hasError) {
            console.log("Editing crew info - Tag:", crewTag, "Description:", crewDescription);
            fetch("https://gamemode/editCrewInfo", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    crewTag: crewTag,
                    crewDescription: crewDescription,
                }),
            });

            // Mettre à jour les données locales
            if (isDev) {
                fakeCrewData.crewTag = crewTag;
                fakeCrewData.crewDescription = crewDescription;
            }

            closeCrewEditPopup();
            setupCrew();
        }
    };

    // Bouton Annuler
    const cancelButton = document.createElement("button");
    cancelButton.className = "crew-popup-btn crew-cancel-btn";
    cancelButton.textContent = "CANCEL";
    cancelButton.onclick = closeCrewEditPopup;

    // Assembler la popup
    buttonContainer.appendChild(saveButton);
    buttonContainer.appendChild(cancelButton);

    popupContent.appendChild(popupTitle);
    popupContent.appendChild(crewTagInput);
    popupContent.appendChild(crewDescriptionInput);
    popupContent.appendChild(buttonContainer);

    popupOverlay.appendChild(popupContent);
    document.body.appendChild(popupOverlay);

    // Focus sur l'input
    setTimeout(() => {
        crewTagInput.focus();
    }, 100);

    // Fermer avec Escape
    document.addEventListener("keydown", function (e) {
        if (e.key === "Escape") {
            closeCrewEditPopup();
        }
    });

    // Sauvegarder avec Enter (seulement si pas dans la textarea)
    crewTagInput.addEventListener("keydown", function (e) {
        if (e.key === "Enter") {
            saveButton.click();
        }
    });

    // Fermer en cliquant sur l'overlay
    popupOverlay.addEventListener("click", function (e) {
        if (e.target === popupOverlay) {
            closeCrewEditPopup();
        }
    });
}

function closeCrewEditPopup() {
    const popup = document.querySelector(".crew-popup-overlay");
    if (popup) {
        popup.remove();
    }
}

function openAnnouncementPopup() {
    // Créer la popup overlay
    const popupOverlay = document.createElement("div");
    popupOverlay.className = "crew-popup-overlay";

    // Créer le contenu de la popup
    const popupContent = document.createElement("div");
    popupContent.className = "crew-popup-content";

    // Titre de la popup
    const popupTitle = document.createElement("h3");
    popupTitle.className = "crew-popup-title";
    popupTitle.textContent = "SEND ANNOUNCEMENT";

    // Textarea pour le message d'annonce
    const announcementInput = document.createElement("textarea");
    announcementInput.className = "crew-description-input";
    announcementInput.placeholder = "Write your announcement message...";
    announcementInput.maxLength = 500;
    announcementInput.rows = 4;

    // Compteur de caractères
    const charCounter = document.createElement("div");
    charCounter.className = "char-counter";
    charCounter.textContent = "0/500";

    // Mettre à jour le compteur en temps réel
    announcementInput.addEventListener("input", function () {
        const currentLength = this.value.length;
        charCounter.textContent = `${currentLength}/500`;

        if (currentLength > 450) {
            charCounter.style.color = "#F31439";
        } else if (currentLength > 400) {
            charCounter.style.color = "#FFA726";
        } else {
            charCounter.style.color = "rgba(255, 255, 255, 0.7)";
        }
    });

    // Container pour les boutons
    const buttonContainer = document.createElement("div");
    buttonContainer.className = "crew-popup-buttons";

    // Bouton Envoyer
    const sendButton = document.createElement("button");
    sendButton.className = "crew-popup-btn crew-create-btn";
    sendButton.textContent = "SEND";
    sendButton.onclick = function () {
        const message = announcementInput.value.trim();

        // Validation
        if (message.length < 5) {
            announcementInput.style.borderColor = "#F31439";
            announcementInput.placeholder = "The announcement must contain at least 5 characters";
            return;
        } else {
            announcementInput.style.borderColor = "";
        }

        console.log("Sending announcement:", message);
        // Envoyer l'annonce au serveur
        fetch("https://gamemode/sendAnnouncement", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                message: message,
                crewName: fakeCrewData.crewName,
            }),
        });

        closeAnnouncementPopup();

        // Optionnel : Afficher un message de confirmation
        showNotification("Announcement sent successfully!", "success");
    };

    // Bouton Annuler
    const cancelButton = document.createElement("button");
    cancelButton.className = "crew-popup-btn crew-cancel-btn";
    cancelButton.textContent = "CANCEL";
    cancelButton.onclick = closeAnnouncementPopup;

    // Assembler la popup
    buttonContainer.appendChild(sendButton);
    buttonContainer.appendChild(cancelButton);

    popupContent.appendChild(popupTitle);
    popupContent.appendChild(announcementInput);
    popupContent.appendChild(charCounter);
    popupContent.appendChild(buttonContainer);

    popupOverlay.appendChild(popupContent);
    document.body.appendChild(popupOverlay);

    // Focus sur l'input
    setTimeout(() => {
        announcementInput.focus();
    }, 100);

    // Fermer avec Escape
    document.addEventListener("keydown", function (e) {
        if (e.key === "Escape") {
            closeAnnouncementPopup();
        }
    });

    // Envoyer avec Ctrl+Enter
    announcementInput.addEventListener("keydown", function (e) {
        if (e.key === "Enter" && e.ctrlKey) {
            sendButton.click();
        }
    });

    // Fermer en cliquant sur l'overlay
    popupOverlay.addEventListener("click", function (e) {
        if (e.target === popupOverlay) {
            closeAnnouncementPopup();
        }
    });
}

function closeAnnouncementPopup() {
    const popup = document.querySelector(".crew-popup-overlay");
    if (popup) {
        popup.remove();
    }
}

function showNotification(message, type = "info") {
    // Créer la notification
    const notification = document.createElement("div");
    notification.className = `crew-notification ${type}`;
    notification.textContent = message;

    // Ajouter au DOM
    document.body.appendChild(notification);

    // Animation d'entrée
    setTimeout(() => {
        notification.classList.add("show");
    }, 100);

    // Supprimer après 3 secondes
    setTimeout(() => {
        notification.classList.remove("show");
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
}
