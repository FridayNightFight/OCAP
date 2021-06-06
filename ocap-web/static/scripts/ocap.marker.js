class Marker {
	constructor(type, text, player, color, startFrame, endFrame, side, positions) {
		this._type = type;
		if (type == "ellipse") {
			this._circle = L.circle([0,0], { radius: 5, fillColor: color, fillOpacity:0.1, interactive: false });
		} else {
			this._icon = L.icon({ iconSize: [35, 35], iconUrl: `images/markers/${type}/${color}.png` });
		};
		this._text = text;
		this._player = player;
		this._color = color;
		this._startFrame = startFrame;
		this._endFrame = endFrame;
		this._side = side;
		this._positions = positions;
		this._marker = null;
		this._isShow = false;
		this._popup = "";
		this._popupClassName = "leaflet-popup-unit";
		this._systemMarkers = ["ObjectMarker", "moduleCoverMap", "safeStart"];
	};

	manageFrame(f) {
		if (this._side !== ui.currentSide && this._side !== "GLOBAL") {
			// console.log(this._side, ui.currentSide);
			this.hide();
			return;
		}
		let frameIndex = this._markerOnFrame(f);
		if (frameIndex != null) {
			this._updateAtFrame(frameIndex);
		} else {
			this.hide();
		};
		return;
	};

	_updateAtFrame(f) {
		let pos = this._positions[f][1];
		let latLng = armaToLatLng(pos);
		if (this._marker == null) {
			this._createMarker(latLng);
		} else {
			this._marker.setLatLng(latLng);
		};
		this.show();
	};

	hide() {
		if (this._isShow) {
			this._isShow = false;
			this.setMarkerOpacity(0);
		};
	};

	show() {
		if (!this._isShow) {
			this._isShow = true;
			if (this._systemMarkers.includes(this._type)) {
				this.setMarkerOpacity(0.5);
			} else {
				this.setMarkerOpacity(0.7);
			};
		};
	};

	_createMarker (latLng) {
		let marker;
		if (this._icon) {
			marker = L.marker(latLng).addTo(map);
			marker.setIcon(this._icon);
		

			let markerCustomText = "";
			if (this._text) { markerCustomText = this._text };
		
			if (
				// objectives
				markerCustomText.search("Terminal") > -1
			) {
				let popup = this._createPopup(`${this._text}`);
				marker.bindPopup(popup).openPopup();
			} else if (
				// map borders & custom objects
				this._systemMarkers.includes(this._type) &&
				this._side == "GLOBAL") {
				console.log("system marker")
			} else if (
				// projectiles
				(
					this._type.search("magIcons") > -1 ||
					this._type == "Minefield" ||
					this._type == "mil_triangle"
				) &&
				this._side == "GLOBAL") {
				let popup = this._createPopup(`${this._player.getName()} ${this._text}`);
				marker.bindPopup(popup).openPopup();
			} else {
				// all normal player marks
				let popup = this._createPopup(`${this._side} ${this._player.getName()} ${this._text}`);
				marker.bindPopup(popup).openPopup();
			}
		} else if (this._circle) {
			marker = this._circle.addTo(map);
		};
			this._marker = marker;
			this.show();
		};

	_createPopup(content) {
		let popup = L.popup({
			autoPan: false,
			autoClose: false,
			closeButton: false,
			className: this._popupClassName
		});
		popup.setContent(content);
		return popup;
	};

	_markerOnFrame(f) {
		if (this._startFrame <= f && this._endFrame >= f) {
			let index = null;
			let startIndex = 0;
			let lastIndex = this._positions.length - 1;
			let lastLength;
			do {
				lastLength = lastIndex - startIndex + 1;
				index = Math.floor((lastIndex - startIndex) / 2) + startIndex;
				if (this._positions[index][0] > f) {
					lastIndex = index - 1;
				} else {
					startIndex = index;
				};
			} while (lastLength != (lastIndex - startIndex + 1));
			return lastIndex;
		};
		return
	};

	setMarkerOpacity(opacity) {
		if (this._icon) {
			this._marker.setOpacity(opacity);
			let popup = this._marker.getPopup();
			if (popup != null) {
				popup.getElement().style.opacity = opacity;
			};
		};
	};
	
	setPopup(popup) {
		if (this._popup != popup) {
			this._marker.getPopup()._contentNode.innerHTML = popup;
			this._popup = popup;
		};
	};
};