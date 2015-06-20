###
Draws a simple line graph.
If you set area=true, turns it into an area graph
###
@ForestD3.ChartItem.line = (selection, selectionData)->
    chart = @

    selection.style 'stroke', chart.seriesColor

    interpolate = selectionData.interpolate or 'linear'
    x = chart.getXInternal()
    y = selectionData.getY or chart.getY()

    lineFn = d3.svg.line()
        .interpolate(interpolate)
        .x((d,i)-> chart.xScale(x(d,i)))

    path = selection.selectAll('path.line').data([selectionData.values])

    path
        .enter()
        .append('path')
        .classed('line', true)
        .attr('d',lineFn.y(chart.canvasHeight))

    path
        .transition()
        .duration(800)
        .attr('d', lineFn.y((d,i)-> chart.yScale(y(d,i))))

    # Draw an area graph if area option is turned on
    if selectionData.area
        # Ensure the base of the area doesn't extend outside the cavnas bounds.
        areaBase = chart.yScale 0
        if areaBase > chart.canvasHeight
            areaBase = chart.canvasHeight
        else if areaBase < 0
            areaBase = 0

        areaFn = d3.svg.area()
            .interpolate(interpolate)
            .x((d,i)-> chart.xScale(x(d,i)))
            .y0(areaBase)

        area = selection.selectAll('path.area').data([selectionData.values])

        area
            .enter()
            .append('path')
            .classed('area', true)
            .attr('d', areaFn.y1(areaBase))

        area
            .transition()
            .duration(800)
            .style('fill', chart.seriesColor(selectionData))
            .attr('d', areaFn.y1((d,i)-> chart.yScale(y(d,i))))

