###
A Chart object renders time series data, or scatter plot data.

You can combine lines, bars, areas and scatter points into one chart.
###
chartProperties = [
    ['getX', (d,i)-> d[0] ]
    ['getY', (d,i)-> d[1] ]
    ['forceDomain', null]
    ['ordinal', true]
    ['autoResize', true]
    ['colorPalette', null]
    ['duration', 250]
    ['pointSize', 4]
    ['xPadding', 0.1]
    ['yPadding', 0.1]
    ['xLabel', '']
    ['yLabel', '']
    ['chartLabel', '']
    ['xScaleType', d3.scale.linear]
    ['yScaleType', d3.scale.linear]
    ['xTickFormat', (d)-> d]
    ['yTickFormat', d3.format(',.2f')]
    ['reduceXTicks', true]
    ['yTicks', null]
    ['showXAxis', true]
    ['showYAxis', true]
    ['showTooltip', true]
    ['showGuideline', true]
    ['tooltipType', 'bisect']  # Can be 'bisect', 'spatial' or 'hover'
    ['tooltipContentMultiple', ForestD3.TooltipContent.multiple]
    ['barPaddingPercent', 0.1]
    ['autoSortXValues', true]
]

@ForestD3.Chart = class Chart extends ForestD3.BaseChart
    constructor: (domContainer)->
        super domContainer
        @_setProperties chartProperties

        @tooltip = new ForestD3.Tooltip @
        @guideline = new ForestD3.Guideline @
        @crosshairs = new ForestD3.Crosshairs @
        @xAxis = d3.svg.axis()
        @yAxis = d3.svg.axis()
        @getXInternal = (d)-> d.x
        @getYInternal = (d)-> d.y

        @_tooltipFrozen = false

    destroy: ->
        super()
        @tooltip.destroy()
        @destroyPlugins()

    ###
    Set chart data. Will attempt to 'normalize' the data for internal chart
    use.
    ###
    data: (d)->
        if arguments.length is 0
            return ForestD3.DataAPI.call @, @_internalData
        else
            @_internalData = ForestD3.Utils.normalize d, {
                getX: @getX()
                getY: @getY()
                ordinal: @ordinal()
                colorPalette: @colorPalette()
                autoSortXValues: @autoSortXValues()
            }

            if @tooltipType() is 'spatial'
                @quadtree = @data().quadtree()

            return @

    ###
    Gives sub-charts a chance to pre-process the data.

    For example, stacked charts will want to call d3.layout.stack() before
    calculating the extent.

    Defaults to no-op.
    ###
    init: ->

    ###
    Main rendering logic.  Here we should update the chart frame, axes
    and series points.
    ###
    render: ->
        return @ unless @svg?
        return @ unless @data().get()?
        @init()
        @updateDimensions()
        @updateChartScale()
        @updateChartFrame()

        chartSeries = @canvas
            .selectAll('g.series')
            .data(@data().visible(), (series)-> series._uniqueKey)

        chartSeries.enter()
            .append('g')
            .attr('class', (series, i)-> "series series-#{series.key}")

        chartSeries.exit()
            .transition()
            .duration(@duration())
            .style('opacity', 0)
            .remove()

        chart = @
        ###
        Main render loop. Loops through the data array, and depending on the
        'type' attribute, renders a different kind of chart element.
        ###
        chartSeries.each (series,i)->
            seriesContainer = d3.select @

            visualization = chart.getVisualization series

            visualization.call chart, seriesContainer, series

        ###
        This line keeps chart-items in order on the canvas. Items that appear
        lower in the list thus overlap items that are near the beginning of the
        list.
        ###
        chartSeries.order()

        @renderPlugins()

        # Trigger the 'rendered' event
        @trigger 'rendered'

        @

    ###
    Given a chart series object, determines what type of visualization
    to render.
    ###
    getVisualization: (series)->
        visualizations = ForestD3.Visualizations
        switch series.type
            when 'scatter'
                visualizations.scatter
            when 'line'
                visualizations.line
            when 'bar'
                visualizations.bar
            when 'ohlc'
                visualizations.ohlc
            when 'marker'
                visualizations.markerLine
            when 'region'
                visualizations.region
            else
                (-> 0)

    ###
    Applies the CSS class 'highlight' to a specific series <g> element.
    key - string representing the series key
    ###
    highlightSeries: (key)->
        @canvas
            .selectAll('g.series')
            .classed('highlight', (series)->
                series.key is key
            )

    ###
    Get or set the chart's margins.
    Takes an object or a list of arguments (top, right, bottom, left)

    Example:
        margin({left: 90, top: 30})
        margin(30,null,null,90)
    ###
    margin: (m)->
        defaults =
            left: 80
            bottom: 50
            right: 20
            top: 20

        if not @_chartMargins
            @_chartMargins = defaults

        if arguments.length is 0
            return @_chartMargins
        else
            keyOrder = ['top','right','bottom','left']
            if m? and (typeof m) is 'object'
                for key in keyOrder
                    @_chartMargins[key] = m[key] if m[key]?
            else
                args = Array.prototype.slice.apply arguments
                for arg,i in args
                    if (typeof arg) is 'number' and i < keyOrder.length
                        @_chartMargins[keyOrder[i]] = arg

            return @
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

            margin = @margin()

            ###
            Calculates the chart canvas dimensions. Uses the parent
            container's dimensions, and subtracts off any margins.
            ###
            @canvasHeight = @height - margin.bottom - margin.top
            @canvasWidth = @width - margin.left - margin.right

            # Ensures that charts cannot get smaller than 50x50 pixels.
            @canvasWidth = d3.max [@canvasWidth, 50]
            @canvasHeight = d3.max [@canvasHeight, 50]

    ###
    Draws the chart frame:
    * Canvas <rect>
    * X and Y Axes
    * Guidelines
    * Labels
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

        margin = @margin()
        # Add axes
        if @showXAxis()
            tickValues = null
            xValuesRaw = @data().xValuesRaw()

            if @ordinal()
                ###
                For ordinal scales, attempts to fit as many x-ticks as possible.
                Will always show the first and last ticks, and fill in the
                space in between.
                ###

                xValues = @data().xValues()

                tickValues = do =>
                    if @reduceXTicks()
                        # Gets the width of each x-tick label
                        xTickWidth = ForestD3.Utils.textWidthApprox(
                            xValuesRaw,
                            @xTickFormat()
                        )

                        # Figures out how many ticks can be shown on x-axis
                        xTicks = @canvasWidth / xTickWidth

                        # Figures out optimal tick layout.
                        widthThreshold = Math.ceil @xScale.invert xTickWidth

                        return ForestD3.Utils.tickValues(
                            xValues,
                            xTicks,
                            widthThreshold
                        )
                    else
                        return xValues

            @xAxis
                .scale(@xScale)
                .tickSize(10, 10)
                .tickValues(tickValues)
                .tickPadding(5)
                .tickFormat((d)=>
                    tick = if @ordinal()
                        xValuesRaw[d]
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
                "translate(#{margin.left}, #{@canvasHeight + margin.top})"
            )

            xAxisGroup.transition().duration(@duration()).call @xAxis

        if @showYAxis()
            @yAxis
                .scale(@yScale)
                .orient('left')
                .ticks(@yTicks())
                .tickSize(-@canvasWidth, 10)
                .tickPadding(10)
                .tickFormat(@yTickFormat())

            yAxisGroup = @svg.selectAll('g.y-axis').data([0])
            yAxisGroup.enter()
                .append('g')
                .attr('class','y-axis axis')

            yAxisGroup.attr(
                'transform',
                "translate(#{margin.left}, #{margin.top})"
            )

            yAxisGroup.transition().duration(@duration()).call @yAxis

        # Create a canvas, where all data points will be plotted.
        @canvas = @svg.selectAll('g.canvas').data([0])

        canvasEnter = @canvas.enter().append('g').classed('canvas', true)

        @canvas
            .attr('transform',"translate(#{margin.left}, #{margin.top})")

        canvasEnter
            .append('rect')
            .classed('canvas-backdrop', true)

        chart = @
        @canvas.select('rect.canvas-backdrop')
            .attr('width', @canvasWidth)
            .attr('height', @canvasHeight)
            # Attach mouse handlers to update the guideline and tooltip
            .on('mousemove', ->
                chart.updateTooltip
                    canvasMouse: d3.mouse(@)
                    clientMouse: [d3.event.clientX, d3.event.clientY]

            )
            .on('mouseout', -> chart.updateTooltip {hide: true})
            .on('click', -> chart._tooltipFrozen = not chart._tooltipFrozen)

        # Add a guideline
        @guideline.create @canvas
        @crosshairs.create @canvas

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
            .duration(@duration())
            .attr('x', @canvasWidth)

        yAxisLabel = axesLabels.selectAll('text.y-axis').data([@yLabel()])
        yAxisLabel
            .enter()
            .append('text')
            .classed('y-axis', true)
            .attr('text-anchor', 'end')
            .attr('transform', 'translate(10,0) rotate(-90 0 0)')

        yAxisLabel.text((d)-> d)

        chartLabel = axesLabels
            .selectAll('text.chart-label')
            .data([@chartLabel()])

        chartLabel
            .enter()
            .append('text')
            .classed('chart-label', true)
            .attr('text-anchor', 'end')

        chartLabel
            .text((d)-> d)
            .attr('y', 0)
            .attr('x', @canvasWidth)

    ###
    Creates an x and y scale, setting the domain and ranges.
    ###
    updateChartScale: ->
        extent = ForestD3.Utils.extent @data().visible(), @forceDomain()
        extent = ForestD3.Utils.extentPadding extent, {
            x: @xPadding()
            y: @yPadding()
        }

        @yScale = @yScaleType()().domain(extent.y).range([@canvasHeight, 0])
        @xScale = @xScaleType()().domain(extent.x).range([0, @canvasWidth])

    ###
    Updates where the guideline and tooltip is.

    canvasMouse: array: [x,y] - location of mouse in canvas
    clientMouse: array: [x,y] - location of mouse in browser
    ###
    updateTooltip: (options={})->
        return unless @showTooltip()

        return if @_tooltipFrozen

        if options.hide
            @hideTooltips()
            @trigger 'tooltipHidden'
        else
            canvasMouse = options.canvasMouse
            clientMouse = options.clientMouse
            # Contains the current pixel coordinates of the mouse, within the
            # canvas context (so [0,0] would be top left corner of canvas)
            [xPos, yPos] = canvasMouse

            if @tooltipType() is 'bisect'
                ###
                Bisect tooltip algorithm works as follows:

                - Given the current X position, look up the index of the
                    closest point, which is basically a binary search.
                - Calculate the x pixel location of the found point.
                - Render the guideline at that point.
                - Do a 'slice' of the data at the found index and render
                    tooltip with all values at the current index.
                ###
                xValues = @data().xValues()

                idx = ForestD3.Utils.smartBisect(
                    xValues,
                    @xScale.invert(xPos),
                    (d)-> d
                )

                @trigger 'tooltipBisect', {
                    index: idx
                    canvasMouse
                    clientMouse
                }

                @renderBisectTooltipAt idx, clientMouse

            else if @tooltipType() is 'spatial'
                ###
                Spatial tooltip algorithm works as follows:

                - Convert current mouse position into the domain coordinates
                - Using those coordinates, look up the closest point in the
                    quadtree data structure.
                - Calculate distance between found point and mouse location.
                - If the distance is under a certain threshold, render the
                    tooltip and crosshairs. Otherwise hide them.

                - the threshold is calculated by dividing the canvas into
                    many small squares and using the diagnol length of each
                    square. It was found through trial and error.
                ###
                x = @xScale.invert xPos
                y = @yScale.invert yPos
                point = @quadtree.find [x,y]

                xActual = @xScale point.x
                yActual = @yScale point.y

                xDiff = xActual - xPos
                yDiff = yActual - yPos
                dist = Math.sqrt(xDiff*xDiff + yDiff*yDiff)

                threshold = Math.sqrt((2*@canvasWidth*@canvasHeight) / 1965)

                ###
                There is an additional check to make sure tooltips are not
                rendered for hidden chart series'.
                ###
                isHidden = point.series.hidden
                if dist < threshold and not isHidden
                    content = ForestD3.TooltipContent.single @, point

                    @renderSpatialTooltip {
                        content
                        clientMouse
                        canvasMouse: [xActual, yActual]
                    }
                else
                    @renderSpatialTooltip {hide: true}

    hideTooltips: ->
        @guideline.hide()
        @crosshairs.hide()
        @tooltip.hide()

    renderBisectTooltipAt: (xIndex, clientMouse=null)->
        idx = xIndex
        xValues = @data().xValues()

        @renderBisectGuideline xValues[idx], idx

        xValue = @xTickFormat()(@data().xValueAt(idx), idx) #raw x value
        dataSlice = @data().sliced(idx).map (d,i)=>
            d.yFormatted = @yTickFormat()(d.y, i)
            d

        content = @tooltipContentMultiple()(xValue, dataSlice)
        @tooltip.render content, clientMouse

    renderBisectGuideline: (xValue, xIndex)->
        xPosition = @xScale xValue
        markerPoints = @data().sliced(xIndex).map (d)=>
            y: @yScale(d.y)
            color: d.series.color

        @guideline.render xPosition, markerPoints

    ###
    Special function to show/hide a spatial tooltip.
    This kind of tooltip has a crosshair as well as the floating tooltip box.

    Used for scatter charts primarily, but can be used for anything.
    Best for showing a single point of data.

    Options you can pass in:
        content - string representing the tooltip content body (HTML)
        clientMouse - [x,y] coordinates of the mouse location in browser.
        canvasMouse - [x,y] coordinates of mouse in chart canvas
        hide - boolean. If true, the tooltips are removed.
    ###
    renderSpatialTooltip: (options={})->
        if options.hide
            @tooltip.hide()
            @crosshairs.hide()
        else
            @tooltip.render options.content, options.clientMouse
            if options.canvasMouse?
                @crosshairs.render options.canvasMouse

    addPlugin: (plugin)->
        @plugins[plugin.name] = plugin

        @

    renderPlugins: ->
        for key, plugin of @plugins
            if plugin.chart?
                plugin.chart @

            if plugin.render?
                plugin.render()

    destroyPlugins: ->
        for key, plugin of @plugins
            if plugin.destroy?
                plugin.destroy()
