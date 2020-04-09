let _localizable = {
	"players": {
		"ru": "Игроки",
		"en": "Players",
	},
	"events": {
		"ru": "События",
		"en": "Events"
	},
	"info": {
		"ru": "Информация",
		"en": "Information"
	},
	"by_killer": {
		"ru": " был убит ",
		"en": " killed by "
	},
	"connected": {
		"ru": "подключился",
		"en": "connected"
	},
	"disconnected": {
		"ru": "отключился",
		"en": "disconnected"
	},
	"by_injured": {
		"ru": " был ранен ",
		"en": " injured by "
	},
	"shared": {
		"ru": "Поделиться",
		"en": "Shared"
	},
	"copy_link": {
		"ru": "Скопируйте ссылку",
		"en": "Copy link"
	},
	"close": {
		"ru": "Закрыть",
		"en": "Close"
	},
	"filter": {
		"ru": "Фильтр",
		"en": "Filter"
	},
	"shown": {
		"ru": " показаны",
		"en": " shown"
	},
	"hidden": {
		"ru": " скрыты",
		"en": " hidden"
	},
	"line_fire": {
		"ru": "Линии выстрелов",
		"en": "Shot lines"
	},
	"nickname": {
		"ru": "Никнеймы игроков и название техники ",
		"en": "Player nicknames and vehicle names"
	},
	"markers": {
		"ru": "Маркеры",
		"en": "Markers"
	},
	"event_fire": {
		"ru": "Эвенты попадания",
		"en": "Hit events"
	},
	"event_dis-connected": {
		"ru": "Эвенты подключения/отключения",
		"en": "Connects / Disconnects"
	},
	"name_missions": {
		"ru": "Название миссии",
		"en": "Mission name"
	},
	"something": {
		"ru": "кто-то",
		"en": "something"
	},
	"select_mission": {
		"ru": "Выбор миссии",
		"en": "Select mission"
	},
	"mission": {
		"ru": "Миссия",
		"en": "Mission"
	},
	"map": {
		"ru": "Карта",
		"en": "Map"
	},
	"data": {
		"ru": "Дата",
		"en": "Date"
	},
	"durability": {
		"ru": "Длительность",
		"en": "Duration"
	},
	"list_compilation": {
		"ru": "Составления списка...",
		"en": "List compilation..."
	},
	"loading": {
		"ru": "Загрузка...",
		"en": "Loading..."
	},
	"win": {
		"ru": "Победа",
		"en": "Win"
	},
	"play-pause": {
		"ru": "Воспроизвести/пауза: пробел",
		"en": "Play/pause: space"
	},
	"show-hide-left-panel": {
		"ru": "Показать/скрыть левую панель: E",
		"en": "Show/Hide left panel: E"
	},
	"show-hide-right-panel": {
		"ru": "Показать/скрыть правую панель: R",
		"en": "Show/Hide left panel: R"
	},
	"language": {
		"ru": "Язык:",
		"en": "Language:"
	}
};
let localizableElement = [];
let current_lang = localStorage.getItem("current_lang");
if (current_lang == null) {
	current_lang = (navigator.language || navigator.userLanguage).substr(0, 2);
	localStorage.setItem("current_lang", current_lang);
};
function localizable(elem, lzb, argR = "", argL = "") {
	var id = elem.dataset.lbId || (elem.dataset.lbId = localizableElement.length);
	localizableElement[id] = [elem, lzb, argR, argL];
	var text = _localizable[lzb][current_lang] || _localizable[lzb]["en"] || lzb;
	if (elem.nodeName == "INPUT")
		elem.placeholder = argL + text + argR;
	else
		elem.innerHTML = argL + text + argR;
};
function switchLocalizable(lang) {
	localStorage.setItem("current_lang", lang);
	current_lang = lang;
	localizableElement.forEach(function(item) {
		if (item.length != 0)
			localizable(item[0], item[1], item[2], item[3]);
	});
};
function deleteLocalizable(elem) {
	var id = elem.dataset.lbId;
	if (id != undefined) {
		localizableElement[id] = [];
	}
}
function getLocalizable(lzb) {
	return _localizable[lzb][current_lang] || _localizable[lzb]["en"] || lzb;
};
Array.prototype.slice.call(document.getElementsByTagName("*")).forEach(function(value) {
	if (value.dataset.lb != undefined) {
		localizable(value, value.dataset.lb);
	}
});
