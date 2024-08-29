import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";

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
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
      // style: "mapbox://styles/mapbox/satellite-v9"
    })

    // search bar
    let geocoder = new MapboxGeocoder({
      accessToken: mapboxgl.accessToken,
      mapboxgl: mapboxgl
    });

    this.map.addControl(geocoder);

    geocoder.on('result', function(e) {
      geocoder._inputEl.value = '';
    });

    this.#addRoute()

  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()
    this.markersValue.forEach(marker => bounds.extend([ marker.lon, marker.lat ]))
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 })
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
    // collect the promises from the API calls
    let coordPromises = [];
    // make 1 API call per 50 piece data chunk
    console.log(this.formattedDataValue);
    for (let i = 0; i < this.formattedDataValue.length; i++) {
      data = this.#getMatch(this.formattedDataValue[i], "walking", this.radiusesValue[i])
      coordPromises.push(data);
    }

    try {
      const coords = await Promise.all(coordPromises)

      // collect all coordinates to be drawn
      let coordsArray = []
      coords.forEach((part) => {
        part.coordinates.forEach((pair) => {
          coordsArray.push(pair)
        })
      })
      // format coordinates for the drawRoute function
      const formattedCoordinates = { coordinates: coordsArray, type: "LineString" }

      // draw a line between all coordinates
      this.#drawRoute(formattedCoordinates)
    } catch (error) {
      console.error("An error occurred while processing coordinates:", error)
    }
  }


}
