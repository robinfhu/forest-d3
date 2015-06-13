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

    visible: ->
        data.filter (d)-> not d.hidden
