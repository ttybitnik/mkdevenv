# Guidelines

## Structure

- Main directory named after the development environment (e.g., `go`, `ansible`, `python`).
- Subdirectory named after the base image (e.g., `fedora`, `debian`, `arch`).
- **`Containerfile`** and **packages files** located inside the subdirectory.
- **`Makefile`** located at the root of the project.

## Containerfile

- **`ARG`**: Build-time argument for specifying the `USERNAME` (default value: `mkdev`).
- **`LABEL`**: Metadata instruction including `name`, `summary`, and `usage` information.
- **`RUN`**: Commands for setting up the environment, including installing the **packages files**, removing cache files, and creating the non-root user.
- **`WORKDIR`**: Path to the project files inside the container `/home/$USERNAME/workspace`.
- **`USER`**: Specifies the user to the non-root `$USERNAME`.
- **`ENV`**: Environment variables for the non-root user, primarily its local `$PATH` and package managers (`/home/$USERNAME/.local/share/<manager>`).
- **`CMD`**: Default command to start the container `["/bin/bash", "-l"]`.

### Base image

- Complete address format (e.g., `registry.fedoraproject.org/fedora:latest`).
- Only official images.

### Packages files

- Plaintext files with the `.txt` extension.
- Files named after the package manager (e.g., `dnf.txt`, `pip.txt`, `npm.txt`).
- Listing one package name per line.

## Makefile

- **`PROJECT_NAME`**: Suffix for container and image names, restricted to letters, numbers, underscores, dots, and hyphens `[a-zA-Z0-9][a-zA-Z0-9_.-]*` (default value: `changeme`).
- **`CONTAINER_ENGINE`**: Command for running the container engine, such as `podman` or `docker` (default value: `changeme`).
- Development image names with complete address format, including `localhost`, and `mkdev` as the namespace (e.g., `localhost/mkdev/$(PROJECT_NAME)`).
- Development container names prefixed with `mkdev-` to avoid conflicts (e.g., `mkdev-$(PROJECT_NAME)`).

### Host targets/commands

- **`dev`**: Target for building the development container image.
- **`start`**: Target for starting the container.
- **`stop`**: Target for stopping the container.
- **`clean`**: Target for removing the container and image.
- **`serestore`** (optional): Target for restoring SELinux context and permissions.

### Container targets/commands

- **`lint`**: Target for running linters.
- **`test`**: Target for running tests (default dependency: `lint`).
- **`build`**: Target for building the project application (default dependency: `test`).
- **`run`**: Target for running the project application (default dependency: `build`).
- **`deploy`**: Target for deploying the project application (default dependency: `build`).
- **`debug`**: Target for debugging (default dependency: `test`).

## Readme

- Basic overview in a markdown file `README.md`.
- Header title following the `baseimage-environment` format.
- Table describing the packages installed through **packages files** for each package manager.
- Basic three-steps instructions with a link for further details:
```text
1. Create a `.mkdev` directory at the root of the project.
2. Copy the boilerplate files into the `.mkdev` directory.
3. Move the `Makefile` to the root of the project.

*For more information, see <https://github.com/ttybitnik/mkdev>.*
```

## Complete example

For a complete example, refer to any of the existing boilerplate files, such as the [ansible-fedora](ansible/fedora) development container.

> [!NOTE]
> All guidelines and rationale are subject to change. Feel free to open an issue or send an email to start a discussion.

# Contributing

To ensure your changes follow the guidelines, run `./linter.sh`.

To keep documentation files up to date with the installed packages, run `./update-docs.sh`.

The files `./Dev.mk` (per-project) and `./Omni.mk` (multi-project) are the source of truth for each approach. Changes to these files, up to the `# Container targets/commands` section, can be propagated to the boilerplates by running `./update-makefiles.sh`.

To streamline this process in one step, run:

```shell
./linter.sh && ./update-docs.sh && ./update-makefiles.sh
```
