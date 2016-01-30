@ForestD3.BaseChart = class BaseChart
    constructor: (domContainer)->
        @properties = {}

        @container domContainer

        @_metadata = {}
        @_dispatch = d3.dispatch 'rendered', 'stateUpdate'
        @plugins = {}

        ###
        Auto resize the chart if user resizes the browser window.
        ###
        @resize = =>
            if @autoResize()
                @render()

        window.addEventListener 'resize', @resize
        @_attachStateHandlers()

    ###
    Call this method to remove chart from the document and any artifacts
    it has (like tooltips) and event handlers.
    ###
    destroy: ->
        domContainer = @container()
        if domContainer?.parentNode?
            domContainer.parentNode.removeChild domContainer

        window.removeEventListener 'resize', @resize

    on: (type, listener)->
        @_dispatch.on type, listener

    trigger: (type)->
        @_dispatch[type].apply @, Array.prototype.slice.call(arguments, 1)

    _attachStateHandlers: ->

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

    _setProperties: (chartProperties)->
        ForestD3.Utils.setProperties @, @properties, chartProperties
