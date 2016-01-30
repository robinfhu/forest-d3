(function() {
  var chart, chartHover, data, dataHover, getValues, legend;

  chart = new ForestD3.Chart('#example');

  legend = new ForestD3.Legend('#legend');

  chart.ordinal(false).chartLabel('Spatial Tooltips').tooltipType('spatial').xTickFormat(d3.format('.2f')).addPlugin(legend);

  getValues = function(deviation) {
    var i, rand, results, values;
    if (deviation == null) {
      deviation = 1.0;
    }
    rand = d3.random.normal(0, deviation);
    return values = (function() {
      results = [];
      for (i = 0; i < 30; i++){ results.push(i); }
      return results;
    }).apply(this).map(function(_) {
      return [rand(), rand()];
    });
  };

  data = [
    {
      shape: 'square',
      color: 'orange',
      values: getValues()
    }, {
      values: getValues(1.9)
    }, {
      shape: 'circle',
      values: getValues(0.7)
    }
  ];

  chart.data(data).render();

  chartHover = new ForestD3.Chart('#example-hover');

  chartHover.ordinal(false).chartLabel('Hover Tooltips').tooltipType('hover').addPlugin(new ForestD3.Legend('#legend-hover'));

  dataHover = [
    {
      values: getValues(1.1)
    }, {
      values: getValues(1.3)
    }, {
      values: getValues(1.4)
    }
  ];

  chartHover.data(dataHover).render();

}).call(this);
