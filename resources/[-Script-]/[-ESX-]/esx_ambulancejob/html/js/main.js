var Config = new Object();
var type = "normal";
Config.closeKeys = [113, 27];

const playSound = (name) => {
	if (name) {
		var audio = new Audio('./sounds/' + name + '.wav');
		audio.volume = 0.2
		audio.play();
	}
}

window.addEventListener('message', function (event) {
	var event = event.data;

	if (event.message == "openUI") {
		$(".ui").fadeIn()
		$(".main").css("animation", "slideUp .30s")
		playSound("open")
	} else if (event.message == "closeUI") {
		$(".main").css("animation", "slideBack .30s forwards")
		$(".ui").fadeOut()
		playSound("back")
    } else if (event.action == "updateTime") {
		$("#timer").html(event.time)
	}
});

$("body").on("keyup", function (key) {
	if (Config.closeKeys.includes(key.which)) {
		$.post('https://esx_ambulancejob/quit', JSON.stringify({}));
	}
});

$(document).on('click', '.action', function() {
	$.post('https://esx_ambulancejob/action', JSON.stringify({
		type: $(this).data('action'),
	}));
	$.post('https://esx_ambulancejob/quit', JSON.stringify({}));
})