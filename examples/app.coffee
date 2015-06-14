container = document.getElementById 'example'
legendContainer = document.getElementById 'legend'

chart = new ForestD3.Chart container
legend = new ForestD3.Legend legendContainer

chart.addPlugin legend

data = [
    key: 'series1'
    label: 'Consumer Discretionary'
    values: do ->
        for i in [0...100]
            if i % 2 is 0
                [Math.random()*6 + 4 + Math.random()*2, Math.random()*6 + 4 + Math.random()*2]
            else
                [Math.random()*-6 - 4, Math.random()*-6 - 4]

,
    key: 'series2'
    label: 'Industrials'
    values: do ->
        for i in [0...30]
            [Math.random()*10 - 5, Math.random()*10 - 5]
,
    key: 'series3'
    label: 'Telecommunications'
    color: '#fff'
    values: do ->
        for i in [0...30]
            [Math.random()*-6 - 4, Math.random()*4]
]

chart.data(data).render()
