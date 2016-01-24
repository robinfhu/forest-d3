describe 'Utilities', ->
    describe 'Extent', ->
        extent = null
        beforeEach ->
            extent = ForestD3.Utils.extent

        it 'exists and is a function', ->
            extent.should.exist
            extent.should.be.a.Function

        it 'handles empty case', ->
            result = extent []
            result.should.deep.equal
                x: [-1, 1]
                y: [-1, 1]

        it 'handles simple case', ->
            data = [
                values: [
                    [1,1]
                    [2,1]
                    [3,2]
                    [4,2]
                    [5,1.3]
                ]
            ]

            result = extent data

            result.should.deep.equal
                x: [1, 5]
                y: [1, 2]

        it 'handles multiple series', ->
            data = [
                values: [
                    [1,5]
                    [2,3]
                ]
            ,
                values: [
                    [1,7]
                    [0,5]
                ]
            ,
                values: [
                    [1,1]
                    [1.6,2.9]
                ]
            ]

            result = extent data

            result.should.deep.equal
                x: [0, 2]
                y: [1, 7]

        it 'rounds extent to nearest integer', ->
            data = [
                values: [
                    [5.1, 5.1]
                    [80.9, 8.9]
                ]
            ]

            result = extent data
            result.should.deep.equal
                x: [5, 81]
                y: [5, 9]

        it 'skips the integer rounding if extent range is small', ->
            data = [
                values: [
                    [0, -0.02]
                    [1, 0.8]
                ]
            ]

            result = extent data
            result.should.deep.equal
                x: [0, 1]
                y: [-0.02, 0.8]

        it 'factors in chart markers as part of the computation', ->
            data = [
                values: [
                    [0, 5]
                    [-3, 8]
                ]
            ,
                type: 'marker'
                axis: 'y'
                value: 10
            ,
                type: 'marker'
                axis: 'x'
                value: 1
            ]

            result = extent data

            result.should.deep.equal
                x: [-3, 1]
                y: [5, 10]

        it 'factors in region values as part of the computation', ->
            data = [
                values: [
                    [0, 5]
                    [-3, 8]
                ]
            ,
                type: 'region'
                axis: 'x'
                values: [-4, 1]
            ,
                type: 'region'
                axis: 'y'
                values: [3, 9]
            ]

            result = extent data

            result.should.deep.equal
                x: [-4, 1]
                y: [3, 9]

        it 'handles case where getter returns index', ->
            data = [
                values: [
                    [1,1]
                    [2,2]
                ]
            ,
                values: [
                    [3,3]
                    [4,4]
                ]
            ]

            getX = (d,i)-> i
            result = extent data, getX

            result.should.deep.equal
                x: [0,1]
                y: [1,4]

        it 'defaults to [-1,1] extent if no valid values', ->
            data = [
                type: 'marker'
                axis: 'y'
                value: 0.5
            ]

            result = extent data
            result.should.deep.equal
                x: [-1, 1]
                y: [0.5,0.5]

        it 'accepts a "force" property, forcing values onto the extent', ->
            data = [
                values: [
                    [-1,1]
                    [0,2]
                    [1,3]
                ]
            ]

            force =
                x: [0]
                y: [0]

            result = extent data, null, null, force

            result.should.deep.equal
                x: [-1, 1]
                y: [0, 3]

            force =
                x: -4
                y: 0

            result = extent data, null, null, force
            result.should.deep.equal
                x: [-4, 1]
                y: [0, 3]

    describe 'Indexify', ->
        it 'adds _index to each series', ->
            data = [
                key: 's1'
                values: []
            ,
                key: 's2'
                values: []
            ,
                key: 's3'
                values: []
            ]

            meta = {}
            result = ForestD3.Utils.indexify data, meta

            meta['s1'].index.should.equal 0
            meta['s2'].index.should.equal 1
            meta['s3'].index.should.equal 2

        it 'skips markers and regions', ->
            data = [
                key: 'm1'
                type: 'marker'
                value: 1
            ,
                key: 'm2'
                type: 'line'
                values: []
            ,
                key: 's1'
                type: 'scatter'
                values: []
            ,
                key: 's2'
                type: 'region'
                values: []
            ]

            meta = {}

            result = ForestD3.Utils.indexify data, meta

            should.not.exist meta['m1'].index
            meta['m2'].index.should.equal 0
            meta['s1'].index.should.equal 1
            should.not.exist meta['s2'].index

    describe 'extentPadding', ->
        extPadding = null
        beforeEach ->
            extPadding = ForestD3.Utils.extentPadding

        it 'increases the extent by a certain percentage', ->
            xyExtent =
                x: [-10, 10]
                y: [2, 5]

            padding =
                x: 0.1   # 10 percent
                y: 0.05  # 5 percent

            newExtent = extPadding xyExtent, padding

            newExtent.should.deep.equal
                x: [-11, 11]
                y: [1.925, 5.075]

        it 'handles cases where the extent values are the same', ->
            xyExtent =
                x: [0.2, 0.2]
                y: [0.2, 0.2]

            padding =
                x: 0.1
                y: 0.1

            newExtent = extPadding xyExtent, padding
            newExtent.x[0].toFixed(2).should.equal '0.19'
            newExtent.x[1].toFixed(2).should.equal '0.21'

        it 'handles case where extent is [0,0]', ->
            xyExtent =
                x: [0,0]
                y: [0,1]

            padding =
                x: 0.1
                y: 0

            newExtent = extPadding xyExtent, padding
            newExtent.should.deep.equal
                x: [-1, 1]
                y: [0, 1]

    describe 'smartBisect', ->
        smartBisect = null
        getX = (d,i)-> i
        beforeEach -> smartBisect = ForestD3.Utils.smartBisect

        it 'handles basic case', ->
            data = [0, 1, 2, 3, 4, 5]

            tests = [
                [0,0]
                [2,2]
                [2.5, 3]
                [2.51, 3]
                [5, 5]
                [7, 5]
                [-1, 0]
            ]

            for test, i in tests
                [search, expected] = test

                result = smartBisect data, search, getX

                result.should.equal expected, "Test case #{i}"

        it 'edge cases', ->
            result = smartBisect 'blah'
            should.not.exist result, 'result is null'

            result = smartBisect []
            should.not.exist result, 'result null if input empty array'

            result = smartBisect [1]
            result.should.equal 0, 'result is 0'

    describe 'tickValues', ->
        tickValues = null
        beforeEach -> tickValues = ForestD3.Utils.tickValues

        it 'handles one or two ticks', ->
            result = tickValues [0], 100

            result.should.deep.equal [0]

            result = tickValues [0,1], 100

            result.should.deep.equal [0,1]

        it 'xValues is less than numTicks', ->
            result = tickValues [0,1,2,3,4], 10
            result.should.deep.equal [0,1,2,3,4]

        it 'numTicks is 3', ->
            result = tickValues [0,1,2,3,4], 3
            result.should.deep.equal [0,2,4]

        it 'numTicks is 5', ->
            width = 2
            result = tickValues [0..10], 4, width
            result.should.deep.equal [0, 3, 6, 10]

