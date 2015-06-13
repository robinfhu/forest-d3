describe 'Smoke Tests', ->
    it 'd3 should exist', ->
        expect(d3).to.exist
        d3.version.should.equal '3.5.5'
        