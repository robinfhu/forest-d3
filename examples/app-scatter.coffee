chart = new ForestD3.Chart '#example'
legend = new ForestD3.Legend '#legend'
chart
    .tooltipType('spatial')
    .xTickFormat(d3.format('.2f'))
    .addPlugin(legend)

getValues = (factor=40)->
    values = [0...20].map (_)->
        [Math.random() * 10, Math.random() * factor]

data = [
    shape: 'square'
    color: 'orange'
    values: getValues()
,
    values: getValues(20)
]

chart.data(data).render()
