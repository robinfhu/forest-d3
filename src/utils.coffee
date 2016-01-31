@ForestD3.Utils = do ->
    colors20 = d3.scale.category20().range()

    setProperties:  (chart, target, chartProperties)->
        for propPair in chartProperties
            [prop, defaultVal] = propPair
            target[prop] = defaultVal

            chart[prop] = do (prop)->
                (d)->
                    if typeof(d) is 'undefined'
                        return target[prop]

                    else
                        target[prop] = d
                        return chart
    ###
    Calculates the minimum and maximum point across all series'.
    Useful for setting the domain for a d3.scale()

    data: chart data that has been passed through normalization function.
    It should be an array of objects, where each object contains an extent
    property. Example:
    [
        key: 'line1'
        extent:
            x: [1,3]
            y: [3,4]
    ,
        key: 'line2'
        extent:
            x: [1,3]
            y: [3,4]
    ]

    the 'force' argument allows you to force certain values onto the final
    extent. Example:
        {y: [0], x: [0]}

    Returns an object with the x,y axis extents:
    {
        x: [min, max]
        y: [min, max]
    }
    ###
    extent: (data, force)->
        defaultExtent = [-1, 1]
        if not data or data.length is 0
            return {
                x: defaultExtent
                y: defaultExtent
            }

        xExt = d3.extent d3.merge data.map((series)-> series.extent?.x or [])
        yExt = d3.extent d3.merge data.map((series)-> series.extent?.y or [])

        # Factor in any forced domain values
        force ?= {}
        force.x ?= []
        force.y ?= []
        force.x = [force.x] if not (force.x instanceof Array)
        force.y = [force.y] if not (force.y instanceof Array)

        xExt = xExt.concat force.x
        yExt = yExt.concat force.y

        xExt = d3.extent xExt
        yExt = d3.extent yExt

        clearNaN = (d,i)->
            if isNaN d
                return if i is 0 then -1 else 1
            else
                return d

        xExt = xExt.map clearNaN
        yExt = yExt.map clearNaN

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

            newObj
        copy

    ###
    Converts the input data into a normalized format.
    Also clones the data so the chart operates on copy of the data.
    It converts the 'values' array into a normal format, that looks like this:
        {
            x: (raw x value, or an index if ordinal=true)
            y: (the raw y value)
            data: (reference to the original data point)
        }

    It also adds an 'extent' property to the series data.

    @param data - the chart data to normalize.
    @param options - object with the following properties:
        getX: function to get the raw x value
        getY: function to get the raw y value
        ordinal: boolean describing whether the data is uniformly distributed
            on the x-axis or not.
    ###
    normalize: (data, options={})->
        data = @clone data

        getX = options.getX
        getY = options.getY
        ordinal = options.ordinal
        colorPalette = options.colorPalette or colors20
        autoSortXValues = options.autoSortXValues

        colorIndex = 0
        seriesIndex = 0

        data.forEach (series,i)->
            series.key ?= "series#{i}"
            series.label ?= "Series ##{i}"
            series.type ?= if series.value? then 'marker' else 'scatter'

            ###
            An internal only unique identifier.
            This is necessary to ensure each chart series has a
            unique key when doing a d3.selectAll.data join.
            ###
            rand = Math.floor (Math.random() * 1000000)
            series._uniqueKey = "#{series.key}_#{i}_#{rand}"

            if series.type is 'region'
                series.extent =
                    x: if series.axis is 'x' then series.values else []
                    y: if series.axis isnt 'x' then series.values else []
                return

            if series.type is 'marker'
                series.extent =
                    x: if series.axis is 'x' then [series.value] else []
                    y: if series.axis isnt 'x' then [series.value] else []
                return

            unless series.color?
                series.color = colorPalette[colorIndex % colorPalette.length]
                colorIndex++

            series.index = seriesIndex
            seriesIndex++

            if series.values instanceof Array
                series.isDataSeries = true
                series.values = series.values.map (d,i)->
                    xRaw = getX(d,i)
                    yRaw = getY(d,i)

                    x: if ordinal then i else xRaw
                    y: yRaw
                    xValueRaw: xRaw
                    yValueRaw: yRaw
                    data: d
                    series: series

                ###
                Calculates the extent (in x and y directions) of the data in
                each series.
                The 'extent' is basically the highest and lowest values,
                used to figure out the chart's scale.
                ###
                series.extent =
                    x: d3.extent(series.values, (d)-> d.x)
                    y: d3.extent(series.values, (d)-> d.y)

                ###
                Sort all the data points in ascending order, by x-value.
                This prevents any scrambled lines being drawn.

                This only needs to happen for
                non-ordinal data series (scatter plots for example).
                Ordinal data is always sorted by default.
                ###
                if autoSortXValues and not ordinal
                    series.values.sort (a,b)->
                        d3.ascending a.xValueRaw, b.xValueRaw

        data
