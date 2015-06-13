@ForestD3.Utils =
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

        allPoints = data.map (series)->
            series.values

        allPoints = d3.merge allPoints

        x ?= (d,i)-> d[0]
        y ?= (d,i)-> d[1]

        xExt = d3.extent allPoints, x
        yExt = d3.extent allPoints, y

        roundOff = (d,i)->
            return Math.floor(d) if i is 0
            return Math.ceil(d)

        xExt = xExt.map roundOff
        yExt = yExt.map roundOff

        x: xExt
        y: yExt
