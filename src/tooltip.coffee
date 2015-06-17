@ForestD3.Tooltip = class Tooltip
    constructor: ->
        @container = null

    render: (data, clientMouse)->
        unless @container?
            @container = document.createElement 'div'
            document.body.appendChild @container

        [xPos, yPos] = clientMouse
        xPos += window.pageXOffset
        yPos += window.pageYOffset

        d3.select(@container)
            .classed('forest-d3 tooltip-box', true)
            .style('left', "#{xPos}px")
            .style('top', "#{yPos}px")
            .transition()
            .style('opacity', 1)

    hide: ->
        d3.select(@container)
            .transition()
            .delay(250)
            .style('opacity', 0)

    cleanUp: ->
        document.body.removeChild @container
