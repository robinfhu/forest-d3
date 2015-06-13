describe 'Chart', ->
    describe 'smoke tests', ->
        it 'should exist', ->
            expect(ForestD3).to.exist
            expect(ForestD3.Chart).to.exist

    describe 'chart API', ->
        chart = null
        container = null

        beforeEach ->
            container = document.createElement 'div'
            container.style.width = '500px'
            container.style.height = '400px'
            document.body.appendChild container

        afterEach ->
            document.body.removeChild container

        it 'can accept container DOM', ->
            chart = new ForestD3.Chart()

            chart.container.should.exist
            chart.container container

            chart.container().querySelector.should.exist

        it 'can render an <svg> element (only once)', ->
            chart = new ForestD3.Chart container

            chart.render.should.exist

            svg = container.querySelector('svg')
            svg.should.exist

        it 'applies forest-d3 class to container', ->
            chart = new ForestD3.Chart container
            $(container).hasClass('forest-d3').should.be.true

        describe 'Scatter Chart', ->
            it 'draws a single point', ->
                sampleData = [
                    key: 'series1'
                    values: [
                        [0,0]
                    ]
                ]

                chart = new ForestD3.Chart container
                chart.data.should.exist

                chart.data(sampleData).render()

                circle = $(container).find('svg circle')
                circle.length.should.equal 1, 'one <circle>'

            it 'renders the chart frame once', ->
                chart = new ForestD3.Chart container

                chart.data([]).render().render()

                rect = $(container).find('svg rect.backdrop')
                rect.length.should.equal 1

                canvas = $(container).find('svg g.canvas')
                canvas.length.should.equal 1

            it 'renders axes', ->
                chart = new ForestD3.Chart container
                sampleData = [
                    key: 'series1'
                    values: [
                        [0,0]
                        [1,1]
                    ]
                ]
                chart.data(sampleData).render()

                xTicks = $(container).find('.x-axis .tick')
                xTicks.length.should.be.greaterThan 0

                yTicks = $(container).find('.y-axis .tick')
                yTicks.length.should.be.greaterThan 0

            it 'renders more than one series', ->
                chart = new ForestD3.Chart container

                sampleData = [
                    key: 'foo'
                    values: [
                        [0,0]
                    ]
                ,
                    key: 'bar'
                    values: [
                        [1,1]
                    ]
                ,
                    key: 'maz'
                    values: [
                        [2,2]
                    ]
                ]

                chart.data(sampleData).render()

                series = $(container).find('g.series')
                series.length.should.equal 3, 'three groups'

                series.eq(0)[0].getAttribute('class').should.contain 'series-foo'
                series.eq(1)[0].getAttribute('class').should.contain 'series-bar'
                series.eq(2)[0].getAttribute('class').should.contain 'series-maz'

