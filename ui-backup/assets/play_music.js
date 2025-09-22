// PATH : /ui/assets/play_music.js & assets/music/*.mp3

window.addEventListener("message", function(event) {
    const data = event.data;

    if (data.type === "sendKillMusic") {
        PlayMusic(data.music);
    }
});

function PlayMusic(music) {
    if (!music || music == "none") {
        return;
    }

    // Create audio instance
    const audioPlayer = new Audio(`./assets/music/${music}.mp3`);
    
    // Set volume to 20%
    audioPlayer.volume = 0.1;
    
    audioPlayer.play();

    setTimeout(() => {
        audioPlayer.pause();
        audioPlayer.currentTime = 0;
    }, 4000);
}