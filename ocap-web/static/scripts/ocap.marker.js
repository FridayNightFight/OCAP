class Marker {
	constructor(type, text, player, color, startFrame, endFrame, side, positions, size, name, shape) {
		this._type = type;
		this._text = text;
		this._player = player;
		this._color = `#${color}`;
		this._startFrame = startFrame;
		this._endFrame = endFrame;
		this._side = side;
		this._positions = positions;
		this._size = size;
		this._name = name;
		this._shape = shape;
		if (this._shape == "ICON") {
			this._icon = L.icon({ iconSize: [35, 35], iconUrl: `images/markers/${type}/${color}.png` });
		} else {
			this._icon = null;
		};
		this._marker = null;
		this._isShow = false;
		this._popup = "";
		this._popupClassName = "leaflet-popup-unit";
		this._systemMarkers = ["ObjectMarker", "moduleCoverMap", "safeStart"];
	};

	manageFrame (f) {
		if (
			this._side != ui.currentSide &&
			this._side != "GLOBAL" &&
			this._marker != null) {
			// console.log(this._side, ui.currentSide);
			this.hide();
			return;
		}
		let frameIndex = this._markerOnFrame(f);
		// if (this._shape == "RECTANGLE") { console.log(frameIndex) };
		if (frameIndex != null) {
			this._updateAtFrame(frameIndex);
		} else {
			// this._updateAtFrame(0);
			this.hide();
		};
		return;
	};

	_updateAtFrame (f) {
		let pos = this._positions[f][1];
		let latLng;
		let points;
		if (this._marker == null) {
			// console.debug(`UPDATE AT FRAME: attempting to create marker ${this._name}`)


			if (this._shape == "ICON") {
				latLng = armaToLatLng(pos);
				this._createMarker(latLng);
			} else if (this._shape == "ELLIPSE") {
				latLng = armaToLatLng(pos);
				this._createMarker(latLng);
			} else if (this._shape == "RECTANGLE") {
				let startX = pos[0];
				let startY = pos[1];
				let sizeY = this._size[0];
				let sizeX = this._size[1];

				let pointsRaw = [
					// [startX - sizeX, startY + sizeY], // top left
					[startX + sizeX, startY + sizeY], // top right
					// [startX + sizeX, startY - sizeY], // bottom right
					[startX - sizeX, startY - sizeY] // bottom left
				];
				points = pointsRaw.map(coord => {
					return armaToLatLng(coord);
				});
				let bounds = L.latLngBounds(points);

				this._createMarker(bounds);
			} else if (this._shape == "POLYLINE") {
				points = pos.map(coord => {
					return armaToLatLng(coord);
				});
				this._createMarker(points);
			};

		} else {
			// console.debug(`UPDATE AT FRAME: attempting to update marker ${this._name}`)

			if (this._shape == "ICON") {
				pos = this._positions[f][1];
				latLng = armaToLatLng(pos);
				this._marker.setLatLng(latLng);
			} else if (this._shape == "ELLIPSE") {
				pos = this._positions[f][1];
				latLng = armaToLatLng(pos);
				this._marker.setLatLng(latLng).redraw();
			} else if (this._shape == "RECTANGLE") {
				pos = this._positions[f][1];
				let startX = pos[0];
				let startY = pos[1];
				let sizeX = this._size[0];
				let sizeY = this._size[1];

				let pointsRaw = [
					// [startX - sizeX, startY + sizeY], // top left
					[startX + sizeX, startY + sizeY], // top right
					// [startX + sizeX, startY - sizeY], // bottom right
					[startX - sizeX, startY - sizeY] // bottom left
				];

				let points = pointsRaw.map(coord => {
					return armaToLatLng(coord);
				});
				let bounds = L.latLngBounds(points);

				this._marker.setLatLngs(bounds).redraw();
			} else if (this._shape == "POLYLINE") {
				// do nothing, polylines can't be moved
			};

			this.show();
		};
	};

	hide () {
		if (this._isShow) {
			this._isShow = false;
			this.setMarkerOpacity(0);
		};
	};

	show () {
		if (!this._isShow) {
			this._isShow = true;
			// if (this._systemMarkers.includes(this._type)) {
				// this.setMarkerOpacity(0.2);
			// } else {
				if (this._shape == "ICON") {
					this.setMarkerOpacity(1);
				} else if (this._shape == "ELLIPSE") {
					this.setMarkerOpacity(0.25);
				} else if (this._shape == "RECTANGLE") {
					this.setMarkerOpacity(0.25);
				} else if (this._shape == "POLYLINE") {
					this.setMarkerOpacity(0.7);
				};
			// };
		};
	};

	_createMarker (latLng) {
		let marker;
		let startPos;
		console.debug(`Creating ${this._name} of shape ${this._shape}`)

		if (this._shape == "ICON") {
			let popupText = "";
			let interactiveVal = false;

			let markerCustomText = "";
			if (this._text) { markerCustomText = this._text };

			if (
				// objectives
				markerCustomText.search("Terminal") > -1 ||
				markerCustomText.search("Sector") > -1
			) {
				popupText = `${this._text}`;
			} else if (
				// map borders & custom objects
				this._systemMarkers.includes(this._type) &&
				this._side == "GLOBAL") {
				// console.log("system marker")
			} else if (
				// projectiles
				(
					this._type.search("magIcons") > -1 ||
					this._type == "Minefield" ||
					this._type == "mil_triangle"
				) &&
				this._side == "GLOBAL") {
				popupText = `${this._player.getName()} ${this._text}`;
			} else {
				// all normal player marks
				interactiveVal = true;
				popupText = `${this._side} ${this._player.getName()} ${this._text}`;
			}

			marker = L.marker(latLng, { interactive: interactiveVal }).addTo(map);
			marker.setIcon(this._icon);
			let popup = this._createPopup(popupText);
			marker.bindPopup(popup).openPopup();
		} else if (this._shape == "ELLIPSE") {
			let rad = this._size[0] * multiplier * 0.01;
			marker = L.circle(latLng, { radius: rad, color: "#000000", opacity: 0.5, fill: true, fillColor: this._color, fillOpacity: 0.2, noClip: true, interactive: false }).addTo(map);
		} else if (this._shape == "RECTANGLE") {
			marker = L.rectangle(latLng, { color: "#000000", opacity: 0.5, fillColor: this._color, fillOpacity: 0.2, noClip: true, interactive: false }).addTo(map);
		} else if (this._shape == "POLYLINE") {
			marker = L.polyline(latLng, { color: this._color, opacity: 1, noClip: true, lineCap: 'butt', lineJoin: 'round', interactive: false }).addTo(map);
		};

		this._marker = marker;
		this.show();
	};

	_createPopup (content) {
		let popup = L.popup({
			autoPan: false,
			autoClose: false,
			closeButton: false,
			className: this._popupClassName
		});
		popup.setContent(content);
		return popup;
	};

	_markerOnFrame (f) {
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
		if (this._startFrame <= f && this._endFrame == -1) {
			return this._positions.length - 1;
		};
		return
	};

	setMarkerOpacity (opacity) {
		let strokeOpacity = opacity;
		if (opacity > 0) {
			strokeOpacity = opacity + 0.3;
		};
		if (this._shape == "ICON") {
			this._marker.setOpacity(opacity);
			let popup = this._marker.getPopup();
			if (popup != null) {
				popup.getElement().style.opacity = opacity;
			};
		} else if (this._shape == "ELLIPSE") {
			this._marker.setStyle({ opacity: strokeOpacity, fillOpacity: opacity });
		} else if (this._shape == "RECTANGLE") {
			this._marker.setStyle({ opacity: strokeOpacity, fillOpacity: opacity });
		} else if (this._shape == "POLYLINE") {
			this._marker.setStyle({ opacity: opacity });
		};
	};

	setPopup (popup) {
		if (this._popup != popup) {
			this._marker.getPopup()._contentNode.innerHTML = popup;
			this._popup = popup;
		};
	};

	hideMarkerPopup (bool) {
		if (this._marker != null) {
			let popup = this._marker.getPopup();
			if (popup == null) { return };

			let element = popup.getElement();
			let display = "inherit";
			if (bool) { display = "none" };

			if (element.style.display != display) {
				element.style.display = display;
			};
		};
	};
};