chartProperties = [
    ['autoResize', true]
    ['getX', (d)-> d[0]]
    ['getY', (d)-> d[1]]
    ['height', null]
    ['barHeight', 40]
    ['barPadding', 10]
]

@ForestD3.BarChart = class BarChart extends ForestD3.BaseChart
    constructor: (domContainer)->
        super domContainer
        d3.select(@container()).classed('auto-height', true)
        @_setProperties chartProperties

        @getXInternal = (d,i)-> i

    ###
    Set chart data.
    ###
    data: (d)->
        unless d?
            return ForestD3.DataAPI.call @, @chartData
        else
            @chartData = d
            return @

    _barData: ->
        @data().get()[0].values

    render: ->
        return unless @svg?
        return unless @chartData?
        @updateDimensions()
        @updateChartScale()
        @updateChartFrame()

        barY = (i)=> @barHeight()*i + @barPadding()*i

        chart = @

        color = @data().get()[0].color

        labels = @labelGroup.selectAll('text').data(@data().xValuesRaw())
        labels
            .enter()
            .append('text')
            .attr('text-anchor', 'end')
            .attr('x', 0)
            .attr('y', 0)
            .style('fill-opacity', 0)

        labels
            .exit()
            .remove()

        labels.each (d,i)->
            d3.select(@)
                .text((d)-> d)
                .transition()
                .duration(700)
                .delay(i*20)
                .attr('y', barY(i))
                .style('fill-opacity', 1)

        bars = @barGroup.selectAll('rect').data(@_barData())

        bars
            .enter()
            .append('rect')
            .attr('x', chart.yScale(0))
            .attr('y', 0)
            .style('fill-opacity', 0)
            .style('stroke-opacity', 0)

        bars
            .exit()
            .remove()

        bars.each (d,i)->
            d3.select(@)
                .attr('height', chart.barHeight())
                .transition()
                .attr('width', (d,i)-> chart.yScale(chart.getY()(d,i)))
                .style('fill', color)
                .duration(700)
                .delay(i*50)
                .attr('x', chart.yScale(0))
                .attr('y', barY(i))
                .style('fill-opacity', 1)
                .style('stroke-opacity', 0.7)

        valueLabels = @valueGroup
            .selectAll('text')
            .data(@data().get()[0].values)

        valueLabels
            .enter()
            .append('text')
            .attr('x', 0)
            .transition()
            .duration(700)

        valueLabels
            .exit()
            .remove()

        valueLabels.each (d,i)->
            d3.select(@)
                .attr('y', barY(i))
                .transition()
                .duration(700)
                .delay(i*20)
                .text((d,i)-> chart.getY()(d,i))
                .attr('x', (d,i)-> chart.yScale(chart.getY()(d,i)))

        zeroLine = @barGroup.selectAll('line.zero-line').data([0])
        zeroLine.enter().append('line').classed('zero-line', true)

        zeroLine
            .transition()
            .attr('x1', @yScale(0))
            .attr('x2', @yScale(0))
            .attr('y1', 0)
            .attr('y2', @canvasHeight)

        @

    ###
    Get the chart's dimensions, based on the parent container <div>.
    Calculate chart margins and canvas dimensions.
    ###
    updateDimensions: ->
        container = @container()
        if container?
            bounds = container.getBoundingClientRect()

            @canvasWidth = bounds.width - 200

            unless @height()
                barCount = @_barData().length
                @canvasHeight = barCount * (@barHeight() + @barPadding())

                @svg.attr('height', @canvasHeight)

    updateChartScale: ->
        extent = ForestD3.Utils.extent @data().get(), @getXInternal(), @getY()
        extent.y = d3.extent extent.y.concat([0])

        @yScale = d3.scale.linear()
            .domain(extent.y)
            .range([0, @canvasWidth])

    ###
    Draws the chart frame. Things like backdrop and canvas.
    ###
    updateChartFrame: ->
        barCenter = @barHeight() / 2 + 5
        @labelGroup = @svg.selectAll('g.bar-labels').data([0])
        @labelGroup.enter().append('g').classed('bar-labels', true)
        @labelGroup
            .attr('transform', "translate(90,#{barCenter})")

        @barGroup = @svg.selectAll('g.bars').data([0])
        @barGroup.enter().append('g').classed('bars', true)
        @barGroup
            .attr('transform', "translate(100,0)")

        @valueGroup = @svg.selectAll('g.bar-values').data([0])
        @valueGroup.enter().append('g').classed('bar-values', true)
        @valueGroup
            .attr('transform', "translate(110,#{barCenter})")