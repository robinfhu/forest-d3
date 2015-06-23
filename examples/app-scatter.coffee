chart = new ForestD3.Chart '#example'
legend = new ForestD3.Legend '#legend'
chart
    .tooltipType('spatial')
    .xTickFormat(d3.format('.2f'))
    .addPlugin(legend)

getValues = (factor=40)->
    values = [0...20].map (_)->
        [Math.random() * 10, Math.random() * factor]

    values.sort (a,b)-> d3.ascending(a[0], b[0])

    values

data = [
    key: 'series1'
    type: 'scatter'
    label: 'Sample A'
    shape: 'square'
    color: 'orange'
    values: getValues()
,
    key: 'series2'
    type: 'scatter'
    label: 'Sample B'
    values: getValues(20)
]

chart.data(data).render()
