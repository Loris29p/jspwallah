window.addEventListener("message", function(event) {
    if (event.data.action === "tebex-site") {
        if (event.data.show) {
            $(".tebex-site-container").show();
        } else {
            $(".tebex-site-container").hide();
        }
    }
});

Config = {
    CloseKeys: ["Escape"]
}


$(document).on("keyup", function (e) {
    $.each(Config.CloseKeys, function (k, v) {
        if (e.key == v) {
            $.post("https://gamemode/CloseTebex");
        }
    });
})