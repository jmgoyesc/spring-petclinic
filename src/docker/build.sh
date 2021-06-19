#build project
./mvnw package
mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)
docker build . -t  jmgoyesc/juan-goyes-petclinic -f ./src/docker/Dockerfile
