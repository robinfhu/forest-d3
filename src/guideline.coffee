###
Handles the guideline that moves along the x-axis
###
@ForestD3.Guideline = class Guideline
    constructor: (chart)->
        @chart = chart

    # Creates the guideline on the canvas selection
    create: (canvas)->
        return unless @chart.showGuideline()
        # Add a guideline
        @line = canvas.selectAll('line.guideline').data([@chart.canvasHeight])

        @line.enter()
            .append('line')
            .classed('guideline', true)
            .style('opacity', 0)

        @line
            .attr('y1', 0)
            .attr('y2', (d)-> d)

    render: (xPosition, idx)->
        return unless @chart.showGuideline()
        return unless @line?

        # Show the guideline and position it.
        @line
            .attr('x1', xPosition)
            .attr('x2', xPosition)
            .transition()
            .style('opacity', 0.5)

    hide: ->
        return unless @chart.showGuideline()
        return unless @line?

        @line
            .transition()
            .delay(250)
            .style('opacity', 0)
