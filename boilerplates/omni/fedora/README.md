# omni-fedora

| dnf               | npm                              | go            | pip          |
|:------------------|:---------------------------------|---------------|:-------------|
| git               | yaml-language-server             | gopls         | yamllint     |
| make              | @ansible/ansible-language-server | goimports     | ansible-lint |
| ripgrep           | bash-language-server             | golangci-lint | molecule     |
| golang            | release-please                   | goreleaser    |              |
| npm               |                                  | delve         |              |
| python3           |                                  |               |              |
| python3-pip       |                                  |               |              |
| ansible-core      |                                  |               |              |
| shellcheck        |                                  |               |              |
| shfmt             |                                  |               |              |
| hadolint          |                                  |               |              |
| trivy             |                                  |               |              |
| gcc               |                                  |               |              |
| clang             |                                  |               |              |
| clang-tools-extra |                                  |               |              |
| gdb               |                                  |               |              |

1. Create a `.mkdev` directory at the root of the project.
2. Copy all the boilerplate files into the `.mkdev` directory.
3. Move the `Makefile` to the root of the project.

*For more information, see <https://github.com/ttybitnik/mkdev>.*
