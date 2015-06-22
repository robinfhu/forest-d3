chart = new ForestD3.Chart '#example'
chart
    .tooltipType('spatial')
    .xTickFormat(d3.format('.2f'))

values = [0...20].map (_)->
    [Math.random() * 10, Math.random() * 40]

values.sort (a,b)-> d3.ascending(a[0], b[0])

data = [
    key: 'series1'
    type: 'scatter'
    label: 'Sample A'
    values: values
]

chart.data(data).render()
