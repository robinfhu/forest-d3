renderArea = (selection, selectionData, options={})->
    chart = @

    drawArea = options.area
    stacked = options.stacked
    # Draw an area graph if area option is turned on
    if drawArea
        # Ensure the base of the area doesn't extend outside the cavnas bounds.
        areaBase = chart.yScale 0
        if areaBase > chart.canvasHeight
            areaBase = chart.canvasHeight
        else if areaBase < 0
            areaBase = 0

        areaFn = d3.svg.area()
            .interpolate(selectionData.interpolate or 'linear')
            .x((d)-> chart.xScale(d.x))

        area = selection
            .selectAll('path.area')
            .data([selectionData.values])

        areaOffsetEnter =
            if stacked
                areaFn
                    .y0((d)-> chart.yScale(d.y0))
                    .y1((d)-> chart.yScale(d.y0))
            else
                areaFn
                    .y0(areaBase)
                    .y1(areaBase)

        area
            .enter()
            .append('path')
            .classed('area', true)
            .attr('d', areaOffsetEnter)

        areaOffset =
            if stacked
                areaOffsetEnter.y1((d)-> chart.yScale(d.y + d.y0))
            else
                areaOffsetEnter.y1((d)-> chart.yScale(d.y))

        area
            .transition()
            .duration(selectionData.duration or chart.duration())
            .style('fill', selectionData.color)
            .attr('d', areaOffset)
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

    renderArea.call @, selection, selectionData, {area: selectionData.area}

@ForestD3.Visualizations.areaStacked = (selection, selectionData)->
    selection.style 'stroke', selectionData.color

    renderArea.call @, selection, selectionData, {area: true, stacked: true}
