@ForestD3.ChartItem.line = (selection, selectionData)->
    chart = @

    selection.style 'stroke', chart.seriesColor

    path = selection.selectAll('path.line').data([selectionData.values])

    interpolate = selectionData.interpolate or 'linear'
    x = chart.getXInternal()
    y = chart.getY()
    path
        .enter()
        .append('path')
        .classed('line', true)
        .attr('d',
            d3.svg.line()
            .interpolate(interpolate)
            .x((d,i)-> chart.xScale(x(d,i)))
            .y(-> chart.canvasHeight)
        )

    lineFn = d3.svg.line()
        .interpolate(interpolate)
        .x((d,i)-> chart.xScale(x(d,i)))
        .y((d,i)-> chart.yScale(y(d,i)))

    path
        .transition()
        .duration(800)
        .attr('d', lineFn)
