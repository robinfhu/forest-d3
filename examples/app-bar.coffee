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

# ******************* ONE GROUP BAR EXAMPLE **************** #
chartOneGroup = new ForestD3.Chart '#example-onegroup'
chartOneGroup.ordinal(true).yPadding(0.3)
dataOneGroup = [
    key: 'k1'
    type: 'bar'
    label: 'Series 1'
    values: [
        ['Population', 234]
    ]
,
    key: 'k2'
    type: 'bar'
    label: 'Series 2'
    values: [
        ['Population', 341]
    ]
]

chartOneGroup.data(dataOneGroup).render()

# ******************* TWO GROUPS BAR EXAMPLE **************** #
chartTwoGroups = new ForestD3.Chart '#example-twogroups'
chartTwoGroups.ordinal(true).yPadding(0.3).xPadding(1.5)
dataTwoGroups = [
    key: 'k1'
    type: 'bar'
    label: 'Series 1'
    values: [
        ['Exp. 1', 234]
        ['Exp. 2', 245]
    ]
,
    key: 'k2'
    type: 'bar'
    label: 'Series 2'
    values: [
        ['Exp. 1', 341]
        ['Exp. 2', 321]
    ]
]

chartTwoGroups.data(dataTwoGroups).render()