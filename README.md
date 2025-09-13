### Description

Project that deploy three API to AWS EKS.

### Project configurations

- Provide a mongo string connection for env variable MONGODB_CONNECTION_URI in kubernetes/users.yaml
- It's necessary create a EFS file system in AWS and change the VolumeHander parameter in kubernetes/users.yaml
- You can run it locally using docker-compose its just need to configure the env variables

### Attention points

- Building images in MacOS (locally): Remember to select the arm64 arch in worker nodes in AWS.
- You need allow an access point to use kubectl locally

### Steps before run

- Create a mongoDB cluster in Mongo Atlas
- Create the EKS cluster in AWS
- Configure AWS CLI in your machine
- Configure Docker in your machine

### How to run

- build images (examples, change the tag and repo)
  `docker build -t vitorvsv/eks-deploy-auth-api:latest auth-api/.`
  `docker build -t vitorvsv/eks-deploy-users-api:latest users-api/.`
  `docker build -t vitorvsv/eks-deploy-tasks-api:latest tasks-api/.`

- push your images (Docker Hub)
  `docker push vitorvsv/eks-deploy-auth-api:latest`
  `docker push vitorvsv/eks-deploy-users-api:latest`
  `docker push vitorvsv/eks-deploy-tasks-api:latest`

- apply yamls in the cluster AWS
  `kubectl apply -f=kubernetes/auth.yaml -f=kubernetes/users.yaml -f=kubernetes/tasks.yaml`
