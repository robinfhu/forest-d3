(function() {
  var chart, chartOneGroup, chartSingle, chartSingleSeries, chartStackedBar, chartTwoGroups, data, dataOneGroup, dataSingle, dataSingleSeries, dataStacked, dataTwoGroups, getStocks, getVals, legend, legendStacked, months;

  chart = new ForestD3.Chart('#example');

  legend = new ForestD3.Legend('#legend');

  chart.chartLabel('Trading Volume').xLabel('Date').yLabel('Volume').yTickFormat(d3.format(',.3f')).xTickFormat(function(d) {
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

  chartSingle.chartLabel('Single Bar');

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

  chartOneGroup.yPadding(0.3).chartLabel('One Group');

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

  chartTwoGroups.xPadding(1.5).yPadding(0).forceDomain({
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

  dataSingleSeries = {
    monthlyData: {
      color: '#aaa',
      type: 'bar',
      classed: function(d) {
        if (d.calc > 22) {
          return '-highlight-bar';
        } else {
          return '';
        }
      },
      values: [
        {
          month: 'Jan',
          calc: 5.5
        }, {
          month: 'Feb',
          calc: 6.7
        }, {
          month: 'Mar',
          calc: 8.0
        }, {
          month: 'Apr',
          calc: 13.5
        }, {
          month: 'May',
          calc: 20.4
        }, {
          month: 'Jun',
          calc: 22.8
        }, {
          month: 'Jul',
          calc: 19.8
        }, {
          month: 'Aug',
          calc: 16.8
        }, {
          month: 'Sep',
          calc: 10.4
        }, {
          month: 'Oct',
          calc: 4.5
        }, {
          month: 'Nov',
          calc: 3.2
        }, {
          month: 'Dec',
          calc: 1.1
        }
      ]
    }
  };

  chartSingleSeries = new ForestD3.Chart('#example-single-series');

  chartSingleSeries.getX(function(d) {
    return d.month;
  }).getY(function(d) {
    return d.calc;
  }).reduceXTicks(false).chartLabel('Monthly Calculations').data(dataSingleSeries).render();

  months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];

  getVals = function(list) {
    return list.map(function(d, i) {
      return {
        month: months[i],
        val: d
      };
    });
  };

  dataStacked = [
    {
      label: 'Apples',
      values: getVals([1, 3, 4.6, 8.81, 7.6, 4, 1.3])
    }, {
      label: 'Pears',
      values: getVals([1, 1.3, 2.4, 5.6, 7.6, 4.5, 1.4])
    }, {
      label: 'Grapes',
      values: getVals([0.4, 0.9, 1.2, 3.4, 2.4, 0.6, 0.3])
    }, {
      label: 'Strawberries',
      values: getVals([1.9, 3, 4.6, 7.3, 5.5, 4.3, 0.6])
    }
  ];

  chartStackedBar = new ForestD3.StackedChart('#example-stacked');

  legendStacked = new ForestD3.Legend('#legend-stacked');

  chartStackedBar.getX(function(d) {
    return d.month;
  }).getY(function(d) {
    return d.val;
  }).xPadding(0.2).barPaddingPercent(0.0).stacked(true).stackType('bar').addPlugin(legendStacked).data(dataStacked).render();

}).call(this);
