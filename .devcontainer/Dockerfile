FROM ghcr.io/tkpegatron/opsdev:rolling

# -{ ENV: Consume VSCode Environment variables }
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG TZ=America/Detroit

# -{ MOD: Configure userspace environment }
RUN \
    # Set the container's timezone \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone; \
    # Add local user account inside container \
    adduser --shell /bin/zsh --disabled-password $USERNAME

# Install krew plugin for kubectl, an addon package manager
run set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    mv ./"${KREW}" /usr/bin/kubectl-krew

# Drop into unprivileged user
USER $USERNAME

# Prepend user's bin to PATH during build
ENV PATH="$PATH:/home/$USERNAME/.local/bin"

# Configure Krew directory
ENV PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Install Krew Addons
RUN set -x \
    # Add the general krew addon index
    && kubectl krew index add krew https://github.com/kubernetes-sigs/krew-index \
    # Add the index for netshoot, a network troubleshooting tools container image
    && kubectl krew index add netshoot https://github.com/nilic/kubectl-netshoot.git \
    # Update repositories
    && kubectl krew update \
    # Install the extensions: cnpg (postgres cluster manager), commander, and netshoot
    && kubectl krew install krew/cnpg \
    && kubectl krew install krew/commander \
    && kubectl krew install krew/oidc-login \
    && kubectl krew install netshoot/netshoot


# Create mount directories
#? Letting vscode do this for us on bind mounts causes ownership issues for parent directories.
RUN mkdir /home/$USERNAME/.config

# Install Python Dependencies
COPY ./requirements.txt /opt/requirements.txt
RUN pip install -r /opt/requirements.txt --break-system-packages

# Install Ansible Depenedencies
COPY ./requirements.yml /opt/requirements.yml
RUN ansible-galaxy install -r /opt/requirements.yml