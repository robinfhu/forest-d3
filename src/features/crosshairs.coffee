###
Handles the guideline that moves along the x-axis
###
@ForestD3.Crosshairs = class Crosshairs
    constructor: (@chart)->

    # Creates the guideline on the canvas selection
    create: (canvas)->
        return unless @chart.showGuideline()

        # Add a guideline
        @xLine = canvas.selectAll('line.crosshair-x')
            .data([@chart.canvasHeight])
        @yLine = canvas.selectAll('line.crosshair-y')
            .data([@chart.canvasWidth])

        @xLine.enter()
            .append('line')
            .classed('crosshair-x', true)
            .style('stroke-opacity', 0)

        @xLine
            .attr('y1', 0)
            .attr('y2', (d)-> d)

        @yLine.enter()
            .append('line')
            .classed('crosshair-y', true)
            .style('stroke-opacity', 0)

        @yLine
            .attr('x1', 0)
            .attr('x2', (d)-> d)

    render: (x,y)->
        return unless @chart.showGuideline()
        return unless @xLine?

        # Show the crosshairs and position it.
        @xLine
            .transition()
            .duration(50)
            .attr('x1', x)
            .attr('x2', x)
            .style('stroke-opacity', 0.5)

        @yLine
            .transition()
            .duration(50)
            .attr('y1', y)
            .attr('y2', y)
            .style('stroke-opacity', 0.5)

    hide: ->
        return unless @chart.showGuideline()
        return unless @xLine?

        @xLine
            .transition()
            .delay(250)
            .style('stroke-opacity', 0)

        @yLine
            .transition()
            .delay(250)
            .style('stroke-opacity', 0)
