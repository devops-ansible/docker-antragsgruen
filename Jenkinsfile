node {

    def built_image

    def baseimage = 'jugendpresse/apache'

    def image = 'jugendpresse/docker-antragsgruen'

    def gitrepository = 'https://github.com/CatoTH/antragsgruen.git'
    def gitbranch     = 'master'
    def begin_commit  = 'eaf83c00'

    def built_tags = []
    def build_tags = []
    def scm_repo   = ''
    def scm_push   = false
    def scm_branch = ''

    def version = 'latest'

    stage('prepare run') {
        /* pull current version of base image */
        docker.image( baseimage ).pull()
        /* Clone current Dockerfile & Jenkinsfile repository */
        def scmVar = checkout scm
        /* build variables for further work in clean up stage */
        scm_repo   = scmVar.GIT_URL
        scm_repo   = scm_repo.replaceAll(~/https:\/\//, "")
        scm_branch = scmVar.GIT_BRANCH
        int ind = scm_branch.lastIndexOf("/")
        if ( ind >= 0 ) {
            scm_branch = new StringBuilder(scm_branch).replace(0, ind+1, "").toString()
        }
        built_tags = readJSON file: 'built_tags.json'
        /* Clone current project */
        sh 'rm -rf app && git clone ' + gitrepository + ' --branch ' + gitbranch + ' --single-branch app/'
        build_tags = sh(
                script: 'cd app && git fetch --tags && git tag --contains ' + begin_commit + ' && cd ..',
                returnStdout: true
            ).split('\n')
    }

    stage('build docker images for tags not already built') {
        def vtag
        int ind
        for (int i = 0; i < build_tags.length; i++) {
            vtag = ''
            if (built_tags[build_tags[i]]) {
                // Already exists – do nothing at the moment
                // echo "Tag " + build_tags[i] + " already built on " + built_tags[build_tags[i]]
            }
            else {
                echo "Tag " + build_tags[i] + " to be built now."

                scm_push = true

                sh 'cd app && git checkout ' + build_tags[i] + ' && mv .git ../app.git && cd ..'

                built_image = docker.build(image + ':' + build_tags[i])
                withCredentials([usernamePassword( credentialsId: 'jpdtechnicaluser', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    docker.withRegistry('', 'jpdtechnicaluser') {
                        sh "docker login -u ${USERNAME} -p ${PASSWORD}"
                        built_image.push()
                        if (build_tags[i] =~ /^v[0-9]+\.[0-9]+\.[0-9]+$/) {
                            ind = build_tags[i].lastIndexOf(".")
                            vtag = build_tags[i]
                            while ( ind > 0 ) {
                                vtag = new StringBuilder(vtag).substring(0, ind).toString()
                                built_image.push(vtag)
                                ind = vtag.lastIndexOf(".")
                            }
                            built_image.push(version)
                        }
                    }
                }
                built_image = null

                sh 'mv app.git app/.git'

                def now = new Date()
                built_tags[build_tags[i]] = now.format("yyyy-MM-dd HH:mm:ss", TimeZone.getTimeZone('Europe/Berlin'))
            }
        }
    }

    version = 'development'

    def old_layers
    def new_layers

    stage('Fetch existing ' + version + ' docker image') {
        /* Pulls current live image and determines layer ids of that image */
        try {
            def old_image = docker.image( image + ':' + version ).pull()
            def json = sh ( returnStdout: true, script: 'docker inspect ' + image + ':' + version )
            def data = readJSON text: json
            old_layers = data[0]['RootFS']['Layers']
        } catch (exc) {
            old_layers = readJSON text: '[]'
        }
    }

    stage('Build ' + version + ' image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */
        built_image = docker.build(image + ':' + version)
    }

    stage('Check ' + version + ' Image-Layers') {
        def json = sh ( returnStdout: true, script: 'docker inspect ' + image + ':' + version )
        def data = readJSON text: json
        new_layers = data[0]['RootFS']['Layers']
    }

    if ( old_layers != new_layers ) {
        stage('Push ' + version + ' image') {
            /* Finally, we'll push the image with two tags:
             * First, the date of the build
             * Second, the version tag.
             * Pushing multiple tags is cheap, as all the layers are reused. */

            withCredentials([usernamePassword( credentialsId: 'jpdtechnicaluser', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {

                docker.withRegistry('', 'jpdtechnicaluser') {
                    sh "docker login -u ${USERNAME} -p ${PASSWORD}"
                    def date = new Date().format( 'yyyyMMdd-HHmm' )
                    built_image.push()
                    built_image.push( 'dev_' + date )
                }
            }
        }
    }

    stage('clean up') {
        sh 'rm -rf app/'
        if (scm_push) {
            writeJSON file: 'built_tags.json', json: built_tags, pretty: 4
            withCredentials([usernamePassword(credentialsId: 'jpdtechnicaluser', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                sh(
                    'git config user.name Jenkins && ' +
                    'git config user.email server@jugendpresse.de && ' +
                    'git add built_tags.json && ' +
                    'git commit -m "Jenkins: automated build from ' + built_tags[build_tags[ build_tags.length - 1 ]] + '" &&' +
                    'git push https://${GIT_USERNAME}:${GIT_PASSWORD}@' + scm_repo + ' HEAD:' + scm_branch
                )
            }
        }
    }
}
