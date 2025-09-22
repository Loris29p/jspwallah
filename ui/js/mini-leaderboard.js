window.addEventListener('message', function(event)
{ 
    var item = event.data;

    const minileaderboard = document.querySelector('.mini-leaderboard');

    if (item.type === "showFFA") {
        minileaderboard.style.display = item.show ? 'block' : 'none';
        
        if (item.scores) {
            updateScoreboard(item.scores, item.myScore);
        }
    }
});


function updateScoreboard(scores, myScore) {
    const container = document.querySelector('.mini-leaderboard');
    container.innerHTML = '';

    const topScores = scores.slice(0, 5);

    topScores.forEach((score, index) => {
        const position = getPosition(index + 1);
        const scoreHTML = `
            <div class="guild-container">
                <p class="guild-name">${position} ${score.username}</p>
                <p class="kills-count">${score.kills} 💀</p>
            </div>
        `;
        container.innerHTML += scoreHTML;
    });


    if (myScore) {
        const myScoreHTML = `
            <div class="guild-container">
                <p class="guild-name">My Kills</p>
                <p class="kills-count">${myScore.kills} 💀</p>
            </div>
        `;
        container.innerHTML += myScoreHTML;
    }
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