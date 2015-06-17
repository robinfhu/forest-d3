chartProperties = [
    ['getX', (d,i)-> d[0] ]
    ['getY', (d,i)-> d[1] ]
    ['autoResize', true]
    ['color', ForestD3.Utils.defaultColor]
    ['pointSize', 4]
    ['xPadding', 0.1]
    ['yPadding', 0.1]
    ['xLabel', '']
    ['yLabel', '']
    ['showTooltip', true]
]

@ForestD3.Chart = class Chart
    constructor: (domContainer)->
        @properties = {}

        for propPair in chartProperties
            [prop, defaultVal] = propPair
            @properties[prop] = defaultVal

            @[prop] = do (prop)=>
                (d)=>
                    unless d?
                        return @properties[prop]

                    else
                        @properties[prop] = d
                        return @


        @container domContainer

        @tooltip = new ForestD3.Tooltip()
        @xAxis = d3.svg.axis().tickPadding(10)
        @yAxis = d3.svg.axis().tickPadding(10)
        @seriesColor = (d)=> d.color or @color()(d._index)
        @plugins = {}

        ###
        Auto resize the chart if user resizes the browser window.
        ###
        window.onresize = =>
            if @autoResize()
                @render()

    ###
    Set chart data.
    ###
    data: (d)->
        unless d?
            return ForestD3.DataAPI.call @, @chartData
        else
            d = ForestD3.Utils.indexify d
            @chartData = d
            return @

    container: (d)->
        unless d?
            return @properties['container']
        else
            if d.select?
                # This is a d3 selection
                d = d.node()

            @properties['container'] = d
            @svg = @createSvg()

            return @

    ###
    Create an <svg> element to start rendering the chart.
    ###
    createSvg: ->
        container = @container()
        if container?
            exists = d3.select(container)
            .classed('forest-d3',true)
            .select 'svg'
            if exists.empty()
                return d3.select(container).append('svg')
            else
                return exists

        return null

    ###
    Main rendering logic.  Here we should update the chart frame, axes
    and series points.
    ###
    render: ->
        return @ unless @svg?
        return @ unless @chartData?
        @updateDimensions()
        @updateChartScale()
        @updateChartFrame()

        chartItems = @canvas
            .selectAll('g.chart-item')
            .data(@data().visible(), (d)-> d.key)

        chartItems.enter()
            .append('g')
            .attr('class', (d, i)-> "chart-item item-#{d.key or i}")

        chartItems.exit()
            .transition()
            .style('opacity', 0)
            .remove()

        chart = @
        ###
        Main render loop. Loops through the data array, and depending on the
        'type' attribute, renders a different kind of chart element.
        ###
        chartItems.each (d,i)->
            renderFn = -> 0

            chartItem = d3.select @
            if (d.type is 'scatter') or (not d.type? and d.values?)
                renderFn = ForestD3.ChartItem.scatter
            else if d.type is 'line'
                renderFn = ForestD3.ChartItem.line
            else if (d.type is 'marker') or (not d.type? and d.value?)
                renderFn = ForestD3.ChartItem.markerLine
            else if d.type is 'region'
                renderFn = ForestD3.ChartItem.region

            renderFn.call chart, chartItem, d

        @renderPlugins()

        @
    ###
    Get the chart's dimensions, based on the parent container <div>.
    Calculate chart margins and canvas dimensions.
    ###
    updateDimensions: ->
        container = @container()
        if container?
            bounds = container.getBoundingClientRect()

            @height = bounds.height
            @width = bounds.width

            @margin =
                left: 80
                bottom: 50
                right: 20
                top: 20

            @canvasHeight = @height - @margin.bottom - @margin.top
            @canvasWidth = @width - @margin.left - @margin.right

    ###
    Draws the chart frame. Things like backdrop and canvas.
    ###
    updateChartFrame: ->
        # Put a rectangle in background to serve as a backdrop.

        backdrop = @svg.selectAll('rect.backdrop').data([0])
        backdrop.enter()
            .append('rect')
            .classed('backdrop', true)
        backdrop
            .attr('width', @width)
            .attr('height', @height)

        # Add axes
        # TODO: Auto generate this xTicks number based on tickFormat.
        xTicks = Math.abs(@xScale.range()[0] - @xScale.range()[1]) / 100
        @xAxis.scale(@xScale).tickSize(-@canvasHeight, 1).ticks(xTicks)

        xAxisGroup = @svg.selectAll('g.x-axis').data([0])
        xAxisGroup.enter()
            .append('g')
            .attr('class','x-axis axis')

        xAxisGroup.attr(
            'transform',
            "translate(#{@margin.left}, #{@canvasHeight + @margin.top})"
        )

        @yAxis.scale(@yScale).orient('left').tickSize(-@canvasWidth, 1)
        yAxisGroup = @svg.selectAll('g.y-axis').data([0])
        yAxisGroup.enter()
            .append('g')
            .attr('class','y-axis axis')

        yAxisGroup.attr(
            'transform',
            "translate(#{@margin.left}, #{@margin.top})"
        )

        xAxisGroup.transition().call @xAxis
        yAxisGroup.transition().call @yAxis

        # Create a canvas, where all data points will be plotted.
        @canvas = @svg.selectAll('g.canvas').data([0])

        canvasEnter = @canvas.enter().append('g').classed('canvas', true)

        @canvas
            .attr('transform',"translate(#{@margin.left}, #{@margin.top})")

        canvasEnter
            .append('rect')
            .classed('canvas-backdrop', true)

        chart = @
        @canvas.select('rect.canvas-backdrop')
            .attr('width', @canvasWidth)
            .attr('height', @canvasHeight)
            # Attach mouse handlers to update the guideline and tooltip
            .on('mousemove', ->
                chart.updateTooltip(
                    d3.mouse(@),
                    [d3.event.clientX, d3.event.clientY]
                )
            )
            .on('mouseout', -> chart.updateTooltip null)

        # Add a guideline
        canvasEnter
            .append('line')
            .classed('guideline', true)
            .style('opacity', 0)

        @canvas.select('line.guideline')
            .attr('y1', 0)
            .attr('y2', @canvasHeight)

        # Add axes labels
        axesLabels = @canvas.selectAll('g.axes-labels').data([0])
        axesLabels.enter().append('g').classed('axes-labels', true)

        xAxisLabel = axesLabels.selectAll('text.x-axis').data([@xLabel()])
        xAxisLabel
            .enter()
            .append('text')
            .classed('x-axis', true)
            .attr('text-anchor', 'end')
            .attr('x', 0)
            .attr('y', @canvasHeight)

        xAxisLabel
            .text((d)-> d)
            .transition()
            .attr('x', @canvasWidth)

        yAxisLabel = axesLabels.selectAll('text.y-axis').data([@yLabel()])
        yAxisLabel
            .enter()
            .append('text')
            .classed('y-axis', true)
            .attr('text-anchor', 'end')
            .attr('transform', 'translate(10,0) rotate(-90 0 0)')

        yAxisLabel.text((d)-> d)

    updateChartScale: ->
        extent = ForestD3.Utils.extent @data().visible(), @getX(), @getY()
        extent = ForestD3.Utils.extentPadding extent, {
            x: @xPadding()
            y: @yPadding()
        }

        @yScale = d3.scale.linear().domain(extent.y).range([@canvasHeight, 0])
        @xScale = d3.scale.linear().domain(extent.x).range([0, @canvasWidth])

    ###
    Updates where the guideline and tooltip is.

    mouse should be an array of two things: [mouse x , mouse y]
    ###
    updateTooltip: (mouse, clientMouse)->
        line = @canvas.select('line.guideline')
        unless mouse?
            # Hide guideline from view if 'null' passed in
            line
                .transition()
                .delay(250)
                .style('opacity', 0)

            @tooltip.hide()

        else
            [xPos, yPos] = mouse

            xValues = @data().xValues()

            x = ForestD3.Utils.smartBisect(
                xValues,
                @xScale.invert(xPos),
                (d)-> d
            )

            xPos = @xScale x

            line
                .attr('x1', xPos)
                .attr('x2', xPos)
                .transition()
                .style('opacity', 0.5)

            @tooltip.render @data().get(), clientMouse

    addPlugin: (plugin)->
        @plugins[plugin.name] = plugin

        @

    renderPlugins: ->
        for key, plugin of @plugins
            if plugin.chart?
                plugin.chart @

            if plugin.render?
                plugin.render()

