@ForestD3.ChartItem.bar = (selection, selectionData)->
    chart = @
    bars = selection.selectAll('rect.bar').data(selectionData.values)

    x = chart.getXInternal()
    y = chart.getY()

    ###
    Ensure the bars are based at the zero line, but does not extend past
    canvas boundaries.
    ###
    barBase = chart.yScale 0
    if barBase > chart.canvasHeight
        barBase = chart.canvasHeight
    else if barBase < 0
        barBase = 0

    # Figure out an optimal width for each bar.
    # TODO: Make this more dynamic. Don't hard code the spacing.
    width = chart.canvasWidth / selectionData.values.length
    width -= 5

    # Adjustment to center each bar on the x-axis tick.
    xAdjust = width/2

    bars
        .enter()
        .append('rect')
        .classed('bar', true)
        .attr('x', (d,i)-> chart.xScale(x(d,i)) - xAdjust)
        .attr('y', barBase)
        .attr('height', 0)

    bars
        .exit()
        .remove()

    bars
        .transition()
        .delay((d,i)-> i * 20)
        .attr('x', (d,i)-> chart.xScale(x(d,i)) - xAdjust)
        .attr('y', (d,i)->
            yVal = y(d,i)
            if yVal < 0
                barBase
            else
                chart.yScale(y(d,i))
        )
        .attr('height', (d,i)->
            Math.abs(chart.yScale(y(d,i)) - barBase)
        )
        .attr('width', width)
        .style('fill', chart.seriesColor(selectionData))
