alias k=kubectl
c.events() {
  kubectl get events --all-namespaces -w  | grep '$1'
}

c.bad() {
  kubectl get pods --all-namespaces -o json | jq -r '.items[] | select((.status.phase == "Running" or .status.phase == "Pending" or .status.phase == "Unknown") and ([ .status.conditions[] | select(.type == "Ready" and .status == "False") ] | length ) == 1 ) | .spec.nodeName + "\t" + .metadata.namespace + "\t" + .metadata.name + "\t" + (.status.conditions[] | select(.type == "Ready") .message)' | column -t
}

c.oom() {
  kubectl get pods --all-namespaces -o json | jq -r '.items[] | select(.status.containerStatuses[].lastState.terminated.reason == "OOMKilled") | .spec.nodeName + "\t" + .metadata.namespace + "\t" + .metadata.name'
}

c.temp() {
  kubectl run --generator=run-pod/v1 --rm -ti micky-temp-$(date +%s) --image=crazybus/dtk --image-pull-policy=Always --rm --command=true --attach=true /bin/sh
}

c.ns() {
  namespace=$(kubectl get namespaces |  awk '{print $1}' | fzf)
  kubectl config set-context --current --namespace=$namespace
}

c.use() {
  kubectl config use-context $(kubectl config view -o jsonpath='{.contexts[*].name}' | tr " " "\n" | fzf)
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
  kubectl exec -ti $(pods.py | fzf --no-sort) sh
}

c.ssh() {
  gcloud compute ssh $(gke-ssh | fzf)
}

c.sha() {
  export ALL_NAMESPACES=t
  kubectl exec -ti $(pods.py | fzf --no-sort) sh
}

c.log() {
  kubectl --tail=100 logs -f $(pods.py | fzf --no-sort) | ccze --raw-ansi
}

c.loga() {
  export ALL_NAMESPACES=t
  kubectl --tail=100 logs -f $(pods.py | fzf --no-sort) | ccze --raw-ansi
}

c.shl() {
  pod=$(kubectl get pods --sort-by=.metadata.creationTimestamp -o name | grep $1 | tail -1)
  if [ -z "$2" ]; then
    kubectl exec -ti $pod sh
  else
    kubectl exec -ti $pod -c $2 sh
  fi
}

c.last() {
  pod=$(kubectl get pods --sort-by=.metadata.creationTimestamp -o name | grep $1 | tail -1)
  if [ -z "$2" ]; then
    kubectl logs -f $pod
  else
    kubectl logs -f $pod -c $2
  fi
}

c.desc() {
  export DONT_PRINT_CONTAINERS=t
  kubectl describe pod $(pods.py | fzf)
}

c.desca() {
  export ALL_NAMESPACES=t
  export DONT_PRINT_CONTAINERS=t
  kubectl describe pod $(pods.py | fzf)
}

c.edit() {
  export DONT_PRINT_CONTAINERS=t
  kubectl edit pod $(pods.py | fzf)
}

c.rm() {
  export DONT_PRINT_CONTAINERS=t
  pods=$(pods.py | fzf --multi --bind "ctrl-a:select-all+accept")
  echo $pods
  echo -n "Remove?"
  read test
  kubectl delete pods $(echo $pods | tr " " "\n")
}

c.edit() {
  export DONT_PRINT_CONTAINERS=t
  kubectl edit pod $(pods.py | fzf)
}

c.tail() {
  namespace=$(kubectl get namespaces |  awk '{print $1}' | fzf)
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

c.secret() {
  kubectl get $(kubectl get secrets -o name | fzf) -o json | ~/bin/kube-secret-read.py
}

c.usage () {
    # show pod usage for cpu/mem
    ns="$1"
    printf "$ns\n"
    separator=$(printf '=%.0s' {1..50})
    printf "$separator\n"
    output=$(join -a1 -a2 -o 0,1.2,1.3,2.2,2.3,2.4,2.5, -e '<none>' \
        <(kubectl top pods -n $ns) \
        <(kubectl get -n $ns pods -o 'custom-columns=NAME:.metadata.name,"CPU_REQ(cores)":.spec.containers[*].resources.requests.cpu,"MEMORY_REQ(bytes)":.spec.containers[*].resources.requests.memory,"CPU_LIM(cores)":.spec.containers[*].resources.limits.cpu,"MEMORY_LIM(bytes)":.spec.containers[*].resources.limits.memory'))
    totals=$(printf "%s" "$output" | awk '{s+=$2; t+=$3; u+=$4; v+=$5; w+=$6; x+=$7} END {print s" "t" "u" "v" "w" "x}')
    printf "%s\n%s\nTotals: %s\n" "$output" "$separator" "$totals" | column -t -s' '
    printf "$separator\n"
}

h.rm() {
  helm del --purge $(helm ls | fzf | awk '{ print $1 }')
}

c.kibana() {
  ingress=$(kubectl get ingress --namespace elastic-apps kibana -o jsonpath='{.spec.rules[0].host}' || kubectl get ingress --namespace elastic-apps ea-kibana-kibana -o jsonpath='{.spec.rules[0].host}')
  xdg-open "https://$ingress"
}

c.kibana.legacy() {
  ingress=$(kubectl get ingress --namespace elastic-apps ea-kibana-kibana -o jsonpath='{.spec.rules[0].host}')
  xdg-open "https://$ingress/app/management/insightsAndAlerting/watcher/watches"
}

c.bad.nodes() {
  xdg-open "https://$(kubectl get ingress --namespace elastic-apps kibana -o jsonpath='{.spec.rules[0].host}')/app/metrics/explorer?_g=()&metricsExplorer=(chartOptions:(stack:!f,type:line,yAxisMode:fromZero),options:(aggregation:count,filterQuery:'kubernetes.node.status.ready : "false" ',groupBy:kubernetes.node.name,metrics:!((aggregation:count))),timerange:(from:now-8h,interval:>%3D10s,to:now))"
}
