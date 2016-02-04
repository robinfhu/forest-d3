(function() {
  var data, pieChart;

  pieChart = new ForestD3.PieChart('#example');

  data = [
    {
      label: 'Apples',
      value: 100
    }, {
      label: 'Pears',
      value: 34
    }, {
      label: 'Bananas',
      value: 6
    }, {
      label: 'Oranges',
      value: 87
    }, {
      label: 'Grapes',
      value: 54
    }, {
      label: 'Melons',
      value: 2
    }, {
      label: 'Strawberries',
      value: 32
    }
  ];

  pieChart.getLabel(function(d) {
    return d.label;
  }).getValue(function(d) {
    return d.value;
  }).data(data).render();

}).call(this);
