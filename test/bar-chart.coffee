describe 'Horizontal Bar Chart', ->
    container = null
    chart = null

    beforeEach ->
        container = document.createElement 'div'
        container.style.width = '500px'
        container.style.height = '400px'
        document.body.appendChild container

        chart = new ForestD3.BarChart container

    afterEach ->
        chart.destroy()

    it 'creates an <svg> tag and adds forest-d3 class to container', ->
        $(container).hasClass('forest-d3').should.be.true
        $(container).find('svg').length.should.equal 1

    it 'can render a chart frame', ->
        data = [
            key: 'series1'
            label: 'Long'
            values: [
                ['Population', 100]
            ]
        ]

        chart.data(data).render()

        labels = $(container).find('svg g.bar-labels')
        bars = $(container).find('svg g.bars')
        values = $(container).find('svg g.bar-values')

        labels.length.should.equal 1
        bars.length.should.equal 1
        values.length.should.equal 1

    it 'can render a single bar', ->
        data = [
            key: 'series1'
            label: 'Long'
            values: [
                ['Population', 100]
            ]
        ]

        chart.data(data).render()

        labels = $(container).find('svg g.bar-labels text')
        bars = $(container).find('svg g.bars rect')
        values = $(container).find('svg g.bar-values text')

        labels.length.should.equal 1
        bars.length.should.equal 1
        values.length.should.equal 1

        labels.get(0).textContent.should.equal 'Population'
