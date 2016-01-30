describe 'Tooltip and Guideline', ->
    chart = null
    container = null
    data = null
    beforeEach ->
        container = document.createElement 'div'
        container.style.width = '500px'
        container.style.height = '500px'
        document.body.appendChild container
        chart = new ForestD3.Chart container

        data = [
            key: 'series1'
            values: [
                [1,1]
                [2,2]
            ]
        ,
            key: 'series2'
            values: [
                [4,0]
                [5,0]
            ]
        ]

    afterEach ->
        chart.destroy()

    it 'rendered a guideline on the chart canvas', ->
        chart.data(data).render()
        line = $(container).find('.canvas line.guideline')
        line.length.should.equal 1

    it 'renders tooltip onto document.body', ->
        chart.data(data).render()
        chart.tooltip.id 'my-tooltip'
        chart.updateTooltip [0,0], [10,10]

        tooltip = $('.forest-d3.tooltip-box')
        tooltip.length.should.equal 1, 'tooltip exists'

        $('#my-tooltip').length.should.equal 1, 'select by id'

    it 'can render spatial tooltips', (done)->
        chart.ordinal(false).tooltipType('spatial').data(data).render()

        chart.updateTooltip [40, 400], [10, 10]

        x = chart.xScale 1
        y = chart.yScale 1

        chart.updateTooltip [x,y], [10,10]

        setTimeout ->
            crosshair = $(container).find('line.crosshair-x')
            crosshair.css('stroke-opacity').should.equal '0.5'
            done()
        , 200

    it 'adds "interactive" class to series when tooltipType=="hover"', (done)->
        chart.ordinal(false).tooltipType('hover').data(data).render()

        setTimeout ->
            series = $(container).find('g.series.interactive')
            series.length.should.equal 2, 'two interactive series'
            done()
        , 200
