chart = new ForestD3.Chart d3.select('#example')
legend = new ForestD3.Legend d3.select('#legend')

chart
    .ordinal(true)
    .xLabel('Date')
    .yLabel('Price')
    .yTickFormat(d3.format(',.3f'))
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
            startPrice - 0.3
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
    interpolate: 'cardinal'
    values: getStocks(0.75, 0.47)
,
    key: 'series2'
    label: 'MSFT'
    type: 'line'
    area: true
    values: getStocks(0.26, 0.2)
,
    key: 'series3'
    label: 'FACEBOOK'
    type: 'line'
    area: true
    interpolate: 'cardinal'
    values: getStocks(0.56, 0.13)
,
    key: 'marker1'
    label: 'Profit'
    type: 'marker'
    axis: 'y'
    value: 0.2
,
    key: 'region1'
    label: 'Election Season'
    type: 'region'
    axis: 'x'
    values: [50, 90]
]

chart.data(data).render()
