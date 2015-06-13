module.exports = (grunt)->
    grunt.initConfig
        jade:
            examples:
                options:
                    pretty: true
                files:
                    'build/index.html': ['examples/index.jade']

        coffee:
            options:
                bare: false
            client:
                files: 
                    'dist/forest-d3.js': [
                        'src/main.coffee'
                        'src/chart.coffee'
                    ]
        karma:
            client:
                options:
                    browsers: ['Firefox']
                    frameworks: ['mocha', 'sinon-chai']
                    reporters: ['spec']
                    junitReporter:
                        outputFile: 'karma.xml'
                    singleRun: true
                    preprocessors:
                        'test/*.coffee': 'coffee'
                    files: [
                        'node_modules/d3/d3.js'
                        'dist/*.js'
                        'test/*.coffee'
                    ]

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-karma'

    grunt.registerTask 'test', ['coffee', 'karma']
    grunt.registerTask 'default', ['coffee', 'jade']

