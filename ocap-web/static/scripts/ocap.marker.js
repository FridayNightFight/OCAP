class Marker {
	constructor(type, text, player, color, startFrame, endFrame, side, positions, size, name, shape) {
		this._type = type;
		this._text = text;
		this._player = player;
		this._color = ("#" + color);
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

	_updateAtFrame (f) {
		let pos;
		let latLng;
		if (this._marker == null) {
			switch (this._shape) {
				case "ICON":
					pos = this._positions[f][1];
					latLng = armaToLatLng(pos);
					this._createMarker(latLng);
					break;

				case "ELLIPSE":
					pos = this._positions[f][1];
					latLng = armaToLatLng(pos);
					this._createMarker(latLng);
					break;

				case "RECTANGLE":
					pos = this._positions[f][1];
					let startX = pos[0];
					let startY = pos[1];
					let sizeX = this._size[0];
					let sizeY = (0 - this._size[1]);

					let pointsRaw = [
						[startX - sizeX, startY + sizeY], // top left
						[startX + sizeX, startY + sizeY], // top right
						[startX + sizeX, startY - sizeY], // bottom right
						[startX - sizeX, startY - sizeY] // bottom left
					];
					let points = pointsRaw.map(coord => {
						return armaToLatLng(coord);
					});
					console.log(points);

					this._createMarker(points);
					break;

				case "POLYLINE":
					pos = this._positions[0][1].map(coord => {
						return armaToLatLng(coord);
					});
					this._createMarker(pos);
					break;

				default:
					break;
			};
		} else {
			switch (this._shape) {
				case "ICON":
					pos = this._positions[f][1];
					latLng = armaToLatLng(pos);
					this._marker.setLatLng(latLng);
					break;

				case "ELLIPSE":
					pos = this._positions[f][1];
					latLng = armaToLatLng(pos);
					this._marker.setLatLng(latLng).redraw();
					break;

				case "RECTANGLE":
					pos = this._positions[f][1];
					let startX = pos[0];
					let startY = pos[1];
					let sizeX = this._size[0];
					let sizeY = (0 - this._size[1]);

					let pointsRaw = [
						[startX - sizeX, startY + sizeY], // top left
						[startX + sizeX, startY + sizeY], // top right
						[startX + sizeX, startY - sizeY], // bottom right
						[startX - sizeX, startY - sizeY] // bottom left
					];
					let points = pointsRaw.map(coord => {
						return armaToLatLng(coord);
					});

					this._marker.setLatLngs(points).redraw();
					break;

				case "POLYLINE":
					// do nothing, polylines can't be moved
					break;

				default:
					break;
			};
		};
		if (this._marker == null) {
			throw `Failed to process ${markerJSON[9]} with text "${markerJSON[1]}"\nError: ${err}`;
		};
		this.show();
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
			if (this._systemMarkers.includes(this._type)) {
				this.setMarkerOpacity(0.2);
			} else {
				switch (this._shape) {
					case "ICON":
						this.setMarkerOpacity(1);
						break;

					case "ELLIPSE":
						this.setMarkerOpacity(0.25);
						break;

					case "RECTANGLE":
						this.setMarkerOpacity(0.25);
						break;

					case "POLYLINE":
						this.setMarkerOpacity(0.7);
						break;

					default:
						break;
				};
			};
		};
	};

	_createMarker (latLng) {
		let marker;
		let startPos;

		switch (this._shape) {
			case "ICON":
				marker = L.marker(latLng).addTo(map);
				marker.setIcon(this._icon);


				let markerCustomText = "";
				if (this._text) { markerCustomText = this._text };

				if (
					// objectives
					markerCustomText.search("Terminal") > -1 ||
					markerCustomText.search("Sector") > -1
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
				break;

			case "ELLIPSE":
				let rad = this._size[0] * multiplier * 0.01;
				marker = L.circle(latLng, { radius: rad, color: "#000000", opacity: 0.5, fill: true, fillColor: this._color, fillOpacity: 0.27, noClip: true, interactive: false }).addTo(map);
				break;

			case "RECTANGLE":
				marker = L.polygon(latLng, { color: "#000000", opacity: 0.5, fillColor: this._color, fillOpacity: 0.2, noClip: true, interactive: false }).addTo(map);
				break;
			
			case "POLYLINE":
				console.log(latLng);
				marker = L.polyline(startPos, { color: this._color, opacity: 1, noClip: true, lineCap: 'butt', lineJoin: 'round', interactive: false }).addTo(map);
				console.log(marker)
				break;

			default:
				break;
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
		return
	};

	setMarkerOpacity (opacity) {
		let strokeOpacity = opacity;
		if (opacity > 0) {
			strokeOpacity = opacity + 0.3;
		};
		switch (this._shape) {
			case "ICON":
				this._marker.setOpacity(opacity);
				let popup = this._marker.getPopup();
				if (popup != null) {
					popup.getElement().style.opacity = opacity;
				};
				break;

			case "ELLIPSE":
				this._marker.setStyle({ opacity: strokeOpacity, fillOpacity: opacity });
				break;

			case "RECTANGLE":
				this._marker.setStyle({ opacity: strokeOpacity, fillOpacity: opacity });
				break;

			case "POLYLINE":
				this._marker.setStyle({ opacity: opacity });
				break;

			default:
				break;
		};
	};

	setPopup (popup) {
		if (this._popup != popup) {
			this._marker.getPopup()._contentNode.innerHTML = popup;
			this._popup = popup;
		};
	};
};