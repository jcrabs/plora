import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    points: Array,
    markers: Array
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
      // style: "mapbox://styles/mapbox/satellite-v9"
    })

    let geocoder = new MapboxGeocoder({
      accessToken: mapboxgl.accessToken,
      mapboxgl: mapboxgl
    });

    this.map.addControl(geocoder);

    geocoder.on('result', function(e) {
      geocoder._inputEl.value = '';
    });

    this.#addMarkersToMap()
    this.#fitMapToMarkers()
    const data = this.#formatRawData()
    this.#getMatch(data, "cycling")
  }

  #addMarkersToMap() {
    this.markersValue.forEach((marker) => {
      new mapboxgl.Marker()
        .setLngLat([ marker.lon, marker.lat ])
        .addTo(this.map)
    })
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()
    this.markersValue.forEach(marker => bounds.extend([ marker.lon, marker.lat ]))
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 })
  }

  #formatRawData() {
    let formattedData = ""
    this.markersValue.forEach(marker => formattedData += `${marker.lon},${marker.lat};`)
    const data = formattedData.slice(0, -1)
    return data
  }

  // Make a Map Matching request
  async #getMatch(coordinates, profile) {
    // Create the query
    const query = await fetch(
      `https://api.mapbox.com/matching/v5/mapbox/${profile}/${coordinates}?geometries=geojson&access_token=${this.apiKeyValue}`,
      { method: 'GET' }
    );
    const response = await query.json();
    // Handle errors
    if (response.code !== 'Ok') {
      alert(
        `${response.code} - ${response.message}.\n\nFor more information: https://docs.mapbox.com/api/navigation/map-matching/#map-matching-api-errors`
      );
      return;
    }
    // Get the coordinates from the response
    const coords = response.matchings[0].geometry;
    // Code from the next step will go here
    this.#addRoute(coords);
  }

  // Draw the Map Matching route as a new layer on the map
  #addRoute(coords) {
    // If a route is already loaded, remove it
    if (this.map.getSource('route')) {
      this.map.removeLayer('route');
      this.map.removeSource('route');
    } else {
      // Add a new layer to the map
      this.map.addLayer({
        id: 'route',
        type: 'line',
        source: {
          type: 'geojson',
          data: {
            type: 'Feature',
            properties: {},
            geometry: coords
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
      })
    }
  }
}
