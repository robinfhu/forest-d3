chartProperties = [
    ['stackType','bar']
    ['stacked', true]
]

@ForestD3.StackedChart = class StackedChart extends ForestD3.Chart
    constructor: (domContainer)->
        super domContainer
        @_setProperties chartProperties

    # Overrides parent class
    preprocessData: ->
        internalData = @data().visible()
        d3.layout.stack()
            .offset('zero')
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
                yVals = yVals.concat([0])
                series.extent.y = d3.extent yVals

    getVisualization: (series)->
        if @stacked()
            ForestD3.Visualizations.barStacked
        else
            ForestD3.Visualizations.bar