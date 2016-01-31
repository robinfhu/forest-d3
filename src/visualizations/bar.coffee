renderBars = (selection, selectionData, options={})->
    chart = @
    stacked = options.stacked

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

    maxPadding = 35
    #add some padding between groups of bars (default to 10% of the full space)
    #Padding is maxed out after a certain threshold
    fullSpace -= d3.min [(fullSpace * chart.barPaddingPercent()), maxPadding]

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

    # Gets total number of visible bars and figures out bar width (if grouped)
    barCount = chart.data().barCount()
    barIndex = chart.data().barIndex selectionData.key
    barWidth =
        if stacked
            fullSpace
        else
            fullSpace / barCount

    barOffset =
        if stacked
            0
        else
            barWidth * barIndex

    barYPosition =
        if stacked
            (d)->
                ###
                For negative stacked bars, place the top of the <rect> at y0.

                For positive bars, place the top of the <rect> at y0 + y
                ###
                if d.y0 <= 0 and d.y < 0
                    chart.yScale d.y0
                else
                    chart.yScale(d.y0 + d.y)
        else
            (d)->
                if d.y < 0
                    barBase
                else
                    chart.yScale(d.y)

    bars
        .transition()
        .duration(selectionData.duration or chart.duration())
        .delay((d,i)-> i * 10)
        .attr('x', (d,i)->
            ###
            Calculates the x position of each bar. Shifts the bar along x-axis
            depending on which series index the bar belongs to.
            ###
            chart.xScale(x(d,i)) - xCentered + barOffset
        )
        .attr('y', barYPosition)
        .attr('height', (d,i)->
            Math.abs(chart.yScale(y(d,i)) - barBase)
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

    # Add hover events, but only if tooltipType is 'hover'
    if chart.tooltipType() is 'hover'
        selection.classed 'interactive', true

        bars
            .on('mousemove.tooltip', (d,i)->
                clientMouse = [d3.event.clientX, d3.event.clientY]
                content = ForestD3.TooltipContent.single chart, d, {
                    series: selectionData
                }

                chart.renderSpatialTooltip {
                    content
                    clientMouse
                }
            )
            .on('mouseout.tooltip', (d,i)->
                chart.renderSpatialTooltip {hide: true}
            )


ForestD3.Visualizations.bar = (selection, selectionData)->
    renderBars.call @, selection, selectionData, {stacked: false}

ForestD3.Visualizations.barStacked = (selection, selectionData)->
    renderBars.call @, selection, selectionData, {stacked: true}
