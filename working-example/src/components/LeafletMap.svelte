<script>
	// Exports
  export let width = '400px';
  export let height = '400px';

  // Imports
  // Svelte methods
	import { onMount, onDestroy } from 'svelte';
  // Svelte stores
  import { methow_huc10, methow_fire_history } from '../stores/polygon-data-store.js';
  import { all_monitors } from '../stores/monitor-data-store.js';
  import { selected_id, selected_location_name } from '../stores/gui-store.js';
  // Leaflet (NOTE:  Don't put {} around the 'L'!)
  import L from "leaflet";
  // Plotting helper functions
  import { pm25ToColor } from 'air-monitor-plots';

  let map;

  function createMap() {

    // Get a copy of the reactive data and id
    const monitor = $all_monitors;

    // Create the map
    map = L.map('map').setView([40, -120], 8);

    // Add background tiles
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(map);

    // Create HUC10 watersheds layer (later used for fitBounds)
    let hucLayer =
      L.geoJSON($methow_huc10, {
        style: {
          fillColor: "#398bfc",
          color: "#398bfc",
          weight: 2,
          opacity: 1,
          fillOpacity: 0.0
        },
        onEachFeature: function (feature, layer) {
          layer.bindPopup(feature.properties.HUCName);
        }
      }
    );
    hucLayer.addTo(map);

    // Add fire history
    methow_fire_history.load().then(function(geojsonData) {
      L.geoJSON(geojsonData, {
        style: {
          fillColor: "#E3735E",
          color: "#E3735E",
          weight: 3,
          opacity: 0.5,
          fillOpacity: 0.2
        },
        onEachFeature: function (feature, layer) {
          layer.bindPopup(feature.properties.INCIDENT + '<br>' + feature.properties.FIRE_YEAR);
        }
      }).addTo(map)
    });

    // Create and add geojson created from monitors
    let monitorGeoJSON = monitor.createGeoJSON();
    let monitorLayer = createMonitorLayer(monitorGeoJSON);
    monitorLayer.addTo(map);

    // Make sure all watersheds show
    map.fitBounds(hucLayer.getBounds(), {
      padding: [10, 10]
    });

  }

	onMount(createMap);

	onDestroy(() => {
		if (map) map.remove();
	});

  /**
   * @param {geojson} geojson to be converted to a leaflet layer
   * @returns
   */
  function createMonitorLayer(geojson) {
    var this_layer = L.geoJSON(geojson, {
      // Icon appearance
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, {
          radius: 10,
          fillColor: pm25ToColor(feature.properties.last_pm25),
          color: '#000',
          weight: 2,
          opacity: 1,
          fillOpacity: 0.8
        });
      },

      // Icon behavior
      onEachFeature: function (feature, layer) {
        let valueText;
        if (isNaN(feature.properties.last_pm25)) {
          valueText = "<span style='font-style:italic'> no data</span>";
        } else {
          valueText = feature.properties.last_pm25 + ' &#xb5;g/m<sup>3</sup>';
        }

        layer.on('mouseover', function (e) {
          selected_id.set(feature.properties.deviceDeploymentID);
          selected_location_name.set(feature.properties.locationName);
        });
      }
    });

    return this_layer;
  }

</script>

<svelte:head>
  <link
    rel="stylesheet"
    href="https://unpkg.com/leaflet@1.9.3/dist/leaflet.css"
    integrity="sha256-kLaT2GOSpHechhsozzB+flnD+zUyjE2LlfWPgU04xyI="
    crossorigin=""
  />
</svelte:head>

<!-- Note that sizing needs to be included as part of the element style. -->
<div id="map"
      style="width: {width}; height: {height};">
</div>

<style>

</style>