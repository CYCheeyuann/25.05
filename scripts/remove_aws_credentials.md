# 从 Git 仓库中移除暴露的 AWS 凭证（说明）

重要：在执行下列任一历史重写操作前，**请先在 AWS 控制台撤销（rotate）暴露的密钥**，因为即使从仓库历史中删除，密钥也可能已被窃取。

推荐流程（Git Bash / WSL）：

1. 在本地生成当前分支和标签的备份（可选）：

```bash
git branch backup-before-history-rewrite
git tag backup-before-history-rewrite
```

2. 在工作树中删除敏感文件并提交：

```bash
git rm --cached dvc_tutorial/.aws/credentials
git rm --cached cycheeyuan_accessKeys.csv || true
git commit -m "remove sensitive credential files from working tree"
```

3. 使用 `git filter-repo` 从历史中彻底删除文件（推荐，速度快且可靠）。如果没有安装，请先安装 `git-filter-repo`。

```bash
# 安装（在大多数系统上）：
pip install git-filter-repo

# 运行（在仓库根目录）
git filter-repo --path dvc_tutorial/.aws/credentials --path cycheeyuan_accessKeys.csv --invert-paths
```

说明：上面命令会删除历史中指定路径的所有版本。完成后，强制推送历史到远端：

```bash
git push origin --force --all
git push origin --force --tags
```

4. 备选：使用 BFG（更简单）

```bash
# 下载 BFG jar（https://rtyley.github.io/bfg-repo-cleaner/），然后运行：
java -jar bfg.jar --delete-files dvc_tutorial/.aws/credentials --delete-files cycheeyuan_accessKeys.csv
# 然后运行：
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push origin --force --all
git push origin --force --tags
```

5. 通知协作者：重写历史会改变 commit id，所有协作者需重新克隆或重置他们的本地仓库。

6. 最后：在远端仓库（如 GitHub）检查是否仍能看到敏感文件；如果文件仍存在，可能需要等待 GitHub 的垃圾回收或联系支持。

安全建议：
- 立即撤销暴露密钥并在 AWS 控制台新建并限制权限的最小权限密钥。
- 在本地将敏感凭证移动到未纳入版本控制的安全位置（如 `~/.aws/credentials`），并添加合适的 `.gitignore` 规则（已添加）。
