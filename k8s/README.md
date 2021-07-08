# Basic instructions for building for Kubernetes

$ docker build . -t localhost:32000/supersecret:latest
$ docker push localhost:32000/supersecret:latest

$ kubectl create namespace supersecret
$ kubectl create -f vault-deployment.yaml -n supersecret
$ kubectl create -f vault-service.yaml -n supersecret

Edit the supersecret-deployment.yml to point to the Docker container created above. It defaults to the localhost:32000 repository (minikube)

$ kubectl create -f supersecret-deployment.yaml -n supersecret
$ kubectl create -f supersecret-service-nodeport.yaml -n supersecret

kubectl get deployments,pods,svc -n supersecret
NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/docker-registry   1/1     1            1           23h
deployment.apps/vault             1/1     1            1           23h
deployment.apps/supersecret       1/1     1            1           2m28s

NAME                                   READY   STATUS    RESTARTS   AGE
pod/docker-registry-6cfd6f94b4-wfspx   1/1     Running   1          23h
pod/vault-5cfcc4f877-h5tcj             1/1     Running   1          23h
pod/supersecret-84f8c566d8-724dk       1/1     Running   0          2m28s

NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
service/docker-registry   NodePort    10.43.188.128   <none>        32000:32000/TCP   23h
service/vault             ClusterIP   10.43.25.93     <none>        8200/TCP          23h
service/supersecret       NodePort    10.43.254.249   <none>        8082:30084/TCP    61s

The site will be available at http://localhost:30084 and http://localip:30084. Use the other TLS environment variables.
