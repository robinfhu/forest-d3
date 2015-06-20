chart = new ForestD3.Chart '#example'
legend = new ForestD3.Legend '#legend'

chart
    .ordinal(true)
    .getX((d)-> d.date)
    .getY((d)-> d.value)
    .xLabel('Date')
    .yLabel('Quote')
    .yTickFormat(d3.format(',.3f'))
    .xTickFormat((d)->
        if d?
            d3.time.format('%Y-%m-%d')(new Date d)
        else
            ''
    )
    .addPlugin(legend)

getStocks = (startPrice, volatility)->
    result = []
    startDate = new Date 2012, 0, 1

    for i in [0...40]
        hi = startPrice + Math.random() * 5
        lo = startPrice - Math.random() * 5

        close = Math.random() * (lo - hi) + hi

        result.push {
                date: startDate.getTime()
                open: startPrice
                hi
                lo
                close
            }

        changePct = 2 * volatility * Math.random()
        if changePct > volatility
            changePct -= 2*volatility

        startPrice += startPrice * changePct
        startDate.setDate(startDate.getDate()+1)

    result

stocks = getStocks(75, 0.047)

data = [
    key: 'series1'
    label: 'AAPL'
    type: 'ohlc'
    values: stocks
    getOpen: (d)-> d.open
    getClose: (d)-> d.close
    getHi: (d)-> d.hi
    getLo: (d)-> d.lo
,
    key: 'series2'
    label: 'AAPL Low'
    type: 'line'
    color: 'orange'
    getY: (d)-> d.lo
    interpolate: 'cardinal'
    values: do->
        stocks.map (d)->
            date: d.date
            value: d.lo
]

chart.data(data).render()
