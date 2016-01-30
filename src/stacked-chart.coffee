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
        internalData = @data().get()
        d3.layout.stack()
            .offset('zero')
            .values((d)-> d.values)(internalData)

        # Calculate the y-extent for each series
        yOffsetVal = (d)-> d.y + d.y0
        internalData.forEach (series)->
            if series.isDataSeries
                series.extent.y = d3.extent series.values, yOffsetVal
