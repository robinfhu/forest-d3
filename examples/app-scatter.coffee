chart = new ForestD3.Chart '#example'
chart
    .tooltipType('spatial')
    .xTickFormat(d3.format('.2f'))

getValues = (factor=40)->
    values = [0...20].map (_)->
        [Math.random() * 10, Math.random() * factor]

    values.sort (a,b)-> d3.ascending(a[0], b[0])

    values

data = [
    key: 'series1'
    type: 'scatter'
    label: 'Sample A'
    values: getValues()
]

chart.data(data).render()

# ****************** Example 2 ****************
chart2 = new ForestD3.Chart '#example2'
chart2
    .tooltipType('spatial')
    .xTickFormat(d3.format('.2f'))

data2 = [
    key: 'series1'
    type: 'scatter'
    label: 'Sample A'
    values: getValues()
,
    key: 'series2'
    type: 'scatter'
    interpolate: 'cardinal'
    label: 'Sample B'
    values: getValues(20)
]

chart2.data(data2).render()
