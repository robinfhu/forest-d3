###
Function responsible for rendering a scatter plot inside a d3 selection.
Must have reference to a chart instance.

Example call:
ForestD3.Visualizations.scatter.call chartInstance, d3.select(this)

###
@ForestD3.Visualizations.scatter = (selection, selectionData)->
    chart = @

    selection.style('fill', selectionData.color)

    all = d3.svg.symbolTypes
    seriesIndex = selectionData.index
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
        .attr('transform', (d)->
            "translate(#{chart.xScale(d.x)},#{base})"
        )
        .attr('d', symbol.size(0))

    points.exit().remove()

    delayFactor = 150 / selectionData.values.length
    delayFactor = d3.max [3, delayFactor]

    points
        .transition()
        .duration(selectionData.duration or chart.duration())
        .delay((d,i)-> i * delayFactor)
        .ease('quad')
        .attr('transform', (d)->
            "translate(#{chart.xScale(d.x)},#{chart.yScale(d.y)})"
        )
        .attr('d', symbol.size(selectionData.size or 96))

    # Add hover events, but only if tooltipType is 'hover'
    if chart.tooltipType() is 'hover'
        selection.classed 'interactive', true
        points
            .on('mouseover.tooltipHover', (d)->
                clientMouse = [d3.event.clientX, d3.event.clientY]
                canvasMouse = [chart.xScale(d.x), chart.yScale(d.y)]
                content = ForestD3.TooltipContent.single chart, d

                chart.renderSpatialTooltip {
                    content
                    clientMouse
                    canvasMouse
                }
            )
            .on('mouseout.tooltipHover', ->
                chart.renderSpatialTooltip {hide: true}
            )