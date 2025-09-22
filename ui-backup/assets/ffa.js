function updateScoreboard(scores) {
    const container = document.querySelector('.score');
    container.innerHTML = ''; // Clear existing scores

    // Only take first 5 scores
    const topScores = scores.slice(0, 5);

    topScores.forEach((score, index) => {
        console.log("EACH", score.username, score.kills)
        const position = getPosition(index + 1);
        const scoreHTML = `
            <div class="score-container">
                <div class="score-position">${position}</div>
                <div class="score-name">
                    <span>
                        <span>${score.username}</span>
                    </span>
                </div>
                <div class="score-points">${score.kills}</div>
            </div>
        `;
        container.innerHTML += scoreHTML;
    });
}

function getPosition(place) {
    switch (place) {
        case 1:
            return "1st";
        case 2:
            return "2nd";
        case 3:
            return "3rd";
        case 4:
            return "4th";
        case 5:
            return "5th";
        default:
            return `${place}th`;
    }
}

window.addEventListener("message", function(event) {
    const item = event.data;
    const extraHudContainer = document.querySelector('.mini-leaderboard');

    if (item.type === "showFFA") {
        extraHudContainer.style.display = item.show ? 'block' : 'none';
        
        if (item.scores) {
            updateScoreboard(item.scores);
        }
    }
});