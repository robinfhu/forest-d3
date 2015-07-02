(function() {
  var chart, data, sortDir;

  chart = new ForestD3.BarChart('#example');

  data = [
    {
      key: 'series1',
      label: 'Long',
      color: '#555',
      values: [['Toyota', 100], ['Honda', 80], ['Mazda', 70], ['Prius', 10], ['Ford F150', 87], ['Hyundai', 23.4], ['Chrysler', 1], ['Lincoln', 102], ['Accord', -60], ['Hummer', -5.6], ['Dodge', -11]]
    }
  ];

  chart.data(data).render();

  chart.sortBy(function(d) {
    return d[1];
  });

  sortDir = 0;

  document.getElementById('sort-button').addEventListener('click', function() {
    chart.sortDirection(sortDir === 0 ? 'asc' : 'desc').render();
    return sortDir = 1 - sortDir;
  });

}).call(this);
