window.addEventListener("message", function(event) {
    const data = event.data;

    if (data.type == "deathframe") {
        deathFrame(data);
    }
});



function deathFrame(data) {
    if (data.bool) {
        const content = `
        <div class="death-killer">
                <div class="game-badge">
                  <img alt="" ${data && data.prestige > 0 ? `src="/ui/assets/badges/prestige_${data.prestige}.png"` : ''}>
                </div>
                <span class="killer-username">
                  <span class="color" style="color: #0000"></span>
                  <span class="color-0">${data.username} (${data.uuid})</span>
                </span>
                <div class="killerlife">
                  <span class="armor-status">
                    <svg width="20" height="20" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="shield" class="svg-inline--fa fa-shield " role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
                      <path fill="currentColor" d="M256 0c4.6 0 9.2 1 13.4 2.9L457.7 82.8c22 9.3 38.4 31 38.3 57.2c-.5 99.2-41.3 280.7-213.6 363.2c-16.7 8-36.1 8-52.8 0C57.3 420.7 16.5 239.2 16 140c-.1-26.2 16.3-47.9 38.3-57.2L242.7 2.9C246.8 1 251.4 0 256 0z"></path>
                    </svg>${data.armor}</span>
                  <span class="health-status">
                    <svg width="20" height="20" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="heart" class="svg-inline--fa fa-heart " role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
                      <path fill="currentColor" d="M47.6 300.4L228.3 469.1c7.5 7 17.4 10.9 27.7 10.9s20.2-3.9 27.7-10.9L464.4 300.4c30.4-28.3 47.6-68 47.6-109.5v-5.8c0-69.9-50.5-129.5-119.4-141C347 36.5 300.6 51.4 268 84L256 96 244 84c-32.6-32.6-79-47.5-124.6-39.9C50.5 55.6 0 115.2 0 185.1v5.8c0 41.5 17.2 81.2 47.6 109.5z"></path>
                    </svg>${data.health}</span>
                </div>
              </div>
              ${data.deathmessage ? `
                <div class="death-message">
                    <span class="message glitch">${data.deathmessage}</span>
                </div>
                ` : ''}
    
        `
        $(".killcam").append(content);
        $(".killcam").css("display", "flex");

        // if (data.deathmessage) {
        //     const deathmessage = `
        //     <div class="death-message-window">
        //         <span class="message glitch">${data.deathmessage}</span>
        //     </div>
        //     `
        //     $(".killcam").append(deathmessage);
        // }
    } else {
        $(".killcam").css("display", "none");
        $(".killcam").empty();
    }
}