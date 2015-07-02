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

    it 'has autoResize function', ->
        should.exist chart.autoResize

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

    it 'automatically figures out SVG height', ->
        data = [
            key: 'series1'
            label: 'Short'
            values: [
                ['Experiment 1', 100]
                ['Experiment 2', 90]
                ['Experiment 3', 80]
            ]
        ]

        chart
            .barHeight(40)
            .barPadding(10)
            .height(null)
            .data(data)
            .render()

        svg = $(container).find('svg')

        height = "#{50*3}"
        svg.get(0).getAttribute('height').should.equal height

    it 'automatically figures out left margin', (done)->
        data = [
            key: 'series1'
            label: 'Short'
            values: [
                ['A', 1]
                ['BBBBBBBBBB', 2]
            ]
        ]

        chart.data(data).render()

        chart.margin.left.should.be.greaterThan 100

        data = [
            key: 'series1'
            label: 'Short'
            values: [
                ['A', 1]
                ['B', 2]
            ]
        ]

        chart.data(data).render()

        chart.margin.left.should.be.lessThan 40

        setTimeout ->
            done()
        , 600

    it 'can sort things by label, ascending', (done)->
        data = [
            key: 'series1'
            label: 'Short'
            values: [
                ['A', 1]
                ['E', 2]
                ['B', 3]
                ['Z', 4]
                ['C', 5]
            ]
        ]

        chart.data(data)
        chart.sortBy((d)-> d[0]).sortDirection('asc').render()

        labels = $(container).find('.bar-labels text')

        for text, i in ['A','B','C','E','Z']
            labels.get(i).textContent.should.equal text

        # original data kept intact

        data[0].values.should.deep.equal [
            ['A', 1]
            ['E', 2]
            ['B', 3]
            ['Z', 4]
            ['C', 5]
        ]

        setTimeout ->
            done()
        , 600

    it 'translates negative bars and labels', (done)->
        data = [
            key: 'series1'
            label: 'Short'
            values: [
                ['A', 100]
                ['B', 60]
                ['C', -60]
                ['D', -100]
            ]
        ]

        chart.data(data).render()

        bars = $(container).find('.bars rect')
        bars.get(2).getAttribute('transform').should.contain 'translate'
        bars.get(3).getAttribute('transform').should.contain 'translate'

        bars.get(1).getAttribute('class').should.contain 'positive'
        bars.get(2).getAttribute('class').should.contain 'negative'

        values = $(container).find('.bar-values text')
        values.get(1).getAttribute('class').should.contain 'positive'
        values.get(2).getAttribute('class').should.contain 'negative'

        values.get(2).getAttribute('x').should.equal values.get(3).getAttribute('x')

        setTimeout ->
            done()
        , 600
