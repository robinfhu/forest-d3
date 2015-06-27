chartProperties = [
    ['autoResize', true]
    ['getX', (d)-> d[0]]
    ['getY', (d)-> d[1]]
    ['height', null]
    ['barHeight', 30]
]

@ForestD3.BarChart = class BarChart extends ForestD3.BaseChart
    constructor: (domContainer)->
        super domContainer
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

    render: ->
        return unless @svg?
        @updateDimensions()
        @updateChartScale()
        @updateChartFrame()

        barHeight = 40
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
                .attr('y', barHeight*i + 10*i + barHeight/2)

        bars = @barGroup.selectAll('rect').data(@data().get()[0].values)

        bars
            .enter()
            .append('rect')

        bars
            .exit()
            .remove()

        bars.each (d,i)->
            d3.select(@)
                .attr('x', chart.yScale(0))
                .attr('y', barHeight*i + 10*i)
                .attr('height', barHeight)
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
                .attr('y', barHeight*i + 10*i + barHeight/2)

        @

    ###
    Get the chart's dimensions, based on the parent container <div>.
    Calculate chart margins and canvas dimensions.
    ###
    updateDimensions: ->
        container = @container()
        if container?
            bounds = container.getBoundingClientRect()

            @canvasHeight = bounds.height
            @canvasWidth = bounds.width - 200

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