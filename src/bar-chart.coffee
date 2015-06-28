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
        barCenter = @barHeight() / 2

        chart = @

        labels = @labelGroup.selectAll('text').data(@data().xValuesRaw())
        labels
            .enter()
            .append('text')
            .attr('text-anchor', 'end')

        labels
            .exit()
            .remove()

        labels.each (d,i)->
            d3.select(@)
                .text((d)-> d)
                .attr('x', chart.yScale(0))
                .attr('y', barY(i) + barCenter)

        bars = @barGroup.selectAll('rect').data(@_barData())

        bars
            .enter()
            .append('rect')

        bars
            .exit()
            .remove()

        bars.each (d,i)->
            d3.select(@)
                .attr('x', chart.yScale(0))
                .attr('y', barY(i))
                .attr('height', chart.barHeight())
                .attr('width', (d,i)-> chart.yScale(chart.getY()(d,i)))
                .style('fill', '#ccc')

        valueLabels = @valueGroup
            .selectAll('text')
            .data(@data().get()[0].values)

        valueLabels
            .enter()
            .append('text')

        valueLabels
            .exit()
            .remove()

        valueLabels.each (d,i)->
            d3.select(@)
                .text((d,i)-> chart.getY()(d,i))
                .attr('x', (d,i)-> chart.yScale(chart.getY()(d,i)))
                .attr('y', barY(i) + barCenter)

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
                height = barCount * (@barHeight() + @barPadding())
                @svg.attr('height', height)

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
        @labelGroup = @svg.selectAll('g.bar-labels').data([0])
        @labelGroup.enter().append('g').classed('bar-labels', true)
        @labelGroup
            .attr('transform', "translate(100,0)")

        @barGroup = @svg.selectAll('g.bars').data([0])
        @barGroup.enter().append('g').classed('bars', true)
        @barGroup
            .attr('transform', "translate(100,0)")

        @valueGroup = @svg.selectAll('g.bar-values').data([0])
        @valueGroup.enter().append('g').classed('bar-values', true)
        @valueGroup
            .attr('transform', "translate(100,0)")