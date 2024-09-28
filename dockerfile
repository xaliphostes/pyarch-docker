# Use a base image with Python and C++ support
FROM python:3.11-buster

# Déclarer les arguments de construction pour les credentials GitHub
ARG GITHUB_USER
ARG GITHUB_TOKEN

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install cmake --upgrade

# --------------------------------------------------------------------------
# Login to Github with credentials GITHUB_USER and GITHUB_TOKEN
# export GITHUB_USER=fmaerten
# export GITHUB_TOKEN=xxxxxxxxx (see https://github.com/settings/tokens)
# --------------------------------------------------------------------------
RUN git config --global credential.helper store && \
    echo "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com" > ~/.git-credentials


# Set up working directory
WORKDIR /app

# Clone the C++ source repositories
RUN git clone https://github.com/youwol/krylov.git
RUN git clone https://github.com/youwol/arch.git

# Clone the Python wrapper repository
RUN git clone https://github.com/youwol/arch-python.git

# Build the C++ library
WORKDIR /app/arch
RUN mkdir build && cd build \
    && cmake .. \
    && make -j12 \
    && cd ..

WORKDIR /app
RUN ls -alt ./bin

# Build the C++ Python wrapper
WORKDIR /app/arch-python
RUN git clone https://github.com/pybind/pybind11.git
#RUN pip install virtualenv
#RUN python -m venv project_env
#RUN source project_env/bin/activate
RUN mkdir build && cd build \
    && cmake .. && make pyarch \
    && mv *.so ../../bin/pyarch.so

# Set the working directory back to /app
WORKDIR /app

# Clear credentials
RUN rm ~/.git-credentials && \
    git config --global --unset credential.helper

# Set the entrypoint to python
ENTRYPOINT ["python"]