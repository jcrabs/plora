import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    home: Object,
    points: Array
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
    });

    this.#addHomeToMap();
    this.#fitMapToHome();

    let geocoder = new MapboxGeocoder({
      accessToken: mapboxgl.accessToken,
      mapboxgl: mapboxgl
    });

    this.map.addControl(geocoder);

    geocoder.on('result', function(e) {
      geocoder._inputEl.value = '';
    });
  }


  #addHomeToMap() {
    if (this.homeValue.hide) return false;

    new mapboxgl.Marker()
      .setLngLat([ this.homeValue.lon, this.homeValue.lat ])
      .addTo(this.map);
  }

  #fitMapToHome() {
    const bounds = new mapboxgl.LngLatBounds();
    bounds.extend([ this.homeValue.lon, this.homeValue.lat ]);
    this.map.fitBounds(bounds, { padding: 200, maxZoom: 12, duration: 0 });
  }
}
