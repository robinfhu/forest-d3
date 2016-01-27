# Forest D3
## Documentation

### What is it?
Forest D3 is a simple charting library built on top of d3.js.

### How to install

The library exists as a single .js distributable and two CSS files.
You need the files:

* dist/forest-d3.js
* dist/forest-d3.css
* dist/forest-d3-dark.css

The library is dependent on d3.js version 3.5.x.

### Basic Usage

Charts need to be placed inside of a predefined DOM element. The chart
will automatically size itself to match the container element's dimensions.

```
<div id="my-chart" style="height:400px; width: 100%;"></div>
```

Next, create a new ForestD3.Chart object and pass in some data:

```
var data = {
    'series1': {
        label: 'My First Series',
        values: [
            [1, 10],
            [2, 30],
            [3, 60],
            [4, 80]
        ]
    }
};

var chart = new ForestD3.Chart('#my-chart');
chart.data(data).render();
```

This will render a scatter chart by default.
