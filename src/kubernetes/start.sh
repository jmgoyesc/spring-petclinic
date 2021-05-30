# Start minikube (none for VM), hyperkit for MacOS
#minikube start --vm-driver=none
minikube start --vm-driver=hyperkit --cpus 6 --memory 8192

# enable ingress in minikube
minikube addons enable ingress
alias k="kubectl"

# add helm repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add oteemocharts https://oteemo.github.io/charts
helm repo add jenkins https://charts.jenkins.io
helm repo update

# start postgresql for sonarqube
helm install postgres -f helm/psql-values.yaml bitnami/postgresql

# start sonar-qube
helm install sonarqube -f helm/sonar-values.yaml oteemocharts/sonarqube

# start jenkins
kubectl create ns jenkins
helm install -n jenkins jenkins jenkins/jenkins

# apply ingress for jenkins, sonar, petclinic
kubectl apply -f global.ingress.yaml
