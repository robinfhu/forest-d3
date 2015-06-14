@ForestD3.DataAPI = (data)->

    chart = @

    get: -> data

    displayInfo: ->
        data.map (d)->
            key: d.key
            label: d.label
            hidden: d.hidden is true
            color: chart.seriesColor d

    hide: (keys, flag = true)->
        if not (keys instanceof Array)
            keys = [keys]

        for d in data
            if d.key in keys
                d.hidden = flag

        return @

    show: (keys)->
        @hide keys, false

    toggle: (keys)->
        if not (keys instanceof Array)
            keys = [keys]

        for d in data
            if d.key in keys
                d.hidden = not d.hidden

        return @

    showOnly: (key)->
        for d in data
            d.hidden = not (d.key is key)

        @
    showAll: ->
        for d in data
            d.hidden = false

        @
    visible: ->
        data.filter (d)-> not d.hidden

    render: -> chart.render()
