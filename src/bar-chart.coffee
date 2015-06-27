chartProperties = [
    ['autoSize', true]
    ['height', null]
    ['barHeight', 30]
]

@ForestD3.BarChart = class BarChart extends ForestD3.BaseChart
    constructor: (domContainer)->
        super domContainer
        @_setProperties chartProperties

    data: (d)->
        @

    render: ->
        return unless @svg?
        @updateDimensions()
        @updateChartFrame()

        @

    ###
    Get the chart's dimensions, based on the parent container <div>.
    Calculate chart margins and canvas dimensions.
    ###
    updateDimensions: ->
        container = @container()
        if container?
            bounds = container.getBoundingClientRect()

            @canvasHeight = bounds.height
            @canvasWidth = bounds.width

    ###
    Draws the chart frame. Things like backdrop and canvas.
    ###
    updateChartFrame: ->
        labelGroup = @svg.selectAll('g.bar-labels').data([0])
        labelGroup.enter().append('g').classed('bar-labels', true)

        barGroup = @svg.selectAll('g.bars').data([0])
        barGroup.enter().append('g').classed('bars', true)

        valueGroup = @svg.selectAll('g.bar-values').data([0])
        valueGroup.enter().append('g').classed('bar-values', true)