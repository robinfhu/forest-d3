@ForestD3.DataAPI = (data)->

    chart = @

    getIdx = (d,i)-> i

    get: -> data

    # Used for legends that need label and color information
    displayInfo: ->
        data.map (d)->
            key: d.key
            label: d.label
            hidden: d.hidden is true
            color: chart.seriesColor d

    # Mark a given data series as hidden
    hide: (keys, flag = true)->
        if not (keys instanceof Array)
            keys = [keys]

        for d in data
            if d.key in keys
                d.hidden = flag

        return @

    # Un-hide data series
    show: (keys)->
        @hide keys, false

    # Flip data series on/off
    toggle: (keys)->
        if not (keys instanceof Array)
            keys = [keys]

        for d in data
            if d.key in keys
                d.hidden = not d.hidden

        return @

    # Turn everything off except for the given data series
    showOnly: (key)->
        for d in data
            d.hidden = not (d.key is key)

        @

    # Turn everything on
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
        @._xValues chart.getXInternal()

    # Get array of all X-axis data points, returning the raw x value
    xValuesRaw: ->
        @._xValues chart.getX()

    # Get the x raw value at a certain position
    xValueAt: (i)->
        dataObjs = @._getSliceable()
        return null unless dataObjs[0]?

        point = dataObjs[0].values[i]
        if point?
            chart.getX()(point)
        else
            null

    ###
    For a set of data series, grabs a slice of the data at a certain index.
    Useful for making the tooltip.
    ###
    sliced: (i)->
        @._getSliceable().filter((d)-> not d.hidden).map (d)->
            point = d.values[i]

            x: chart.getX()(point)
            y: chart.getY()(point)
            key: d.key
            label: d.label
            color: chart.seriesColor d

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
    render: -> chart.render()
