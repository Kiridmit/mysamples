//
// Helpers
//

var entityMap = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  '"': '&quot;',
  "'": '&#39;',
  //"/": '&#x2F;'
};

function escapeHtml(string) {
  return String(string).replace(/[&<>"']/g, function (s) {
    return entityMap[s];
  });
}

var lastLongMessage = "";
var nowSaying = false;
function sayText(text) {
  if (nowSaying){
    if (text.length > lastLongMessage.length) {
      lastLongMessage = text;
    }
    return;
  }

  // firefox: https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis
  var u = new SpeechSynthesisUtterance(text);
  u.voice = window.speechSynthesis.getVoices()[0];
  u.lang = 'ru-RU';
  u.pitch = 0.0 + Math.random() * 1.3;
  u.rate = 1.1 + Math.random() * 0.2;
  u.volume = 1.0;
  window.speechSynthesis.speak(u);

  u.onend = function() {
    nowSaying = false;
    if(lastLongMessage != "") {
      sayText(lastLongMessage);
    }
  };
  lastLongMessage = "";
  nowSaying = true;
}



//
// Application
//

var smiles = [];
var timer = 0;
//console.log2 = function (message) {
//
//};

$('#app').append("<div class='images'></div>");
$('#app').append("<div class='message chattitle'>Пекачат. Все чаты в одном. Разрабатываем и тестируем, картинки и webm</div>");

var socket = io('wss://chat.funstream.tv', {
    transports: ['websocket'],
    path: '/',
    reconnection: true,
    reconnectionDelay: 500,
    reconnectionDelayMax: 2000,
    reconnectionAttempts: Infinity
});


var streams = [];
// listen new messages
socket.on('/chat/message', function(message) {
  $.post( "http://funstream.tv/api/channel/data", { channels: [message.channel] }, function( channels ) {
    var name = escapeHtml(message.from.name);
    var nameTo = message.to ? message.to.name : null;
    var messageText = escapeHtml(message.text);
    var channelName = channels[0].user ? channels[0].user.name : message.channel;
    var channelTitle = channels[0].name;
    streams[channelName] = streams[channelName] ? streams[channelName] + 1 : 1;

    var time =  message.text.length * 100;
    timer = timer + time;

    var speechText = message.text.replace(/(:\/\/[\.\-\_a-zA-Z0-9\/\&\?]*)/gi, function(str,v1) {
      return '';
    });
    speechText = speechText.replace(/([^ ][0-9]+[^ ^\,^\.^\\^/])/g, function(str,v1) {
      //console.log(str + "===" + v1);
      return ",";
    });
    speechText = speechText.replace(/([^а-я^А-Я^ё^Ё^ ^0-9]+)/g, function(str,v1) {
      //console.log(str + "===" + v1);
      return ",";
    });

    speechText = speechText.substring(0, 100);

    //console.log(speechText);
    if (speechText.length > 1) sayText(speechText);


    // Формеруем предваряющую сообщение надпись

    var pretext = "";
    //pretext += "" + channelName + " || ";
    pretext += name;
    //pretext += nameTo ? " &gt " + nameTo : "";
    pretext += nameTo ? " to " + nameTo : "";
    pretext += " ";
    pretext += "<div class='messagetitle'>" + "" + channelTitle + "" + "</div>";
    pretext = "<div class='messagenick'>" + pretext + "</div>";

    // Формеруем текст сообщения
    var text = messageText + " ";
    text = text.replace(/(https?:\/\/[\.\-\_a-zA-Z0-9\/\&\?]*\.(?:png|jpg|jpeg|gif|svg|bmp)) /gi, function(str,v1) {
      $(".images").html('<img class="media" src="' + v1 + '"></img>');
      return '(картинка)';
    });
    text = text.replace(/(https?:\/\/[\.\-\_a-zA-Z0-9\/\&\?]*\.(?:webm)) /gi, function(str,v1) {
      $(".images").html('<video muted autoplay class="media" src="' + v1 + '"></img>');
      return '(вебм)';
    });
    //console.log(text);
    text = text.replace(/:([a-zA-Z0-9\-]+):/gi, function(_, smilecode) {
      //console.log(smiles.length);
      smilecode = smilecode.toLowerCase();
      for (i = 0; i < smiles.length; ++i) {
        //console.log(smiles[i].code);
        if (smiles[i].code == smilecode) {
          return "<img class='smile' width='" + smiles[i].width
          +"' height='" + smiles[i].height
          +"' src='" + escapeHtml(smiles[i].url)
          + "'></img>";
        }
      }
      return ":" + smilecode + ":";
    });

    var animation1 = {opacity: 0};
    var animation2 = {height: 0 /*, marginBottom: 0, paddingTop: 0, paddingBottom: 0*/};

    var output =  pretext + text;
    var el = $("<div class='message'>")
      .html(output)
      .hide()
      .fadeIn(1000)
      .delay(/*message.text.length * 50 + */3000 + Math.sqrt(timer/500)*500)
      .animate(animation1, 1000 , "linear")
      .animate(animation2, 3000, "swing", function() {
        this.parentNode.removeChild(this); //$(this).remove();
        timer = timer - time;
      }
    );
    $("#app").append(el);
  });


});

socket.on('connect', function () {

    //console.log('socket connected');
    // join chat channel
    socket.emit('/chat/join', {channel: 'all'}, function(data) {
        //console.log('joined main');
    });

    $.post( "http://funstream.tv/api/smile", function( data ) {
      smiles = data;
      //console.log(smiles);
    });
});

socket.on('connect_error', function(error) {
    //console.log('socket connect error');
    //console.log(error);
});

socket.on('reconnect', function() {
    //console.log('socket reconnect');
});

function toggleFullScreen() {
  if (!document.fullscreenElement && // alternative standard method
      !document.mozFullScreenElement && !document.webkitFullscreenElement) { // current working methods
    if (document.documentElement.requestFullscreen) {
      document.documentElement.requestFullscreen();
    } else if (document.documentElement.mozRequestFullScreen) {
      document.documentElement.mozRequestFullScreen();
    } else if (document.documentElement.webkitRequestFullscreen) {
      document.documentElement.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
    }
  } else {
    if (document.cancelFullScreen) {
      document.cancelFullScreen();
    } else if (document.mozCancelFullScreen) {
      document.mozCancelFullScreen();
    } else if (document.webkitCancelFullScreen) {
      document.webkitCancelFullScreen();
    }
  }
}

document.getElementById("app").addEventListener('dblclick', function(e) {
  //toggleFullScreen();
  //console.log(e);
  toggleFullScreen();
  //document.getElementById("app").mozRequestFullScreen()
}, false);

//addEventListener
//$("body").on('click', function() {
//  launchFullScreen(document.body);
//})
