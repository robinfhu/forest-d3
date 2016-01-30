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

            internal[0].values[0].y0.should.equal 0
            internal[0].values[1].y0.should.equal 0
            internal[0].values[2].y0.should.equal 0

            internal[1].values[0].y0.should.equal 3
            internal[1].values[1].y0.should.equal 2
            internal[1].values[2].y0.should.equal 6

            internal[2].values[0].y0.should.equal 4
            internal[2].values[1].y0.should.equal 5
            internal[2].values[2].y0.should.equal 7

            internal[0].extent.y.should.deep.equal [2, 6]
            internal[1].extent.y.should.deep.equal [4, 7]
            internal[2].extent.y.should.deep.equal [5, 8]

        it 'renders stacked bars', (done)->
            chart = new ForestD3.StackedChart container

            chart.stacked(true).stackType('bar').data(data).render()

            setTimeout ->
                done()
            , 500

