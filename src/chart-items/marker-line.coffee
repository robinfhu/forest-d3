###
Draws a horizontal or vertical line at the specified x or y location.
###
@ForestD3.ChartItem.markerLine = (selection, selectionData)->
    chart = @

    line = selection.selectAll('line.marker').data((d)-> [d.value])
    label = selection.selectAll('text.marker-label').data([selectionData.label])

    labelEnter = label
        .enter()
        .append('text')
        .classed('marker-label', true)
        .text((d)-> d)
        .attr('x', 0)
        .attr('y', 0)

    labelPadding = 10

    if selectionData.axis is 'x'
        x = chart.xScale selectionData.value

        line
            .enter()
            .append('line')
            .classed('marker', true)
            .attr('x1', 0)
            .attr('x2', 0)
            .attr('y1', 0)

        line
            .attr('y2', chart.canvasHeight)
            .transition()
            .attr('x1', x)
            .attr('x2', x)

        # Rotates the x marker label 90 degrees.
        labelRotate = "rotate(-90 #{x} #{chart.canvasHeight})"
        labelOffset = "translate(0 #{-labelPadding})"

        labelEnter.attr('transform', labelRotate)
        label
            .attr('y', chart.canvasHeight)
            .transition()
            .attr('transform', "#{labelRotate} #{labelOffset}")
            .attr('x', x)

    else
        y = chart.yScale selectionData.value

        line
            .enter()
            .append('line')
            .classed('marker', true)
            .attr('x1', 0)
            .attr('y1', 0)
            .attr('y2', 0)

        line
            .attr('x2', chart.canvasWidth)
            .transition()
            .attr('y1', y)
            .attr('y2', y)

        label
            .attr('text-anchor', 'end')
            .transition()
            .attr('x', chart.canvasWidth)
            .attr('y', y + labelPadding)
