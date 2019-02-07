# Currently the install-script uses RPM/yum
FROM centos:7

# Installer bootstrap script
COPY install.sh /
RUN /install.sh

# Helper for commandline actions
COPY _kube /usr/local/bin
ENV PATH=/usr/local/bin:$PATH
