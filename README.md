# Containerized Dell RACADM client

## Why?

So I can make changes to iDRACs everywhere.

## Usage

```
podman build -t iranzo/racadm
podman run -it iranzo/racadm -r <ip> -u <user> -p <pass> <command> [args...]
```

## References

Forked from https://github.com/eminguez/docker-racadm
