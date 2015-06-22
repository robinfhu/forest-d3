(function() {
  var chart, data, values;

  chart = new ForestD3.Chart('#example');

  chart.tooltipType('spatial').xTickFormat(d3.format('.2f'));

  values = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19].map(function(_) {
    return [Math.random() * 10, Math.random() * 40];
  });

  values.sort(function(a, b) {
    return d3.ascending(a[0], b[0]);
  });

  data = [
    {
      key: 'series1',
      type: 'scatter',
      label: 'Sample A',
      values: values
    }
  ];

  chart.data(data).render();

}).call(this);
