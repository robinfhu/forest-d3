describe 'Chart', ->
    describe 'OHLC (open high low close) Chart', ->
        it 'can render', ->
            container = document.createElement 'div'
            chart = new ForestD3.Chart container
            data = [
                key: 's1'
                type: 'ohlc'
                values: [
                    [0, 0.01, 0.2, 0.01, 0.15]
                    [1, 0.02, 0.21, 0.016, 0.17]
                ]
            ]

            chart.data(data).render()

            lines = $(container).find('line.ohlc-range')
            lines.length.should.equal 2, 'two range lines'
