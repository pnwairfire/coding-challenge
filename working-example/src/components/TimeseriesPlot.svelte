<script>
	// Exports
	export let element_id = 'default-timeseries-plot';
  export let width = '400px';
  export let height = '300px';

	// Imports
  // Svelte methods
  import { afterUpdate } from 'svelte';
  // Svelte stores
  import { all_monitors } from '../stores/monitor-data-store.js';
  import { selected_id } from '../stores/gui-store.js';
  // Highcharts for plotting
  import Highcharts from 'highcharts';
  import { pm25ToYMax, pm25_AQILines, pm25_addAQIStackedBar } from "air-monitor-plots";

  // Good examples to learn from:
  //   https://www.youtube.com/watch?v=s7rk2b1ioVE
  //   https://svelte.dev/repl/d283589caa554badb16644ad40682802?version=3.38.2

  // We need these variables to live on after an individual chart is destroyed
  let chartConfig;
  let context;
  let myChart;

  function createChart() {

    context = document.getElementById(element_id);

    // See https://www.youtube.com/watch?v=s7rk2b1ioVE @6:30
    if (myChart) myChart.destroy();

    // Get a copy of the reactive data and id
    const monitor = $all_monitors;
    const id = $selected_id;

    if ( id !== "" ) {

      // NOTE:  monitor is an 'air-monitor' object with methods defined by the
      // NOTE:  air-monitor package:  https://github.com/MazamaScience/air-monitor

      // Assemble required plot data
      const data = {
        datetime: monitor.getDatetime(),
        pm25: monitor.getPM25(id),
        nowcast: monitor.getNowcast(id),
        locationName: monitor.getMetadata(id, 'locationName'),
        timezone: monitor.getMetadata(id, 'timezone'),
        title: "", // Empty string causes HighCharts to make the title space available
      }

      // ----- Data preparation --------------------------------

      let startTime = data.datetime[0];
      // let xAxis_title = 'Time (${data.timezone})';

      // Default to well defined y-axis limits for visual stability
      let ymin = 0;
      let ymax = pm25ToYMax(Math.max(...data.pm25));

      let title = data.title;
      if (data.title === undefined) {
        title = data.locationName;
      }

      // ----- Chart configuration --------------------------------

      // NOTE:  See the HighCharts API:  https://api.highcharts.com/highcharts/

      let chartConfig = {
        accessibility: { enabled: false },
        chart: {
          animation: false,
          plotBorderColor: "#ddd",
          plotBorderWidth: 1,
        },
        plotOptions: {
          series: {
            animation: false,
          },
          scatter: {
            animation: false,
            marker: { radius: 3, symbol: "circle", fillColor: "#bbbbbb" },
          },
          line: {
            animation: false,
            color: "#000",
            lineWidth: 1,
            marker: { radius: 1, symbol: "square", fillColor: "transparent" },
          },
        },
        title: {
          text: title,
        },
        time: {
          timezone: data.timezone,
          useUTC: false,
        },
        xAxis: {
          type: "datetime",
          gridLineColor: "#ddd",
          gridLineDashStyle: "Dash",
          gridLineWidth: 1,
          minorTicks: true,
          minorTickInterval: 3 * 3600 * 1000, // every 3 hrs
          minorGridLineColor: "#eee",
          minorGridLineDashStyle: "Dot",
          minorGridLineWidth: 1,
        },
        yAxis: {
          min: ymin,
          max: ymax,
          gridLineColor: "#ddd",
          gridLineDashStyle: "Dash",
          gridLineWidth: 1,
          title: {
            text: "PM2.5 (\u00b5g/m\u00b3)",
          },
          plotLines: pm25_AQILines(2),
        },
        legend: {
          enabled: true,
          verticalAlign: "top",
        },
        series: [
          {
            name: "Hourly PM2.5 Values",
            type: "scatter",
            pointInterval: 3600 * 1000,
            pointStart: startTime.valueOf(), // milliseconds
            data: data.pm25,
          },
          {
            name: "Nowcast",
            type: "line",
            lineWidth: 2,
            pointInterval: 3600 * 1000,
            pointStart: startTime.valueOf(), // milliseconds
            data: data.nowcast,
          },
        ],
      };

      // Create the chart
      myChart = Highcharts.chart(context, chartConfig);
      pm25_addAQIStackedBar(myChart, 4);

    }

  }

  // Regenerate the chart after any update
  afterUpdate(createChart);
</script>

<!-- Note that sizing needs to be included as part of the element style. -->
<div id="{element_id}" class="chart-container"
     style="width: {width}; height: {height};">
</div>

<style>

</style>

