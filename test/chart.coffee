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
            chart.destroy()

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

                circle = $(container).find('svg g.chart-item path.point')
                circle.length.should.equal 1, 'one <path> point'

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

                chart.xTicks(1).data(sampleData).render()

                xTicks = $(container).find('.x-axis .tick')
                xTicks.length.should.be.greaterThan 0

                yTicks = $(container).find('.y-axis .tick')
                yTicks.length.should.be.greaterThan 0

            it 'formats x-axis tick labels', ->
                chart = new ForestD3.Chart container
                sampleData = [
                    key: 'series1'
                    values: [
                        [ (new Date(2012, 0, 1)).getTime(), 0]
                        [ (new Date(2012, 0, 2)).getTime(), 2]
                    ]
                ]

                chart.xTickFormat (d)->
                    d3.time.format('%Y-%m-%d')(new Date d)

                chart.ordinal(true).data(sampleData).render()

                tickFormat = chart.xAxis.tickFormat()
                tickFormat(0).should.equal '2012-01-01'
                tickFormat(1).should.equal '2012-01-02'

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

                series = $(container).find('g.chart-item')
                series.length.should.equal 3, 'three groups'

                series.eq(0)[0].getAttribute('class').should.contain 'item-foo'
                series.eq(1)[0].getAttribute('class').should.contain 'item-bar'
                series.eq(2)[0].getAttribute('class').should.contain 'item-maz'

            it 'does not render hidden series', (done)->
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

                chart.data(sampleData)
                chart.data().hide(['bar'])
                chart.render()

                series = $(container).find('g.chart-item')
                series.length.should.equal 2, 'two series only'
                series.find('.series-bar').length.should.equal 0

                chart.data().show('bar')
                chart.render()

                series = $(container).find('g.chart-item')
                series.length.should.equal 3, 'three now'

                chart.data().hide('maz')
                chart.render()
                setTimeout ->
                    series = $(container).find('g.chart-item')
                    series.length.should.equal 2, 'back to two series only'
                    done()
                , 400

            it 'keeps chart items in order', (done)->
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

                chart.data(sampleData)
                chart.data().hide(['bar']).render()

                chart.data().show('bar').render()

                items = $(container).find('g.chart-item')
                items.get(0).getAttribute('class').should.contain 'item-foo'
                items.get(1).getAttribute('class').should.contain 'item-bar'
                items.get(2).getAttribute('class').should.contain 'item-maz'
                done()

        describe 'Marker Lines', ->
            it 'can render horizontal line (y-axis marker)', (done)->
                data = [
                    key: 'marker1'
                    label: 'Threshold'
                    type: 'marker'
                    value: 0
                    axis: 'y'
                ]

                chart = new ForestD3.Chart container
                chart.data(data).render()

                chartItems = $(container).find('g.chart-item')
                chartItems.length.should.equal 1

                line = chartItems.eq(0).find('line')
                line.length.should.equal 1, 'line exists'

                text = chartItems.eq(0).find('text')
                text.text().should.contain 'Threshold'

                setTimeout ->
                    line[0].getAttribute('x1').should.equal '0'
                    line[0].getAttribute('y1')
                    .should.equal line[0].getAttribute('y2')
                    done()
                , 300

            it 'can render horizontal line (x-axis marker)', (done)->
                data = [
                    key: 'marker1'
                    type: 'marker'
                    label: 'Threshold'
                    value: 0
                    axis: 'x'
                ]

                chart = new ForestD3.Chart container
                chart.data(data).render()

                line = $(container).find('g.chart-item line')
                text = $(container).find('g.chart-item text')
                text.text().should.contain 'Threshold'

                setTimeout ->
                    line[0].getAttribute('y1').should.equal '0'
                    line[0].getAttribute('x1')
                    .should.equal line[0].getAttribute('x2')
                    done()
                , 300

        describe 'Regions', ->
            it 'can render regions', ->
                data = [
                    key: 'region1'
                    type: 'region'
                    label: 'Tolerance'
                    axis: 'x'
                    values: [-1, 1]
                ,
                    key: 'region2'
                    type: 'region'
                    axis: 'y'
                    values: [-1, 1]
                ]

                chart = new ForestD3.Chart container
                chart.data(data).render()

                rect = $(container).find('g.chart-item rect')
                rect.length.should.equal 2, 'two rectangles'

        describe 'Line Chart', ->
            it 'can render an SVG line', ->
                data = [
                    key: 'line1'
                    type: 'line'
                    values: [
                        [0,0]
                        [1,1]
                        [2,4]
                    ]
                ]

                chart = new ForestD3.Chart container
                chart.data(data).render()

                line = $(container).find('g.chart-item path.line')
                line.length.should.equal 1, 'line path exists'

            it 'can render an SVG line and path if area=true', ->
                data = [
                    key: 'line1'
                    type: 'line'
                    area: true
                    values: [
                        [0,0]
                        [1,1]
                        [2,4]
                    ]
                ]

                chart = new ForestD3.Chart container
                chart.data(data).render()

                line = $(container).find('g.chart-item path.line')
                line.length.should.equal 1, 'line path exists'

                area = $(container).find('g.chart-item path.area')
                area.length.should.equal 1, 'area path exists'

        describe 'Bar Chart', ->
            it 'can render bar chart', ->
                data = [
                    key: 's1'
                    type: 'bar'
                    values: [
                        [0, 10]
                        [1, 20]
                        [2, 25]
                    ]
                ,

                    key: 's2'
                    type: 'bar'
                    values: [
                        [0, 11]
                        [1, 22]
                        [2, 27]
                    ]
                ]

                chart = new ForestD3.Chart container
                chart.data(data).render()

                bars1 = $(container).find('g.item-s1 rect')
                bars1.length.should.equal 3, 'three bars s1'

                bars2 = $(container).find('g.item-s2 rect')
                bars2.length.should.equal 3, 'three bars s2'

            it 'should set max width for each bar', (done)->
                data = [
                    key: 's1'
                    type: 'bar'
                    values: [
                        ['Population', 234]
                    ]
                ]

                chart = new ForestD3.Chart container
                chart.ordinal(true).data(data).render()

                setTimeout ->
                    bar = $(container).find('g.item-s1 rect').get(0)
                    width = parseFloat(bar.getAttribute('width'))
                    width.should.be.lessThan 300
                    done()
                , 300
