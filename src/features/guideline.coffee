###
Handles the guideline that moves along the x-axis
###
@ForestD3.Guideline = class Guideline
    constructor: (@chart)->

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

        # Add container to put markers
        @markerContainer = canvas.selectAll('g.guideline-markers').data([0])

        @markerContainer
            .enter()
            .append('g')
            .classed('guideline-markers', true)

    render: (xPosition, xIndex)->
        return unless @chart.showGuideline()
        return unless @line?

        # Show the guideline and position it.
        @line
            .attr('x1', xPosition)
            .attr('x2', xPosition)
            .transition()
            .style('opacity', 0.5)

        # Render some markers, placed at the Y position at the current slice.
        slice = @chart.data().sliced xIndex

        @markerContainer
            .transition()
            .style('opacity', 1)

        markers = @markerContainer
            .selectAll('circle.marker')
            .data(slice)

        markers
            .enter()
            .append('circle')
            .classed('marker', true)
            .attr('r', 3)

        markers.exit().remove()

        markers
            .attr('cx', xPosition)
            .attr('cy', (d)=> @chart.yScale d.y)
            .style('fill', (d)-> d.series.color)

    hide: ->
        return unless @chart.showGuideline()
        return unless @line?

        @line
            .transition()
            .delay(250)
            .style('opacity', 0)

        @markerContainer
            .transition()
            .delay(250)
            .style('opacity', 0)
