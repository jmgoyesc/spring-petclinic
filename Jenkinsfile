pipeline {
  agent any
  
  stages {
    
    stage("test") {
      steps {
        echo "testing application"
      }
    }
    
    stage("quality-checks") {
      steps {
        echo "checking application"
      }
    }
    
    stage("build-jvm") {
      steps {
        echo "building application"
      }
    }
    
    stage("build-image") {
      steps {
        echo "creating image"
      }
    }
    
    stage("deploy") {
      steps {
        echo "deploying application"
      }
    }
    
  }
  
}
