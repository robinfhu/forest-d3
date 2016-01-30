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
        yOffsetVal = (d)-> d.y + d.y0
        internalData.forEach (series)->
            if series.isDataSeries
                yVals = series.values.map yOffsetVal
                yVals = yVals.concat([0])
                series.extent.y = d3.extent yVals

    getVisualization: (series)->
        ForestD3.Visualizations.barStacked
