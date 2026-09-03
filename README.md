# IAL27W 刷题计划 — 说明

独立站点：`CIE/刷题计划/`（与错题本无关，单独部署）。

- **学生端：https://manguecn.github.io/ial27w-plan/**
- **教师端：https://manguecn.github.io/ial27w-plan/teacher.html**

改动后运行 `./deploy.sh`（或双击）即可上线，1–2 分钟生效。

## 计划怎么排的

- 考试（Cambridge Nov 2026 Zone 5 官方时间表）：**9702/23 Paper 2 → 10 月 14 日（周三）上午**；
  **9702/13 Paper 1 → 11 月 10 日（周二）上午**。截止 = 考试前 3 天：P2 **10/11**，P1 **11/7**。
- 9 月 4 日开始。每卷先刷 **阶段复习**（2019–21）第 1→11 章，再刷 **总复习**（2024–25）第 1→11 章。
- **周末量 = 平日量 × 2**。每套按题数估时（P1 每题 3–4 min，P2 每题 16–20 min，再加 25% 对答案和错题时间），
  依次填进每天的容量，得出每套的截止日，并标注「平日 / 周末」。
- **补充拓展**（2016–18）设为选做：有勾，不排日期，进度不计入「落后」。**日常作业**（2022–23）视为已完成。
- 估算负荷：9 月两卷并行时平日约 **2 小时**、周末约 **4 小时**；10 月 11 日 P2 截止后只剩 P1，平日约 50 min。
  想改节奏，改 `build_plan_site.py` 顶部的 `START / EXAMS / BUFFER / RATE`，重跑一遍即可。

## 学生怎么用

1. 打开 `…/plan/`，填一次姓名。
2. 顶部切 Paper 1 / 2 / 4。每套题三个勾：**做题 → 对答案 → 错题清零**，三个都勾上就算完成（会放彩带 🎉）。
3. 首页显示：完成率、距考试天数、**今天的任务**、落后 / 领先几套、连续打卡天数。
4. 换设备：右上「发给老师」里的进度码，粘到新设备「导入」即可。

## 老师怎么看进度

### 方式一（零设置）：进度码
学生点「发给老师」→ 复制「姓名: 进度码」→ 微信发你。打开 `teacher.html`，整段粘贴，
立刻得到：每人 P1/P2 完成率、**落后套数**（截止日已过却没完成的必做套）、点姓名展开每章热力图。

### 方式二（实时）：Supabase，约 10 分钟
静态网站没有后端，「实时监控」需要一个免费数据库。Supabase 免费版足够（用 GitHub 账号即可注册）。

1. https://supabase.com → New project（区域选 Singapore）。
2. 左侧 **SQL Editor** → 粘贴运行：
   ```sql
   create table progress (
     name text primary key,
     code text not null,
     updated_at timestamptz default now()
   );
   alter table progress enable row level security;
   create policy "read"   on progress for select using (true);
   create policy "insert" on progress for insert with check (true);
   create policy "update" on progress for update using (true);
   ```
3. **Settings → API**：复制 `Project URL` 和 `anon public` key。
4. 打开 `plan/config.js`，填进去：
   ```js
   window.PLAN_SYNC = { url: "https://xxxx.supabase.co", key: "eyJ…", table: "progress" };
   ```
5. `git push`。之后学生每打一个勾，30 秒内教师端自动刷新（右上角显示「实时同步中」），不需要再发进度码。

> anon key 是公开的（前端本来就能看到），表里只有姓名和一串进度位，没有敏感信息。
> 如果担心同学乱改别人的记录，可以把 update 策略去掉，改为只允许 insert，教师端取每人最新一条。

## 部署（独立仓库，和错题本互不影响）

```bash
cd "/Users/franking/Desktop/物理资源claude/CIE/刷题计划"
~/bin/gh repo create ial27w-plan --public --source=. --push
```

然后仓库 **Settings → Pages** → 分支 `main`、目录 `/ (root)` → Save。网址：
`https://<你的账号>.github.io/ial27w-plan/`（教师端加 `teacher.html`）。整站不到 1 MB，几秒钟就推完。

## 添加到手机主屏幕（像 App 一样用）

- **iPhone**：Safari 打开网址 → 底部「分享」→「添加到主屏幕」。
- **Android**：Chrome 打开 → 右上菜单 → 「添加到主屏幕」/「安装应用」。

图标是校徽（哈佛红底），打开后全屏、无浏览器地址栏。以后学生点桌面图标直接打勾。

## 改计划

考试日期、开始日期、提前天数、每题估时都在 `build_plan_site.py` 顶部；改完重跑：

```bash
python3 "专题练习/真题原文件/Topical/_state/build_plan_site.py" "CIE/错题本" "CIE/刷题计划"
```

学生已打的勾按「试卷-章-套组」存，重排日期不会丢。
