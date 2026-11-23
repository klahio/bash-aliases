# completion.bash — bash completion for kubectl and other cloud-native CLIs,
# plus the short aliases in .bash_aliases. Source it after .bash_aliases.

# ──────────────────────────────────────────────────────────────────────
# Kubernetes / cloud-native tooling completion
# Completion scripts are generated once and cached, then regenerated
# automatically whenever the binary is newer than its cached script.
# ──────────────────────────────────────────────────────────────────────
if ! shopt -oq posix; then

  _kcomp_cache="${XDG_CACHE_HOME:-$HOME/.cache}/bash_completion.d"
  [ -d "$_kcomp_cache" ] || mkdir -p "$_kcomp_cache"

  # _kcomp <command> [args-to-generate-bash-completion...]
  # Silently does nothing when the command isn't installed.
  _kcomp() {
      local cmd=$1; shift
      local bin cache
      bin=$(command -v "$cmd" 2>/dev/null) || return 0
      [ -n "$bin" ] || return 0
      cache="$_kcomp_cache/$cmd.bash"
      if [ ! -s "$cache" ] || [ "$bin" -nt "$cache" ]; then
          "$bin" "$@" > "$cache" 2>/dev/null || { rm -f "$cache"; return 0; }
      fi
      # shellcheck disable=SC1090
      . "$cache" 2>/dev/null
  }

  # _kcomp_alias <alias> <real-command>
  # Reuses the cobra/kubectl "__start_<cmd>" completion function for an alias.
  _kcomp_alias() {
      local fn="__start_$2"
      declare -F "$fn" >/dev/null 2>&1 &&
          complete -o default -o bashdefault -F "$fn" "$1"
  }

  # --- Kubernetes core ---
  _kcomp kubectl    completion bash
  _kcomp helm       completion bash
  _kcomp kustomize  completion bash
  _kcomp k9s        completion bash
  _kcomp oc         completion bash
  _kcomp kubeadm    completion bash
  _kcomp crictl     completion bash

  # --- CNPE / platform tooling ---
  _kcomp tkn        completion bash    # Tekton CLI
  _kcomp argocd     completion bash    # Argo CD
  _kcomp argo       completion bash    # Argo Workflows
  _kcomp flux       completion bash    # Flux CD
  _kcomp kn         completion bash    # Knative
  _kcomp skaffold   completion bash
  _kcomp velero     completion bash
  _kcomp istioctl   completion bash
  _kcomp kubeseal   completion bash
  _kcomp crossplane completion bash
  _kcomp yq         shell-completion bash
  _kcomp stern      --completion=bash

  # --- completion for the aliases defined in ~/.bash_aliases ---
  _kcomp_alias k    kubectl
  _kcomp_alias kx   kubectl
  _kcomp_alias h    helm
  _kcomp_alias a    argocd
  _kcomp_alias t    tkn
  _kcomp_alias f    flux

  # --- tools that register their own completer ---
  command -v terraform >/dev/null 2>&1 && complete -C "$(command -v terraform)" terraform tf
  command -v vault     >/dev/null 2>&1 && complete -C "$(command -v vault)"     vault

  unset _kcomp_cache
fi
