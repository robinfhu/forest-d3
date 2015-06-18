chart = new ForestD3.Chart d3.select('#example')
legend = new ForestD3.Legend d3.select('#legend')

chart
    .ordinal(true)
    .xLabel('Date')
    .yLabel('Price')
    .xTickFormat((d)->
        if d?
            d3.time.format('%Y-%m-%d')(new Date d)
        else
            ''
    )
    .addPlugin(legend)

getStocks = (startPrice, volatility)->
    result = []
    startDate = new Date 2012, 0, 1

    for i in [0...200]
        result.push [
            startDate.getTime(),
            startPrice
        ]
        changePct = 2 * volatility * Math.random()
        if changePct > volatility
            changePct -= 2*volatility

        startPrice += startPrice * changePct
        startDate.setDate(startDate.getDate()+1)

    result

data = [
    key: 'series1'
    label: 'AAPL'
    type: 'line'
    interpolate: 'basis'
    values: getStocks(301.43, 0.0015)
,
    key: 'series2'
    label: 'MSFT'
    type: 'line'
    values: getStocks(303.12, 0.002)
,
    key: 'marker1'
    label: 'Profit'
    type: 'marker'
    axis: 'y'
    value: 305.1
,
    key: 'region1'
    label: 'Election Season'
    type: 'region'
    axis: 'x'
    values: [50, 90]
]

chart.yAxis.tickFormat(d3.format('$,.2f'))

chart.data(data).render()
