describe 'Chart', ->
    describe 'Stackable Charts', ->
        chart = null
        container = null

        data = [
            values: [
                [1, 3]
                [2, 2]
                [3, 6]
            ]
        ,
            values: [
                [1, 1]
                [2, 3]
                [3, 1]
            ]
        ,
            values: [
                [1, 1]
                [2, 1]
                [3, 1]
            ]
        ]

        beforeEach ->
            container = document.createElement 'div'
            container.style.width = '500px'
            container.style.height = '400px'
            document.body.appendChild container

        afterEach ->
            chart.destroy()

        it 'computes the stacked offsets and extents', ->
            chart = new ForestD3.StackedChart container

            chart.stacked(true).stackType('bar').data(data).render()

            internal = chart.data().get()

            internal[2].values[0].y0.should.equal 0
            internal[2].values[1].y0.should.equal 0
            internal[2].values[2].y0.should.equal 0

            internal[1].values[0].y0.should.equal 1
            internal[1].values[1].y0.should.equal 1
            internal[1].values[2].y0.should.equal 1

            internal[0].values[0].y0.should.equal 2
            internal[0].values[1].y0.should.equal 4
            internal[0].values[2].y0.should.equal 2

            internal[2].extent.y.should.deep.equal [0, 1]
            internal[1].extent.y.should.deep.equal [0, 4]
            internal[0].extent.y.should.deep.equal [0, 8]

        it 'negative stacked values', (done)->
            chart = new ForestD3.StackedChart container

            dataNeg = [
                values: [[0, -1]]
            ,
                values: [[0, -2]]
            ,
                values: [[0, -3]]
            ,
                values: [[0, -2]]
            ]

            chart.stacked(true).stackType('bar').data(dataNeg).render()

            internal = chart.data().get()

            internal[3].values[0].y0.should.equal 0
            internal[2].values[0].y0.should.equal -2
            internal[1].values[0].y0.should.equal -5
            internal[0].values[0].y0.should.equal -7

            setTimeout ->
                series = $(container).find('g.series').eq(0)
                bar = series.find('rect')
                parseInt(bar.attr('y')).should.equal(parseInt(chart.yScale(-7)))

                series = $(container).find('g.series').eq(1)
                bar = series.find('rect')
                parseInt(bar.attr('y')).should.equal(parseInt(chart.yScale(-5)))

                series = $(container).find('g.series').eq(2)
                bar = series.find('rect')
                parseInt(bar.attr('y')).should.equal(parseInt(chart.yScale(-2)))

                series = $(container).find('g.series').eq(3)
                bar = series.find('rect')
                parseInt(bar.attr('y')).should.equal(parseInt(chart.yScale(0)))

                done()
            , 300

        it 'renders stacked bars and markers', (done)->
            chart = new ForestD3.StackedChart container

            data2 = data.concat [
                type: 'marker'
                label: 'Marker 1'
                axis: 'y'
                value: 4.5
            ]

            chart.stacked(true).stackType('bar').data(data2).render()

            internal = chart.data().get()
            for series,i in internal
                if i < 3
                    series.type.should.equal 'bar'
                else if i is 3
                    series.type.should.equal 'marker'

            setTimeout ->
                series = $(container).find('g.series')
                series.length.should.equal 4, '4 series'

                series.eq(0).find('rect.bar').length.should.equal 3, '3 bars'
                series.eq(1).find('rect.bar').length.should.equal 3, '3 bars'
                series.eq(2).find('rect.bar').length.should.equal 3, '3 bars'

                series.eq(3).find('line.marker').length.should.equal 1,'marker'
                done()
            , 500

        it 'calculates offset only for visible bars', ->
            chart = new ForestD3.StackedChart container

            chart.stacked(true).stackType('bar').data(data)

            chart.data().hide('series1').render()

            internal = chart.data().visible()

            internal[0].values[0].y0.should.equal 1
