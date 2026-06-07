#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'USAGE'
usage: scripts/deploy-vps.sh [--migrate] [--skip-build] [--dry-run]

Required .env values:
  DEPLOY_SSH_HOST   IPv6 address or hostname of the VPS
  DEPLOY_SSH_USER   SSH user

Optional .env values:
  DEPLOY_SSH_PORT   SSH port (default: 22)

Optional environment:
  DEPLOY_REMOTE_DIR Remote deploy directory (default: /opt/expenseclaim)
  DEPLOY_COMPOSE    Compose command on VPS (default: docker compose)
USAGE
}

die() {
  echo "deploy-vps: $*" >&2
  exit 1
}

shell_quote() {
  # Single-quote a value for a POSIX shell command evaluated on the VPS.
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is required"
}

dotenv_value() {
  key="$1"
  value="$(sed -n "s/^[[:space:]]*\\(export[[:space:]]\\{1,\\}\\)\\{0,1\\}${key}[[:space:]]*=[[:space:]]*//p" "$dotenv_file" | tail -n 1)"
  value="$(printf '%s' "$value" | sed 's/[[:space:]]*$//')"

  case "$value" in
    \"*\")
      value="${value#\"}"
      value="${value%\"}"
      ;;
    \'*\')
      value="${value#\'}"
      value="${value%\'}"
      ;;
  esac

  printf '%s' "$value"
}

migrate=0
skip_build=0
dry_run=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --migrate)
      migrate=1
      ;;
    --skip-build)
      skip_build=1
      ;;
    --dry-run)
      dry_run=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      die "unknown option: $1"
      ;;
  esac
  shift
done

require_cmd git

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

dotenv_file="$repo_root/.env"
[ -f "$dotenv_file" ] || die ".env is required"

deploy_host="$(dotenv_value DEPLOY_SSH_HOST)"
deploy_user="$(dotenv_value DEPLOY_SSH_USER)"
deploy_port="$(dotenv_value DEPLOY_SSH_PORT)"
[ -n "$deploy_port" ] || deploy_port="22"
remote_dir="${DEPLOY_REMOTE_DIR:-/opt/expenseclaim}"
compose_cmd="${DEPLOY_COMPOSE:-docker compose}"

[ -n "$deploy_host" ] || die "DEPLOY_SSH_HOST is required in .env"
[ -n "$deploy_user" ] || die "DEPLOY_SSH_USER is required in .env"

if [ "$dry_run" -eq 0 ]; then
  require_cmd ssh
  require_cmd rsync
fi

case "$deploy_host" in
  *"["*|*"]"*|*"@"*)
    die "DEPLOY_SSH_HOST must be a bare IPv6 address or hostname"
    ;;
esac

case "$deploy_port" in
  *[!0-9]*|"")
    die "DEPLOY_SSH_PORT must be numeric"
    ;;
esac

dirty="$(git status --porcelain)"
if [ -n "$dirty" ]; then
  echo "$dirty" >&2
  if [ "$dry_run" -eq 0 ]; then
    die "working tree must be clean before deploy"
  fi
  echo "deploy-vps: dry-run continues with a dirty working tree" >&2
fi

remote_dir_q="$(shell_quote "$remote_dir")"
compose_cmd_q="$(shell_quote "$compose_cmd")"
ssh_target="${deploy_user}@${deploy_host}"
rsync_host="$deploy_host"
case "$deploy_host" in
  *:*)
    rsync_host="[${deploy_host}]"
    ;;
esac
rsync_target="${deploy_user}@${rsync_host}:${remote_dir}/"
ssh_cmd="ssh -p ${deploy_port}"

run_remote() {
  label="$1"
  command_body="$2"

  echo "==> remote: $label"
  if [ "$dry_run" -eq 1 ]; then
    printf '%s\n' "$command_body"
    return 0
  fi

  ssh -p "$deploy_port" "$ssh_target" "sh -eu -c $(shell_quote "$command_body")"
}

run_remote "create remote directory" "mkdir -p $remote_dir_q"

echo "==> local: sync tracked files"
if [ "$dry_run" -eq 1 ]; then
  echo "git ls-files -z | rsync -az --delete --filter='P .env' --from0 --files-from=- -e '$ssh_cmd' ./ '$rsync_target'"
else
  git ls-files -z | rsync -az --delete --filter='P .env' --from0 --files-from=- -e "$ssh_cmd" ./ "$rsync_target"
fi

run_remote "deploy compose services" "
cd $remote_dir_q
[ -f .env ] || { echo '.env is required on VPS' >&2; exit 1; }
compose=$compose_cmd_q
\$compose config >/dev/null
if [ $skip_build -eq 0 ]; then
  \$compose build backend frontend
fi
\$compose up -d --wait postgres
if [ $migrate -eq 1 ]; then
  (cd apps/backend && mise exec -- make migrate-up)
fi
\$compose up -d --wait
\$compose ps
curl -fsS http://localhost:8080/healthz >/dev/null
curl -fsS http://localhost:3000/ >/dev/null
"

echo "deploy-vps: done"
