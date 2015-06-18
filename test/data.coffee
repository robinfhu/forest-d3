describe 'Data API', ->
    it 'should have ability to get raw data', ->
        api = ForestD3.DataAPI [1,2,3]

        api.get().should.deep.equal [1,2,3]

    it 'can get basic display info (label and color)', ->
        data = [
            key: 'series1'
            label: 'Hello'
            values: []
        ,
            key: 'series2'
            label: 'World'
            hidden: true
            values: []
        ,
            key: 'series3'
            color: '#00f'
            label: 'Foo'
            values: []
        ]

        chart = new ForestD3.Chart()
        chart.data(data)

        api = chart.data()

        display = api.displayInfo()

        for d in display
            d.should.have.property 'key'
            d.should.have.property 'label'
            d.should.have.property 'color'
            d.should.have.property 'hidden'

        display[2].color.should.equal '#00f'
        display[1].hidden.should.be.true
        display[0].label.should.equal 'Hello'

    it 'has methods to show/hide data series`', ->
        data = [
            key: 'series1'
            label: 'Hello'
            values: []
        ,
            key: 'series2'
            label: 'World'
            values: []
        ,
            key: 'series3'
            color: '#00f'
            label: 'Foo'
            values: []
        ]

        chart = new ForestD3.Chart()
        chart.data(data)

        api = chart.data()

        api.hide(['series1', 'series2'])

        visible = api.visible()
        visible.length.should.equal 1

        api.show('series2')

        visible = api.visible()
        visible.length.should.equal 2

        api.toggle('series2')

        visible = api.visible()
        visible.length.should.equal 1

    it 'has methods for showOnly and showAll data', ->
        data = [
            key: 'series1'
            label: 'Hello'
            values: []
        ,
            key: 'series2'
            label: 'World'
            values: []
        ,
            key: 'series3'
            color: '#00f'
            label: 'Foo'
            values: []
        ]

        api = ForestD3.DataAPI data

        api.showOnly 'series2'
        visible = api.visible()
        visible.length.should.equal 1
        visible[0].key.should.equal 'series2'

        api.showAll()
        visible = api.visible()
        visible.length.should.equal 3


    it 'has method to get visible data only', ->
        data = [
            key: 'series1'
            label: 'Hello'
            values: []
        ,
            key: 'series2'
            label: 'World'
            hidden: true
            values: []
        ,
            key: 'series3'
            color: '#00f'
            label: 'Foo'
            hidden: true
            values: []
        ]

        chart = new ForestD3.Chart()
        chart.data(data)

        visible = chart.data().visible()
        visible.length.should.equal 1
        visible[0].key.should.equal 'series1'

    it 'has method to get list of x values', ->
        data = [
            values: [
                [2, 10]
                [80, 100]
                [90, 101]
            ]
        ]
        chart = new ForestD3.Chart()
        chart.data(data)

        chart.data().xValues().should.deep.equal [2, 80, 90]

        data = [
            value: [1,2]
        ]

        chart.data(data)

        chart.data().xValues().should.deep.equal []

        chart.getX (d,i)-> i

        data = [
            values: [
                [2, 10]
                [80, 100]
                [90, 101]
            ]
        ]

        chart.data(data)

        chart.data().xValues().should.deep.equal [0,1,2]

    it 'can get raw x values for an ordinal chart', ->
        data = [
            values: [
                [2, 10]
                [80, 100]
                [90, 101]
            ]
        ]
        chart = new ForestD3.Chart()
        chart.ordinal(true).data(data)

        chart.data().xValuesRaw().should.deep.equal [2,80,90]
