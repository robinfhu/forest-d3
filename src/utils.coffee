@ForestD3.Utils = do ->
    colors20 = d3.scale.category20().range()
    ###
    Calculates the minimum and maximum point across all series'.
    Useful for setting the domain for a d3.scale()

    data: Array of series'
    x: function to get X value
    y: function to get Y value
    force: values to force onto domains. Example: {y: [0]},
        force 0 onto y domain.

    Returns:
        {
            x: [min, max]
            y: [min, max]
        }
    ###
    extent: (data, x, y, force)->
        defaultExtent = [-1, 1]
        if not data or data.length is 0
            return {
                x: defaultExtent
                y: defaultExtent
            }

        x ?= (d,i)-> d[0]
        y ?= (d,i)-> d[1]
        force ?= {}
        force.x ?= []
        force.y ?= []
        force.x = [force.x] if not (force.x instanceof Array)
        force.y = [force.y] if not (force.y instanceof Array)

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

        # Factor in any forced domain values
        xExt = xExt.concat force.x
        yExt = yExt.concat force.y

        xExt = d3.extent xExt
        yExt = d3.extent yExt

        roundOff = (d,i)->
            return d if Math.abs(d) < 1

            if i is 0
                if isNaN d
                    return -1
                else
                    return Math.floor(d)
            else
                if isNaN d
                    return 1
                else
                    return Math.ceil(d)

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
                if domain[0] is 0 and domain[1] is 0
                    result[key] = [-1, 1]
                else
                    range = Math.abs(domain[0] - domain[1]) or domain[0]
                    amount = range * padPercent
                    amount /= 2

                    result[key] = [domain[0] - amount, domain[1] + amount]


        result
    ###
    Assigns a numeric 'index' to each series, which is used to uniquely
    identify it. Stores this index in chart.metadata
    ###
    indexify: (data, metadata)->
        data.forEach((d)->
            metadata[d.key] = {} unless metadata[d.key]?
        )

        data
        .filter((d)-> (not d.type?) or (d.type not in ['region', 'marker']))
        .forEach (d, i)->
            metadata[d.key].index = i

        data

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
                if getX(vals[mid],mid) < sch
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

    # Approximate the max width in pixels that a label can use up in x-axis.
    # Used to calculate how many ticks to show in x-axis.
    textWidthApprox: (xValues, format)->
        return 100 unless xValues?
        sample = '' + format(xValues[0] or '')
        sample.length * 10 + 40

    ###
    Returns an array that is a good approximation for what ticks should
    be shown on x-axis.

    xValues - array of all available x-axis values
    numTicks - max number of ticks that can fit on the axis
    widthThreshold - minimum distance between ticks allowed.
    ###
    tickValues: (xValues, numTicks, widthThreshold = 1)->
        if numTicks is 0
            return []

        L = xValues.length
        if L <= 2
            return xValues

        result = [xValues[0]]

        counter = 0
        increment = Math.ceil(L / numTicks)

        while counter < L - 1
            counter += increment
            break if counter >= L - 1
            result.push xValues[counter]

        dist = xValues[L-1] - result[result.length-1]
        if dist < widthThreshold
            result.pop()

        result.push xValues[L-1]

        result

    convertObjectToArray: (obj)->
        if obj instanceof Array
            return obj.slice()
        else
            array = []
            for key, data of obj
                data.key ?= key
                array.push data

            return array

    ###
    Create a clone of a chart data object.
    ###
    clone: (data)->
        copy = @convertObjectToArray data

        copy = copy.map (d)->
            newObj = {}
            newObj[key] = val for key, val of d

            if newObj.values?
                newObj.values = newObj.values.slice()

            newObj
        copy
