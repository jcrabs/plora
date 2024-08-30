import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'

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

  }


  #addHomeToMap() {
    if (this.homeValue.hide) return false

    new mapboxgl.Marker()
      .setLngLat([ this.homeValue.lon, this.homeValue.lat ])
      .addTo(this.map)
  }

  #fitMapToHome() {
    const bounds = new mapboxgl.LngLatBounds()
    bounds.extend([ this.homeValue.lon, this.homeValue.lat ])
    this.map.fitBounds(bounds, { padding: 200, maxZoom: 12, duration: 0 })
  }
}
