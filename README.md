# bash-aliases

Short bash aliases for kubectl, plus helm, Tekton (`tkn`), Argo CD and Flux, with tab completion that also works on the aliases.

| File | What it has |
|---|---|
| `.bash_aliases` | The aliases and the `kns` function |
| `completion.bash` | Completion for kubectl and other cloud-native CLIs, cached under `~/.cache/bash_completion.d` and regenerated when a binary is upgraded. Also wires completion to the `k`, `kx`, `h`, `t`, `a` and `f` aliases |

## Install

```bash
git clone git@github.com:klahio/bash-aliases.git ~/.bash-aliases
ln -sf ~/.bash-aliases/.bash_aliases ~/.bash_aliases
```

Ubuntu's default `~/.bashrc` already sources `~/.bash_aliases`. For completion, add this to the end of `~/.bashrc`, after bash-completion is loaded:

```bash
[ -f ~/.bash-aliases/completion.bash ] && . ~/.bash-aliases/completion.bash
```

## kubectl aliases

| Alias | Command |
|---|---|
| `k` | `kubectl` |
| `kg`, `kga` | `kubectl get`, `kubectl get --all-namespaces` |
| `kd` | `kubectl describe` |
| `kdel` | `kubectl delete` |
| `kaf`, `kdf` | `kubectl apply -f`, `kubectl delete -f` |
| `kdry` | `kubectl apply --dry-run=client -o yaml -f` |
| `kl`, `klf` | `kubectl logs`, `kubectl logs -f` |
| `kex` | `kubectl exec -it` |
| `kpf` | `kubectl port-forward` |
| `kgp`, `kgpw`, `kgpa` | get pods, with `-o wide`, in all namespaces |
| `kgd`, `kgs`, `kgi`, `kgn`, `kgns` | get deployments, services, ingresses, nodes, namespaces |
| `kge`, `kev` | `kubectl get events --sort-by=.lastTimestamp` |
| `ktp`, `ktn` | `kubectl top pods`, `kubectl top nodes` |
| `kcc`, `kcgc`, `kcuc`, `kctx` | current context, list contexts, use a context |
| `kcv` | `kubectl config view --minify` |
| `kns` | Without arguments, shows the current context and namespace. `kns <namespace>` switches the namespace of the current context |
| `watchpods` | `watch -n2 kubectl get pods` |

See `.bash_aliases` for the helm, Tekton, Argo CD and Flux aliases.
