container = document.getElementById 'example'
chart = new ForestD3.Chart container 

data = [
    key: 'series1'
    values: [
        [0,0]
    ]
]

chart.data(data).render()
