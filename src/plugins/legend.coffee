###
Draws a chart legend using HTML.
It acts as a plugin to a main chart instance.
###

@ForestD3.Legend = class Legend
    constructor: (domContainer)->
        @container = d3.select(domContainer).classed('forest-d3 legend', true)

    dataApi: (api)->

    render: ->
