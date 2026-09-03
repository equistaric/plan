#!/bin/bash
# 一键部署：重新生成站点 → 提交 → 推送。GitHub Pages 会在 1–2 分钟内自动更新。
# 用法：双击本文件，或终端运行 ./deploy.sh ["提交说明"]
set -e
cd "$(dirname "$0")"
STATE="/Users/franking/Desktop/物理资源claude/CIE/专题练习/真题原文件/Topical/_state"
python3 "$STATE/build_plan_site.py" "/Users/franking/Desktop/物理资源claude/CIE/错题本" "$(pwd)"
git add -A
if git diff --cached --quiet; then echo "没有改动，无需部署。"; exit 0; fi
git -c user.email=teacher@equistar -c user.name=Equistar commit -q -m "${1:-更新 $(date '+%Y-%m-%d %H:%M')}"
git push -q origin main
echo "已推送。约 1–2 分钟后生效：$(git remote get-url origin | sed -E 's#https://github.com/([^/]+)/([^/.]+).*#https://\1.github.io/\2/#')"
