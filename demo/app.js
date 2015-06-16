(function() {
  var chart, data, legend;

  chart = new ForestD3.Chart(d3.select('#example'));

  legend = new ForestD3.Legend(d3.select('#legend'));

  chart.xLabel('Independent Variable').yLabel('Manufacture Error').addPlugin(legend);

  data = [
    {
      key: 'series1',
      label: 'Consumer Discretionary',
      type: 'scatter',
      values: (function() {
        var i, j, k, l, result;
        result = [];
        for (i = k = -5; k < 5; i = ++k) {
          for (j = l = 0; l < 10; j = ++l) {
            result.push([i - Math.random(), Math.random() * 6 + 1]);
          }
        }
        return result;
      })()
    }, {
      key: 'series2',
      label: 'Industrials',
      values: (function() {
        var i, j, k, l, result;
        result = [];
        for (i = k = -5; k < 5; i = ++k) {
          for (j = l = 0; l < 10; j = ++l) {
            result.push([i, Math.random() * -4]);
          }
        }
        return result;
      })()
    }, {
      key: 'series3',
      label: 'Telecommunications',
      color: '#f09822',
      values: (function() {
        var i, j, k, l, result;
        result = [];
        for (i = k = -5; k < 5; i = ++k) {
          for (j = l = 0; l < 10; j = ++l) {
            result.push([i, Math.random() * -3 + 1]);
          }
        }
        return result;
      })()
    }, {
      key: 'marker1',
      label: 'Performance Threshold',
      type: 'marker',
      axis: 'y',
      value: 5.75
    }, {
      key: 'marker2',
      label: 'Performance Threshold',
      type: 'marker',
      axis: 'x',
      value: 1.07
    }, {
      key: 'region1',
      label: 'Tolerance',
      type: 'region',
      axis: 'x',
      values: [-2.6, -0.9]
    }, {
      key: 'region2',
      label: 'Tolerance',
      type: 'region',
      axis: 'y',
      values: [3.8, 5.67]
    }
  ];

  chart.data(data).render();

}).call(this);
