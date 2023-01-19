# S2I build types

## build type: Docker

```
podman build ./docker -t gradio
```

## build type: source (python)

```
s2i build ./source \
  registry.access.redhat.com/ubi7/python-38 \
  s2i-gradio
```