import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";
import MapboxDraw from "@mapbox/mapbox-gl-draw";

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    segmentsCoordinates: Object,
    pois: Array,
    createUrl: String,
    destroyUrl: String,
    showSearch: Boolean,
    mapId: Number,
    importDrawUrl: String
  }

  static targets = ["container", "saveMatched", "saveFreeform", "loading"]

  connect() {
    // Initialize Mapbox
    mapboxgl.accessToken = this.apiKeyValue;
    console.log('Controller connected');
    const mapId = this.element.getAttribute('data-map-id-value');
    console.log('Direct Attribute Map ID:', mapId);
    // Manually set the mapIdValue using this direct attribute value
    this.mapIdValue = parseInt(mapId, 10);
    console.log('Converted Map ID:', this.mapIdValue);
    this.markers = []
    this.map = new mapboxgl.Map({
      container: this.containerTarget,
      style: "mapbox://styles/mapbox/streets-v10"
    });

    // search bar:
    if (this.showSearchValue) {
      let geocoder = new MapboxGeocoder({
        accessToken: mapboxgl.accessToken,
        mapboxgl: mapboxgl
      });

      this.map.addControl(geocoder);

      geocoder.on('result', function(e) {
        geocoder._inputEl.value = '';
      });
    }

    // drawing tool:
    this.draw = new MapboxDraw({
      displayControlsDefault: false,
      controls: {
        line_string: true,
        trash: true
      }})
    this.map.addControl(this.draw, 'top-left')

    this.map.on('load', () => {
      // draw lines for all segments, if segments exist (after map style has loaded):
      if (JSON.stringify(this.segmentsCoordinatesValue) != '{}') {
        this.#drawRoute(this.segmentsCoordinatesValue)
      }

      // Load saved annotations from server
      this.#loadAnnotations();

      // Add marker on right-click or long-press
      this.map.on('contextmenu', (e) => {
        this.#addMarkerAndSave(e.lngLat);
      });

      this.map.on('touchend', (e) => {
        const touch = e.originalEvent.touches[0];
        const lngLat = this.map.unproject([touch.clientX, touch.clientY]);
        this.#addMarkerAndSave(lngLat);
      });

      // Draw lines for all segments, if segments exist (after map style has loaded)
      if (JSON.stringify(this.segmentsCoordinatesValue) !== '{}') {
        this.map.on("styledata", () => {
          this.#drawRoute(this.segmentsCoordinatesValue);
        });
      }
    });
    // Add the locations as buttons on the map
    this.poisValue.forEach((location) => {
      const popup = new mapboxgl.Popup({ offset: 25, closeOnClick: true }).setText(
        location.name? location.name:"Nameless Fountain")
      .setLngLat([location.lon, location.lat])
      .setDOMContent(this.createCard(location)) // Attach the custom card to the popup
      .addTo(this.map);
      const el = document.createElement("div")
      location.explored ? el.className = "marker_explored" : el.className = "marker"
      const marker = new mapboxgl.Marker(el)
      .setLngLat([ location.lon, location.lat ])
      .setPopup(popup)
      .addTo(this.map)
      marker.id = location.id
      this.markers.push(marker)
      });
  }

  // annotations:
  #loadAnnotations() {
    fetch(`/maps/${this.mapIdValue}/annotations`)
      .then(response => response.json())
      .then(data => {
        data.forEach(annotation => {
          this.addMarker([annotation.lon, annotation.lat], annotation.description);
        });
      });
  }

  #addMarkerAndSave(lngLat) {
    const description = prompt("Enter a description:");
    if (description) {
      console.log('Map ID:', this.mapIdValue);
      this.addMarker(lngLat, description);
      this.#saveMarker(lngLat, description);
    }
  }

  // Function to create a custom popup card
  createCard(location) {
    const url = this.createUrlValue
    const url_del = this.destroyUrlValue
    const marker = this.markers
    const map = this.map

    const card = document.createElement('div');
    card.className = 'custom-card';
    card.style.width = '200px';
    card.style.padding = '10px';
    card.style.backgroundColor = 'white';
    card.style.borderRadius = '8px';
    card.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.1)';

    const title = document.createElement('h5');
    title.textContent = location.name;
    card.appendChild(title);

    const category = document.createElement('p');
    category.textContent = location.category;
    card.appendChild(category);

    const description = document.createElement('p');
    description.textContent = location.description;
    card.appendChild(description);

    // Create the button
    const button = document.createElement('button');
    button.textContent = location.explored ? "Explored" : "Explore"
    button.style.marginTop = '10px';
    button.style.padding = '8px 12px';
    button.style.backgroundColor = location.explored ? '#F4A800' : '#007bff';
    button.style.color = 'white';
    button.style.border = 'none';
    button.style.borderRadius = '4px';
    button.style.cursor = 'pointer';

    // Button click event
    button.addEventListener('click', () => {
      const poiId = { "id": location.id }
      const poiIdJSON = JSON.stringify(poiId)
      console.log(location.id);
      console.log(`location explored status: ${location.explored}`);
      if (location.explored) {
        button.style.backgroundColor = '#007bff'
        button.textContent = "Explore"
        location.explored = false
        const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        console.log(url_del + `/${location.id}`);
        fetch(url_del + `/${location.id}`, {
          method: "DELETE",
          headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
          body: poiIdJSON
        })
      } else {
        button.style.backgroundColor = '#F4A800'
        button.textContent = "Explored"
        location.explored = true
        const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        fetch(url, {
          method: "POST",
          headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
          body: poiIdJSON
        })
      }
      const status = location.explored
      this.updateMarkerIcon(marker.find(element => element.id === location.id), status)
    });

    card.appendChild(button);

    return card;
    }


  // Function to update the marker icon
  updateMarkerIcon(marker, status) {
    // Get the marker's position and popup
    const lngLat = marker.getLngLat();
    const popup = marker.getPopup();
    // Remove the old marker
    marker.remove();
    console.log("marker removed");
    // Create a new marker with the explored class
    const el = document.createElement("div")
    if (status) {
      el.className = "marker_explored"
    } else {
      el.className = "marker"
    }

    const newMarker = new mapboxgl.Marker(el)
    .setLngLat(lngLat)
    .setPopup(popup)
    .addTo(this.map);
    return newMarker;
  }

  saveMatched(event) {
    event.preventDefault()
    this.#saveData("matched")
  }

  saveFreeform(event) {
    event.preventDefault()
    this.#saveData("freeform")
  }

  #saveData(mode) {
    // Grab coordinates from the segments that we drew and format them
    const segmentsCoordinates = [];
    const segments = this.draw.getAll().features;
    for (let i = 0; i < segments.length; i++) {
      const points = [];
      segments[i].geometry.coordinates.forEach((pair) => {
        const pointCoordinates = {
          lon: pair[0],
          lat: pair[1]
        };
        points.push(pointCoordinates)
      });
      segmentsCoordinates.push(points)
    }
    const segmentsCoordinatesForJSON = {"coordinates": segmentsCoordinates, "mode": mode}
    const segmentsCoordinatesJSON = JSON.stringify(segmentsCoordinatesForJSON)

    // Send the coordinates to the backend
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    fetch(this.importDrawUrlValue, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
      body: segmentsCoordinatesJSON
    })
      // reload page if successfully saved:
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          location.reload();
        } else if (data.errors != []) {
          data.errors.forEach ((error) => {
            alert(error)
          })
        } else {
          alert("An error has occurred while saving your data.")
        }
      })
  }

  #saveMarker(lngLat, description) {
    const data = {
      annotation: {
        lat: lngLat.lat,
        lon: lngLat.lng,
        name: 'New Marker',
        description: description
      }
    };
    fetch(`/maps/${this.mapIdValue}/annotations`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(data => {
      console.log('Marker saved successfully:', data);
    });
  }

  // Add marker on the map
  addMarker(lngLat, description) {
    const marker = new mapboxgl.Marker()
      .setLngLat(lngLat)
      .addTo(this.map);

    if (description) {
      const popup = new mapboxgl.Popup({ closeButton: false })
        .setText(description);

      marker.setPopup(popup);
      marker.getElement().addEventListener('mouseenter', () => popup.addTo(this.map));
      marker.getElement().addEventListener('mouseleave', () => popup.remove());
    }
  }

  #fitMapToCoordinates(coordinates) {
    const bounds = new mapboxgl.LngLatBounds();
    coordinates.forEach(pair => bounds.extend([pair[0], pair[1]]));
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 });
  }

  // Draw the Map Matching routes as new layers on the map
  #drawRoute(coords) {
    const all_segments = [];
    Object.entries(coords).forEach(([id, segment]) => {
      const all_coords = [];
      segment.forEach(pair => {
        all_coords.push([pair.lon, pair.lat]);
        all_segments.push([pair.lon, pair.lat]);
      });
      const formattedCoordinates = { coordinates: all_coords, type: "LineString" };

      if (!this.map.getSource(id)) {
        this.map.addLayer({
          id: id,
          type: 'line',
          source: {
            type: 'geojson',
            data: {
              type: 'Feature',
              properties: {},
              geometry: formattedCoordinates
            }
          },
          layout: {
            'line-join': 'round',
            'line-cap': 'round'
          },
          paint: {
            'circle-color': '#00afb9',
            'circle-opacity': 0.8,
            'circle-radius': 4,
            'line-color': '#a7c957',
            'line-width': 4,
            'line-opacity': 0.8
          }
        });
      }
    });

    this.#fitMapToCoordinates(all_segments);
  }

  loading() {
    this.loadingTarget.classList.remove("d-none");
  }
}
