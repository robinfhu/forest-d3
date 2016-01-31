chart = new ForestD3.Chart '#example'
legend = new ForestD3.Legend '#legend'
chart
    .ordinal(false)
    .chartLabel('Spatial Tooltips')
    .tooltipType('spatial')
    .xTickFormat(d3.format('.2f'))
    .addPlugin(legend)


getValues = (deviation=1.0)->
    rand = d3.random.normal 0, deviation
    values = [0...30].map (_)-> [rand(), rand()]

data = [
    shape: 'square'
    color: 'orange'
    values: getValues()
,
    values: getValues(1.9)
,
    shape: 'circle'
    values: getValues(0.7)
]

chart.data(data).render()

# ************************* Hover example ******************
chartHover = new ForestD3.Chart '#example-hover'
chartHover
    .ordinal(false)
    .chartLabel('Hover Tooltips')
    .tooltipType('hover')
    .xTickFormat(d3.format('.2f'))
    .addPlugin(new ForestD3.Legend '#legend-hover')

dataHover = [
    values: getValues(1.1)
,
    values: getValues(1.3)
,
    values: getValues(1.4)
]

chartHover.data(dataHover).render()