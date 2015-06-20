(function() {
  var chart, data, getStocks, legend, stocks;

  chart = new ForestD3.Chart('#example');

  legend = new ForestD3.Legend('#legend');

  chart.ordinal(true).getX(function(d) {
    return d.date;
  }).getY(function(d) {
    return d.value;
  }).xLabel('Date').yLabel('Quote').yTickFormat(d3.format(',.3f')).xTickFormat(function(d) {
    if (d != null) {
      return d3.time.format('%Y-%m-%d')(new Date(d));
    } else {
      return '';
    }
  }).addPlugin(legend);

  getStocks = function(startPrice, volatility) {
    var changePct, close, hi, i, j, lo, result, startDate;
    result = [];
    startDate = new Date(2012, 0, 1);
    for (i = j = 0; j < 40; i = ++j) {
      hi = startPrice + Math.random() * 5;
      lo = startPrice - Math.random() * 5;
      close = Math.random() * (lo - hi) + hi;
      result.push({
        date: startDate.getTime(),
        open: startPrice,
        hi: hi,
        lo: lo,
        close: close
      });
      changePct = 2 * volatility * Math.random();
      if (changePct > volatility) {
        changePct -= 2 * volatility;
      }
      startPrice += startPrice * changePct;
      startDate.setDate(startDate.getDate() + 1);
    }
    return result;
  };

  stocks = getStocks(75, 0.047);

  data = [
    {
      key: 'series1',
      label: 'AAPL',
      type: 'ohlc',
      values: stocks,
      getOpen: function(d) {
        return d.open;
      },
      getClose: function(d) {
        return d.close;
      },
      getHi: function(d) {
        return d.hi;
      },
      getLo: function(d) {
        return d.lo;
      }
    }, {
      key: 'series2',
      label: 'AAPL Low',
      type: 'line',
      color: 'orange',
      getY: function(d) {
        return d.lo;
      },
      interpolate: 'cardinal',
      values: (function() {
        return stocks.map(function(d) {
          return {
            date: d.date,
            value: d.lo
          };
        });
      })()
    }
  ];

  chart.data(data).render();

}).call(this);
