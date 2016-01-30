@ForestD3.Visualizations.barStacked = (selection, selectionData)->
    chart = @
    bars = selection.selectAll('rect.bar').data(selectionData.values)

    x = chart.getXInternal
    y = chart.getYInternal

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

    # Ensure the bars don't get too wide either.
    maxFullSpace = chart.xScale(1) / 2

    fullSpace = d3.min [maxFullSpace, fullSpace]

    maxPadding = 15
    #add some padding between groups of bars (default to 10% of the full space)
    #Padding is maxed out after a certain threshold
    fullSpace -= d3.min [(fullSpace * 0.1), maxPadding]

    # Ensure we don't get negative bar widths
    fullSpace = d3.max [1, fullSpace]

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

    barWidth = fullSpace

    bars
        .transition()
        .duration(selectionData.duration or chart.duration())
        .delay((d,i)-> i * 20)
        .attr('x', (d,i)->
            ###
            Calculates the x position of each bar. Shifts the bar along x-axis
            depending on which series index the bar belongs to.
            ###
            chart.xScale(x(d,i)) - xCentered
        )
        .attr('y', (d,i)->
            chart.yScale(d.y0 + d.y)
        )
        .attr('height', (d,i)->
            Math.abs(chart.yScale(d.y) - barBase)
        )
        .attr('width', barWidth)
        .style('fill', selectionData.color)
        .attr('class', (d,i)->
            additionalClass =
                if (typeof selectionData.classed) is 'function'
                    selectionData.classed d.data, i, selectionData
                else
                    ''

            "bar #{additionalClass}"
        )
