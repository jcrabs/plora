import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder"

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    home: Object
  }

  connect() {
    // display the map:
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
    })

    // add home icon and center map around it:
    this.#addHomeToMap()
    this.#fitMapToHome()

    // search bar:
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
    if (this.homeValue.hide) return false
    const el = document.createElement("div")
    el.className = "marker_home"
    new mapboxgl.Marker(el)
      .setLngLat([ this.homeValue.lon, this.homeValue.lat ])
      .addTo(this.map)
  }

  #fitMapToHome() {
    const bounds = new mapboxgl.LngLatBounds()
    bounds.extend([this.homeValue.lon, this.homeValue.lat])
    this.map.fitBounds(bounds, { padding: 50, maxZoom: 12, duration: 0 })
  }
}
