describe 'Chart', ->
    describe 'Guideline', ->
        chart = null
        container = null

        beforeEach ->
            container = document.createElement 'div'
            container.style.width = '500px'
            container.style.height = '400px'
            document.body.appendChild container

            data = [
                key: 'line1'
                type: 'line'
                values: [
                    [0,0]
                    [1,1]
                    [2,2]
                ]
            ,
                key: 'line2'
                type: 'line'
                values: [
                    [0,2]
                    [1,4]
                    [2,6]
                ]
            ]

            chart = new ForestD3.Chart container

            chart
                .showGuideline(true)
                .data(data)
                .render()

        afterEach ->
            chart.destroy()

        it 'can render a guideline', ->
            chart.updateTooltip [250, 200], [0,0]
            line = $(container).find('g.canvas line.guideline')

            line.length.should.equal 1, 'line exists'

            line = line.get(0)
            line.getAttribute('x1').should.not.equal '0'

            line.getAttribute('x1').should.equal line.getAttribute('x2')

        it 'renders guideline marker circles along the guideline', ->
            chart.updateTooltip [250, 200], [0,0]

            markerContainer = $(container).find('g.canvas g.guideline-markers')
            markerContainer.length.should.equal 1, 'container exists'

            markers = markerContainer.find('circle.marker')
            markers.length.should.equal 2, 'two markers'

        it 'can hide guideline', (done)->
            chart.updateTooltip [250, 200], [0,0]

            chart.updateTooltip null

            setTimeout ->
                line = $(container).find('line.guideline')
                line.css('opacity').should.equal '0'
                done()
            , 800
