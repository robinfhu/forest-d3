@ForestD3.ChartItem.line = (selection, selectionData)->
    chart = @

    selection.style 'stroke', chart.seriesColor

    path = selection.selectAll('path.line').data([selectionData.values])

    interpolate = selectionData.interpolate or 'linear'
    x = chart.getXInternal()
    y = chart.getY()

    lineFn = d3.svg.line()
        .interpolate(interpolate)
        .x((d,i)-> chart.xScale(x(d,i)))

    path
        .enter()
        .append('path')
        .classed('line', true)
        .attr('d',lineFn.y(-> chart.canvasHeight)
        )

    path
        .transition()
        .duration(800)
        .attr('d', lineFn.y((d,i)-> chart.yScale(y(d,i))))
