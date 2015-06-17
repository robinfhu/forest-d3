@ForestD3.DataAPI = (data)->

    chart = @

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

    # Get array of all X-axis data points
    xValues: ->
        dataObjs = data.filter (d)-> d.values? and d.type isnt 'region'
        return [] unless dataObjs[0]?

        dataObjs[0].values.map (d,i)-> chart.getX()(d,i)

    render: -> chart.render()
