(function() {
  var chart, data, getStocks;

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

  chart = new ForestD3.StackedChart('#example');

  data = [
    {
      label: 'Consumer Discretionary',
      values: getStocks(30, 0.05)
    }, {
      label: 'Health Care',
      values: getStocks(40, 0.05)
    }, {
      label: 'Industrials',
      values: getStocks(45, 0.05)
    }, {
      label: 'Financial',
      values: getStocks(100, 0.07)
    }, {
      label: 'Oil',
      values: getStocks(10, 0.04)
    }, {
      label: 'Mid Cap',
      values: getStocks(32, 0.01)
    }, {
      label: 'Real Estate',
      values: getStocks(70, 0.03)
    }
  ];

  chart.stacked(true).stackType('area').xPadding(0.02).xTickFormat(function(d) {
    if (d != null) {
      return d3.time.format('%Y-%m-%d')(new Date(d));
    } else {
      return '';
    }
  }).addPlugin(new ForestD3.Legend('#legend')).data(data).render();

}).call(this);
