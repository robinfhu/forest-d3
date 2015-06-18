describe 'Tooltip and Guideline', ->
    chart = null
    container = null
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

        chart.data(data).render()

    afterEach ->
        chart.tooltip.cleanUp()
        document.body.removeChild container

    it 'rendered a guideline on the chart canvas', ->
        line = $(container).find('.canvas line.guideline')
        line.length.should.equal 1

    it 'renders tooltip onto document.body', ->
        chart.updateTooltip [0,0], [10,10]

        tooltip = $('.forest-d3.tooltip-box')
        tooltip.length.should.equal 1, 'tooltip exists'
