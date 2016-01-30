describe 'Plugin: Legend', ->
    chartContainer = null
    legendContainer = null
    chart = null
    sampleData = null

    beforeEach ->
        sampleData = [
            key: 'hello'
            label: 'Hello World'
            values: []
        ,
            key: 'bye'
            label: 'Good Bye'
            values: []
        ,
            key: 'adios'
            label: 'Good Bye Again'
            color: '#000'
            values: []
        ]

        chartContainer = document.createElement 'div'
        legendContainer = document.createElement 'div'

        chart = new ForestD3.Chart chartContainer

        document.body.appendChild chartContainer
        document.body.appendChild legendContainer

        afterEach ->
            chart.destroy()

    it 'sets forest-d3 class on parent div', ->
        legend = new ForestD3.Legend legendContainer

        $(legendContainer).hasClass('forest-d3').should.be.true
        $(legendContainer).hasClass('legend').should.be.true

    it 'renders legend items given chart data', ->
        chart.data sampleData
        legend = new ForestD3.Legend legendContainer

        legend.chart(chart).render()

        items = $(legendContainer).find('.item')
        items.length.should.equal 3, 'three legend items'

        items.eq(0).find('.color-square').length.should.equal 1, 'color square'
        items.eq(0).text().should.contain 'Hello World'

        items.eq(1).text().should.contain 'Good Bye'
        items.eq(2).text().should.contain 'Good Bye Again'

        items.eq(2).find('.color-square')
        .css('background-color').should.equal 'rgb(0, 0, 0)'

    it 'renders via chart plugin API', (done)->
        chart.data sampleData
        legend = new ForestD3.Legend legendContainer

        chart.addPlugin.should.exist
        chart.addPlugin legend

        chart.render()

        setTimeout ->
            items = $(legendContainer).find('.item')
            items.length.should.equal 3, 'three legend items'
            done()
        , 300

    it 'marks legend item as disabled', ->
        chart.data sampleData
        legend = new ForestD3.Legend legendContainer
        chart.addPlugin legend

        chart.render()
        chart.data().hide('hello').render()

        items = $(legendContainer).find('.item')
        items.eq(0).hasClass('disabled').should.be.true

    it 'marks legend item as disabled', ->
        data2 = sampleData.concat [
            type: 'region'
            values: [3,4]
        ,
            type: 'marker'
            value: 1
        ]

        chart.data data2
        legend = new ForestD3.Legend legendContainer
        legend.onlyDataSeries(true)
        chart.addPlugin legend

        chart.render()
        items = $(legendContainer).find '.item'
        items.length.should.equal 3, '3 items only'
