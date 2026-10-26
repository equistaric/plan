#!/bin/bash
# 一键部署学习系统：重新生成 index.html / teacher.html → 镜像到 iCloud 之外 → 提交 → 推送。
# GitHub Pages 会在 1–3 分钟内自动更新（网址不变：https://equistaric.github.io/plan/）。
# 用法：双击本文件，或终端运行 ./deploy.sh ["提交说明"]
# 题库重建（新切片 / 新分类）请先运行 build_wrongbook.py，再跑本脚本。
# Claude 和 Codex 都用这个脚本发布（分工见 AGENTS.md）：同一时间只允许一个发布；
# 构建后先跑全部回归 + 功能合约测试，不通过就不发布——谁的优化都不能把另一方的功能 / 题库修正冲掉。
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
STATE="$SRC/_源码"                      # 页面模板 + 构建脚本（2026-09-24 从 CIE/专题练习/…/_state 搬到这里）
LOCK="$HOME/Sites/.learn_deploy.lock"
mkdir -p "$HOME/Sites"
if ! mkdir "$LOCK" 2>/dev/null; then
  echo "❌ 另一个发布正在进行（$LOCK，$(cat "$LOCK/who" 2>/dev/null)）。等它结束再试；确认没有在跑才手动删掉这个文件夹。"; exit 1
fi
echo "$(date '+%m-%d %H:%M') ${1:-deploy}" > "$LOCK/who"
trap 'rm -rf "$LOCK"' EXIT
python3 "$STATE/build_plan_site.py" "$SRC"
if ! node --test "$STATE"/tests/*.test.cjs > /tmp/learn_deploy_tests.log 2>&1; then
  grep -E "^not ok|AssertionError|ℹ (pass|fail)" /tmp/learn_deploy_tests.log | head -30
  echo "❌ 测试没通过，没有发布。完整输出：/tmp/learn_deploy_tests.log"; exit 1
fi
echo "✓ 测试通过（$(grep -o 'ℹ pass [0-9]*' /tmp/learn_deploy_tests.log | cut -d' ' -f3) 项）"
# 这个文件夹在 iCloud 里，6000+ 张题图会把 git 拖到超时；所以先镜像到 ~/Sites 再推。
# 线上仓库是 equistaric/plan；equistaric/physics 是旧错题本站，不再更新。
DST="$HOME/Sites/learn"
[ -d "$DST/.git" ] || git clone -q https://github.com/equistaric/plan.git "$DST"
cd "$DST"
# 线上如果有本机没有的提交（别处推过），先停下，不覆盖
git fetch -q origin main 2>/dev/null || true
if git rev-parse -q --verify origin/main >/dev/null && ! git merge-base --is-ancestor origin/main HEAD; then
  echo "❌ 线上 equistaric/plan 有本机 ~/Sites/learn 没有的提交，先查清是谁推的，不要覆盖。"; exit 1
fi
rsync -a --delete --exclude .DS_Store --exclude '._*' --exclude .git --exclude _private --exclude _源码 --exclude '*.xlsx' --exclude AGENTS.md --exclude CLAUDE.md "$SRC/" "$DST/"
git add -A
if git diff --cached --quiet; then echo "没有改动，无需部署。"; exit 0; fi
git -c user.email=teacher@equistar -c user.name=Equistar commit -q -m "${1:-更新 $(date '+%Y-%m-%d %H:%M')}"
if [ -n "$GH_TOKEN" ]; then
  git -c credential.helper='!f(){ echo "username=x-access-token"; echo "password=$GH_TOKEN"; }; f' push -q origin main
else
  git push -q origin main
fi
echo "已推送。约 1–3 分钟后生效：https://equistaric.github.io/plan/"
