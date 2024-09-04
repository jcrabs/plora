import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder"

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    segmentsCoordinates: Object,
    pois: Array,
    showSearch: Boolean,
    createUrl: String,
    destroyUrl: String
  }

  connect() {
    // display the map:
    console.log(this.poisValue);
    mapboxgl.accessToken = this.apiKeyValue;
    this.markers = []
    console.log(this.poisValue);
    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
      // style: "mapbox://styles/mapbox/satellite-v9"
    })

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

    const url = this.createUrlValue
    const url_del = this.destroyUrlValue
    const marker = this.markers
    const map = this.map

    // Function to create a custom popup card
    function createCard(location) {
      const card = document.createElement('div');
      card.className = 'custom-card';
      card.style.width = '200px';
      card.style.padding = '10px';
      card.style.backgroundColor = 'white';
      card.style.borderRadius = '8px';
      card.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.1)';

      const title = document.createElement('h5');
      title.textContent = location.name;
      card.appendChild(title);

      const category = document.createElement('p');
      category.textContent = location.category;
      card.appendChild(category);

      const description = document.createElement('p');
      description.textContent = location.description;
      card.appendChild(description);

      // Create the button
      const button = document.createElement('button');
      button.textContent = location.explored ? "Explored" : "Explore"
      button.style.marginTop = '10px';
      button.style.padding = '8px 12px';
      button.style.backgroundColor = location.explored ? '#F4A800' : '#007bff';
      button.style.color = 'white';
      button.style.border = 'none';
      button.style.borderRadius = '4px';
      button.style.cursor = 'pointer';

      // Button click event
      button.addEventListener('click', () => {
        const poiId = { "id": location.id }
        const poiIdJSON = JSON.stringify(poiId)
        console.log(location.id);
        console.log(`location explored status: ${location.explored}`);
        if (location.explored) {
          button.style.backgroundColor = '#007bff'
          button.textContent = "Explore"
          location.explored = false
          const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
          console.log(url_del + `/${location.id}`);
          fetch(url_del + `/${location.id}`, {
            method: "DELETE",
            headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
            body: poiIdJSON
          })
        } else {
          button.style.backgroundColor = '#F4A800'
          button.textContent = "Explored"
          location.explored = true
          const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
          fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
            body: poiIdJSON
          })
        }
        const status = location.explored
        updateMarkerIcon(marker.find(element => element.id === location.id), status)
      });

      card.appendChild(button);

      return card;
    }


    // Add the locations as buttons on the map
    this.poisValue.forEach((location) => {
      const popup = new mapboxgl.Popup({ offset: 25, closeOnClick: true }).setText(
        location.name? location.name:"Nameless Fountain")
      .setLngLat([location.lon, location.lat])
      .setDOMContent(createCard(location)) // Attach the custom card to the popup
      .addTo(this.map);
      const el = document.createElement("div")
      location.explored ? el.className = "marker_explored" : el.className = "marker"
      const marker = new mapboxgl.Marker(el)
      .setLngLat([ location.lon, location.lat ])
      .setPopup(popup)
      .addTo(map)
      marker.id = location.id
      this.markers.push(marker)
      });

    // Function to update the marker icon
    function updateMarkerIcon(marker, status) {
      // Get the marker's position and popup
      const lngLat = marker.getLngLat();
      const popup = marker.getPopup();
      // Remove the old marker
      marker.remove();
      console.log("marker removed");
      // Create a new marker with the explored class
      const el = document.createElement("div")
      if (status) {
        el.className = "marker_explored"
      } else {
        el.className = "marker"
      }

      const newMarker = new mapboxgl.Marker(el)
      .setLngLat(lngLat)
      .setPopup(popup)
      .addTo(map);
      return newMarker;
    }
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
            'circle-color': '#00afb9',
            'circle-opacity': 0.8,
            'circle-radius': 4,
            'line-color': '#a7c957',
            'line-width': 4,
            'line-opacity': 0.8
          }
        })
      }
    })

    // fit the map to the coordinates
    this.#fitMapToCoordinates(all_segments)
  }

}
