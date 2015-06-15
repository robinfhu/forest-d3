chart = new ForestD3.Chart d3.select('#example')
legend = new ForestD3.Legend d3.select('#legend')

chart.addPlugin legend

data = [
    key: 'series1'
    label: 'Consumer Discretionary'
    type: 'scatter'
    values: do ->
        result = []
        for i in [-5...5]
            for j in [0...10]
                result.push [i - Math.random(), Math.random()*6 + 1]

        result

,
    key: 'series2'
    label: 'Industrials'
    values: do ->
        result = []
        for i in [-5...5]
            for j in [0...10]
                result.push [i, Math.random()*-4]

        result
,
    key: 'series3'
    label: 'Telecommunications'
    color: '#f09822'
    values: do ->
        result = []
        for i in [-5...5]
            for j in [0...10]
                result.push [i, Math.random()*-3 + 1]

        result
,
    key: 'marker1'
    label: 'Performance Threshold'
    type: 'marker'
    axis: 'y'
    value: 5.75
,
    key: 'marker2'
    label: 'Performance Threshold'
    type: 'marker'
    axis: 'x'
    value: 1.07
,
    key: 'region1'
    label: 'Tolerance'
    type: 'region'
    axis: 'x'
    values: [-2.6, -0.9]
]

chart.data(data).render()
