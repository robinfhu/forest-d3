lineChart = new ForestD3.Chart '#line-plot'
barChart = new ForestD3.Chart '#bar-plot'
legend = new ForestD3.Legend '#legend'

getStocks = (startPrice, volatility, points=20)->
    result = []
    startDate = new Date 2012, 0, 1

    for i in [0...points]
        result.push [
            startDate.getTime(),
            startPrice - 0.3
        ]
        changePct = 2 * volatility * Math.random()
        if changePct > volatility
            changePct -= 2*volatility

        startPrice += startPrice * changePct
        startDate.setDate(startDate.getDate()+1)

    result

lineData =
    series1:
        label: 'AAPL'
        type: 'line'
        color: 'rgb(143,228,94)'
        values: getStocks(320, 0.23, 100)
    series2:
        label: 'AAPL Volatility'
        type: 'line'
        area: true
        values: getStocks(304, 0.34, 100)
    series3:
        label: 'Benchmark S&P'
        type: 'scatter'
        shape: 'triangle-down'
        size: 64
        color: 'rgb(108, 109, 186)'
        values: getStocks(306, 0.289, 100)
    marker1:
        label: 'DOW Average'
        type: 'marker'
        axis: 'y'
        value: 404

legend.onlyDataSeries false

lineChart
    .ordinal(true)
    .xTickFormat((d)->
        if d?
            d3.time.format('%Y-%m-%d')(new Date d)
        else
            ''
    )
    .showXAxis(false)
    .duration(500)
    .addPlugin(legend)
    .on('tooltipBisect.test', (evt)->
        mouse = evt.clientMouse.slice()
        mouse[1] += 300
        barChart.renderBisectTooltipAt evt.index, mouse
    )
    .data(lineData)
    .render()

barData = [
    key: 'bar1'
    label: 'Volume'
    type: 'bar'
    values: getStocks(100, 0.35, 100)
,
    key: 'marker1'
    label: 'VOL Average'
    type: 'marker'
    axis: 'y'
    value: 230
]

barChart
    .ordinal(true)
    .yTicks(3)
    .xTickFormat((d)->
        if d?
            d3.time.format('%Y-%m-%d')(new Date d)
        else
            ''
    )
    .on('tooltipBisect.test', (evt)->

    )
    .data(barData)
    .render()