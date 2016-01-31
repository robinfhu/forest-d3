###
A StackedChart is responsible for rendering a chart with 'layers'.
Examples include stacked bar and stacked area charts.

Due to the unique nature of the stacked visualization, you are not
allowed to combine it with lines and scatters.
###
chartProperties = [
    ['stackType','bar']
    ['stacked', true]
]

@ForestD3.StackedChart = class StackedChart extends ForestD3.Chart
    constructor: (domContainer)->
        super domContainer
        @_setProperties chartProperties

    # Overrides parent class
    init: ->
        internalData = @data().visible().filter (d)-> d.isDataSeries
        d3.layout.stack()
            .offset('zero')
            .order('reverse')
            .values((d)-> d.values)(internalData)

        # Calculate the y-extent for each series
        yOffsetVal =
            if @stacked()
                (d)-> d.y + d.y0
            else
                (d)-> d.y

        seriesType = 'bar'
        internalData.forEach (series)->
            if series.isDataSeries
                # Set type=bar, so that data().barCount() returns valid length.
                series.type = seriesType

                yVals = series.values.map yOffsetVal

                ###
                Add 0 to the extent always, because stacked bar charts
                should be based on the zero axis
                ###
                yVals = yVals.concat([0])
                series.extent.y = d3.extent yVals

    ###
    Override the parent class' method.
    ###
    getVisualization: (series)->
        renderFn = super series

        if series.type is 'bar'
            if @stacked()
                ForestD3.Visualizations.barStacked
            else
                ForestD3.Visualizations.bar
        else
            renderFn
