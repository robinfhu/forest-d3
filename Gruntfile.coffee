module.exports = (grunt)->
    grunt.initConfig
        jade:
            examples:
                options:
                    pretty: true
                files:
                    'build/index.html': ['examples/index.jade']

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
                        'test/*.coffee'
                    ]

    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-karma'

    grunt.registerTask 'test', ['karma']
    grunt.registerTask 'default', ['jade']

