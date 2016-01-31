(function() {
  var chart, chartLog, chartNonOrdinal, chartRandom, chartUpdate, data, dataLog, dataNonOrdinal, dataRandom, dataUpdate, getRandom, getStocks, legend, rand;

  chart = new ForestD3.Chart(d3.select('#example'));

  legend = new ForestD3.Legend(d3.select('#legend'));

  chart.ordinal(true).margin({
    left: 90
  }).xPadding(0).xLabel('Date').yLabel('Price').yTickFormat(d3.format(',.2f')).xTickFormat(function(d) {
    if (d != null) {
      return d3.time.format('%Y-%m-%d')(new Date(d));
    } else {
      return '';
    }
  }).addPlugin(legend);

  getStocks = function(startPrice, volatility, points) {
    var changePct, i, j, ref, result, startDate;
    if (points == null) {
      points = 80;
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
      values: getStocks(5.75, 0.47)
    }, {
      key: 'series2',
      label: 'MSFT',
      type: 'line',
      area: true,
      values: getStocks(5, 1.1)
    }, {
      key: 'series3',
      label: 'FACEBOOK',
      type: 'line',
      area: true,
      interpolate: 'cardinal',
      values: getStocks(6.56, 0.13)
    }, {
      key: 'series4',
      label: 'AMAZON',
      type: 'line',
      area: false,
      values: getStocks(7.89, 0.37)
    }, {
      key: 'marker1',
      label: 'Profit',
      type: 'marker',
      axis: 'y',
      value: 0.2
    }, {
      key: 'region1',
      label: 'Earnings Season',
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
      values: getStocks(200, 0.4, 100).map(function(p) {
        if (p[1] <= 0) {
          p[1] = 1;
        }
        return p;
      })
    }
  ];

  chartLog.data(dataLog).render();

  chartRandom = new ForestD3.Chart('#example-random');

  chartRandom.ordinal(false).getX(function(d) {
    return d.x;
  }).getY(function(d) {
    return d.y;
  }).chartLabel('Random Data Points');

  getRandom = function() {
    var j, points, rand, results;
    rand = d3.random.normal(0, 0.6);
    points = (function() {
      results = [];
      for (j = 0; j < 50; j++){ results.push(j); }
      return results;
    }).apply(this).map(function(i) {
      return {
        x: i,
        y: rand()
      };
    });
    return d3.shuffle(points);
  };

  dataRandom = {
    series1: {
      type: 'line',
      values: getRandom()
    },
    series2: {
      type: 'line',
      values: getRandom()
    }
  };

  chartRandom.data(dataRandom).render();

  chartNonOrdinal = new ForestD3.Chart('#example-non-ordinal');

  chartNonOrdinal.ordinal(false).tooltipType('spatial').xTickFormat(d3.format('.2f')).chartLabel('Non-Ordinal Chart');

  rand = d3.random.normal(0, 0.6);

  dataNonOrdinal = [
    {
      type: 'scatter',
      symbol: 'circle',
      color: 'yellow',
      values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].map(function(d) {
        return [rand(), rand()];
      })
    }, {
      type: 'line',
      color: 'white',
      values: [[-1, -1], [-0.8, -0.7], [-0.3, -0.56], [0.4, 0.7], [0.2, 0.5], [0.5, 0.8], [1, 1.1]]
    }
  ];

  chartNonOrdinal.data(dataNonOrdinal).render();

  document.getElementById('update-x-sort').addEventListener('click', function() {
    chartRandom.autoSortXValues(!chartRandom.autoSortXValues());
    return chartRandom.data(dataRandom).render();
  });

}).call(this);
