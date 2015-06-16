@ForestD3.ChartItem.line = (selection, selectionData)->
    chart = @

    selection.style 'stroke', chart.seriesColor

    path = selection.selectAll('path.line').data([selectionData.values])

    path
        .enter()
        .append('path')
        .classed('line', true)
        .attr('d',
            d3.svg.line()
            .interpolate('linear')
            .x((d,i)-> chart.xScale(chart.getX()(d,i)))
            .y(-> chart.canvasHeight)
        )

    lineFn = d3.svg.line()
        .interpolate('linear')
        .x((d,i)-> chart.xScale(chart.getX()(d,i)))
        .y((d,i)-> chart.yScale(chart.getY()(d,i)))

    path
        .transition()
        .duration(800)
        .attr('d', lineFn)
