(function() {
  var chart, data;

  chart = new ForestD3.BarChart('#example');

  data = [
    {
      key: 'series1',
      label: 'Long',
      color: '#555',
      values: [['Toyota', 100], ['Honda', 80], ['Mazda', 70], ['Prius', 10], ['Ford F150', 87]]
    }
  ];

  chart.data(data).render();

}).call(this);
