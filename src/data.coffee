###
Returns an API object that performs calculations and operations on a chart
data object.

Some operations can mutate the original chart data.
###
@ForestD3.DataAPI = (data)->
    chart = @

    # Returns the entire raw data object.
    get: -> data

    # Mark a given data series as hidden.
    hide: (keys, flag = true)->
        if not (keys instanceof Array)
            keys = [keys]

        for d in data
            if d.key in keys
                d.hidden = flag

        @

    # Un-hide data series.
    show: (keys)->
        @hide keys, false

    # Flip data series on/off.
    toggle: (keys)->
        if not (keys instanceof Array)
            keys = [keys]

        for d in data
            if d.key in keys
                d.hidden = not d.hidden

        @

    # Turn everything off except for the given data series.
    showOnly: (key)->
        for d in data
            d.hidden = not (d.key is key)

        @

    # Turn everything on.
    showAll: ->
        for d in data
            d.hidden = false

        @

    # Get list of data series' that are not hidden
    visible: ->
        data.filter (d)-> not d.hidden

    _getSliceable: ->
        data.filter (d)-> d.values? and d.type isnt 'region'

    _xValues: (getX)->
        dataObjs = @._getSliceable()
        return [] unless dataObjs[0]?

        dataObjs[0].values.map getX

    # Get array of all X-axis data points
    # Returns natural ordered indices if chart.ordinal is true
    xValues: ->
        @._xValues chart.getXInternal

    # Get array of all X-axis data points, returning the raw x value
    xValuesRaw: ->
        getX = (d,i)-> chart.getX()(d.data,i)
        @._xValues getX

    # Get the x raw value at a certain position
    xValueAt: (i)->
        dataObjs = @._getSliceable()
        return null unless dataObjs[0]?

        point = dataObjs[0].values[i]
        if point?
            chart.getX()(point.data)
        else
            null

    ###
    For a set of data series, grabs a slice of the data at a certain index.
    Useful for making the tooltip.
    ###
    sliced: (idx)->
        @._getSliceable().filter((d)-> not d.hidden).map (d)->
            point = d.values[idx]

            x: chart.getX()(point.data, idx)
            y: chart.getY()(point.data, idx)
            key: d.key
            label: d.label
            color: d.color

    _barItems: -> @.visible().filter((d)-> d.type is 'bar')
    ###
    Count how many visible bar series items there are.
    Used for doing bar chart math.
    ###
    barCount: ->
        @._barItems().length

    ###
    Returns the index of the bar item given a key.
    Only takes into account visible bar items.
    Returns null if the key specified is not a bar item
    ###
    barIndex: (key)->
        for item, i in @._barItems()
            if item.key is key
                return i

        return null

    quadtree: ->
        allPoints = @._getSliceable()
        .filter((d)-> not d.hidden)
        .map (s, i)->
            s.values.map (d,i)->
                x: chart.getXInternal(d,i)
                y: chart.getYInternal(d,i)
                xValue: chart.getX()(d.data,i)
                series: s
                data: d

        allPoints = d3.merge allPoints

        d3.geom.quadtree()
            .x((d)-> d.x)
            .y((d)-> d.y)(allPoints)

    ###
    Alias to chart.render(). Allows you to do things like:
    chart.data().show('mySeries').render()
    ###
    render: -> chart.render()
