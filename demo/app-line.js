(function() {
  var chart, data, getStocks, legend;

  chart = new ForestD3.Chart(d3.select('#example'));

  legend = new ForestD3.Legend(d3.select('#legend'));

  chart.ordinal(true).xLabel('Date').yLabel('Price').xTickFormat(function(d) {
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
      result.push([startDate.getTime(), startPrice]);
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
      interpolate: 'basis',
      values: getStocks(301.43, 0.0015)
    }, {
      key: 'series2',
      label: 'MSFT',
      type: 'line',
      values: getStocks(303.12, 0.002)
    }, {
      key: 'marker1',
      label: 'Profit',
      type: 'marker',
      axis: 'y',
      value: 305.1
    }, {
      key: 'region1',
      label: 'Election Season',
      type: 'region',
      axis: 'x',
      values: [50, 90]
    }
  ];

  chart.yAxis.tickFormat(d3.format('$,.2f'));

  chart.data(data).render();

}).call(this);
