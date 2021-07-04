# Basic instructions for building for Kubernetes
 
$ docker build . -t supersecret:latest
$ docker image tag a564cfd46815 supersecret:latest
$ docker image push supersecret

$ kubectl create namespace supersecret
$ kubectl create -f vault-deployment.yaml -n supersecret
$ kubectl create -f vault-service.yaml -n supersecret

Edit the supersecret-deployment.yml to point to the Docker container created above. It defaults to the localhost:32000 repository (minikube)

$ kubectl create -f supersecret-deployment.yaml -n supersecret
$ kubectl create -f supersecret-service-nodeport.yaml -n supersecret

$ kubectl get deployment -s supersecret
$ kubectl get pods -s supersecret
$ kubectl get services -n supersecret

$ kubectl get services -n supersecret
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
vault         ClusterIP   10.152.183.196   <none>        8200/TCP         99m
supersecret   NodePort    10.152.183.203   <none>        8082:30082/TCP   97m

The site will be available at http://localhost:30082 and http://localip:30082. Use the other TLS environment variables.
