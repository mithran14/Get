pipeline {
  agent any
  stages {
    stage('Full pipeline') {
      steps {
        sh '''pipeline {
    agent any
    
    environment {
        DEV_SERVER_IP = \'52.66.178.147\'
        TEST_SERVER_IP = \'3.108.60.202\'
        QA_SERVER_IP = \'3.110.212.41\'
    }

    stages {
        stage(\'Dev Deployment and Run\') {
            steps {

                // SSH into dev server
                sshagent([\'dev-ssh-credentials\']) {
                    sh \'\'\'
                    ssh -o StrictHostKeyChecking=no ubuntu@${DEV_SERVER_IP} \'
                        # Kill Java process
                        sudo fuser -k 80/tcp
                        # Clone the repository if not already done
                        if [ ! -d .git ]; then
                            git clone https://github.com/TestLeafInc/jenkins-pipeline
                        fi
                        # Pull latest code
                        cd /home/ubuntu/jenkins-pipeline/leafhub
                        git pull
                        # Store commit ID
                        export COMMIT_ID=$(git rev-parse HEAD)
                        # Run maven spring boot
                        nohup sudo mvn spring-boot:run > /dev/null 2>&1 &
                    \'
                    \'\'\'
                }
            }
        }
        
         stage(\'Smoke Test on Dev\') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo(\'SUCCESS\') }
            }
            steps {
                // This will pause the pipeline for 30 seconds for the dev server to be ready
                sleep(10)
                
                sshagent([\'dev-ssh-credentials\']) {
                    sh \'\'\'
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER_IP} \'
                    
                    # Update the package lists for upgrades and new package installations
                    sudo apt-get update

                    # Install OpenJDK 8
                    sudo apt-get install -y openjdk-8-jdk

                    # Install Maven
                    sudo apt-get install -y maven

                    # Install xvfb
                    sudo apt-get install -y xvfb

                    # Start xvfb
                    Xvfb :99 &
                    export DISPLAY=:99

                    # Download and install Google Chrome
                    if ! command -v google-chrome > /dev/null; then
                    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
                    sudo dpkg -i google-chrome-stable_current_amd64.deb
                    sudo apt --fix-broken install -y
                    else
                    echo "Google Chrome is already installed."
                    fi


                    # Clone the webdriver-tests repository
                    git clone https://github.com/TestLeafInc/webdriver-leafhub

                    # Move to the webdriver-tests folder
                    cd webdriver-leafhub

                    # pull the changes if any
                    git pull

                    # Run Maven tests
                    mvn clean test -DsuiteXmlFile=smoke.xml -Dserver.ip=52.66.178.147
                            
                    yes | sudo apt install awscli                                                       
                    aws configure set aws_access_key_id AKIA2ZLFKTOADE5HKO5U
                    aws configure set aws_secret_access_key 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
                    aws configure set region ap-south-1
                    aws configure set output json
    
                    # Push the results to S3 (make sure to install and configure awsconfigure before)
                    #aws s3 rb s3://reports12-html12-selenium12 --force
                    aws s3api create-bucket --bucket smoke024 --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1
                    aws s3 sync reports/ s3://smoke024
                    
                       
                    \'
                    \'\'\'
                }
            }
        }
        
        stage(\'QA Deployment\') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo(\'SUCCESS\') }
            }
            steps {

                // SSH into qa server
                sshagent([\'dev-ssh-credentials\']) {
                    sh \'\'\'
                    ssh -o StrictHostKeyChecking=no ubuntu@${QA_SERVER_IP} \'
                    
                        # Kill Java process
                        sudo fuser -k 80/tcp
                        
                        # Clone the repository if not already done
                        if [ ! -d .git ]; then
                            git clone https://github.com/TestLeafInc/jenkins-pipeline
                        fi
                        
                        # Change directory to the git repo
                        cd jenkins-pipeline
                        
                        # Checkout the specified commit
                        git checkout $COMMIT_ID
                        
                        # Change directory to leafhub
                        cd leafhub
                    
                        # Run maven spring boot
                        nohup sudo mvn spring-boot:run > /dev/null 2>&1 &
                    \'
                    \'\'\'
                }
            }
        }
        stage(\'Sanity API Tests on QA\') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo(\'SUCCESS\') }
            }
            steps {
                // This will pause the pipeline for 30 seconds for the dev server to be ready
                sleep(10)
                
                sshagent([\'dev-ssh-credentials\']) {
                    sh \'\'\'
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER_IP} \'
                    
                    # Update the package lists for upgrades and new package installations
                    sudo apt-get update

                    # Install OpenJDK 8
                    sudo apt-get install -y openjdk-8-jdk

                    # Install Maven
                    sudo apt-get install -y maven

                    # Clone the webdriver-tests repository
                    git clone https://github.com/mithran14/api-leafhub-tests

                    # Move to the webdriver-tests folder
                    cd api-leafhub-tests

                    # pull the changes if any
                    git pull
                    
                    # Create report directory
                    mkdir reports
                    
                    # Run Maven tests
                    mvn clean test

                    yes | sudo apt install awscli                                                       
                    aws configure set aws_access_key_id AKIA2ZLFKTOADE5HKO5U
                    aws configure set aws_secret_access_key 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
                    aws configure set region ap-south-1
                    aws configure set output json
    
                    # Push the results to S3 (make sure to install and configure awsconfigure before)
                    #aws s3 rb s3://reports12-html12-selenium12 --force
                    aws s3api create-bucket --bucket api024 --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1
                    aws s3 sync reports/ s3://api024
                       
                    \'
                    \'\'\'
                }
            }
        }
        stage(\'Sanity Web Tests on QA\') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo(\'SUCCESS\') }
            }
            steps {
                // This will pause the pipeline for 30 seconds for the dev server to be ready
                sleep(10)
                
                sshagent([\'dev-ssh-credentials\']) {
                    sh \'\'\'
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER_IP} \'
                    
                    # Update the package lists for upgrades and new package installations
                    sudo apt-get update

                    # Install OpenJDK 8
                    sudo apt-get install -y openjdk-8-jdk

                    # Install Maven
                    sudo apt-get install -y maven

                    # Install xvfb
                    sudo apt-get install -y xvfb

                    # Start xvfb
                    Xvfb :99 &
                    export DISPLAY=:99

                    # Download and install Google Chrome
                    if ! command -v google-chrome > /dev/null; then
                    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
                    sudo dpkg -i google-chrome-stable_current_amd64.deb
                    sudo apt --fix-broken install -y
                    else
                    echo "Google Chrome is already installed."
                    fi


                    # Clone the webdriver-tests repository
                    git clone https://github.com/mithran14/api-leafhub-tests

                    # Move to the webdriver-tests folder
                    cd webdriver-leafhub

                    # pull the changes if any
                    git pull
                    
                    # Run Maven tests
                    mvn clean test -DsuiteXmlFile=sanity.xml -Dserver.ip=3.110.212.41

                    yes | sudo apt install awscli                                                       
                    aws configure set aws_access_key_id AKIA2ZLFKTOADE5HKO5U
                    aws configure set aws_secret_access_key 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
                    aws configure set region ap-south-1
                    aws configure set output json
    
                    # Push the results to S3 (make sure to install and configure awsconfigure before)
                    #aws s3 rb s3://reports12-html12-selenium12 --force
                    aws s3api create-bucket --bucket sanity024 --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1
                    aws s3 sync reports/ s3://sanity024
                       
                    \'
                    \'\'\'
                }
            }
        }

    }
}'''
        }
      }

    }
  }