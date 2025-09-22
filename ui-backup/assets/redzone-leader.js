window.addEventListener("message", function(event) {
    if (event.data.type == "updateRedzone") {
        const killLeaderWidget = document.querySelector(".kill-leader-widget");
        const playerName = document.querySelector(".kill-leader-widget .player-info .player-name");
        const killCount = document.querySelector(".kill-leader-widget .kill-stats .kill-number");
        const playerTitle = document.querySelector(".kill-leader-widget .player-info .player-title");

        if (killLeaderWidget.style.display == "none") {
            killLeaderWidget.style.display = "";
        }
        
        killCount.innerHTML = event.data.kills;
        playerName.innerHTML = event.data.name;
        playerTitle.innerHTML = "Kill Leader";
    } else if (event.data.type == "hideRedzoneInfo") {
        const killLeaderWidget = document.querySelector(".kill-leader-widget");
        killLeaderWidget.style.display = "none";
    }
});