###
Draws a chart legend using HTML.
It acts as a plugin to a main chart instance.
###

@ForestD3.Legend = class Legend
    constructor: (domContainer)->
        @name = 'legend'

        if domContainer.select?
            @container = domContainer
        else
            @container = d3.select domContainer

        @container.classed('forest-d3 legend', true)

        ###
        This is a technique to distinguish between single and double clicks.

        When any kind of click happens, the last event handler gets stored in
        @lastClickEvent.

        After a brief delay of about 200 ms, the lastClickEvent is executed.
        ###
        @lastClickEvent = ->
        processClickEvent = =>
            @lastClickEvent.call @

        @legendClickHandler = ForestD3.Utils.debounce processClickEvent, 200

    chart: (chart)->
        @chartInstance = chart

        @
    render: ->
        return unless @chartInstance?

        showAll = @container.selectAll('div.show-all').data([0])
        showAll
            .enter()
            .append('div')
            .classed('show-all button', true)
            .text('show all')
            .on('click', (d)=> @chartInstance.data().showAll().render())

        data = @chartInstance.data().get()

        items = @container.selectAll('div.item').data(data, (d)-> d.key)
        itemsEnter = items
            .enter()
            .append('div')
            .classed('item', true)

        items
            .on('click.legend', (d)=>
                @lastClickEvent = =>
                    @chartInstance.data().toggle(d.key).render()
                @legendClickHandler()
            )
            .on('dblclick.legend', (d)=>
                @lastClickEvent = =>
                    @chartInstance.data().showOnly(d.key).render()
                @legendClickHandler()
            )
            .on('mouseover.legend', (d)=>
                @chartInstance.highlightSeries d.key
            )
            .on('mouseout.legend', (d)=>
                @chartInstance.highlightSeries null
            )

        items.classed('disabled', (d)-> d.hidden)

        itemsEnter
            .append('span')
            .classed('color-square', true)
            .style('background-color', (d)-> d.color)

        itemsEnter
            .append('span')
            .classed('description', true)
            .text((d)-> d.label)

        itemsEnter
            .append('span')
            .classed('show-only button', true)
            .text('only')
            .on('click.showOnly', (d)=>
                d3.event.stopPropagation()
                @chartInstance.data().showOnly(d.key).render()
            )
