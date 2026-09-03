#!/bin/bash
# 一键部署学习系统：重新生成 index.html / teacher.html → 镜像到 iCloud 之外 → 提交 → 推送。
# GitHub Pages 会在 1–3 分钟内自动更新（网址不变：https://equistaric.github.io/plan/）。
# 用法：双击本文件，或终端运行 ./deploy.sh ["提交说明"]
# 题库重建（新切片 / 新分类）请先运行 build_wrongbook.py，再跑本脚本。
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
STATE="/Users/franking/Desktop/物理资源claude/CIE/专题练习/真题原文件/Topical/_state"
python3 "$STATE/build_plan_site.py" "$SRC"
# 这个文件夹在 iCloud 里，6000+ 张题图会把 git 拖到超时；所以先镜像到 ~/Sites 再推。
# 线上仓库是 equistaric/plan；equistaric/physics 是旧错题本站，不再更新。
DST="$HOME/Sites/learn"
mkdir -p "$HOME/Sites"
[ -d "$DST/.git" ] || git clone -q https://github.com/equistaric/plan.git "$DST"
rsync -a --delete --exclude .DS_Store --exclude '._*' --exclude .git --exclude _private "$SRC/" "$DST/"
cd "$DST"
git add -A
if git diff --cached --quiet; then echo "没有改动，无需部署。"; exit 0; fi
git -c user.email=teacher@equistar -c user.name=Equistar commit -q -m "${1:-更新 $(date '+%Y-%m-%d %H:%M')}"
if [ -n "$GH_TOKEN" ]; then
  git -c credential.helper='!f(){ echo "username=x-access-token"; echo "password=$GH_TOKEN"; }; f' push -q origin main
else
  git push -q origin main
fi
echo "已推送。约 1–3 分钟后生效：https://equistaric.github.io/plan/"
