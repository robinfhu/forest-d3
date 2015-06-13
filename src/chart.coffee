chartProperties = [
    ['container'],
    ['autoResize', true]
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
        @svg = @createSvg()

        @xAxis = d3.svg.axis()
        @yAxis = d3.svg.axis()

        ###
        Auto resize the chart if user resizes the browser window.
        ###
        window.onresize = =>
            if @autoResize()
                @render()

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
        

        seriesGroups = @canvas
            .selectAll('g.series')
            .data(@chartData, (d)-> d.key)

        seriesGroups.enter()
            .append('g')
            .classed('series', true)

        points = seriesGroups
            .selectAll('circle.point')
            .data((d)-> d.values)

        points.enter()
            .append('circle')
            .classed('point', true)
            .attr('cx', (d,i)=> @xScale d[0])
            .attr('cy', (d,i)=> @yScale d[1])
            .attr('r',0)

        points
            .transition()
            .ease('quad')
            .attr('cx',(d,i)=> @xScale d[0])
            .attr('cy',(d,i)=> @yScale d[1])
            .attr('r', 7)
            
        @

    ###
    Set chart data.
    ###
    data: (d)->
        @chartData = d
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
                top: 40

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

        xAxisGroup.attr('transform', "translate(#{@margin.left}, #{@canvasHeight + @margin.top})")

        @yAxis.scale(@yScale).orient('left').tickSize(-@canvasWidth, 1)
        yAxisGroup = @svg.selectAll('g.y-axis').data([0])
        yAxisGroup.enter()
            .append('g')
            .attr('class','y-axis axis')

        yAxisGroup.attr('transform', "translate(#{@margin.left}, #{@margin.top})")


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
        @yScale = d3.scale.linear().domain([0,1]).range([@canvasHeight, 0])
        @xScale = d3.scale.linear().domain([0,1]).range([0, @canvasWidth])



     