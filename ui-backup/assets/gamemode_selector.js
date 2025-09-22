$(document).on("click", ".ui-mode-item", function () {
    const gamemodeItem = document.querySelector(".mode-title")
    const gamemodeName = gamemodeItem.textContent

    console.log(gamemodeName, "gamemodeName");

    if (gamemodeName === "1v1 Tricks") {
        $.post("https://gamemode/selectGamemode", JSON.stringify({
            gamemodeItem: gamemodeName
        }));
        $.post("https://gamemode/Close");

        // $(".ui-mode-selection").fadeOut(300);
    }
});

Config = {
    CloseKeys: ["Escape"]
}

window.addEventListener("message", function (event) {
    var item = event.data;
    if (item.type === "openGamemodeSelector") {
        console.log("openGamemodeSelector");
        $(".ui-body").css("display", "flex");
        $(".ui-mode-selection").css("display", "flex");
        $(".ui-mode-selection").fadeIn(300);
    }
    if (item.type === "closeGamemodeSelector") {
        console.log("closeGamemodeSelector");
        $(".ui-body").css("display", "none");
        $(".ui-mode-selection").css("display", "none");
        $(".ui-mode-selection").fadeOut(300);
    }
});


$(document).on("keyup", function (e) {
    $.each(Config.CloseKeys, function (k, v) {
        if (e.key == v) {
            $.post("https://gamemode/closeGameSelec");
        }
    });
})