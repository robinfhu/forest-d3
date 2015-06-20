@ForestD3.ChartItem.ohlc = (selection, selectionData)->
    chart = @

    selection.classed('ohlc', true)

    rangeLines = selection
        .selectAll('line.ohlc-range')
        .data(selectionData.values)

    x = chart.getXInternal()
    open = selectionData.getOpen or (d,i)-> d[1]
    hi = selectionData.getHi or (d,i)-> d[2]
    lo = selectionData.getLo or (d,i)-> d[3]
    close = selectionData.getClose or (d,i)-> d[4]

    rangeLines
        .enter()
        .append('line')
        .classed('ohlc-range', true)
        .attr('x1', (d,i)-> chart.xScale(x(d,i)))
        .attr('x2', (d,i)-> chart.xScale(x(d,i)))
        .attr('y1', 0)
        .attr('y2', 0)

    rangeLines
        .exit()
        .remove()

    rangeLines
        .transition()
        .delay((d,i)-> i*20)
        .attr('x1', (d,i)-> chart.xScale(x(d,i)))
        .attr('x2', (d,i)-> chart.xScale(x(d,i)))
        .attr('y1', (d,i)-> chart.yScale(hi(d,i)))
        .attr('y2', (d,i)-> chart.yScale(lo(d,i)))

    openMarks = selection
        .selectAll('line.ohlc-open')
        .data(selectionData.values)

    openMarks
        .enter()
        .append('line')
        .classed('ohlc-open', true)
        .attr('y1', 0)
        .attr('y2', 0)

    openMarks
        .exit()
        .remove()

    openMarks
        .transition()
        .delay((d,i)-> i*20)
        .attr('y1', (d,i)-> chart.yScale(open(d,i)))
        .attr('y2', (d,i)-> chart.yScale(open(d,i)))
        .attr('x1', (d,i)-> chart.xScale(x(d,i)))
        .attr('x2', (d,i)-> chart.xScale(x(d,i)) - 5)

    closeMarks = selection
        .selectAll('line.ohlc-close')
        .data(selectionData.values)

    closeMarks
        .enter()
        .append('line')
        .classed('ohlc-close', true)
        .attr('y1', 0)
        .attr('y2', 0)

    closeMarks
        .exit()
        .remove()

    closeMarks
        .transition()
        .delay((d,i)-> i*20)
        .attr('y1', (d,i)-> chart.yScale(close(d,i)))
        .attr('y2', (d,i)-> chart.yScale(close(d,i)))
        .attr('x1', (d,i)-> chart.xScale(x(d,i)))
        .attr('x2', (d,i)-> chart.xScale(x(d,i)) + 5)


