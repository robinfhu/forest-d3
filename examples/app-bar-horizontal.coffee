chart = new ForestD3.BarChart '#example'
data = [
    key: 'series1'
    label: 'Long'
    color: '#555'
    values: [
        ['Toyota', 100]
        ['Honda', 80]
        ['Mazda', 70]
        ['Prius', 10]
        ['Ford F150', 87]
        ['Hyundai', 23.4]
        ['Chrysler', 1]
        ['Lincoln', 102]
    ]
]

chart.data(data).render()
chart.sortBy((d)-> d[1])

sortDir = 0

document.getElementById('sort-button').addEventListener 'click', ->
    chart.sortDirection(if sortDir is 0 then 'asc' else 'desc').render()
    sortDir = 1 - sortDir
