# ~/.bash_aliases — sourced from ~/.bashrc
# Completion for these aliases is in completion.bash.

# ── kubectl ──────────────────────────────────────────────────────────
alias k='kubectl'
alias kx='kubectl'                      # spare, in case `k` is taken
alias kg='kubectl get'
alias kga='kubectl get --all-namespaces'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias kpf='kubectl port-forward'
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -o wide'
alias kgpa='kubectl get pods --all-namespaces'
alias kgd='kubectl get deploy'
alias kgs='kubectl get svc'
alias kgi='kubectl get ingress'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kge='kubectl get events --sort-by=.lastTimestamp'
alias kev='kubectl get events --sort-by=.lastTimestamp'
alias ktp='kubectl top pods'
alias ktn='kubectl top nodes'
alias kcv='kubectl config view --minify'
alias kcc='kubectl config current-context'
alias kcuc='kubectl config use-context'
alias kcgc='kubectl config get-contexts'
# kns: no args → show current context/namespace; kns <ns> → switch namespace
unalias kns 2>/dev/null
kns() {
  if [ $# -eq 0 ]; then
    local ns
    ns=$(kubectl config view --minify -o jsonpath='{..namespace}')
    echo "context:   $(kubectl config current-context)"
    echo "namespace: ${ns:-default}"
  else
    kubectl config set-context --current --namespace "$@"
  fi
}
alias kdry='kubectl apply --dry-run=client -o yaml -f'
# ── helm ─────────────────────────────────────────────────────────────
alias h='helm'
alias hl='helm list'
alias hla='helm list --all-namespaces'
alias hup='helm upgrade --install'
alias hun='helm uninstall'
alias hst='helm status'
alias hhi='helm history'
alias htpl='helm template'

# ── Tekton (tkn) ─────────────────────────────────────────────────────
alias t='tkn'
alias tpr='tkn pipelinerun'
alias tprl='tkn pipelinerun list'
alias tprlo='tkn pipelinerun logs -f'
alias ttr='tkn taskrun'
alias ttrl='tkn taskrun list'
alias ttrlo='tkn taskrun logs -f'
alias tp='tkn pipeline'
alias tpl='tkn pipeline list'
alias tpst='tkn pipeline start'
alias tt='tkn task'
alias ttl='tkn task list'

# ── Argo CD ──────────────────────────────────────────────────────────
alias a='argocd'
alias aa='argocd app'
alias aal='argocd app list'
alias aag='argocd app get'
alias aas='argocd app sync'
alias aad='argocd app diff'
alias aaw='argocd app wait'
alias aah='argocd app history'
alias aalo='argocd app logs'
alias acl='argocd cluster list'
alias arl='argocd repo list'

# ── Flux / Argo Workflows / Knative ──────────────────────────────────
alias f='flux'
alias fgk='flux get kustomizations'
alias fgh='flux get helmreleases'
alias frk='flux reconcile kustomization'
alias frs='flux reconcile source git'

# ── misc ─────────────────────────────────────────────────────────────
alias kctx='kubectl config use-context'
alias watchpods='watch -n2 kubectl get pods'
