@ForestD3.Tooltip = class Tooltip
    constructor: ->
        @container = null

    ###
    data: array of data objects to render
    clientMouse: Array of [mouse screen x, mouse screen y] positions
    ###
    render: (data, clientMouse)->
        unless @container?
            @container = document.createElement 'div'
            document.body.appendChild @container

        ###
        xPos and yPos are the relative coordinates of the mouse in the
        browser window.

        Adding page offset to it takes into account any scrolling.

        Because the tooltip DIV is placed on document.body, this should give
        us the absolute correct position.
        ###
        [xPos, yPos] = clientMouse
        xPos += window.pageXOffset
        yPos += window.pageYOffset

        d3.select(@container)
            .classed('forest-d3 tooltip-box', true)
            .style('left', "#{xPos}px")
            .style('top', "#{yPos}px")
            .transition()
            .style('opacity', 1)

    # Hide tooltip from view by making it transparent.
    hide: ->
        d3.select(@container)
            .transition()
            .delay(250)
            .style('opacity', 0)

    # Call this to remove the tooltip DIV from the page.
    cleanUp: ->
        if @container?
            document.body.removeChild @container
