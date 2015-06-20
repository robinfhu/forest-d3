chartProperties = [
    ['getX', (d,i)-> d[0] ]
    ['getY', (d,i)-> d[1] ]
    ['ordinal', false]
    ['autoResize', true]
    ['color', ForestD3.Utils.defaultColor]
    ['pointSize', 4]
    ['xPadding', 0.1]
    ['yPadding', 0.1]
    ['xLabel', '']
    ['yLabel', '']
    ['xTickFormat', (d)-> d]
    ['yTickFormat', d3.format(',.2f')]
    ['showTooltip', true]
    ['showGuideline', true]
]

getIdx = (d,i)-> i

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

        @tooltip = new ForestD3.Tooltip @
        @guideline = new ForestD3.Guideline @
        @xAxis = d3.svg.axis()
        @yAxis = d3.svg.axis()
        @seriesColor = (d)=> d.color or @color()(d._index)
        @getXInternal = =>
            if @ordinal()
                getIdx
            else
                @getX()

        @plugins = {}

        ###
        Auto resize the chart if user resizes the browser window.
        ###
        @resize = =>
            if @autoResize()
                @render()

        window.addEventListener 'resize', @resize

    ###
    Call this method to remove chart from the document and any artifacts
    it has (like tooltips) and event handlers.
    ###
    destroy: ->
        domContainer = @container()
        if domContainer?.parentNode?
            domContainer.parentNode.removeChild domContainer

        @tooltip.destroy()
        window.removeEventListener 'resize', @resize

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
            if d.select? and d.node?
                # This is a d3 selection
                d = d.node()
            else if typeof(d) is 'string'
                d = document.querySelector d

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
            else if d.type is 'bar'
                renderFn = ForestD3.ChartItem.bar
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

        xValues = @data().xValuesRaw()

        @xAxis
            .scale(@xScale)
            .tickSize(10, 10)
            .ticks(xTicks)
            .tickPadding(5)
            .tickFormat((d)=>
                tick = if @ordinal()
                    xValues[d]
                else
                    d

                @xTickFormat()(tick, d)
            )
        xAxisGroup = @svg.selectAll('g.x-axis').data([0])
        xAxisGroup.enter()
            .append('g')
            .attr('class','x-axis axis')

        xAxisGroup.attr(
            'transform',
            "translate(#{@margin.left}, #{@canvasHeight + @margin.top})"
        )

        @yAxis
            .scale(@yScale)
            .orient('left')
            .tickSize(-@canvasWidth, 10)
            .tickPadding(10)
            .tickFormat(@yTickFormat())

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
        @guideline.create @canvas

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
        extent = ForestD3.Utils.extent(
            @data().visible(),
            @getXInternal(),
            @getY()
        )
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
        unless mouse?
            # Hide guideline from view if 'null' passed in
            @guideline.hide()
            @tooltip.hide()
        else
            [xPos, yPos] = mouse

            xValues = @data().xValues()

            idx = ForestD3.Utils.smartBisect(
                xValues,
                @xScale.invert(xPos),
                (d)-> d
            )

            xPos = @xScale xValues[idx]

            # Show the guideline and position it.
            @guideline.render xPos, idx

            content = ForestD3.TooltipContent.multiple @, idx
            @tooltip.render content, clientMouse

    addPlugin: (plugin)->
        @plugins[plugin.name] = plugin

        @

    renderPlugins: ->
        for key, plugin of @plugins
            if plugin.chart?
                plugin.chart @

            if plugin.render?
                plugin.render()

