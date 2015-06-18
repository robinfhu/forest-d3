###
Function responsible for rendering a scatter plot inside a d3 selection.
Must have reference to a chart instance.

Example call: ForestD3.ChartItem.scatter.call chartInstance, d3.select(this)

###
@ForestD3.ChartItem.scatter = (selection, selectionData)->
    chart = @

    selection.style 'fill', chart.seriesColor

    points = selection
        .selectAll('circle.point')
        .data((d)-> d.values)

    x = chart.getXInternal()
    y = chart.getY()
    points.enter()
        .append('circle')
        .classed('point', true)
        .attr('cx', chart.canvasWidth / 2)
        .attr('cy', chart.canvasHeight / 2)
        .attr('r',0)

    points.exit().remove()

    points
        .transition()
        .delay((d,i)-> i * 10)
        .ease('quad')
        .attr('cx',(d,i)-> chart.xScale x(d,i))
        .attr('cy',(d,i)-> chart.yScale y(d,i))
        .attr('r', chart.pointSize())
