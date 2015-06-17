# Forest D3
### A javascript charting library

[![Build Status](https://travis-ci.org/robinfhu/forest-d3.svg?branch=master)](https://travis-ci.org/robinfhu/forest-d3)

My attempt at implementing a better time series charting library, based on d3.js

## Motivations and Design Ideas
I learned a lot from my experience working on NVD3. I wanted to take the lessons
learned from that project to build a better charting library.

Here are some guidelines I'd like to apply to this library:

*   Better data cleanup. Having the library take care of filling in missing points.
*   For large datasets, charts should reduce resolution of the lines for performance gain.
*   Better margin auto adjusting.
*   Easier ability to integrate different chart types into the same plot (line, area, scatter, bars)
*   Easier ability to add horizontal and vertical line markers.
*   Adding and removing data points in real time should be seamless.
*   Ability to use data generators (so you can write functions like y=x^2).
*   Removal of the chart legend, with hooks to enable series'. Allows developer to create their own legend.
*   Provide an AngularJS and React.js companion library.
*   No need to create your own SVG tag. Library creates it for you and sizes it to the container.
*   Code is tested and linted properly. Written in CoffeeScript.

## Development
To build the project, run the following

    npm install
    npm test

