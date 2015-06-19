@ForestD3.ChartItem.line = (selection, selectionData)->
    chart = @

    selection.style 'stroke', chart.seriesColor

    interpolate = selectionData.interpolate or 'linear'
    x = chart.getXInternal()
    y = chart.getY()

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

    if selectionData.area
        areaFn = d3.svg.area()
            .interpolate(interpolate)
            .x((d,i)-> chart.xScale(x(d,i)))
            .y0(chart.yScale(0))

        area = selection.selectAll('path.area').data([selectionData.values])

        area
            .enter()
            .append('path')
            .classed('area', true)
            .attr('d', areaFn.y1(chart.yScale(0)))

        area
            .transition()
            .duration(800)
            .style('fill', chart.seriesColor(selectionData))
            .attr('d', areaFn.y1((d,i)-> chart.yScale(y(d,i))))

