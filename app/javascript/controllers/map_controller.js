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
    importDrawUrl: String
  }

  static targets = ["container", "save", "loading"]

  connect() {
    // display the map:
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.containerTarget,
      style: "mapbox://styles/mapbox/streets-v10"
      // style: "mapbox://styles/mapbox/satellite-v9"
    })

    // drawing tool:
    this.draw = new MapboxDraw();
    this.map.addControl(this.draw, 'top-left');
    this.map.on('load', () => {

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

      // draw lines for all segments, if segments exist (after map style has loaded):
      if (JSON.stringify(this.segmentsCoordinatesValue) != '{}') {
        this.map.on("styledata", () => {
          this.#drawRoute(this.segmentsCoordinatesValue)
        })
      }

    });

  }

  save(event) {
    event.preventDefault()

    // grab coordinates from the segments that we drew and format them:
    const segmentsCoordinates = []
    const segments = this.draw.getAll().features
    for (let i = 0; i < segments.length; i++) {
      const points = []
      segments[i].geometry.coordinates.forEach((pair) => {
        const pointCoordinates = {
          lon: pair[0],
          lat: pair[1]
        }
        points.push(pointCoordinates)
      })
      segmentsCoordinates.push(points)
    }
    const segmentsCoordinatesForJSON = {"coordinates": segmentsCoordinates}
    const segmentsCoordinatesJSON = JSON.stringify(segmentsCoordinatesForJSON)

    // send the coordinates to the backend:
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
        } else {
          alert("An error has occurred while saving your data.")
        }
      })
  }

  loading() {
    this.loadingTarget.classList.remove("d-none")
  }

  #fitMapToCoordinates(coordinates) {
    const bounds = new mapboxgl.LngLatBounds()
    coordinates.forEach(pair => bounds.extend([ pair[0], pair[1] ]))
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 })
  }

  // draw the Map Matching routes as new layers on the map
  #drawRoute(coords) {
    // collect all the coordinates in a single array to fit the map to them
    const all_segments = []
    // draw one line for each segment
    Object.entries(coords).forEach((pair) => {
      const id = pair[0]
      const segment = pair[1]
      // collect a segment's coordinate pairs
      const all_coords = []
      segment.forEach((pair) => {
        // collect a segment's coordinate pairs
        all_coords.push([pair.lon, pair.lat])
        // collect all the coordinates in a single array to fit the map to them
        all_segments.push([pair.lon, pair.lat])
      })
      // format for the addLayer function
      const formattedCoordinates = { coordinates: all_coords, type: "LineString" }

      // if a route is already loaded, don't draw it again
      if (!this.map.getSource(id)) {
        // add a new layer to the map
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
        })
      }
    })

    // fit the map to the coordinates
    this.#fitMapToCoordinates(all_segments)
  }

}
