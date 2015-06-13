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
            container.style.width = '500px'
            container.style.height = '400px'
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

            svg = container.querySelector('svg')
            svg.should.exist 

            svg.getAttribute('width').should.equal '500'
            svg.getAttribute('height').should.equal '400'
            