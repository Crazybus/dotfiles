c.events() {
  kubectl get events --all-namespaces -w  | grep '$1'
}

c.bad() {
  kubectl get pods --all-namespaces -o json  | jq -r '.items[] | select(.status.phase == "Running" and ([ .status.conditions[] | select(.type == "Ready" and .status == "False") ] | length ) == 1 ) | .metadata.name + ": " + (.status.conditions[] | select(.type == "Ready") .message)'
}

c.temp() {
  kubectl run --rm -ti micky-temp-$(date +%s) --image=crazybus/dtk --image-pull-policy=Always --rm --command=true --attach=true /bin/sh
}

c.ns() {
  namespace=$(kubectl get namespaces |  awk '{print $1}' | grep $1 | head -n 1)
  kubectl config set-context $(kubectl config current-context) --namespace=$namespace
}

c.use() {
  kubectl config use-context $(kubectl config view | grep '    cluster:' | sed 's/cluster://g' | sed 's/ //g' | sort | grep $1)
}

c.off() {
  kubectl config unset current-context
}

c.ls() {
  if [ -z "$1" ]; then
    kubectl get pods -o wide
  else
    kubectl get pods -o wide | grep "$1"
  fi
}

c.lsw() {
  if [ -z "$1" ]; then
    watch 'kubectl get pods -o wide'
  else
    watch "kubectl get pods -o wide | grep "$1""
  fi
}

c.lsa() {
  if [ -z "$1" ]; then
    kubectl get pods --all-namespaces -o wide
  else
    kubectl get pods --all-namespaces -o wide | grep "$1"
  fi
}

c.wait() {
  name=$1
  count=$2
  namespace=$3
  for i in {1..120}; do
    echo waiting for $name ... $i
    kubectl get pods --namespace="$3" | grep "$name" | grep 'Running' | wc -l | grep $count && break
    sleep 1
  done
}

c.sh() {
  if [ -n "$2" ] ; then
    kubectl exec -ti $(kubectl get pods -o wide | grep -v Terminating | grep "$1" | awk '{ print $1 }' | head -n 1) -c $2 sh
  else
    kubectl exec -ti $(kubectl get pods -o wide | grep -v Terminating | grep "$1" | awk '{ print $1 }' | head -n 1) sh
  fi
}

c.log() {
  if [ -n "$2" ] ; then
    kubectl logs -f $(kubectl get pods -o wide | grep -v Terminating | grep "$1" | awk '{ print $1 }' | head -n 1) -c $2
  else
    kubectl logs -f $(kubectl get pods -o wide | grep -v Terminating | grep "$1" | awk '{ print $1 }' | head -n 1)
  fi
}

c.desc() {
  kubectl describe pod $(kubectl get pods -a | grep -v Terminating | awk '{ print $1 }' | grep "$1" | head -n 1)
}

c.rm() {
  pods=$(kubectl get pods -a -o name | grep "$1")
  echo $pods
  echo -n "Remove?"
  read test
  echo "$pods" | xargs kubectl delete
}

c.tail() {
  namespace=$(kubectl get namespaces |  awk '{print $1}' | grep $1 | head -n 1)
  k8stail --namespace $namespace
}

c.cp() {
  cat $1 | kubectl exec -i $(kubectl get pods -a | grep -v Terminating | awk '{ print $1 }' | grep "$2" | head -n 1) -- tee $3 > /dev/null
}

c.apply() {
  kubectl apply -f $1
}

c.roll() {
  pods=$(kubectl get pods -a -o name | grep "$1")
  echo $pods
  echo -n "Remove?"
  read test
  for pod in $(kubectl get pods -a -o name | grep "$1"); do
    echo Deleting $pod
    kubectl delete $pod
    sleep 1
    for i in {1..30}; do
      echo $i
      kubectl get pods -a | grep "$1" | grep Running | wc | awk '{ print $1 }' | grep $2 && break
      sleep 1
    done
  done
}

c.con() {
  clusters=$(kubectl config view | grep '    cluster:' | sed 's/.*cluster://g' | sort)
  while read -r line; do
      server=$(kubectl config view | grep -A 3 '\- cluster:' | grep -B 1 $line | grep 'server:' | sed 's/.*server: //')
    echo "$line: \n  $server"
  done <<< "$clusters"
}

