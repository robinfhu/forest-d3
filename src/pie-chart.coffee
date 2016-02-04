chartProperties = [
    ['getLabel', (d)-> d.label]
    ['getValue', (d)-> d.value]
]

@ForestD3.PieChart = class PieChart extends ForestD3.BaseChart
    constructor: (domContainer)->
        super domContainer
        d3.select(@container()).classed('pie-chart', true)
        @_setProperties chartProperties

    data: (d)->
        if arguments.length is 0
            return ForestD3.DataAPI.call @, @_internalData
        else
            @_internalData = d.slice()

            @_internalData.sort (a,b)=>
                d3.ascending @getValue()(a), @getValue()(b)

            return @

    render: ->
        return @ unless @svg?
        return @ unless @data().get()?

        @updateDimensions()
        @updateChartFrame()

        radius = d3.min([@canvasWidth,@canvasHeight]) / 2
        arc = d3.svg.arc()
            .outerRadius(radius)
            .innerRadius(0)

        pieData = d3.layout.pie()
            .sort(null)
            .value(@getValue())(@data().get())

        slicesContainer = @canvas.selectAll('g.slices-container').data([0])
        slicesContainer.enter().append('g').classed('slices-container')

        slicesContainer
            .attr('transform',
                "translate(#{@canvasWidth/2}, #{@canvasHeight/2})"
            )

        slices = slicesContainer.selectAll('path.slice').data(pieData)

        slices
            .enter()
            .append('path')
            .classed('slice', true)
            .attr('d', (d)->
                arc({startAngle: d.startAngle, endAngle: d.startAngle})
            )

        slices
            .transition()
            .duration(1000)
            .attr('d', arc)
            .style('fill', (d,i)-> ForestD3.Utils.defaultColor(i))

    updateChartFrame: ->
        # Create a canvas, where all data points will be plotted.
        @canvas = @svg.selectAll('g.canvas').data([0])

        canvasEnter = @canvas.enter().append('g').classed('canvas', true)

        @canvas
            .attr('transform',"translate(#{@margin}, #{@margin})")

        canvasEnter
            .append('rect')
            .classed('canvas-backdrop', true)

        @canvas.select('rect.canvas-backdrop')
            .attr('width', @canvasWidth)
            .attr('height', @canvasHeight)

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

            @margin = 30

            ###
            Calculates the chart canvas dimensions. Uses the parent
            container's dimensions, and subtracts off any margins.
            ###
            @canvasHeight = @height - @margin * 2
            @canvasWidth = @width - @margin * 2

            # Ensures that charts cannot get smaller than 50x50 pixels.
            @canvasWidth = d3.max [@canvasWidth, 50]
            @canvasHeight = d3.max [@canvasHeight, 50]
