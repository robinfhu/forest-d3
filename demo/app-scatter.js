(function() {
  var chart, chart2, data, data2, getValues;

  chart = new ForestD3.Chart('#example');

  chart.tooltipType('spatial').xTickFormat(d3.format('.2f'));

  getValues = function(factor) {
    var values;
    if (factor == null) {
      factor = 40;
    }
    values = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19].map(function(_) {
      return [Math.random() * 10, Math.random() * factor];
    });
    values.sort(function(a, b) {
      return d3.ascending(a[0], b[0]);
    });
    return values;
  };

  data = [
    {
      key: 'series1',
      type: 'scatter',
      label: 'Sample A',
      values: getValues()
    }
  ];

  chart.data(data).render();

  chart2 = new ForestD3.Chart('#example2');

  chart2.tooltipType('spatial').xTickFormat(d3.format('.2f'));

  data2 = [
    {
      key: 'series1',
      type: 'scatter',
      label: 'Sample A',
      values: getValues()
    }, {
      key: 'series2',
      type: 'scatter',
      interpolate: 'cardinal',
      label: 'Sample B',
      values: getValues(20)
    }
  ];

  chart2.data(data2).render();

}).call(this);
