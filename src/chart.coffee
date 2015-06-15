chartProperties = [
    ['getX', (d,i)-> d[0] ]
    ['getY', (d,i)-> d[1] ]
    ['autoResize', true]
    ['color', ForestD3.Utils.defaultColor]
    ['pointSize', 4]
    ['xPadding', 0.1]
    ['yPadding', 0.1]
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
            colorItem = true

            chartItem = d3.select @
            if (d.type is 'scatter') or (not d.type? and d.values?)
                renderFn = ForestD3.ChartItem.scatter
            else if (d.type is 'marker') or (not d.type? and d.value?)
                renderFn = ForestD3.ChartItem.markerLine
                colorItem = false
            else if d.type is 'region'
                renderFn = ForestD3.ChartItem.region
                colorItem = false

            if colorItem
                chartItem.style 'fill', chart.seriesColor

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
        @xAxis.scale(@xScale).tickSize(-@canvasHeight, 1)
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

        @canvas.enter().append('g')
            .classed('canvas', true)
            .attr('transform',"translate(#{@margin.left}, #{@margin.top})")
            .append('rect')
            .classed('canvas-backdrop', true)

        @canvas.select('rect.canvas-backdrop')
            .attr('width', @canvasWidth)
            .attr('height', @canvasHeight)

    updateChartScale: ->
        extent = ForestD3.Utils.extent @data().visible(), @getX(), @getY()
        extent = ForestD3.Utils.extentPadding extent, {
            x: @xPadding()
            y: @yPadding()
        }

        @yScale = d3.scale.linear().domain(extent.y).range([@canvasHeight, 0])
        @xScale = d3.scale.linear().domain(extent.x).range([0, @canvasWidth])

    addPlugin: (plugin)->
        @plugins[plugin.name] = plugin

        @

    renderPlugins: ->
        for key, plugin of @plugins
            if plugin.chart?
                plugin.chart @

            if plugin.render?
                plugin.render()

