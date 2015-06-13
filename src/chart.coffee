chartProperties = [
    'container'
]

@ForestD3.Chart = class Chart
    constructor: (domContainer)->
        @properties = {}

        for prop in chartProperties
            @[prop] = do (prop)=>
                (d)=>
                    unless d?
                        return @properties[prop]
                    else
                        @properties[prop] = d 


        @container domContainer
    render: ->
        svg = document.createElement 'svg'
        container = @container()
        if container?
            exists = container.querySelector 'svg'
            unless exists?
                container.appendChild svg


        