import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    home: Array
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
    })

    this.#addHomeToMap()
    this.#fitMapToHome()
  }

  #addHomeToMap() {
    new mapboxgl.Marker()
      .setLngLat([ this.homeValue[0].lon, this.homeValue[0].lat ])
      .addTo(this.map)
  }

  #fitMapToHome() {
    const bounds = new mapboxgl.LngLatBounds()
    bounds.extend([ this.homeValue[0].lon, this.homeValue[0].lat ])
    this.map.fitBounds(bounds, { padding: 200, maxZoom: 12, duration: 0 })
  }
}
