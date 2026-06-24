# app-deploy

Ansible role that deploys the DevOps Lab application as a Docker container,
waits for its health endpoint, and prints a deployment summary.

## Requirements

- Docker Engine installed and running on the target host
- The target image (`docker_image`) must be pullable or already present locally

## Role Variables

Variables are resolved in priority order: task vars > playbook vars > `group_vars/all.yml` > `defaults/main.yml`.

### Defaults (`defaults/main.yml`)

| Variable | Default | Description |
|---|---|---|
| `container_name` | `devops-lab` | Name assigned to the running container |
| `container_restart_policy` | `unless-stopped` | Docker restart policy |

### Group vars (`group_vars/all.yml`)

| Variable | Example | Description |
|---|---|---|
| `app_name` | `devops-lab` | Human-readable application name |
| `app_version` | `1.0.0` | Application version string |
| `app_port` | `5000` | Host port the container is mapped to |
| `docker_image` | `devops-lab:latest` | Docker image to deploy |
| `healthcheck_path` | `/health` | Path polled by the URI health check |
| `log_level` | `INFO` | `LOG_LEVEL` env var injected into the container |

## Example Playbook

```yaml
---
- name: Deploy DevOps Lab Application
  hosts: webservers
  become: false
  pre_tasks:
    - name: Announce deployment start
      ansible.builtin.debug:
        msg: "Starting deployment of {{ app_name }} v{{ app_version }}"
  roles:
    - role: app-deploy
  post_tasks:
    - name: Announce deployment complete
      ansible.builtin.debug:
        msg: "{{ app_name }} v{{ app_version }} deployed successfully on port {{ app_port }}"
```

## Tags

No tags are defined by default. Add them to individual tasks in `tasks/main.yml` if you need selective execution (e.g., `--tags healthcheck`).

## License

MIT
