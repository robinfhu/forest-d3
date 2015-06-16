@ForestD3.ChartItem.line = (selection, selectionData)->
    chart = @

    selection.style 'stroke', chart.seriesColor

    path = selection.selectAll('path.line').data([selectionData.values])

    path
        .enter()
        .append('path')
        .classed('line', true)

    lineFn = d3.svg.line()
        .interpolate('linear')
        .x((d,i)-> chart.xScale(chart.getX()(d,i)))
        .y((d,i)-> chart.yScale(chart.getY()(d,i)))

    path
        .transition()
        .attr('d', lineFn)
