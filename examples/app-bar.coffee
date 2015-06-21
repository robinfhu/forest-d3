chart = new ForestD3.Chart '#example'
legend = new ForestD3.Legend '#legend'

chart
    .ordinal(true)
    .xLabel('Date')
    .yLabel('Volume')
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

    for i in [0...15]
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
    type: 'bar'
    values: getStocks(0.75, 0.47)
,
    key: 'series2'
    label: 'GOLDMAN'
    type: 'bar'
    values: getStocks(0.6, 0.32)
,
    key: 'series3'
    label: 'CITI'
    type: 'bar'
    values: getStocks(0.45, 0.76)
,
    key: 'marker1'
    label: 'High Volume'
    type: 'marker'
    axis: 'y'
    value: 0.21
]

chart.data(data).render()

# ******************* SINGLE BAR EXAMPLE **************** #
chartSingle = new ForestD3.Chart '#example-single'
chartSingle.ordinal(true)
dataSingle = [
    key: 'k1'
    type: 'bar'
    label: 'Series 1'
    values: [
        ['Population', 234]
    ]
]

chartSingle.data(dataSingle).render()