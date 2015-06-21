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

    # Calculates how much available space there is between each x-axis tick mark
    fullSpace = chart.canvasWidth / selectionData.values.length

    # Gets total number of visible bars
    barCount = chart.data().barCount()

    # Ensure the bars don't get too wide either.
    maxFullSpace = chart.xScale(1) / 2

    fullSpace = d3.min [maxFullSpace, fullSpace]

    maxPadding = 15
    #add some padding between groups of bars
    # Padding is maxed out after a certain threshold
    fullSpace -= d3.min [(fullSpace / 2), maxPadding]

    # Ensure we don't get negative bar widths
    fullSpace = d3.max [barCount, fullSpace]

    ###
    This is used to ensure that the bar group is centered around the x-axis
    tick mark.
    ###
    xCentered = fullSpace / 2

    bars
        .enter()
        .append('rect')
        .classed('bar', true)
        .attr('x', (d,i)-> chart.xScale(x(d,i)) - xCentered)
        .attr('y', barBase)
        .attr('height', 0)

    bars
        .exit()
        .remove()

    barIndex = chart.data().barIndex selectionData.key
    barWidth = fullSpace / barCount
    bars
        .transition()
        .delay((d,i)-> i * 20)
        .attr('x', (d,i)->
            ###
            Calculates the x position of each bar. Shifts the bar along x-axis
            depending on which series index the bar belongs to.
            ###
            chart.xScale(x(d,i)) - xCentered + barWidth*barIndex
        )
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
        .attr('width', barWidth)
        .style('fill', chart.seriesColor(selectionData))
