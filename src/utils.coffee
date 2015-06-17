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

    ###
    TODO: Add data normalization routine
    It should fill in missing gaps and sort the data in ascending order.
    ###
    normalize: (data)->

    ###
    Utility class that uses d3.bisect to find the index in a given array,
    where a search value can be inserted.
    This is different from normal bisectLeft; this function finds the nearest
    index to insert the search value.
    For instance, lets say your array is [1,2,3,5,10,30], and you search for 28.
    Normal d3.bisectLeft will return 4, because 28 is inserted after the number
    10.

    But smartBisect will return 5
    because 28 is closer to 30 than 10.
    Has the following known issues:
       * Will not work if the data points move backwards (ie, 10,9,8,7, etc) or
       if the data points are in random order.
       * Won't work if there are duplicate x coordinate values.
    ###
    smartBisect: (values, search, getX = (d)-> d[0])->
        return null unless values instanceof Array
        return null if values.length is 0
        return 0 if values.length is 1

        if search >= values[values.length - 1]
            return values.length-1

        if search <= values[0]
            return 0

        bisect = (vals, sch)->
            lo = 0
            hi = vals.length
            while lo < hi
                mid = (lo + hi) >>> 1
                if vals[mid] < sch
                    lo = mid + 1
                else
                    hi = mid

            lo

        index = bisect values,search

        index = d3.min [index, values.length-1]
        if index > 0
            prevIndex = index-1
            prevVal = getX(values[prevIndex], prevIndex)
            nextVal = getX(values[index], index)

            if Math.abs(search-prevVal) < Math.abs(search-nextVal)
                index = prevIndex

        index

    defaultColor: (i)-> colors20[i % colors20.length]

    debounce: (fn, delay)->
        promise = null
        ->
            args = arguments
            window.clearTimeout promise

            promise = window.setTimeout =>
                promise = null
                fn.apply @, args
            , delay
