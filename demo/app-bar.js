(function() {
  var chart, chartOneGroup, chartSingle, chartTwoGroups, data, dataOneGroup, dataSingle, dataTwoGroups, getStocks, legend;

  chart = new ForestD3.Chart('#example');

  legend = new ForestD3.Legend('#legend');

  chart.ordinal(true).chartLabel('Trading Volume').xLabel('Date').yLabel('Volume').yTickFormat(d3.format(',.3f')).xTickFormat(function(d) {
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
    for (i = j = 0; j < 15; i = ++j) {
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
      type: 'bar',
      values: getStocks(0.75, 0.47)
    }, {
      key: 'series2',
      label: 'GOLDMAN',
      type: 'bar',
      values: getStocks(0.6, 0.32)
    }, {
      key: 'series3',
      label: 'CITI',
      type: 'bar',
      values: getStocks(0.45, 0.76)
    }, {
      key: 'marker1',
      label: 'High Volume',
      type: 'marker',
      axis: 'y',
      value: 0.21
    }
  ];

  chart.data(data).render();

  chartSingle = new ForestD3.Chart('#example-single');

  chartSingle.ordinal(true).chartLabel('Single Bar');

  dataSingle = [
    {
      key: 'k1',
      type: 'bar',
      label: 'Series 1',
      values: [['Population', 234]]
    }
  ];

  chartSingle.data(dataSingle).render();

  chartOneGroup = new ForestD3.Chart('#example-onegroup');

  chartOneGroup.ordinal(true).yPadding(0.3).chartLabel('One Group');

  dataOneGroup = [
    {
      key: 'k1',
      type: 'bar',
      label: 'Series 1',
      values: [['Population', 234]]
    }, {
      key: 'k2',
      type: 'bar',
      label: 'Series 2',
      values: [['Population', 341]]
    }
  ];

  chartOneGroup.data(dataOneGroup).render();

  chartTwoGroups = new ForestD3.Chart('#example-twogroups');

  chartTwoGroups.ordinal(true).xPadding(1.5).yPadding(0).forceDomain({
    y: 0
  }).chartLabel('Two Groups');

  dataTwoGroups = [
    {
      key: 'k1',
      type: 'bar',
      label: 'Series 1',
      values: [['Exp. 1', 234], ['Exp. 2', 245]]
    }, {
      key: 'k2',
      type: 'bar',
      label: 'Series 2',
      values: [['Exp. 1', 341], ['Exp. 2', 321]]
    }
  ];

  chartTwoGroups.data(dataTwoGroups).render();

}).call(this);
