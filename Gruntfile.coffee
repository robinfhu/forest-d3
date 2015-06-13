module.exports = (grunt)->
    grunt.initConfig
        jade:
            examples:
                options:
                    pretty: true
                files:
                    'build/index.html': ['examples/index.jade']
        stylus:
            client:
                files:
                    'dist/forest-d3.css': ['style/*.styl']

        coffee:
            options:
                bare: false
            client:
                files: 
                    'dist/forest-d3.js': [
                        'src/main.coffee'
                        'src/chart.coffee'
                    ]

                    'build/app.js': [
                        'examples/app.coffee'
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
                        'node_modules/jquery/dist/jquery.js'
                        'dist/*.js'
                        'test/*.coffee'
                    ]

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-contrib-stylus'
    grunt.loadNpmTasks 'grunt-karma'

    grunt.registerTask 'test', ['coffee', 'karma']
    grunt.registerTask 'default', ['coffee', 'stylus', 'karma','jade']

