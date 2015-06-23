(function() {
  var barChart, barData, getStocks, legend, lineChart, lineData;

  lineChart = new ForestD3.Chart('#line-plot');

  barChart = new ForestD3.Chart('#bar-plot');

  legend = new ForestD3.Legend('#legend');

  getStocks = function(startPrice, volatility, points) {
    var changePct, i, j, ref, result, startDate;
    if (points == null) {
      points = 20;
    }
    result = [];
    startDate = new Date(2012, 0, 1);
    for (i = j = 0, ref = points; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
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

  lineData = [
    {
      key: 'series1',
      label: 'AAPL',
      type: 'line',
      color: 'rgb(143,228,94)',
      values: getStocks(320, 0.23, 100)
    }, {
      key: 'series2',
      label: 'AAPL Volatility',
      type: 'line',
      area: true,
      values: getStocks(304, 0.34, 100)
    }, {
      key: 'series3',
      label: 'Benchmark S&P',
      type: 'scatter',
      shape: 'triangle-down',
      size: 64,
      color: 'rgb(108, 109, 186)',
      values: getStocks(306, 0.289, 100)
    }, {
      key: 'marker1',
      label: 'DOW Average',
      type: 'marker',
      axis: 'y',
      value: 404
    }
  ];

  lineChart.ordinal(true).xTickFormat(function(d) {
    if (d != null) {
      return d3.time.format('%Y-%m-%d')(new Date(d));
    } else {
      return '';
    }
  }).showXAxis(false).addPlugin(legend).data(lineData).render();

  barData = [
    {
      key: 'bar1',
      label: 'Volume',
      type: 'bar',
      values: getStocks(100, 0.35, 100)
    }, {
      key: 'marker1',
      label: 'VOL Average',
      type: 'marker',
      axis: 'y',
      value: 230
    }
  ];

  barChart.ordinal(true).xTickFormat(function(d) {
    if (d != null) {
      return d3.time.format('%Y-%m-%d')(new Date(d));
    } else {
      return '';
    }
  }).data(barData).render();

}).call(this);
