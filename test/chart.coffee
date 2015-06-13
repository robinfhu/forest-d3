describe 'Chart', ->
    describe 'smoke tests', ->
        it 'should exist', ->
            expect(ForestD3).to.exist
            expect(ForestD3.Chart).to.exist

    describe 'chart API', ->
        chart = null
        container = null

        beforeEach ->
            container = document.createElement 'div'
            document.body.appendChild container 

        afterEach ->
            document.body.removeChild container

        it 'can accept container DOM', ->
            chart = new ForestD3.Chart()

            chart.container.should.exist
            chart.container container

            chart.container().querySelector.should.exist

        it 'can render an <svg> element (only once)', ->
            chart = new ForestD3.Chart container 

            chart.render.should.exist
            chart.render()

            container.querySelector('svg').should.exist

            chart.render()

            container.querySelectorAll('svg').length.should.equal 1