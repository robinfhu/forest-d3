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


        @container domContainer
        @svg = @createSvg()

    render: ->
        @svg.append('rect')
        .attr('width', @width)
        .attr('height', @height)

    calcDimensions: ->
        container = @container()
        if container?
            bounds = container.getBoundingClientRect()

            @height = bounds.height
            @width = bounds.width

    createSvg: ->
        container = @container()
        if container?
            exists = d3.select(container).select 'svg'
            if exists.empty()
                @calcDimensions()

                return d3.select(container).append('svg')
                .attr('width', @width)
                .attr('height', @height)
            else
                return exists 

        return null

        