(function() {
  var chart, data, getStocks, legend;

  chart = new ForestD3.Chart(d3.select('#example'));

  legend = new ForestD3.Legend(d3.select('#legend'));

  chart.ordinal(true).xLabel('Date').yLabel('Price').yTickFormat(d3.format(',.3f')).xTickFormat(function(d) {
    if (d != null) {
      return d3.time.format('%Y-%m-%d')(new Date(d));
    } else {
      return '';
    }
  }).addPlugin(legend);

  getStocks = function(startPrice, volatility) {
    var changePct, i, j, result, startDate;
    result = [];
    startDate = new Date(2012, 0, 1);
    for (i = j = 0; j < 200; i = ++j) {
      result.push([startDate.getTime(), startPrice - 0.3]);
      changePct = 2 * volatility * Math.random();
      if (changePct > volatility) {
        changePct -= 2 * volatility;
      }
      startPrice += startPrice * changePct;
      startDate.setDate(startDate.getDate() + 1);
    }
    return result;
  };

  data = [
    {
      key: 'series1',
      label: 'AAPL',
      type: 'line',
      interpolate: 'cardinal',
      values: getStocks(0.75, 0.47)
    }, {
      key: 'series2',
      label: 'MSFT',
      type: 'line',
      area: true,
      values: getStocks(0.26, 0.2)
    }, {
      key: 'series3',
      label: 'FACEBOOK',
      type: 'line',
      area: true,
      interpolate: 'cardinal',
      values: getStocks(0.56, 0.13)
    }, {
      key: 'marker1',
      label: 'Profit',
      type: 'marker',
      axis: 'y',
      value: 0.2
    }, {
      key: 'region1',
      label: 'Election Season',
      type: 'region',
      axis: 'x',
      values: [50, 90]
    }
  ];

  chart.data(data).render();

}).call(this);
