describe 'Chart', ->
    describe 'State and Event management', ->
        chart = null
        beforeEach ->
            data = [
                key: 's1'
                values: [
                    [1,1]
                ]
            ,
                key: 's2'
                values: [
                    [1,2]
                ]
            ,
                key: 's3'
                values: [
                    [1,3]
                ]
            ]

            container = document.createElement 'div'
            container.style.width = '500px'
            container.style.height = '400px'
            chart = new ForestD3.Chart container
            chart.data(data)

        afterEach -> chart.destroy()

        it 'has `on` and `trigger` methods', ->
            should.exist chart.on
            should.exist chart.trigger

        it 'fires `rendered` event which contains current state', ->
            spy = sinon.spy()

            chart.on 'rendered', spy

            chart.data().hide('s2')
            chart.render()

            spy.should.have.been.calledOnce
