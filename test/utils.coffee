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
                    [1,1]
                    [2,3]
                ]
            ,
                values: [
                    [1,1]
                    [0,5]
                ]
            ,
                values: [
                    [1,0.5]
                    [1.6,2.9]
                ]
            ]

            result = extent data

            result.should.deep.equal
                x: [0, 2]
                y: [0, 5]

        it 'rounds extent to nearest integer', ->
            data = [
                values: [
                    [0.1, 0.1]
                    [0.9, 0.9]
                ]
            ]

            result = extent data
            result.should.deep.equal
                x: [0, 1]
                y: [0, 1]

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

    describe 'Indexify', ->
        it 'adds _index to each series', ->
            data = [
                values: []
            ,
                values: []
            ,
                values: []
            ]

            result = ForestD3.Utils.indexify data

            for d, i in data
                d._index.should.equal i

    describe 'extentPadding', ->
        it 'increases the extent by a certain percentage', ->
            xyExtent =
                x: [-10, 10]
                y: [2, 5]

            padding =
                x: 0.1   # 10 percent
                y: 0.05  # 5 percent

            newExtent = ForestD3.Utils.extentPadding xyExtent, padding

            newExtent.should.deep.equal
                x: [-11, 11]
                y: [1.925, 5.075]

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

    describe 'isOrdinal', ->
        it 'has utility to check if function is an ordinal type', ->
            getX = (d,i)-> i

            result = ForestD3.Utils.isOrdinal getX
            result.should.equal true, 'yes, it is ordinal'

            getX = (d,i)-> d[0]

            result = ForestD3.Utils.isOrdinal getX

            result.should.equal false, 'no it is not ordinal'

