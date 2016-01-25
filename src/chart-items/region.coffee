###
Draws a transparent rectangle across the canvas signifying an important
region.
###
@ForestD3.ChartItem.region = (selection, selectionData)->
    chart = @

    region = selection.selectAll('rect.region').data([selectionData])

    regionEnter = region
        .enter()
        .append('rect')
        .classed('region', true)

    start = d3.min selectionData.values
    end = d3.max selectionData.values

    duration = selectionData.duration or chart.duration()

    if selectionData.axis is 'x'
        x = chart.xScale start
        width = Math.abs(chart.xScale(start) - chart.xScale(end))
        regionEnter
            .attr('width', 0)

        region
            .attr('x', x)
            .attr('y', 0)
            .attr('height', chart.canvasHeight)
            .transition()
            .duration(duration)
            .attr('width', width)
    else
        y = chart.yScale end
        height = Math.abs(chart.yScale(start) - chart.yScale(end))
        regionEnter
            .attr('height', 0)

        region
            .attr('x', 0)
            .attr('y', y)
            .transition()
            .duration(duration)
            .attr('width', chart.canvasWidth)
            .attr('height', height)
