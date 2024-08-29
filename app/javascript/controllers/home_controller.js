import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    home: Object,
    points: Array,
    formattedData: Array,
    unformattedData: Array,
    radiuses: Array
  }


  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
    })

    this.#addHomeToMap()
    this.#fitMapToHome()

    this.#addMarkersToMap()
    this.#addRoute()
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





  #addMarkersToMap() {
    this.unformattedDataValue.forEach((marker) => {
      new mapboxgl.Marker()
        .setLngLat([ marker.lon, marker.lat ])
        .addTo(this.map)
    })
  }

  // Make a Map Matching request
  async #getMatch(coordinates, profile, radiuses) {
    // Create the query
    const query = await fetch(
      `https://api.mapbox.com/matching/v5/mapbox/${profile}/${coordinates}?geometries=geojson&radiuses=${radiuses}&access_token=${this.apiKeyValue}`,
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
    return coords
  }

  // Draw the Map Matching route as a new layer on the map
  #drawRoute(coords) {
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
      });
    }
  }

  async #addRoute() {
    let coordPromises = [];
    for (let i = 0; i < this.formattedDataValue.length; i++) {
      coordPromises.push(this.#getMatch(this.formattedDataValue[i], "walking", this.radiusesValue[i]));
    }

    try {
      const coords = await Promise.all(coordPromises)

      let coordsArray = []
      coords.forEach((part) => {
        part.coordinates.forEach((pair) => {
          coordsArray.push(pair)
        })
      })
      const formattedCoordinates = { coordinates: coordsArray, type: "LineString" }

      this.#drawRoute(formattedCoordinates)
    } catch (error) {
      console.error("An error occurred while processing coordinates:", error)
    }
  }
}
