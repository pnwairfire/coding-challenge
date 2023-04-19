// All polygons needed by the custom-smoke-page map

// NOTE:  The @square/svelte-store replacement for svelte-store is
// NOTE:  Incredibly helpful for us. The problem it solves is explained here:
// NOTE:    https://github.com/sveltejs/svelte/issues/8011
// NOTE:  More details and examples are given here:
// NOTE:    https://github.com/square/svelte-store

// NOTE:  Basically, it allows us to abstract away the async/await aspects of
// NOTE:  fetching data.

// npm install @square/svelte-store --save
import { asyncReadable } from "@square/svelte-store";

// Methow HUC10 watersheds
export const methow_huc10 = asyncReadable(
  {},
  async () => {
    const response = await fetch(
      "https://airfire-data-exports.s3.us-west-2.amazonaws.com/community-smoke/v1/methow-valley/data/polygon/Methow_HUC10_02.geojson"
    );
    const userObject = await response.json();
    console.log("loaded methow_huc10 polygons");
    return userObject;
  },
  { reloadable: true }
);

// Methow Fire history
export const methow_fire_history = asyncReadable(
  {},
  async () => {
    const response = await fetch('https://airfire-data-exports.s3.us-west-2.amazonaws.com/community-smoke/v1/methow-valley/data/polygon/Methow-fire-history.geojson');
    const userObject = await response.json();
    return userObject;
  },
  { reloadable: true }
);
