###
Function responsible for rendering a scatter plot inside a d3 selection.
Must have reference to a chart instance.

Example call: ForestD3.ChartItem.scatter.call chartInstance, d3.select(this)

###
@ForestD3.ChartItem.scatter = (selection, selectionData)->
    chart = @

    selection.style 'fill', selectionData.color

    x = chart.getXInternal
    y = chart.getYInternal

    all = d3.svg.symbolTypes
    seriesIndex = chart.metadata(selectionData).index
    shape =
        selectionData.shape or all[seriesIndex % all.length]

    symbol = d3.svg.symbol().type shape

    points = selection
        .selectAll('path.point')
        .data((d)-> d.values)

    base = Math.min(chart.yScale(0), chart.canvasHeight)

    points.enter()
        .append('path')
        .classed('point', true)
        .attr('transform', (d,i)->
            "translate(#{chart.xScale(x(d,i))},#{base})"
        )
        .attr('d', symbol.size(0))

    points.exit().remove()

    points
        .transition()
        .duration(selectionData.duration or chart.duration())
        .delay((d,i)-> i * 10)
        .ease('quad')
        .attr('transform', (d,i)->
            "translate(#{chart.xScale(x(d,i))},#{chart.yScale(y(d,i))})"
        )
        .attr('d', symbol.size(selectionData.size or 96))
