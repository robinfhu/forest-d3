@ForestD3.Utils = do ->
    colors20 = d3.scale.category20().range()
    ###
    Calculates the minimum and maximum point across all series'.
    Useful for setting the domain for a d3.scale()

    data: Array of series'
    x: function to get X value
    y: function to get Y value

    Returns:
        {
            x: [min, max]
            y: [min, max]
        }
    ###
    extent: (data, x, y)->
        defaultExtent = [-1, 1]
        if not data or data.length is 0
            return {
                x: defaultExtent
                y: defaultExtent
            }

        x ?= (d,i)-> d[0]
        y ?= (d,i)-> d[1]

        xAllPoints = data.map (series)->
            if series.values? and series.type isnt 'region'
                d3.extent series.values, x
            else
                []

        yAllPoints = data.map (series)->
            if series.values? and series.type isnt 'region'
                d3.extent series.values, y
            else
                []

        xExt = d3.extent d3.merge xAllPoints
        yExt = d3.extent d3.merge yAllPoints

        roundOff = (d,i)->
            return Math.floor(d) if i is 0
            return Math.ceil(d)

        # Factor in any markers
        data.filter((d)-> d.type is 'marker').forEach (marker)->
            if marker.axis is 'x'
                xExt.push marker.value
            else
                yExt.push marker.value

        # Factor in any regions
        data.filter((d)-> d.type is 'region').forEach (region)->
            if region.axis is 'x'
                xExt = xExt.concat region.values
            else
                yExt = yExt.concat region.values

        xExt = d3.extent xExt
        yExt = d3.extent yExt

        xExt = xExt.map roundOff
        yExt = yExt.map roundOff

        x: xExt
        y: yExt

    ###
    Increases an extent by a certain percentage. Useful for padding the
    edges of a chart so the points are not right against the axis.

    extent: Object of form:
        {
            x: [-10, 10]
            y: [-1, 1]
        }

    padding: Object of form:
        {
            x: 0.1    # percentage to pad by
            y: 0.05
        }
    ###
    extentPadding: (extent, padding)->
        result = {}

        for key, domain of extent
            padPercent = padding[key]
            if padPercent?
                amount = Math.abs(domain[0] - domain[1]) * padPercent
                amount /= 2

                result[key] = [domain[0] - amount, domain[1] + amount]


        result
    ###
    Adds a numeric _index to each series, which is used to uniquely
    identify it.
    ###
    indexify: (data)->
        data.map (d, i)->
            d._index = i
            d

    defaultColor: (i)-> colors20[i % colors20.length]
