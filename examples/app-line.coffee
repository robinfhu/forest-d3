chart = new ForestD3.Chart d3.select('#example')
legend = new ForestD3.Legend d3.select('#legend')

chart
    .xLabel('Date')
    .yLabel('Price')
    .addPlugin(legend)

data = [
    key: 'series1'
    label: 'AAPL'
    type: 'line'
    values: do ->
        result = []
        startPrice = 301.34
        volatility = 0.02
        startDate = new Date 2012, 0, 1

        for i in [0...200]
            result.push [
                startDate.getTime(),
                startPrice
            ]
            changePct = 2 * volatility * Math.random()
            if changePct > volatility
                changePct -= 2*volatility

            startPrice += startPrice * changePct
            startDate.setDate(startDate.getDate()+1)

        result

]

chart.data(data).render()
