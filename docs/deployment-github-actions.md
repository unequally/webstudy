# GitHub 自动部署

每次把代码推送到 GitHub 的 `main` 分支后，`.github/workflows/deploy.yml` 会自动执行：

1. 安装依赖并运行 `npm run build`。
2. 将 `dist` 内容同步到 ECS 的 `/var/www/wyjlove/`。
3. 检查 Nginx 配置并 reload。

## 本地保存后自动推送

如果希望保存项目文件后自动触发上述流程，在 PowerShell 执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\start-auto-deploy.ps1
```

监控脚本会等待 5 秒合并同一轮文件修改，然后自动执行 `git add`、`git commit` 和 `git push`。它会忽略 `.git`、`node_modules` 和 `dist`。电脑关机或脚本停止时不会自动同步。

## 首次配置

在项目目录执行：

```powershell
git init
git add .
git commit -m "chore: initialize research workspace"
git branch -M main
git remote add origin https://github.com/你的账号/你的仓库.git
git push -u origin main
```

在 GitHub 仓库的 `Settings > Secrets and variables > Actions` 添加：

| Secret | 内容 |
| --- | --- |
| `ECS_HOST` | ECS 公网 IP 或域名 |
| `ECS_USER` | 登录用户，例如 `root` |
| `ECS_SSH_KEY` | 对应 ECS 登录用户的私钥全文 |
| `ECS_KNOWN_HOSTS` | 在本机执行 `ssh-keyscan -H ECS公网IP` 的完整输出 |

私钥只放在 GitHub Secrets，不要提交到仓库。服务器上的 `/var/www/wyjlove/` 应只用于这个网站，工作流的 `--delete` 会删除目标目录中不在新 `dist` 里的文件。
