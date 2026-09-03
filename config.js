// 实时同步：学生每次打勾都会上传到 Supabase，教师端每 15 秒自动刷新。
// anon key 是前端公开密钥（只能按表的 RLS 策略读写 progress 表），不是管理员密钥。
window.PLAN_SYNC = {
  url: "https://pijljjeypqnbypjzfewn.supabase.co",
  key: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBpamxqamV5cHFuYnlwanpmZXduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg0NTA2NzcsImV4cCI6MjEwNDAyNjY3N30.aEeOZHWf3sad4Xa_juNjHGQ4LeXX55aCUMql7ENvYk8",
  table: "progress"
};
