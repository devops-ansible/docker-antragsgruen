node {

    def built_image

    def baseimage = 'jugendpresse/apache:php-7.2'

    def image = 'jugendpresse/docker-antragsgruen'

    def gitrepository = 'https://github.com/CatoTH/antragsgruen.git'
    def gitbranch     = 'master'
    def begin_commit  = 'eaf83c00'

    def built_tags = []
    def build_tags = []
    def repo       = ''
    def git_push   = false

    stage('GIT preparation') {
        /* Clone current Dockerfile & Jenkinsfile repository */
        def scmVar = checkout scm
        repo = scmVar.GIT_URL
        repo = repo.replaceAll(~/https:\/\//, "")
        built_tags = readJSON file: 'built_tags.json'
        /* Clone current project */
        sh 'git clone ' + gitrepository + ' --branch ' + gitbranch + ' --single-branch ' + 'app/'
        build_tags = sh(
                script: 'cd app && git tag --contains ' + begin_commit + ' && cd ..',
                returnStdout: true
            ).split('\n')
    }

    for (int i = 0; i < build_tags.length; i++) {
        if (built_tags[build_tags[i]]) {
            // Already exists – do nothing at the moment
        }
        else {
            git_push = true

            def now = new Date()
            built_tags[build_tags[i]] = now.format("yyyy-MM-dd HH:mm:ss", TimeZone.getTimeZone('Europe/Berlin'))
        }
        // stage("Test ${tests[i]}") {
        //     sh '....'
        // }
    }

    stage('clean up') {
        sh 'rm -rf app/'
        if (git_push) {
            writeJSON file: 'built_tags.json', json: built_tags, pretty: 4
            withCredentials([usernamePassword(credentialsId: 'jpdtechnicaluser', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                sh(
                    'git config user.name Jenkins && ' +
                    'git config user.email server@jugendpresse.de && ' +
                    'git add built_tags.json && ' +
                    'git commit -m "Jenkins: automated build from ' + built_tags[build_tags[ build_tags.length - 1 ]] + '" &&' +
                    'git push https://${GIT_USERNAME}:${GIT_PASSWORD}@' + repo
                )
            }
        }
    }
    //
    // def version = 'latest'
    //
    // def old_layers
    // def new_layers
    //
    // stage('Fetch existing latest docker image') {
    //     /* Pulls current live image and determines layer ids of that image */
    //     try {
    //         def old_image = docker.image( image + ':' + version ).pull()
    //         def json = sh ( returnStdout: true, script: 'docker inspect ' + image + ':' + version )
    //         def data = readJSON text: json
    //         old_layers = data[0]['RootFS']['Layers']
    //     } catch (exc) {
    //         old_layers = readJSON text: '[]'
    //     }
    // }
    //
    // stage('Build latest image') {
    //     /* This builds the actual image; synonymous to
    //      * docker build on the command line */
    //     docker.image( baseimage ).pull()
    //     built_image = docker.build(image + ':' + version)
    // }
    //
    // stage('Check latest Image-Layers') {
    //     def json = sh ( returnStdout: true, script: 'docker inspect ' + image + ':' + version )
    //     def data = readJSON text: json
    //     new_layers = data[0]['RootFS']['Layers']
    // }
    //
    // if ( old_layers != new_layers ) {
    //     stage('Push develop image') {
    //         /* Finally, we'll push the image with two tags:
    //          * First, the date of the build
    //          * Second, the 'latest' tag.
    //          * Pushing multiple tags is cheap, as all the layers are reused. */
    //
    //         withCredentials([usernamePassword( credentialsId: 'jpdtechnicaluser', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
    //
    //             docker.withRegistry('', 'jpdtechnicaluser') {
    //                 sh "docker login -u ${USERNAME} -p ${PASSWORD}"
    //                 def date = new Date().format( 'yyyyMMdd-HHmm' )
    //                 built_image.push()
    //                 built_image.push( 'dev_' + date )
    //             }
    //         }
    //     }
    // }
}
