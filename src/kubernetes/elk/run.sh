# minikube start
minikube start --vm-driver=hyperkit --cpus 6 --memory 8192

# enable minikube plugins
minikube addons enable ingress
minikube addons enable default-storageclass
minikube addons enable storage-provisioner

# 1. (datasource) install elastic search
helm repo add elastic https://helm.elastic.co
helm install elasticsearch elastic/elasticsearch -f ./elastic-values.yaml

# 2. install logstash
helm install logstash elastic/logstash -f ./logstash-values.yaml

# 3. install kibana
helm install kibana elastic/kibana -f ./kibana-values.yaml


#######
# test local pipeline
#install logstash locally
brew tap elastic/tap
brew install elastic/tap/logstash-full
brew services start elastic/tap/logstash-full

./mvnw spring-boot:run

#
logstash -f ./logstash.pipeline.conf
