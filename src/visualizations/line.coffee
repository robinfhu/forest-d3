renderArea = (selection, selectionData)->
    chart = @

    # Draw an area graph if area option is turned on
    if selectionData.area
        # Ensure the base of the area doesn't extend outside the cavnas bounds.
        areaBase = chart.yScale 0
        if areaBase > chart.canvasHeight
            areaBase = chart.canvasHeight
        else if areaBase < 0
            areaBase = 0

        areaFn = d3.svg.area()
            .interpolate(selectionData.interpolate or 'linear')
            .x((d)-> chart.xScale(d.x))
            .y0(areaBase)

        area = selection.selectAll('path.area').data([selectionData.values])

        area
            .enter()
            .append('path')
            .classed('area', true)
            .attr('d', areaFn.y1(areaBase))

        area
            .transition()
            .duration(selectionData.duration or chart.duration())
            .style('fill', selectionData.color)
            .attr('d', areaFn.y1((d)-> chart.yScale(d.y)))
    else
        selection.selectAll('path.area').remove()
###
Draws a simple line graph.
If you set area=true, turns it into an area graph
###
@ForestD3.Visualizations.line = (selection, selectionData)->
    chart = @

    selection.style 'stroke', selectionData.color

    interpolate = selectionData.interpolate or 'linear'

    lineFn = d3.svg.line()
        .interpolate(interpolate)
        .x((d)-> chart.xScale(d.x))

    path = selection.selectAll('path.line').data([selectionData.values])

    path
        .enter()
        .append('path')
        .classed('line', true)
        .attr('d',lineFn.y(chart.canvasHeight))

    duration = selectionData.duration or chart.duration()

    path
        .transition()
        .duration(duration)
        .attr('d', lineFn.y((d)-> chart.yScale(d.y)))

    renderArea.call @, selection, selectionData
