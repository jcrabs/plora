import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";
import MapboxDraw from "@mapbox/mapbox-gl-draw";

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    segmentsCoordinates: Object,
    pois: Array,
    createUrl: String,
    destroyUrl: String,
    showSearch: Boolean,
    mapId: Number,
    importDrawUrl: String
  }

  static targets = ["container", "saveMatched", "saveFreeform", "loading"]

  connect() {
    // Initialize Mapbox
    mapboxgl.accessToken = this.apiKeyValue;
    // Manually set the mapIdValue using direct attribute value
    const mapId = this.element.getAttribute('data-map-id-value');
    // Convert the mapIdValue to an integer
    this.mapIdValue = parseInt(mapId, 10);
    console.log('Converted Map ID:', this.mapIdValue);
    // Initialize the map
    this.markers = []
    this.map = new mapboxgl.Map({
      container: this.containerTarget,
      style: "mapbox://styles/mapbox/streets-v10"
    });

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

    // drawing tool:
    this.draw = new MapboxDraw({
      displayControlsDefault: false,
      controls: {
        line_string: true,
        trash: true
      }})
    this.map.addControl(this.draw, 'top-left')

    this.map.on('load', () => {
      // draw lines for all segments, if segments exist (after map style has loaded):
      if (JSON.stringify(this.segmentsCoordinatesValue) != '{}') {
        this.#drawRoute(this.segmentsCoordinatesValue)
      }

      // Load saved annotations from server
      this.#loadAnnotations();

      // Add marker on right-click on web
      this.map.on('contextmenu', (e) => {
        this.#addMarkerAndSave(e.lngLat);
      });

      //  Long touch on mobile to add annotation
      let touchTimer = null;
      this.map.getCanvas().addEventListener('touchstart', (e) => {
        touchTimer = setTimeout(() => {
          const touch = e.touches[0];
          const lngLat = this.map.unproject([touch.clientX, touch.clientY]);
          this.#addMarkerAndSave(lngLat);
        }, 500); // 500 ms for long press
      });
      // Clear the timer and popup if the user lifts their finger before the timeout
      this.map.getCanvas().addEventListener('touchend', () => {
        clearTimeout(touchTimer);
      });

      // Draw lines for all segments, if segments exist (after map style has loaded)
      if (JSON.stringify(this.segmentsCoordinatesValue) !== '{}') {
        this.map.on("styledata", () => {
          this.#drawRoute(this.segmentsCoordinatesValue);
        });
      }
    });
    // Add the locations as buttons on the map
    this.poisValue.forEach((location) => {
      const popup = new mapboxgl.Popup({ offset: 25, closeOnClick: true }).setText(
        location.name? location.name:"Nameless Fountain")
      .setLngLat([location.lon, location.lat])
      .setDOMContent(this.createCard(location)) // Attach the custom card to the popup
      .addTo(this.map);
      const el = document.createElement("div")
      location.explored ? el.className = "marker_explored" : el.className = "marker"
      const marker = new mapboxgl.Marker(el)
      .setLngLat([ location.lon, location.lat ])
      .setPopup(popup)
      .addTo(this.map)
      marker.id = location.id
      this.markers.push(marker)
      });
  }

  // Load annotations from the server
  #loadAnnotations() {
    fetch(`/maps/${this.mapIdValue}/annotations`)
      .then(response => response.json())
      .then(data => {
        data.forEach(annotation => {
          this.addMarker([annotation.lon, annotation.lat], annotation.description);
        });
      });
  }

  // Add marker on the map and save it to the server
  #addMarkerAndSave(lngLat) {
    const description = prompt("Enter a description:");
    if (description) {
      // console.log('Map ID:', this.mapIdValue);
      this.addMarker(lngLat, description);
      this.#saveMarker(lngLat, description);
    }
  }

  // Function to create a custom popup card
  createCard(location) {
    const url = this.createUrlValue
    const url_del = this.destroyUrlValue
    const marker = this.markers
    const map = this.map

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
      this.updateMarkerIcon(marker.find(element => element.id === location.id), status)
    });

    card.appendChild(button);

    return card;
    }

  // Function to update the marker icon
  updateMarkerIcon(marker, status) {
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
    .addTo(this.map);
    return newMarker;
  }

  saveMatched(event) {
    event.preventDefault()
    this.#saveData("matched")
  }

  saveFreeform(event) {
    event.preventDefault()
    this.#saveData("freeform")
  }

  #saveData(mode) {
    // Grab coordinates from the segments that we drew and format them
    const segmentsCoordinates = [];
    const segments = this.draw.getAll().features;
    for (let i = 0; i < segments.length; i++) {
      const points = [];
      segments[i].geometry.coordinates.forEach((pair) => {
        const pointCoordinates = {
          lon: pair[0],
          lat: pair[1]
        };
        points.push(pointCoordinates)
      });
      segmentsCoordinates.push(points)
    }
    const segmentsCoordinatesForJSON = {"coordinates": segmentsCoordinates, "mode": mode}
    const segmentsCoordinatesJSON = JSON.stringify(segmentsCoordinatesForJSON)

    // Send the coordinates to the backend
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
        } else if (data.errors != []) {
          data.errors.forEach ((error) => {
            alert(error)
          })
        } else {
          alert("An error has occurred while saving your data.")
        }
      })
  }
  // Saving marker to the server
  #saveMarker(lngLat, description) {
    const data = {
      annotation: {
        lat: lngLat.lat,
        lon: lngLat.lng,
        name: 'New Marker',
        description: description
      }
    };
    // console.log('Sending data:', data);
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    fetch(`/maps/${this.mapIdValue}/annotations`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify(data)
    })
    .then(response => {
      // console.log('Response status:', response.status);
      return response.json();
    })
    // .then(data => {
    //   console.log('Response from server:', data);
    //   if (data.success) {
    //     console.log('Annotation saved successfully.');
    //   } else {
    //     console.error('Error saving annotation:', data.error);
    //   }
    // })
    // .catch(error => {
    //   console.error('Network error:', error);
    // });
  }

  // Add marker on the map
  // Add marker on the map
addMarker(lngLat, description) {
  // Create a new HTML element for the marker
  const el = document.createElement('div');
  el.className = 'custom-marker'; // Add a class for custom styling
  el.innerHTML = '<i class="fa-solid fa-message"></i>'; // Set Font Awesome icon

  // Style the marker element
  el.style.fontSize = '20px'; // Size of the icon
  el.style.color = '#006B8F'; // Color of the icon


  // Create a new Mapbox marker with the custom element
  const marker = new mapboxgl.Marker(el)
    .setLngLat(lngLat)
    .addTo(this.map);

  // Add a popup to the marker
  if (description) {
    const popup = new mapboxgl.Popup({ closeButton: false, offset: 25 })
      .setText(description);

    marker.setPopup(popup);

    // Detect if the device is touch-enabled
    const isTouchDevice = 'ontouchstart' in window || navigator.maxTouchPoints > 0;

    const showPopup = () => {
      // Close the currently open popup, if any
      if (this.currentPopup && this.currentPopup !== popup) {
        this.currentPopup.remove();
      }
      // Ensure the popup is only shown if it is not already visible
      if (!popup.isOpen()) {
        popup.addTo(this.map);
        this.currentPopup = popup;
      }
    };

    if (isTouchDevice) {
      // When on Mobile: Show popup on touch
      marker.getElement().addEventListener('touchstart', showPopup);
    } else {
      // When on Desktop: Show popup on mouseenter and hide on mouseleave
      marker.getElement().addEventListener('mouseenter', showPopup);
      marker.getElement().addEventListener('mouseleave', () => {
        popup.remove();
        this.currentPopup = null;
      });
    }
  }
}



  #fitMapToCoordinates(coordinates) {
    const bounds = new mapboxgl.LngLatBounds();
    coordinates.forEach(pair => bounds.extend([pair[0], pair[1]]));
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 });
  }

  // Draw the Map Matching routes as new layers on the map
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
            'circle-color': '#00afb9',
            'circle-opacity': 0.8,
            'circle-radius': 4,
            'line-color': '#a7c957',
            'line-width': 4,
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
