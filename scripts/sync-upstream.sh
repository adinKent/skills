#!/usr/bin/env bash
set -euo pipefail

# 取得專案根目錄 (scripts 的上一層)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM_DIR="${ROOT_DIR}/upstream"

# 定義要同步的 upstream 來源 (格式: "名稱|GitHub Repo|分支")
SOURCES=(
  "mattpocock|mattpocock/skills|main"
  "vercel|vercel-labs/agent-skills|main"
)

usage() {
  cat <<EOF
用法: $(basename "$0") [選項] [skill名稱...]

選項:
  -s, --source <name>   指定來源: mattpocock, vercel 或 all (預設: all)
  -l, --list            列出上游所有可用的 skill 名稱 (不進行下載)
  -a, --all             抓取指定來源的所有 skills (若未傳入 skill 名稱則預設為全部)
  -h, --help            顯示此說明

範例:
  $(basename "$0") --list                           # 列出 mattpocock 與 vercel 所有可用的 skills
  $(basename "$0") -s mattpocock --list             # 只列出 mattpocock 的 skills
  $(basename "$0") grill-me tdd                     # 只抓取 grill-me 與 tdd 到對應的 upstream 資料夾
  $(basename "$0") -s vercel react-best-practices   # 從 vercel 抓取 react-best-practices
  $(basename "$0") -s mattpocock                    # 抓取 mattpocock 的所有 skills
  $(basename "$0")                                  # 抓取所有來源的全部 skills
EOF
}

TARGET_SOURCE="all"
LIST_ONLY=false
SKILLS_TO_SYNC=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--source)
      TARGET_SOURCE="${2:-}"
      if [[ -z "${TARGET_SOURCE}" ]]; then
        echo "❌ 錯誤: --source 需要指定來源名稱 (mattpocock 或 vercel)" >&2
        exit 1
      fi
      shift 2
      ;;
    -l|--list)
      LIST_ONLY=true
      shift
      ;;
    -a|--all)
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "❌ 未知的選項: $1" >&2
      usage
      exit 1
      ;;
    *)
      SKILLS_TO_SYNC+=("$1")
      shift
      ;;
  esac
done

# 記錄每個指定 skill 是否至少在一個來源找到
FOUND_SKILLS=()

mark_found() {
  local found="$1"
  FOUND_SKILLS+=("${found}")
}

is_skill_found() {
  local target="$1"
  local item
  for item in "${FOUND_SKILLS[@]:-}"; do
    if [[ "${item}" == "${target}" ]]; then
      return 0
    fi
  done
  return 1
}

process_source() {
  local name="$1"
  local repo="$2"
  local branch="$3"
  local target_base="${UPSTREAM_DIR}/${name}"
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  # 下載最新 tarball 並解壓縮到暫存目錄
  if ! curl -fsSL "https://codeload.github.com/${repo}/tar.gz/refs/heads/${branch}" \
    | tar -xz -C "${tmp_dir}" --strip-components=1; then
    echo "❌ 無法下載 ${repo} (${branch})" >&2
    rm -rf "${tmp_dir}"
    return 1
  fi

  # 找出所有包含 SKILL.md 的資料夾
  local skill_files=()
  while IFS= read -r file; do
    [[ -n "${file}" ]] && skill_files+=("${file}")
  done < <(find "${tmp_dir}" -type f -name "SKILL.md" | sort)

  if [[ "${LIST_ONLY}" == true ]]; then
    echo "📦 [${name}] (${repo}) 可用的 Skills:"
    for skill_md in "${skill_files[@]:-}"; do
      local skill_dir
      skill_dir="$(dirname "${skill_md}")"
      local skill_name
      skill_name="$(basename "${skill_dir}")"
      echo "  - ${skill_name}"
    done
    echo ""
    rm -rf "${tmp_dir}"
    return 0
  fi

  # 若未指定特定 skill，則同步該來源的所有 skills
  if [[ ${#SKILLS_TO_SYNC[@]} -eq 0 ]]; then
    echo "==> 正在同步 [${name}] 的所有 skills 到 upstream/${name}/ ..."
    mkdir -p "${target_base}"
    for skill_md in "${skill_files[@]:-}"; do
      local skill_dir
      skill_dir="$(dirname "${skill_md}")"
      local skill_name
      skill_name="$(basename "${skill_dir}")"
      mkdir -p "${target_base}/${skill_name}"
      rsync -a --delete "${skill_dir}/" "${target_base}/${skill_name}/"
      echo "  ✓ ${name}/${skill_name}"
    done
  else
    # 只同步指定的 skills
    for requested in "${SKILLS_TO_SYNC[@]}"; do
      for skill_md in "${skill_files[@]:-}"; do
        local skill_dir
        skill_dir="$(dirname "${skill_md}")"
        local skill_name
        skill_name="$(basename "${skill_dir}")"

        if [[ "${skill_name}" == "${requested}" ]]; then
          mkdir -p "${target_base}/${skill_name}"
          rsync -a --delete "${skill_dir}/" "${target_base}/${skill_name}/"
          echo "  ✓ 已抓取 ${name}/${skill_name} -> upstream/${name}/${skill_name}"
          mark_found "${requested}"
        fi
      done
    done
  fi

  rm -rf "${tmp_dir}"
}

for entry in "${SOURCES[@]}"; do
  IFS='|' read -r name repo branch <<< "${entry}"
  if [[ "${TARGET_SOURCE}" != "all" && "${TARGET_SOURCE}" != "${name}" ]]; then
    continue
  fi
  process_source "${name}" "${repo}" "${branch}"
done

# 檢查是否有指定的 skill 沒找到
if [[ "${LIST_ONLY}" == false && ${#SKILLS_TO_SYNC[@]} -gt 0 ]]; then
  missing=0
  for requested in "${SKILLS_TO_SYNC[@]}"; do
    if ! is_skill_found "${requested}"; then
      echo "⚠️  找不到指定的 skill: '${requested}' (可使用 --list 查看可用清單)" >&2
      missing=1
    fi
  done
  exit "${missing}"
fi
