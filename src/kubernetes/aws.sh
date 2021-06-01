# update OS
sudo apt-get update -y

#install kubectl
# url. https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# install docker
sudo apt-get update && sudo apt-get install docker.io -y

# install minikube
# url. https://minikube.sigs.k8s.io/docs/start/
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version

#switch to root and start minikube
sudo -i

sudo apt-get install -y conntrack
minikube start --vm-driver=none
minikube status

# enable ingress in minikube
minikube addons enable ingress
minikube addons enable metrics-server
alias k="kubectl"

#install helm
# url. https://helm.sh/docs/intro/install/
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

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
helm install -n jenkins -f helm/jenkins-values.yaml jenkins jenkins/jenkins

# apply ingress for jenkins, sonar, petclinic
kubectl apply -f global.ingress.yaml

# enable docker sock
chmod 777 /var/run/docker.sock
