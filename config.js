// 实时同步（可选）：填入 Supabase 项目的 URL 和 anon key 后，学生每次打勾都会上传，
// 教师端自动刷新。留空则退回“发给老师”同步码模式。见 plan/README.md。
window.PLAN_SYNC = { url: "", key: "", table: "progress" };
