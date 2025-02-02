# omni-fedora

| dnf               | go                                                         | npm                              | pip          |
|:------------------|:-----------------------------------------------------------|:---------------------------------|:-------------|
| git               | golang.org/x/tools/gopls@latest                            | yaml-language-server             | ansible      |
| make              | golang.org/x/tools/cmd/goimports@latest                    | @ansible/ansible-language-server | ansible-lint |
| ripgrep           | github.com/golangci/golangci-lint/cmd/golangci-lint@latest | bash-language-server             | yamllint     |
| golang            | github.com/goreleaser/goreleaser/v2@latest                 | release-please                   | molecule     |
| npm               | github.com/go-delve/delve/cmd/dlv@latest                   |                                  |              |
| python3           |                                                            |                                  |              |
| python3-pip       |                                                            |                                  |              |
| shellcheck        |                                                            |                                  |              |
| shfmt             |                                                            |                                  |              |
| hadolint          |                                                            |                                  |              |
| trivy             |                                                            |                                  |              |
| gcc               |                                                            |                                  |              |
| clang             |                                                            |                                  |              |
| clang-tools-extra |                                                            |                                  |              |
| gdb               |                                                            |                                  |              |
| podman-remote     |                                                            |                                  |              |

1. Create a `.mkdev` directory at the root of the project.
2. Copy all the boilerplate files into the `.mkdev` directory.
3. Move the `Makefile` to the root of the project.

*For more information, see <https://github.com/ttybitnik/mkdev>.*
