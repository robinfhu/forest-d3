(function() {
  var chart, chartLog, chartUpdate, data, dataLog, dataUpdate, getStocks, legend;

  chart = new ForestD3.Chart(d3.select('#example'));

  legend = new ForestD3.Legend(d3.select('#legend'));

  chart.ordinal(true).margin({
    left: 50
  }).xLabel('Date').yLabel('Price').yTickFormat(d3.format(',.3f')).xTickFormat(function(d) {
    if (d != null) {
      return d3.time.format('%Y-%m-%d')(new Date(d));
    } else {
      return '';
    }
  }).addPlugin(legend);

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
      values: [5, 9]
    }
  ];

  chart.data(data).render();

  chartUpdate = new ForestD3.Chart('#example-update');

  chartUpdate.ordinal(true).chartLabel('Citi Bank (NYSE)').xTickFormat(function(d) {
    if (d != null) {
      return d3.time.format('%Y-%m-%d')(new Date(d));
    } else {
      return '';
    }
  });

  dataUpdate = [
    {
      key: 'series1',
      type: 'line',
      label: 'CITI',
      values: getStocks(206, 0.07, 200)
    }
  ];

  chartUpdate.data(dataUpdate).render();

  document.getElementById('update-data').addEventListener('click', function() {
    dataUpdate[0].values = getStocks(206, 0.07, 200);
    return chartUpdate.data(dataUpdate).render();
  });

  chartLog = new ForestD3.Chart('#example-log-scale');

  chartLog.ordinal(true).yScaleType(d3.scale.log).yPadding(0).chartLabel('Logarithmic Scale Example').tooltipType('spatial').xTickFormat(function(d) {
    if (d != null) {
      return d3.time.format('%Y-%m')(new Date(d));
    } else {
      return '';
    }
  });

  dataLog = [
    {
      key: 'series1',
      label: 'AAPL',
      type: 'line',
      color: '#efefef',
      values: getStocks(200, 0.4, 100)
    }
  ];

  chartLog.data(dataLog).render();

}).call(this);
