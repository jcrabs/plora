import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";
import MapboxDraw from "@mapbox/mapbox-gl-draw";

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    segmentsCoordinates: Object,
    showSearch: Boolean,
    mapId: Number,
    importDrawUrl: String
  }

  static targets = ["container", "save", "loading"]

  connect() {
    // Initialize Mapbox
    mapboxgl.accessToken = this.apiKeyValue;
    // Manually set the mapIdValue using direct attribute value
    const mapId = this.element.getAttribute('data-map-id-value');
    // Convert the mapIdValue to an integer
    this.mapIdValue = parseInt(mapId, 10);

    this.map = new mapboxgl.Map({
      container: this.containerTarget,
      style: "mapbox://styles/mapbox/streets-v10"
    });

    // Drawing tool
    this.draw = new MapboxDraw();
    this.map.addControl(this.draw, 'top-left');

    this.map.on('load', () => {
      // Search bar
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

      // Load saved annotations from server
      this.#loadAnnotations();

      // Add marker on right-click on web
      this.map.on('contextmenu', (e) => {
        this.#addMarkerAndSave(e.lngLat);
      });

      //  Long touch on mobile to add annotation
      let touchTimer = null;
      this.map.getCanvas().addEventListener('touchstart', (e) => {
        touchTimer = setTimeout(() => {
          const touch = e.touches[0];
          const lngLat = this.map.unproject([touch.clientX, touch.clientY]);
          this.#addMarkerAndSave(lngLat);
        }, 500); // 500 ms for long press
      });
      // Clear the timer and popup if the user lifts their finger before the timeout
      this.map.getCanvas().addEventListener('touchend', () => {
        clearTimeout(touchTimer);
      });

      // Draw lines for all segments, if segments exist (after map style has loaded)
      if (JSON.stringify(this.segmentsCoordinatesValue) !== '{}') {
        this.map.on("styledata", () => {
          this.#drawRoute(this.segmentsCoordinatesValue);
        });
      }
    });
  }

  // Load annotations from the server
  #loadAnnotations() {
    fetch(`/maps/${this.mapIdValue}/annotations`)
      .then(response => response.json())
      .then(data => {
        data.forEach(annotation => {
          this.addMarker([annotation.lon, annotation.lat], annotation.description);
        });
      });
  }

  // Add marker on the map and save it to the server
  #addMarkerAndSave(lngLat) {
    const description = prompt("Enter a description:");
    if (description) {
      // console.log('Map ID:', this.mapIdValue);
      this.addMarker(lngLat, description);
      this.#saveMarker(lngLat, description);
    }
  }

  save(event) {
    event.preventDefault();

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
        points.push(pointCoordinates);
      });
      segmentsCoordinates.push(points);
    }
    const segmentsCoordinatesForJSON = {"coordinates": segmentsCoordinates};
    const segmentsCoordinatesJSON = JSON.stringify(segmentsCoordinatesForJSON);

    // Send the coordinates to the backend
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    fetch(this.importDrawUrlValue, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
      body: segmentsCoordinatesJSON
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        location.reload();
      } else {
        alert("An error has occurred while saving your data.");
      }
    });
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
    // console.log('Sending data:', data);
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    fetch(`/maps/${this.mapIdValue}/annotations`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify(data)
    })
    .then(response => {
      // console.log('Response status:', response.status);
      return response.json();
    })
    // .then(data => {
    //   console.log('Response from server:', data);
    //   if (data.success) {
    //     console.log('Annotation saved successfully.');
    //   } else {
    //     console.error('Error saving annotation:', data.error);
    //   }
    // })
    // .catch(error => {
    //   console.error('Network error:', error);
    // });
  }

  // Add marker on the map
  addMarker(lngLat, description) {
    const marker = new mapboxgl.Marker()
      .setLngLat(lngLat)
      .addTo(this.map);
    // Add a popup to the marker
    if (description) {
      const popup = new mapboxgl.Popup({ closeButton: false, offset: 25 })
        .setText(description);

      marker.setPopup(popup);

      // Detect if the device is touch-enabled
      const isTouchDevice = 'ontouchstart' in window || navigator.maxTouchPoints > 0;

      const showPopup = () => {
        // Close the currently open popup, if any
        if (this.currentPopup && this.currentPopup !== popup) {
          this.currentPopup.remove();
        }
        // Ensure the popup is only shown if it is not already visible
        if (!popup.isOpen()) {
          popup.addTo(this.map);
          this.currentPopup = popup;
        }
      };

      if (isTouchDevice) {
        // When on Mobile: Show popup on touch
        marker.getElement().addEventListener('touchstart', showPopup);
      } else {
        // When on Desktop: Show popup on mouseenter and hide on mouseleave
        marker.getElement().addEventListener('mouseenter', showPopup);
        marker.getElement().addEventListener('mouseleave', () => {
          popup.remove();
          this.currentPopup = null;
        });
      }
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
            'line-color': '#03AA46',
            'line-width': 8,
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
