chart = new ForestD3.Chart '#example'
legend = new ForestD3.Legend '#legend'

chart
    .chartLabel('Trading Volume')
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
chartSingle.chartLabel('Single Bar')
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
chartOneGroup.yPadding(0.3).chartLabel('One Group')
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
chartTwoGroups
    .xPadding(1.5)
    .yPadding(0)
    .forceDomain({y: 0})
    .chartLabel('Two Groups')

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

# ************************* Just a regular single series
dataSingleSeries =
    monthlyData:
        color: '#aaa'
        type: 'bar'
        classed: (d)->
            if d.calc > 22 then '-highlight-bar' else ''
        values: [
            month: 'Jan'
            calc: 5.5
        ,
            month: 'Feb'
            calc: 6.7
        ,
            month: 'Mar'
            calc: 8.0
        ,
            month: 'Apr'
            calc: 13.5
        ,
            month: 'May'
            calc: 20.4
        ,
            month: 'Jun'
            calc: 22.8
        ,
            month: 'Jul'
            calc: 19.8
        ,
            month: 'Aug'
            calc: 16.8
        ,
            month: 'Sep'
            calc: 10.4
        ,
            month: 'Oct'
            calc: 4.5
        ,
            month: 'Nov'
            calc: 3.2
        ,
            month: 'Dec'
            calc: 1.1
        ]

chartSingleSeries = new ForestD3.Chart '#example-single-series'
chartSingleSeries
    .getX((d)-> d.month)
    .getY((d)-> d.calc)
    .reduceXTicks(false)
    .chartLabel('Monthly Calculations')
    .data(dataSingleSeries)
    .render()

# ******************** Stacked Bar Example ****************
dataStacked = [
    label: 'Apples'
    values: [
        month: 'Jan'
        val: 1
    ,
        month: 'Feb'
        val: 3
    ,
        month: 'Mar'
        val: 4.6
    ,
        month: 'Apr'
        val: 8.81
    ,
        month: 'May'
        val: 7.5
    ]
,
    label: 'Pears'
    values: [
        month: 'Jan'
        val: 5
    ,
        month: 'Feb'
        val: 1.2
    ,
        month: 'Mar'
        val: 1.4
    ,
        month: 'Apr'
        val: 3.4
    ,
        month: 'May'
        val: 0.4
    ]
,
    label: 'Bananas'
    values: [
        month: 'Jan'
        val: 10.2
    ,
        month: 'Feb'
        val: 2
    ,
        month: 'Mar'
        val: 1.4
    ,
        month: 'Apr'
        val: 7.4
    ,
        month: 'May'
        val: 2.3
    ]
]

chartStackedBar = new ForestD3.Chart '#example-stacked'
legendStacked = new ForestD3.Legend '#legend-stacked'

chartStackedBar
    .getX((d)-> d.month)
    .getY((d)-> d.val)
    .xPadding(0.4)
    .stackable(true)
    .stacked(true)
    .stackType('bar')
    .addPlugin(legendStacked)
    .data(dataStacked)
    .render()
