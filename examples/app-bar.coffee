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
months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
getVals = (list)-> list.map (d,i)-> {month: months[i], val: d}

dataSingleSeries =
    monthlyData:
        color: '#aaa'
        type: 'bar'
        classed: (d)->
            if d.val > 22 then '-highlight-bar' else ''
        values: getVals([3.4,4.5,6.7,8.0,13.5,22.4,19.8,15.4,11.3,8.3,6.5,2.4])
    average:
        color: '#aaf'
        type: 'line'
        interpolate: 'cardinal'
        values: getVals([3.9,5.5,2.7,8.9,30.5,36.4,23.8,14.4,11.3,7.3,8.5,5.4])


chartSingleSeries = new ForestD3.Chart '#example-single-series'
chartSingleSeries
    .getX((d)-> d.month)
    .getY((d)-> d.val)
    .reduceXTicks(false)
    .chartLabel('Monthly Calculations')
    .data(dataSingleSeries)
    .addPlugin(new ForestD3.Legend('#legend-single-series'))
    .render()

# ******************** Stacked Bar Example ****************
dataStacked = [
    label: 'Apples'
    values: getVals([-1.3,1,3,4.6,8.81,7.6,4,1.3])
,
    label: 'Pears'
    values: getVals([-1.7,1,1.3,2.4,5.6,7.6,4.5,1.4])
,
    label: 'Grapes'
    values: getVals([-2.3,0.4,0.9,1.2,3.4,2.4,0.6,0.3])
,
    label: 'Strawberries'
    values: getVals([-6.7,1.9,3,4.6,7.3,5.5,4.3,0.6])
,
    type: 'marker'
    axis: 'y'
    value: 7.1
    label: 'Threshold'
]

chartStackedBar = new ForestD3.StackedChart '#example-stacked'
legendStacked = new ForestD3.Legend '#legend-stacked'

chartStackedBar
    .getX((d)-> d.month)
    .getY((d)-> d.val)
    .chartLabel('Stacked Bar Example')
    .xPadding(0.2)
    .barPaddingPercent(0.0)
    .stacked(true)
    .stackType('bar')
    .addPlugin(legendStacked)
    .data(dataStacked)
    .render()

document.getElementById('toggle-stacked-button').addEventListener 'click', ->
    chartStackedBar.stacked(not chartStackedBar.stacked()).render()
