<script>
  // Svelte stores
  import { methow_huc10 } from './stores/polygon-data-store.js';
  import { all_monitors, monitorLoadTime } from './stores/monitor-data-store.js';
  import { selected_id, selected_location_name } from './stores/gui-store.js';
  // Svelte Components
  import AlertBox from "./components/AlertBox.svelte";
  import TimeseriesPlot from "./components/TimeseriesPlot.svelte";
  import LeafletMap from "./components/LeafletMap.svelte";
</script>

<main>

	<AlertBox>
		<b>Hover over a map icon to see a new plot.</b>
	</AlertBox>

	<h1>Working Example</h1>

	{#await all_monitors.load()}
		<p>Loading monitoring data...</p>
	{:then}

		<div class="row">

			<div class="col-md-6">
				{#if selected_id !== "" }
				  <div class="header">Site: {$selected_location_name}</div>
				  <div class="plot-row">
						<TimeseriesPlot element_id="r1_timeseries" width="500px" height="200px"/>
					</div>
				{/if}
			</div>

			<div class="col-md-6">
				{#await methow_huc10.load() then}
				<div>
					<LeafletMap width="500px" height="450px"/>
				</div>
				{/await}
			</div>

		</div>

		<div class="status">
			Status: selected_id = {$selected_id}
		</div>

		<div class="status">
			Status: loaded {$all_monitors.count()} monitors in {$monitorLoadTime} seconds.
		</div>

	{:catch}
		<p style="color: red">An error occurred</p>
	{/await}

</main>

<style>
  h1 {
    color: coral;
  }
  .plot-row {
    display: flex;
  }
	div.status {
		font-size: 0.8rem;
		text-align: left;
		color: #888;
	}
	div.header {
		font-size: 1.2rem;
		font-weight: bold;
	}
</style>
