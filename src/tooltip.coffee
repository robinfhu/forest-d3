@ForestD3.Tooltip = class Tooltip
    constructor: (@chart)->
        @container = null

    ###
    content: string or DOM object or d3 object representing tooltip content.
    clientMouse: Array of [mouse screen x, mouse screen y] positions
    ###
    render: (content, clientMouse)->
        return unless @chart.showTooltip()

        unless @container?
            @container = document.createElement 'div'
            document.body.appendChild @container

        if (typeof content is 'string') or (typeof content is 'number')
            d3.select(@container)
                .classed('forest-d3 tooltip-box', true)
                .html(content)

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

        ###
        Adjust tooltip so that it is centered on the mouse.
        Accomplish this by calculating container height and dividing it by 2.
        ###
        containerCenter = @container.getBoundingClientRect().height / 2
        yPos -= containerCenter

        d3.select(@container)
            .style('left', "#{xPos}px")
            .style('top', "#{yPos}px")
            .transition()
            .style('opacity', 0.9)

    # Hide tooltip from view by making it transparent.
    hide: ->
        return unless @chart.showTooltip()

        d3.select(@container)
            .transition()
            .delay(250)
            .style('opacity', 0)

    # Call this to remove the tooltip DIV from the page.
    cleanUp: ->
        if @container?
            document.body.removeChild @container
