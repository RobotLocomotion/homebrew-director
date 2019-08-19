#!/usr/bin/env groovy

/*
 * Copyright (c) 2018, Massachusetts Institute of Technology.
 * Copyright (c) 2018, Toyota Research Institute.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

pipeline {
    agent none
    environment {
        CLICOLOR_FORCE = 1
        HOMEBREW_COLOR = 1
        HOMEBREW_GIT_EMAIL = 'drake-jenkins-bot@users.noreply.github.com'
        HOMEBREW_GIT_NAME = 'drake-jenkins-bot'
        HOMEBREW_GITHUB_API_TOKEN = credentials('d7b9b34c-01c9-48fa-ad91-e0516cf6e817')
        HOMEBREW_NO_ANALYTICS = 1
        HOMEBREW_NO_AUTO_UPDATE = 1
        HOMEBREW_NO_EMOJI = 1
    }
    options {
        ansiColor('xterm')
        timeout(time: 3, unit: 'HOURS')
        timestamps()
    }
    stages {
        stage('brew test-bot') {
            parallel {
                stage('high sierra') {
                    agent {
                       label 'mac-high-sierra-unprovisioned'
                    }
                    environment {
                       PATH = "/usr/local/bin:/usr/local/sbin:${env.PATH}"
                    }
                    steps {
                        sh 'brew update-reset'
                        sh 'brew cask install adoptopenjdk xquartz'
                        sh 'brew cleanup'
                        sh 'brew tap homebrew/test-bot'
                        sh "brew test-bot --git-email=${env.HOMEBREW_GIT_EMAIL} --git-name=${env.HOMEBREW_GIT_NAME} --root-url=https://drake-homebrew.csail.mit.edu/bottles"
                    }
                    post {
                        always {
                            junit(
                                allowEmptyResults: true,
                                testResults: 'brew-test-bot.xml'
                            )
                            s3Upload(
                                consoleLogLevel: 'INFO',
                                dontWaitForConcurrentBuildCompletion: true,
                                entries: [
                                    [
                                        bucket: 'drake-jenkins-artifacts',
                                        managedArtifacts: true,
                                        selectedRegion: 'us-east-1',
                                        sourceFile: '*.bottle.*',
                                        uploadFromSlave: true
                                    ]
                                ],
                                pluginFailureResultConstraint: 'FAILURE',
                                profileName: 'jenkins',
                                userMetadata: [
                                    [key: 'build-number', value: env.BUILD_NUMBER],
                                    [key: 'build-tag', value: env.BUILD_TAG],
                                    [key: 'build-url', value: env.BUILD_URL],
                                    [key: 'git-author-email', value: env.GIT_AUTHOR_EMAIL],
                                    [key: 'git-author-name', value: env.GIT_AUTHOR_NAME],
                                    [key: 'git-branch', value: env.GIT_BRANCH],
                                    [key: 'git-commit', value: env.GIT_COMMIT],
                                    [key: 'git-committer-email', value: env.GIT_COMMITTER_EMAIL],
                                    [key: 'git-committer-name', value: env.GIT_COMMITTER_NAME],
                                    [key: 'git-previous-commit', value: env.GIT_PREVIOUS_COMMIT],
                                    [key: 'git-previous-successful-commit', value: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT],
                                    [key: 'git-url', value: env.GIT_URL],
                                    [key: 'job-name', value: env.JOB_NAME],
                                    [key: 'job-url', value: env.JOB_URL]
                                ]
                            )
                            deleteDir()
                            dir("${env.WORKSPACE}@tmp") {
                                deleteDir()
                            }
                        }
                    }
                }
                stage('mojave') {
                    agent {
                       label 'mac-mojave-unprovisioned'
                    }
                    environment {
                       PATH = "/usr/local/bin:/usr/local/sbin:${env.PATH}"
                    }
                    steps {
                        sh 'brew update-reset'
                        sh 'brew cask install adoptopenjdk xquartz'
                        sh 'brew cleanup'
                        sh 'brew tap homebrew/test-bot'
                        sh "brew test-bot --git-email=${env.HOMEBREW_GIT_EMAIL} --git-name=${env.HOMEBREW_GIT_NAME} --root-url=https://drake-homebrew.csail.mit.edu/bottles"
                    }
                    post {
                        always {
                            junit(
                                allowEmptyResults: true,
                                testResults: 'brew-test-bot.xml'
                            )
                            s3Upload(
                                consoleLogLevel: 'INFO',
                                dontWaitForConcurrentBuildCompletion: true,
                                entries: [
                                    [
                                        bucket: 'drake-jenkins-artifacts',
                                        managedArtifacts: true,
                                        selectedRegion: 'us-east-1',
                                        sourceFile: '*.bottle.*',
                                        uploadFromSlave: true
                                    ]
                                ],
                                pluginFailureResultConstraint: 'FAILURE',
                                profileName: 'jenkins',
                                userMetadata: [
                                    [key: 'build-number', value: env.BUILD_NUMBER],
                                    [key: 'build-tag', value: env.BUILD_TAG],
                                    [key: 'build-url', value: env.BUILD_URL],
                                    [key: 'git-author-email', value: env.GIT_AUTHOR_EMAIL],
                                    [key: 'git-author-name', value: env.GIT_AUTHOR_NAME],
                                    [key: 'git-branch', value: env.GIT_BRANCH],
                                    [key: 'git-commit', value: env.GIT_COMMIT],
                                    [key: 'git-committer-email', value: env.GIT_COMMITTER_EMAIL],
                                    [key: 'git-committer-name', value: env.GIT_COMMITTER_NAME],
                                    [key: 'git-previous-commit', value: env.GIT_PREVIOUS_COMMIT],
                                    [key: 'git-previous-successful-commit', value: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT],
                                    [key: 'git-url', value: env.GIT_URL],
                                    [key: 'job-name', value: env.JOB_NAME],
                                    [key: 'job-url', value: env.JOB_URL]
                                ]
                            )
                            deleteDir()
                            dir("${env.WORKSPACE}@tmp") {
                                deleteDir()
                            }
                        }
                    }
                }
            }
        }
    }
}
