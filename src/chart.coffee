chartProperties = [
    'container'
]

@ForestD3.Chart = class Chart
    constructor: (domContainer)->
        @properties = {}

        for prop in chartProperties
            @[prop] = do (prop)=>
                (d)=>
                    unless d?
                        return @properties[prop]
                        
                    else
                        @properties[prop] = d 
                        return @


        @container domContainer
        @svg = @createSvg()
        @createChartFrame @svg

    render: ->
        return @ unless @chartData?

        @

    data: (d)->
        @chartData = d
        @

    calcDimensions: ->
        container = @container()
        if container?
            bounds = container.getBoundingClientRect()

            @height = bounds.height
            @width = bounds.width

    createSvg: ->
        container = @container()
        if container?
            exists = d3.select(container)
            .classed('forest-d3',true)
            .select 'svg'
            if exists.empty()
                @calcDimensions()

                return d3.select(container).append('svg')
                .attr('width', @width)
                .attr('height', @height)
            else
                return exists 

        return null

    createChartFrame: (svg)->
        return unless svg?
        unless @frameCreated
            svg.append('rect')
            .classed('backdrop',true)
            .attr('width', @width)
            .attr('height', @height)

            @margin = 
                left: 80
                bottom: 40
                right: 0
                top: 0

            canvas = svg.append('g')
            .classed('canvas', true)
            .attr('transform',"translate(#{@margin.left}, 0)")
            
            canvas.append('rect')
            .attr('width', @width - @margin.left)
            .attr('height', @height - @margin.bottom)


            @frameCreated = true


        