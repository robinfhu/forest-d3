module.exports = (grunt)->
    grunt.initConfig
        jade:
            examples:
                options:
                    pretty: true
                files:
                    'build/index.html': ['examples/index.jade']

    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.registerTask 'default', ['jade']

