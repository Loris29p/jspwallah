

console.log("loaded")
window.addEventListener('message', (event) => {
    console.log(JSON.stringify(event.data));
    if (event.data.type == "showLeaderboard") {

    } else if (event.data.type == "updateLeaderboard") {
        console.log(JSON.stringify(event.data));
        populateLeaderboard(event.data.pistol, "kill-rang");
    }
});

function populateLeaderboard(data, containerId) {
    const sortedData = data.sort((a, b) => b.kd - a.kd);

    const container = document.getElementById(containerId);
    sortedData.forEach(player => {
        const rankCell = document.createElement("div");
        rankCell.classList.add("cell");
        rankCell.textContent = player.position;

        const nameCell = document.createElement("div");
        nameCell.classList.add("cell");
        nameCell.textContent = player.name;

        const eloCell = document.createElement("div");
        eloCell.classList.add("cell");
        eloCell.textContent = player.kd;

        container.appendChild(rankCell);
        container.appendChild(nameCell);
        container.appendChild(eloCell);
    });
}