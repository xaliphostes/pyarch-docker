# Running the docker file

```sh
docker build --no-cache \
    --build-arg GITHUB_USER=YOUR_PSEUDO \
    --build-arg GITHUB_TOKEN=YOUR_TOKEN \
    -t youwol-arch-python . > build_log.txt 2>&1
```