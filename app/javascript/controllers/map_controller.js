import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    segmentsCoordinates: Object,
    showSearch: Boolean,
    mapId: Number,
  }

  static targets = ["container", "loading"]

  connect() {
    // Initialize Mapbox
    mapboxgl.accessToken = this.apiKeyValue;
    console.log('Controller connected');
    const mapId = this.element.getAttribute('data-map-id-value');
    console.log('Direct Attribute Map ID:', mapId);
    // Manually set the mapIdValue using this direct attribute value
    this.mapIdValue = parseInt(mapId, 10);
    console.log('Converted Map ID:', this.mapIdValue);


    this.map = new mapboxgl.Map({
      container: this.containerTarget,
      style: "mapbox://styles/mapbox/streets-v10"
    });

    // Search bar
    if (this.showSearchValue) {
      const geocoder = new MapboxGeocoder({
        accessToken: mapboxgl.accessToken,
        mapboxgl: mapboxgl
      });

      this.map.addControl(geocoder);

      geocoder.on('result', (e) => {
        geocoder._inputEl.value = '';
      });
    }

    // Draw routes if segment coordinates are provided
    if (JSON.stringify(this.segmentsCoordinatesValue) !== '{}') {
      this.map.on("styledata", () => {
        this.#drawRoute(this.segmentsCoordinatesValue);
      });
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
  }

  #loadAnnotations() {
    fetch(`/maps/${this.mapIdValue}/annotations`)
      .then(response => {
        return response.json();
      })
      .then(data => {
        data.forEach(annotation => {
          this.addMarker([annotation.lon, annotation.lat], annotation.description);
        });
      })
      .catch(error => console.error('Error fetching annotations:', error));
    }

  #addMarkerAndSave(lngLat) {
    const description = prompt("Enter a description:");
    if (description) {
      const testLngLat = { lat: 40.7128, lng: -74.0060 };
      console.log('Map ID:', this.mapIdValue);
      this.addMarker(lngLat, description);
      this.#saveMarker(lngLat, description);
    }
  }

  #saveMarker(lngLat, description) {
    const data = {
      annotation: {
        lat: lngLat.lat,
        lon: lngLat.lng,
        name: 'New Marker',
        description: description
      }
    }
    fetch(`/maps/${this.mapIdValue}/annotations`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify(data)
    })
    .then(response => {
      return response.json();
    })
    .then(data => {
      console.log('Marker saved successfully:', data);
    })
    .catch(error => {
      console.error('Check Error:', error);
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
