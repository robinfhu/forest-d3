describe 'Data API', ->
    it 'should have ability to get raw data', ->
        api = ForestD3.DataAPI [1,2,3]

        api.get().should.deep.equal [1,2,3]

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

    it 'showOnly accepts "onlyDataSeries" option', ->
        data = [
            key: 'series1'
            label: 'Hello'
            values: []
        ,
            key: 'series2'
            label: 'World'
            values: []
        ,
            key: 'seriesMarker'
            type: 'marker'
            value: 0
        ,
            key: 'seriesRegion'
            type: 'region'
            values: [0,1]
        ,
            key: 'series3'
            color: '#00f'
            label: 'Foo'
            values: []
        ]

        chart = new ForestD3.Chart()
        chart.data(data)

        api = chart.data()

        api.showOnly 'series2', {onlyDataSeries: true}
        visible = api.visible()

        visible.length.should.equal 3, '3 visible'
        visible[0].key.should.equal 'series2'
        visible[1].key.should.equal 'seriesMarker'
        visible[2].key.should.equal 'seriesRegion'

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
        chart.ordinal(false).data(data)

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
        internalData[0].type.should.equal 'line'

        internalData[1].key.should.equal 'bar1'
        internalData[1].type.should.equal 'bar'

    it 'converts data to consistent format internally', ->
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
        internalData[0].values[0].x.should.equal 0
        internalData[0].values[0].y.should.equal 0

        internalData[1].values[2].x.should.equal 2
        internalData[1].values[2].y.should.equal 4

        internalData[1].values[2].data.should.deep.equal [2,4]

    it 'calculates the x,y extent of each series', ->
        data = [
            type: 'line'
            values: [
                [-3,4]
                [0,6]
                [4,8]
            ]
        ,
            type: 'line'
            values: [
                [4,-1]
                [5,3]
                [6,2]
            ]
        ,
            type: 'marker'
            axis: 'x'
            value: 30
        ,
            type: 'marker'
            axis: 'y'
            value: 40
        ,
            type: 'region'
            axis: 'x'
            values: [3,10]
        ,
            type: 'region'
            axis: 'y'
            values: [-10,11]
        ]

        chart = new ForestD3.Chart()
        chart.ordinal(true).data(data)
        internalData = chart.data().get()

        internalData[0].extent.should.deep.equal
            x: [0,2]
            y: [4,8]

        internalData[1].extent.should.deep.equal
            x: [0,2]
            y: [-1,3]

        internalData[2].extent.should.deep.equal
            x: [30]
            y: []

        internalData[3].extent.should.deep.equal
            x: []
            y: [40]

        internalData[4].extent.should.deep.equal
            x: [3,10]
            y: []

        internalData[5].extent.should.deep.equal
            x: []
            y: [-10,11]

    it 'fills in key and label if not defined', ->
        data = [
            values: []
        ,
            values: []
        ,
            values: []
        ]

        chart = new ForestD3.Chart()
        chart.data(data)
        internalData = chart.data().get()

        internalData[0].key.should.equal 'series0'
        internalData[0].label.should.equal 'Series #0'

        internalData[1].key.should.equal 'series1'
        internalData[1].label.should.equal 'Series #1'


        internalData[2].key.should.equal 'series2'
        internalData[2].label.should.equal 'Series #2'
        internalData[2].type.should.equal 'scatter'

    it 'automatically adds color and index field to each series', ->
        data = [
            values: []
        ,
            color: '#00f'
            values: []
        ,
            type: 'marker'
            value: 30
        ,
            values: []
        ,
            values: []
        ,
            values: []
        ]

        colors = [
            "#1f77b4",
            "#aec7e8",
            "#ff7f0e",
            "#ffbb78",
            "#2ca02c",
            "#98df8a"
        ]

        chart = new ForestD3.Chart()
        chart.colorPalette(colors).data(data)
        internalData = chart.data().get()
        internalData[0].color.should.equal '#1f77b4'
        internalData[1].color.should.equal '#00f'
        should.not.exist internalData[2].color
        internalData[3].color.should.equal '#aec7e8'
        internalData[4].color.should.equal '#ff7f0e'
        internalData[5].color.should.equal '#ffbb78'

        internalData[0].index.should.equal 0
        internalData[1].index.should.equal 1
        should.not.exist internalData[2].index
        internalData[3].index.should.equal 2
        internalData[4].index.should.equal 3
        internalData[5].index.should.equal 4

    it 'auto sorts data by x value ascending', ->
        getPoints = ->
            points = [0...50].map (i)->
                x: i
                y: Math.random()

            d3.shuffle points
            points
        data =
            series1:
                type: 'line'
                values: getPoints()
            series2:
                type: 'line'
                values: getPoints()

        chart = new ForestD3.Chart()
        chart
            .getX((d)->d.x)
            .getY((d)->d.y)
            .ordinal(false)
            .autoSortXValues(true)
            .data(data)

        internal = chart.data().get()

        internalXVals = internal[0].values.map (d)-> d.x
        internalXVals.should.deep.equal [0...50]

        internalXVals = internal[1].values.map (d)-> d.x
        internalXVals.should.deep.equal [0...50]

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
                    [70, 11]
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

            slice[0].y.should.equal 10
            slice[0].series.label.should.equal 'Foo'
            slice[0].series.color.should.equal '#000'

            slice[1].y.should.equal 11
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
