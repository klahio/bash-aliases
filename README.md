# bash-aliases

Short bash aliases for kubectl, plus helm, Tekton (`tkn`), Argo CD and Flux, with tab completion that also works on the aliases.

| File | What it has |
|---|---|
| `.bash_aliases` | The aliases and the `kns` function |
| `install.sh` | Links `.bash_aliases` into your home directory and makes `~/.bashrc` load it and `completion.bash` |
| `completion.bash` | Completion for kubectl and other cloud-native CLIs, cached under `~/.cache/bash_completion.d` and regenerated when a binary is upgraded. Also wires completion to the `k`, `kx`, `h`, `t`, `a` and `f` aliases |

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/klahio/bash-aliases/main/install.sh | bash
```

This downloads `.bash_aliases`, `completion.bash` and `install.sh` into `~/.bash-aliases` and then:

- Links `~/.bash_aliases` to the downloaded copy. An existing `~/.bash_aliases` is moved to `~/.bash_aliases.bak.<timestamp>` first.
- Adds a block to the end of `~/.bashrc` that loads `~/.bash_aliases` and `completion.bash`, leaving out what `~/.bashrc` already loads. Ubuntu's default `~/.bashrc` already sources `~/.bash_aliases`, for example.

Run the same command again to update. Nothing is added to `~/.bashrc` twice, and a failed download leaves the installed files as they were. Set `BASH_ALIASES_DIR` to download somewhere other than `~/.bash-aliases`.

To read the script before running it:

```bash
curl -fsSL https://raw.githubusercontent.com/klahio/bash-aliases/main/install.sh -o install.sh
less install.sh
bash install.sh
```

### From a clone

```bash
git clone https://github.com/klahio/bash-aliases.git ~/.bash-aliases
~/.bash-aliases/install.sh
```

`install.sh` run from a clone uses the clone's files and downloads nothing. Update with `git pull` in the clone.

### Uninstall

```bash
~/.bash-aliases/install.sh --uninstall
```

This removes the block from `~/.bashrc` and the `~/.bash_aliases` link, deletes the downloaded files (a clone is left alone), and tells you where the backup of your earlier aliases is.

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
