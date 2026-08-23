$(function () {
    function display(bool) {
        if (bool) {
            $('.container').fadeIn(500);
            $('.header').removeClass("out");
        } else {
            $('.container').fadeOut(500);
            $('.header').addClass("out");
        }
    }


    respawn = function() {
        $(".body-loading").show();
        $(".probar").slideDown(0)
        $(".probar").stop().css({"width": 0}).animate({
            width: '70%'
            }, {
            duration: parseInt(4000),
            complete: function() {
                $(".probar").css("width", 0);
                $(".body-loading").hide();
            }
            });
    };
    

    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.type === "ui") {
            if (item.status == true) {
                display(true)
                $('#Playerid').html(item.id);
                $("#requesttalk").show();
                $("#sendgang").show();
                $("#clearbody").show();
                $(".ambulance").show();
                $(".ambulance2").hide();
                $(".policee").hide();
                $(".gangg").hide();
                ropacity();
            } else {
                display(false)
            }
        } else if (item.type === "clearbody") {
            if (item.status == true) {
                $(".pedd").fadeIn(300);
            } else {
                $(".pedd").fadeOut(300);
            }
        } else if (item.type === "time") {
            $("#time").html(item.time);
        } else if (item.type === "sendsignal") {
            if (item.status == true) {
            
                $(".ambulance").fadeOut(300);
                $(".ambulance2").hide();
            } else {
            
                $(".ambulance").fadein(300);
                $(".ambulance2").hide();
            }

        } else if (item.type === "sendsignal2") {
            if (item.status == true) {
            
                $(".ambulance").hide();
                $(".ambulance2").show();
            } 
        } else if (item.type === "requestTalk") {
            if (item.status == true) {
             
                $(".talk").fadeIn(300);
				
            } else {
           
				$(".talk").fadeOut(300);
            }
		 } else if (item.type === "sendgang") {
            if (item.status == true) {
             
                $(".send_gang").fadeIn(300);
				
            } else {
           
				$(".send_gang").fadeOut(300);
            }
        } else if (item.type === "gang") {
            if (item.status == true) {
                $(".gangg").hide();
            } else {
                $(".gangg").show();
            }
        } else if (item.type === "police") {
            if (item.status == true) {
                $(".policee").hide();
            } else {
                $(".policee").show();
            }
        }
    })
})