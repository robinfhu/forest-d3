###
Draws a chart legend using HTML.
It acts as a plugin to a main chart instance.
###

@ForestD3.Legend = class Legend
    constructor: (domContainer)->
        @name = 'legend'
        @container = d3.select(domContainer).classed('forest-d3 legend', true)

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

        data = @chartInstance.data().displayInfo()

        items = @container.selectAll('div.item').data(data, (d)-> d.key)
        items
            .enter()
            .append('div')
            .classed('item', true)

        items.on 'click', (d)=> @chartInstance.data().toggle(d.key).render()

        items.classed('disabled', (d)-> d.hidden)

        colorSquares = items
            .selectAll('span.color-square')
            .data((d)-> [d])

        colorSquares
            .enter()
            .append('span')
            .classed('color-square', true)
            .style('background-color', (d)-> d.color)

        labels = items
            .selectAll('span.description')
            .data((d)-> [d])

        labels
            .enter()
            .append('span')
            .classed('description', true)
            .text((d)-> d.label)

        onlyButton = items
            .selectAll('span.show-only')
            .data((d)-> [d])

        onlyButton
            .enter()
            .append('span')
            .classed('show-only button', true)
            .text('only')
            .on('click', (d)=>
                d3.event.stopPropagation()
                @chartInstance.data().showOnly(d.key).render()
            )
