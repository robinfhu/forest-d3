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
