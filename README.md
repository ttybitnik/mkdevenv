# ttybitnik/mkdevenv

**mkdevenv** is a collection of OCI-compliant container image boilerplates for managing isolated development environments using GNU Make.

It enables a **consistent**, **open**, and **extensible** workflow by using `Containerfile` and `Makefile` as the standard points of entry. Dependencies and tools are packaged in a custom container, providing isolation and replicability of the development environment while still integrating with the `$EDITOR` on the host system.

[![release](https://img.shields.io/github/v/release/ttybitnik/mkdevenv)](https://github.com/ttybitnik/mkdevenv/releases/latest)
[![ci/cd](https://github.com/ttybitnik/mkdevenv/actions/workflows/cicd.yaml/badge.svg)](https://github.com/ttybitnik/mkdevenv/actions/workflows/cicd.yaml)
[![conventional commits](https://img.shields.io/badge/conventional%20commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)

**Example of resources on host system**:

- GNU Make
- Container Engine
- `$EDITOR`
- Git
- OpenPGP subkeys (for signing and pushing commits)
- Project source files

**Example of resources on development container**:

- Language Runtime
- Language Compiler
- LSP
- Linter
- Test suite
- Dependencies
- Any other necessary SDK tooling
- Project source files (binded from host using `make start`)

## Requirements

> [!TIP]
> Basic familiarity with [container engines](https://docs.podman.io/en/latest/) (e.g., Podman, Docker), [OCI Image](https://github.com/containers/common/blob/main/docs/Containerfile.5.md) (Containerfile), and [GNU Make](https://www.gnu.org/software/make/) is recommended.

- Container Engine
- GNU Make

## Usage

### Setup

1. **Create a `.mkdevenv` directory** at the root of the project or environment. Only files within this path will be shared with the container.
1. **Copy the appropriate files from the [boilerplates](boilerplates/) directory** into the `.mkdevenv` directory—for example, the [ansible-fedora](boilerplates/ansible/fedora) development environment. Clone the **mkdevenv** repository to streamline this process.
1. **Move the `Makefile`** from the `.mkdevenv` directory to the root of the project or environment.
1. **Edit the `Makefile`** and adjust variables with `changeme` values. These variables are used for naming, managing, and running the container.

#### Per-project example
```
project/
├── .mkdevenv/
│   ├── Containerfile
│   ├── README.md
│   ├── dnf.txt
│   └── pip.txt
└── Makefile
```

#### Multi-project (omni) example
```
repositories/
├── .mkdevenv/
│   ├── Containerfile
│   ├── README.md
│   ├── apt.txt
│   ├── npm.txt
│   └── go.txt
├── project1/
├── project2/
├── project3/
└── Makefile
```

### Commands

#### Default commands on host system

- **`make devenv`**: Build the container image defined in `.mkdevenv/Containerfile`.
- **`make start`**: Start the mkdevenv container, passing the current working directory as a bind mount.
- **`make stop`**: Stop the mkdevenv container.
- **`make clean`**: Remove the mkdevenv container and its artifacts. Executes the `distclean` target first.
- **`make serestore`**: Restore project files context on SELinux host systems.

#### Custom commands inside the container

- **`make lint`**: Run linters.
- **`make test`**: Run tests. Executes the `lint` target first.
- **`make build`**: Build the project. Executes the `test` target first.
- **`make run`**: Run the project. Executes the `build` target first.
- **`make deploy`**: Deploy the project. Executes the `build` target first.
- **`make debug`**: Run debugging tasks. Executes the `test` target first.
- **`make distclean`**: Clean artifacts.

### Workflow

[![asciicast](https://asciinema.org/a/Ib6lXP2Ic6wsPiK5AcpJ13Jfj.svg)](https://asciinema.org/a/Ib6lXP2Ic6wsPiK5AcpJ13Jfj)

## Side notes

### Run and compose

If a project requires additional containers, enable it by uncommenting the compose command in the `start` target. Ensure that the same network is applied in both the run command and the container compose file.

### Git and GPG

Since Git configuration and OpenPGP keys aren't shared with the containers, all Git operations and GPG signing must happen on the host system. This ensures sensitive information stays separate from the development environment, which is my preferred approach.

### Per-project and multi-project (omni)

The main difference between the per-project and omni boilerplates is that the omni use a shared volume for the `~/.local` directory in the container, where non-root packages and dependencies are installed. This allows dependencies to persist across container runs, eliminating the need to rebuild the image when project dependencies change or update.

For sharing and occasional contributions, the per-project approach offers an isolated development environment with all the necessary tools for ephemerally working on a specific project.

For personal and frequent use, the multi-project (omni) approach can be more beneficial, as it enables sharing common dependencies and tools across multiple projects. For example, a single omni container provides access to all my Git repositories and contains all the languages and tooling that I regularly use.

### GNU Emacs

To run programs from containers in Emacs on host system, TRAMP needs to search the correct paths. Since the boilerplates define the least required access for non-root packages, TRAMP's default mechanism (`getconf PATH` + TRAMP standard paths) might not always locate the tools, so some additional parentheses are needed.

The following configuration adds `~/.local/bin`, the default location for non-root programs in the boilerplates, to TRAMP’s search paths. It also includes `tramp-own-remote-path`, which adds the remote user’s assigned path on supported shells:
``` emacs-lisp
(add-to-list 'tramp-remote-path (concat
				 (file-name-as-directory (getenv "HOME"))
				 ".local/bin"))
(add-to-list 'tramp-remote-path 'tramp-own-remote-path)
```

Helpful commands:

- **`tramp-cleanup-all-buffers`**: Kills all remote buffers, useful for preventing TRAMP warnings when stopping containers.
- **`tramp-cleanup-all-connections`**: Flushes all TRAMP objects (its caching), handy after changing configuration.
- **`project-forget-project`**: Removes a directory from the project list, useful for preventing TRAMP warnings related to remote zombie projects.

### Compatibility

Any IDE that supports opening files and executing binaries within a container's file system should work with the boilerplates. However, since Emacs is my preferred `$EDITOR`, the boilerplates are specifically created and tested with it in mind.

In worst-case scenarios, SSH protocol can also be used.

## Contributing

In case of unexpected behavior, please open a [bug report](https://github.com/ttybitnik/mkdevenv/issues/new?assignees=&labels=bug&projects=&template=bug_report.md&title=).

For matters requiring privacy, such as security-related reports or patches, check the [security policy](SECURITY.md).

To contribute to **mkdevenv** boilerplates, see the [project guidelines](boilerplates/README.md).

### Mailing list

[Email workflow](https://git-send-email.io/) is also available.

Feel free to send patches, questions, or discussions related to **mkdevenv** to the [~ttybitnik/general mailing list](https://lists.sr.ht/~ttybitnik/general).

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0), **unless an exception is made explicit in context**. See the `COPYING` file for more information.

Be aware that the resulting container images may include other software subject to additional licenses, such as the base operating system, shells, and any direct or indirect dependencies of the software being contained. As with any built container image, it is the user's responsibility to ensure their use of the image complies with all relevant licenses for the software contained within.

The source code for this project is available at <https://github.com/ttybitnik/mkdevenv>.
