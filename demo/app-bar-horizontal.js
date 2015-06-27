(function() {
  var chart, data;

  chart = new ForestD3.BarChart('#example');

  data = [
    {
      key: 'series1',
      label: 'Long',
      values: [['Toyota', 100], ['Honda', 80], ['Mazda', 70]]
    }
  ];

  chart.data(data).render();

}).call(this);
