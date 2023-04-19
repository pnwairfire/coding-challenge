# Svelte Setup

This directory contains a Svelte app that can be used as a starting point for
the USFS AirFire _Coding Challenge_. For more information about Svelte, see
https://svelte.dev.

Reading at https://svelte.dev/docs#getting-started we see:

> If you don't need a full-fledged app framework and instead want to build a
> simple frontend-only site/app, you can also use Svelte (without Kit) with Vite
> by running `npm init vite` and selecting the svelte option. With this,
> `npm run build` will generate HTML, JS and CSS files inside the dist directory.

We will be building frontend-only applications and so will use Svelte (without Kit).

# Setup

These instructions are for people who have just cloned the repository and want
to install npm packages and run the app interactively.

At the command line, download source code and install npm packages with:

```
git clone git@github.com:pnwairfire/coding-challenge.git
...
cd working-example
npm install
```

To run the app interactively, you need to be in the `working-example/`
subdirectory:

```
cd working-example
npm run dev
```

The app should be visible at: http://localhost:5174

# Initial Setup

These instructions are for setting up a new Svelte project from scratch.

## Install default app

At the command line:

```
npm init vite
# Project name: my-new-project
# Select a framework: Svelte
# Select a variant: JavaScript
cd my-new-project
npm install
npm run dev
```

This will create a default Svelte app visible at:

And view the page at http://localhost:5174/

## Copy in working example

Ctrl-C to stop serving the Svelte app. At this point you may want to copy in
some files from the `working-example/` to get jump-started.

These will probably include at least:

```
./src/App.svelte
./src/components/
./src/stores/
```

## Remove/modify example files/code

Remove unneeded files that came with the example app:

```
rm -rf ./src/assets
rm -rf ./src/lib
```

Modify `./index.html` by removing this line:

```
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
```

## Install required packages

For monitoring data and plots, the following packages need to be installed.
At the command line:

```
# npm packages
npm install arquero highcharts moment-timezone suncalc
npm install @square/svelte-store
npm install leaflet
# AirFire packages
npm install github:MazamaScience/air-monitor
npm install github:MazamaScience/air-monitor-algorithms
npm install github:pnwairfire/air-monitor-plots.git
```

Now `npm run dev` to see the monitoring Svelte app.

## Build the static site

Compile/build the static site with:

```
npm run build
```

Files will be found in the `dist/` directory:

```
dist
├── assets
│   ├── index-ad776a4e.js
│   └── index-f9ecc00f.css
├── index.html
└── vite.svg
```

## Deploy the static site

Before copying `dist/index.html` and the `dist/assets/` subdirectory to a web
server, you will need to modify the references in `dist/index.html` so they are
relative rather than absolute. Just begin the paths with `./` rather than `/`:

```
    <script type="module" crossorigin src="./assets/index-ad776a4e.js"></script>
    <link rel="stylesheet" href="./assets/index-f9ecc00f.css">
```

Now just copy these files to your favorite web server!
