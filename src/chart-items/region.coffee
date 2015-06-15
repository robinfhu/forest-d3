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


    if selectionData.axis is 'x'
        start = d3.min selectionData.values
        end = d3.max selectionData.values

        x = chart.xScale start
        width = Math.abs(chart.xScale(start) - chart.xScale(end))
        regionEnter
            .attr('width', 0)

        region
            .attr('x', x)
            .attr('y', 0)
            .attr('height', chart.canvasHeight)
            .transition()
            .attr('width', width)
