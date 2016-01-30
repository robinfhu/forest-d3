(function() {
  var chart, data, getValues, legend;

  chart = new ForestD3.Chart('#example');

  legend = new ForestD3.Legend('#legend');

  chart.ordinal(false).tooltipType('spatial').xTickFormat(d3.format('.2f')).addPlugin(legend);

  getValues = function(factor) {
    var values;
    if (factor == null) {
      factor = 40;
    }
    return values = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19].map(function(_) {
      return [Math.random() * 10, Math.random() * factor];
    });
  };

  data = [
    {
      shape: 'square',
      color: 'orange',
      values: getValues()
    }, {
      values: getValues(20)
    }
  ];

  chart.data(data).render();

}).call(this);
