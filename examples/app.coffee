container = document.getElementById 'example'
chart = new ForestD3.Chart container 

data = [
    key: 'series1'
    values: do ->
        for i in [0...50]
            [Math.random(), Math.random()]
]

chart.data(data).render()
