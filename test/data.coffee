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
            values: []
        ,
            key: 'series3'
            color: '#00f'
            values: []
        ]

        chart = new ForestD3.Chart()
        chart.data(data)

        api = chart.data()

        api.hide 'series2'

        display = api.displayInfo()

        for d in display
            d.should.have.property 'key'
            d.should.have.property 'label'
            d.should.have.property 'color'
            d.should.have.property 'hidden'

        display[2].color.should.equal '#00f'
        display[1].hidden.should.be.true
        display[0].label.should.equal 'Hello'
        display[2].label.should.equal 'series3'

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

        chart = new ForestD3.Chart()
        chart.data(data)

        api = chart.data()

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
            values: []
        ,
            key: 'series3'
            color: '#00f'
            label: 'Foo'
            values: []
        ]

        chart = new ForestD3.Chart()
        chart.data(data)

        chart.data().hide(['series2','series3'])

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

    it 'can get x value at certain index', ->
        data = [
            values: [
                [2, 10]
                [80, 100]
                [90, 101]
            ]
        ]
        chart = new ForestD3.Chart()
        chart.ordinal(true).data(data)

        chart.data().xValueAt(0).should.equal 2
        chart.data().xValueAt(1).should.equal 80
        chart.data().xValueAt(2).should.equal 90
        should.not.exist chart.data().xValueAt(4)

    it 'makes a copy of the data', ->
        data = [
            key: 'line1'
            type: 'line'
            values: [
                [0,0]
                [1,1]
                [2,4]
            ]
        ,
            key: 'line2'
            type: 'line'
            values: [
                [0,7]
                [1,8]
                [2,9]
            ]
        ]

        chart = new ForestD3.Chart()
        chart.data(data)

        internalData = chart.data().get()

        (internalData is data).should.be.false
        (internalData[0].values is data[0].values).should.be.false
        (internalData[1].values is data[1].values).should.be.false

    it 'accepts an object of objects as chart data', ->
        data =
            'line1':
                type: 'line'
                values: [
                    [0,0]
                    [1,1]
                    [2,4]
                ]
            'bar1':
                type: 'bar'
                values: [
                    [0,0]
                    [1,1]
                    [2,4]
                ]

        chart = new ForestD3.Chart()
        chart.data(data)

        internalData = chart.data().get()

        internalData.should.be.instanceof Array
        internalData[0].key.should.equal 'line1'
        internalData[0].values.should.deep.equal [
            [0,0]
            [1,1]
            [2,4]
        ]

        internalData[1].key.should.equal 'bar1'
        internalData[1].type.should.equal 'bar'

    describe 'Data Slice', ->
        it 'can get a slice of data at an index', ->
            data = [
                key: 'series1'
                label: 'Foo'
                color: '#000'
                values: [
                    [70, 10]
                    [80, 100]
                    [90, 101]
                ]
            ,
                key: 'series2'
                label: 'Bar'
                values: [
                    [70, 10]
                    [80, 800]
                    [90, 709]
                ]
            ,
                key: 'series3'
                label: 'Maz'
                color: '#0f0'
                values: [
                    [70, 12]
                    [80, 300]
                    [90, 749]
                ]
            ]

            chart = new ForestD3.Chart()
            chart.data(data)

            slice = chart.data().sliced(0)

            slice.length.should.equal 3, '3 items'

            slice[0].should.deep.equal
                x: 70
                y: 10
                key: 'series1'
                label: 'Foo'
                color: '#000'

            slice[2].y.should.equal 12

            slice = chart.data().sliced(2)

            yData = slice.map (d)-> d.y

            yData.should.deep.equal [101, 709, 749]

        it 'keeps hidden data out of slice', ->
            it 'can get a slice of data at an index', ->
            data = [
                key: 's1'
                values: [
                    [70, 10]
                    [80, 100]
                    [90, 101]
                ]
            ,
                key: 's2'
                values: [
                    [70, 10]
                    [80, 800]
                    [90, 709]
                ]
            ,
                key: 's3'
                values: [
                    [70, 12]
                    [80, 300]
                    [90, 749]
                ]
            ]

            chart = new ForestD3.Chart()
            chart.data(data)
            chart.data().hide(['s2','s3'])

            slice = chart.data().sliced(0)
            slice.length.should.equal 1, 'only one item'

    describe 'bar item api', ->
        data = [
            key: 's1'
            type: 'line'
            values: []
        ,
            key: 's2'
            type: 'bar'
            values: []
        ,
            key: 's3'
            type: 'line'
            values: []
        ,
            key: 's4'
            type: 'bar'
            values: []
        ,
            key: 's5'
            type: 'bar'
            values: []
        ]

        it 'can count number of bar items', ->
            chart = new ForestD3.Chart()
            chart.data(data)
            api = chart.data()

            api.hide 's5'
            api.barCount().should.equal 2, 'two visible bars'

            api.show 's5'
            api.barCount().should.equal 3, 'three bars visible'

        it 'can get the relative bar index', ->
            chart = new ForestD3.Chart()
            chart.data(data)
            api = chart.data()

            api.barIndex('s5').should.equal 2
            api.barIndex('s4').should.equal 1
            api.barIndex('s2').should.equal 0
            should.not.exist api.barIndex('s1')

            api.hide 's2'

            api.barIndex('s4').should.equal 0
            api.barIndex('s5').should.equal 1

    describe 'Update data', ->
        it 'can update the data values', ->
            data = [
                key: 's1'
                values: [
                    [1,1]
                    [2,1]
                ]
            ,
                key: 's2'
                values: [
                    [1,10]
                    [2,11]
                ]
            ]

            api = ForestD3.DataAPI data
            api.updateValues 's2', [
                [1, 13]
                [2, 14]
            ]

            api.get()[1].values.should.deep.equal [
                [1, 13]
                [2, 14]
            ]