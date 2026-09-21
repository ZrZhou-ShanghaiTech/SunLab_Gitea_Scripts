# 课题组 Gitea 使用指南  
> 请根据所使用的操作系统选择对应的连接脚本：
>
> - macOS：`LabGit.command`
> - Windows：`LabGit.bat`
> - Linux：`LabGit.sh`

---

## 1. 使用目的

课题组使用自建 Gitea 作为内部代码托管与协作平台，用于管理科研代码、实验脚本、配置文件和项目版本。

Gitea 的主要用途包括：

- 代码版本管理
- 多人协作开发
- 历史修改追踪
- 分支管理
- Pull Request 与代码审阅
- 课题组内部私有项目管理

医学影像数据、模型权重和大规模实验结果建议继续保存在课题组数据存储中。Git 仓库主要保存代码、配置、文档和必要的小型资源文件。

常见的大文件类型可在 `.gitignore` 中统一排除，例如：

```text
*.nii
*.nii.gz
*.dcm
*.h5
*.mat
*.pth
*.pt
*.ckpt

data/
datasets/
checkpoints/
outputs/
logs/
```

---

# 2. 首次使用流程

首次使用课题组 Gitea 时，请依次完成以下步骤：

```text
1. 确认 Git 已安装
2. 运行对应操作系统的 LabGit 脚本
3. 登录课题组 Gitea
4. 生成个人 SSH Key
5. 将 SSH 公钥添加到 Gitea
6. 测试 SSH 认证
7. Clone 项目并开始使用 Git
```

完成首次配置后，日常使用流程通常为：

```text
运行 LabGit 脚本
→ git pull
→ 修改代码
→ git add
→ git commit
→ git push
```

---

# 3. Git 基础概念

Git 是分布式版本控制工具，用于记录代码的修改历史并支持多人协作。

常用命令如下：

```bash
git clone
git pull
git status
git add
git commit
git push
```

对应含义：

```text
git clone
    第一次将远程仓库下载到本地

git pull
    获取远程仓库中的最新提交

git status
    查看当前文件修改状态

git add
    将指定修改加入暂存区

git commit
    在本地创建一次版本记录

git push
    将本地提交上传到远程仓库
```

---

# 4. 首次配置 Git 用户信息

在一台新电脑上首次使用 Git 时，建议先配置姓名和邮箱：

```bash
git config --global user.name "你的姓名"
git config --global user.email "你的邮箱"
```

例如：

```bash
git config --global user.name "Zirui Zhou"
git config --global user.email "your_name@shanghaitech.edu.cn"
```

查看当前配置：

```bash
git config --global --list
```

---

# 5. macOS：使用 `LabGit.command`

## 5.1 添加执行权限

首次使用时，在 Terminal 中执行：

```bash
chmod +x LabGit.command
```

如果脚本位于桌面：

```bash
chmod +x ~/Desktop/LabGit.command
```

之后可以直接双击：

```text
LabGit.command
```

也可以在 Terminal 中运行：

```bash
./LabGit.command
```

---

## 5.2 输入服务器用户名与密码

脚本启动后会提示：

```text
SSH username:
```

请输入个人在课题组服务器上的 Linux 用户名，例如：

```text
zhangsan2026
```

随后系统会提示输入服务器密码：

```text
zhangsan2026@10.15.49.221's password:
```

输入密码后，脚本将建立 SSH Tunnel。

Terminal 在输入密码时通常不会显示字符，这是 OpenSSH 的正常行为。

---

## 5.3 连接建立后的访问方式

脚本会建立以下两个本地入口：

```text
127.0.0.1:3000
→ Gitea Web
```

以及：

```text
127.0.0.1:2222
→ Gitea SSH
```

连接成功后，浏览器会自动打开：

```text
http://127.0.0.1:3000/
```

---

## 5.4 重复运行

`LabGit.command` 支持重复运行。

当脚本检测到 Gitea 已经连接时，会直接打开网页：

```text
Lab Gitea is already connected.
```

此时无需再次建立 SSH Tunnel。

---

## 5.5 断开连接

macOS 版本使用后台 SSH Tunnel。

查看监听 3000 端口的进程：

```bash
lsof -nP -iTCP:3000 -sTCP:LISTEN
```

示例：

```text
ssh    12345    username    ...    TCP 127.0.0.1:3000 (LISTEN)
```

确认该 PID 对应 LabGit Tunnel 后，可以执行：

```bash
kill 12345
```

如果需要进一步确认进程命令：

```bash
ps -p 12345 -o pid,command=
```

---

# 6. Windows：使用 `LabGit.bat`

## 6.1 检查 OpenSSH 与 Git

打开 CMD 或 PowerShell：

```cmd
ssh -V
```

如果显示 OpenSSH 版本，即可使用 SSH。

检查 Git：

```cmd
git --version
```

如果尚未安装 Git，可安装 Git for Windows。

---

## 6.2 运行脚本

双击：

```text
LabGit.bat
```

脚本会提示：

```text
SSH username:
```

输入个人服务器用户名。

随后会打开一个新的命令行窗口：

```text
Lab Git SSH Tunnel
```

并提示：

```text
username@10.15.49.221's password:
```

输入服务器密码后即可建立连接。

---

## 6.3 使用期间保持 Tunnel 窗口运行

Windows 版本会保留：

```text
Lab Git SSH Tunnel
```

窗口。

该窗口负责维护：

```text
127.0.0.1:3000 → Gitea Web
127.0.0.1:2222 → Gitea SSH
```

使用 Gitea 期间请保持该窗口运行。

---

## 6.4 断开连接

关闭：

```text
Lab Git SSH Tunnel
```

窗口即可结束本次 SSH Tunnel。

---

## 6.5 重复运行

当 Gitea 已经连接时，脚本会检测现有连接并直接打开：

```text
http://127.0.0.1:3000/
```

---

# 7. Linux：使用 `LabGit.sh`

## 7.1 添加执行权限

首次使用时：

```bash
chmod +x LabGit.sh
```

运行：

```bash
./LabGit.sh
```

---

## 7.2 输入用户名与密码

脚本会提示：

```text
SSH username:
```

请输入个人服务器用户名。

随后输入服务器密码：

```text
username@10.15.49.221's password:
```

连接成功后，本地会提供：

```text
http://127.0.0.1:3000/
```

以及：

```text
127.0.0.1:2222
```

---

## 7.3 Linux 桌面环境

如果系统包含 `xdg-open`，脚本会自动打开默认浏览器。

也可以手动访问：

```text
http://127.0.0.1:3000/
```

---

## 7.4 Linux 纯命令行环境

在无桌面环境的 Linux 系统中，SSH Tunnel 仍可正常建立。

可以使用：

```bash
curl http://127.0.0.1:3000/
```

检查 Gitea Web 服务。

---

## 7.5 断开连接

查看监听进程：

```bash
ss -ltnp | grep :3000
```

或者：

```bash
lsof -nP -iTCP:3000 -sTCP:LISTEN
```

找到对应 SSH PID 后执行：

```bash
kill PID
```

---

# 8. 在 `sungpu01` 服务器本机使用 Gitea

如果当前已经登录：

```text
sungpu01
```

则可以直接访问 Gitea 的本机服务。

Gitea Web：

```text
127.0.0.1:3000
```

Gitea SSH：

```text
127.0.0.1:2222
```

可以在：

```text
~/.ssh/config
```

中添加：

```ssh
Host lab-gitea
    HostName 127.0.0.1
    Port 2222
    User git
    IdentityFile ~/.ssh/id_ed25519_gitea
    IdentitiesOnly yes
```

测试：

```bash
ssh -T lab-gitea
```

---

# 9. SSH Tunnel 与 Gitea SSH Key

课题组当前访问流程包含两类 SSH 使用场景：

```text
第一层
个人电脑
→ 课题组服务器
→ 用于建立 SSH Tunnel

第二层
Git
→ Gitea
→ 用于 clone / pull / push
```

第一层使用个人服务器账号进行认证。

第二层使用 Gitea 账户中绑定的 SSH Key 进行认证。

因此，能够打开 Gitea 网页后，还需要完成一次 SSH Key 配置，之后即可正常进行 Git 仓库操作。

---

# 10. SSH Key 使用原则

每位成员建议使用自己的 SSH Key。

典型配置方式：

```text
张三
└── ZhangSan-MacBook SSH Key

李四
└── LiSi-Windows SSH Key

王五
└── WangWu-Linux SSH Key
```

同一位成员拥有多台设备时，也可以为每台设备分别创建 Key，例如：

```text
ZhangSan-MacBook
ZhangSan-Windows
ZhangSan-Server
```

这样便于后续识别设备和管理访问权限。

---

# 11. macOS / Linux：生成 SSH Key

执行：

```bash
ssh-keygen -t ed25519
```

系统会提示：

```text
Enter file in which to save the key:
```

如果当前没有同名 Key，可以直接按 Enter 使用默认路径。

默认会生成：

```text
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```

其中：

```text
id_ed25519
```

为私钥，保存在个人设备中。

```text
id_ed25519.pub
```

为公钥，用于添加到 Gitea。

查看公钥：

```bash
cat ~/.ssh/id_ed25519.pub
```

通常格式类似：

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIxxxxxxxxxxxxxxxx user@computer
```

复制完整一行即可。

---

# 12. Windows：生成 SSH Key

在 CMD 或 PowerShell 中执行：

```cmd
ssh-keygen -t ed25519
```

默认保存路径：

```text
C:\Users\你的用户名\.ssh\
```

生成：

```text
id_ed25519
id_ed25519.pub
```

查看公钥：

```cmd
type %USERPROFILE%\.ssh\id_ed25519.pub
```

复制输出的完整一行。

---

# 13. 同时使用 GitHub 与课题组 Gitea

如果当前设备已经使用 GitHub SSH Key，可以单独为 Gitea 创建一把 Key：

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_gitea
```

将生成：

```text
~/.ssh/id_ed25519_gitea
~/.ssh/id_ed25519_gitea.pub
```

查看 Gitea 公钥：

```bash
cat ~/.ssh/id_ed25519_gitea.pub
```

推荐的对应关系：

```text
GitHub
→ ~/.ssh/id_ed25519

Lab Gitea
→ ~/.ssh/id_ed25519_gitea
```

这种方式便于分别管理两个平台的访问权限。

---

# 14. 将 SSH 公钥添加到 Gitea

运行对应的 LabGit 脚本后访问：

```text
http://127.0.0.1:3000/
```

登录个人 Gitea 账号。

依次进入：

```text
右上角头像
→ Settings
→ SSH / GPG Keys
→ Add Key
```

Title 建议填写设备名称，例如：

```text
ZhangSan-MacBook
```

或：

```text
ZhangSan-Sungpu
```

Key 中粘贴完整公钥：

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...
```

保存即可。

---

# 15. 测试 Gitea SSH Key

## 15.1 个人电脑

先运行 LabGit 脚本建立 SSH Tunnel。

然后执行：

```bash
ssh -p 2222 git@127.0.0.1
```

首次连接时可能出现：

```text
The authenticity of host '[127.0.0.1]:2222' can't be established.
Are you sure you want to continue connecting?
```

确认当前正在连接课题组 Gitea 后输入：

```text
yes
```

认证成功时会出现类似：

```text
Hi there, your_username! You've successfully authenticated ...
but Gitea does not provide shell access.
```

这表示 SSH Key 已经成功绑定到个人 Gitea 账号。

---

# 16. 为 Gitea 配置独立 SSH Key

如果 Gitea 使用：

```text
~/.ssh/id_ed25519_gitea
```

可以在：

```text
~/.ssh/config
```

中添加：

```ssh
Host lab-gitea
    HostName 127.0.0.1
    Port 2222
    User git
    IdentityFile ~/.ssh/id_ed25519_gitea
    IdentitiesOnly yes
```

测试：

```bash
ssh -T lab-gitea
```

配置成功后可以直接使用：

```bash
git clone lab-gitea:Medical-Imaging-AI/project.git
```

---

# 17. Windows SSH Config

Windows OpenSSH 配置文件通常位于：

```text
C:\Users\你的用户名\.ssh\config
```

可以添加：

```ssh
Host lab-gitea
    HostName 127.0.0.1
    Port 2222
    User git
    IdentityFile ~/.ssh/id_ed25519_gitea
    IdentitiesOnly yes
```

测试：

```cmd
ssh -T lab-gitea
```

---

# 18. 第一次 Clone 课题组项目

假设仓库地址为：

```text
Medical-Imaging-AI/301_7T
```

使用 SSH Alias：

```bash
git clone lab-gitea:Medical-Imaging-AI/301_7T.git
```

也可以直接使用：

```bash
git clone ssh://git@127.0.0.1:2222/Medical-Imaging-AI/301_7T.git
```

进入项目：

```bash
cd 301_7T
```

查看状态：

```bash
git status
```

---

# 19. 开始工作前同步最新代码

进入项目目录：

```bash
cd your-project
```

查看当前分支：

```bash
git branch
```

更新代码：

```bash
git pull
```

或者明确指定：

```bash
git pull origin main
```

建议在开始修改代码前先同步远程最新版本。

---

# 20. 提交代码

查看修改：

```bash
git status
```

例如：

```text
modified: train.py
modified: config.yaml
```

将文件加入暂存区：

```bash
git add train.py config.yaml
```

如果希望加入当前目录中的全部修改：

```bash
git add .
```

创建提交：

```bash
git commit -m "Update MRI reconstruction training config"
```

上传：

```bash
git push
```

首次推送当前分支时通常使用：

```bash
git push -u origin main
```

---

# 21. 分支开发

对于新功能、实验性修改或较大的代码调整，建议创建独立分支。

例如：

```bash
git switch -c feature/new-reconstruction-loss
```

较旧版本 Git 也可以使用：

```bash
git checkout -b feature/new-reconstruction-loss
```

完成修改后：

```bash
git add .
git commit -m "Add new reconstruction loss"
git push -u origin feature/new-reconstruction-loss
```

随后在 Gitea 中创建 Pull Request：

```text
Pull Requests
→ New Pull Request
→ feature/new-reconstruction-loss
→ main
```

---

# 22. 查看与切换分支

查看：

```bash
git branch
```

示例：

```text
* main
  feature/new-loss
```

`*` 表示当前所在分支。

切换：

```bash
git switch main
```

或：

```bash
git switch feature/new-loss
```

---

# 23. 查看远程仓库

执行：

```bash
git remote -v
```

示例：

```text
origin  lab-gitea:Medical-Imaging-AI/301_7T.git (fetch)
origin  lab-gitea:Medical-Imaging-AI/301_7T.git (push)
```

---

# 24. 同一个项目同时连接 GitHub 与 Gitea

一个本地仓库可以配置多个 Remote。

例如当前 GitHub 为：

```text
origin
```

添加 Gitea：

```bash
git remote add gitea lab-gitea:Medical-Imaging-AI/301_7T.git
```

查看：

```bash
git remote -v
```

向 GitHub 推送：

```bash
git push origin main
```

向课题组 Gitea 推送：

```bash
git push gitea main
```

如果希望 Gitea 作为主要 Remote，也可以采用：

```text
origin → Gitea
github → GitHub
```

---

# 25. `.gitignore` 建议

医学影像项目可以参考：

```gitignore
# Medical imaging data
*.nii
*.nii.gz
*.dcm
*.h5
*.mat

# Model weights
*.pth
*.pt
*.ckpt

# Data and experiment outputs
data/
dataset/
datasets/
checkpoints/
outputs/
results/
logs/

# Python
__pycache__/
*.pyc

# IDE
.vscode/
.idea/

# macOS
.DS_Store
```

在执行：

```bash
git add .
```

之前，建议通过：

```bash
git status
```

确认将要提交的文件符合项目管理要求。

---

# 26. 常见问题

## 26.1 `Permission denied (publickey)`

示例：

```text
git@127.0.0.1: Permission denied (publickey)
```

建议依次检查：

```bash
ssh -T lab-gitea
```

或者：

```bash
ssh -p 2222 git@127.0.0.1
```

同时确认个人公钥已经添加到：

```text
Gitea
→ Settings
→ SSH / GPG Keys
```

---

## 26.2 `Address already in use`

示例：

```text
bind [127.0.0.1]:3000: Address already in use
```

通常表示本地 3000 端口当前已经有监听进程。

先访问：

```text
http://127.0.0.1:3000/
```

如果能够正常打开 Gitea，则现有 Tunnel 已经可用。

macOS / Linux 可以查看：

```bash
lsof -nP -iTCP:3000 -sTCP:LISTEN
```

Windows 可以查看：

```cmd
netstat -ano | findstr :3000
```

---

## 26.3 Push 权限问题

请确认：

```text
个人 SSH Key 已正确绑定
个人账号已加入相应 Organization / Repository
当前账号具有 Write 权限
```

如需调整仓库权限，请联系课题组 Gitea 管理员。

---

## 26.4 `repository does not exist`

查看当前远程地址：

```bash
git remote -v
```

核对：

```text
Organization
用户名
Repository 名称
```

---

## 26.5 `git` 命令不存在

检查：

```bash
git --version
```

Ubuntu / Debian：

```bash
sudo apt update
sudo apt install git
```

macOS 可以安装 Xcode Command Line Tools：

```bash
xcode-select --install
```

Windows 可以安装 Git for Windows。

---

# 27. 推荐的日常工作流程

进入项目：

```bash
cd your-project
```

同步主分支：

```bash
git switch main
git pull
```

创建开发分支：

```bash
git switch -c feature/my-feature
```

修改完成后：

```bash
git status
git add .
git commit -m "Describe what was changed"
git push -u origin feature/my-feature
```

随后在 Gitea 中：

```text
Pull Requests
→ New Pull Request
→ feature/my-feature
→ main
```

---

# 28. Commit Message 建议

Commit Message 应简要说明本次修改内容。

推荐示例：

```text
Add 4x undersampling training config
Fix sensitivity map normalization
Update 3T-to-7T preprocessing pipeline
Add uncertainty evaluation metrics
Fix data loader memory issue
```

建议保持：

```text
简短
明确
可追溯
```

---

# 29. 账号与密钥管理

课题组代码管理建议遵循以下原则：

```text
每位成员使用个人 Gitea 账号
每位成员使用个人 SSH Key
不同设备可以分别配置 SSH Key
私钥保存在个人设备
公钥添加到 Gitea
服务器密码不写入 LabGit 脚本
Token、Password、API Key 使用环境变量或安全配置文件管理
```

私钥文件示例：

```text
~/.ssh/id_ed25519
~/.ssh/id_ed25519_gitea
```

公钥文件示例：

```text
~/.ssh/id_ed25519.pub
~/.ssh/id_ed25519_gitea.pub
```

Gitea 中添加的是公钥内容。

---

# 30. 最简使用流程

首次使用：

```text
① 安装/确认 Git
        ↓
② 运行 LabGit.command / LabGit.bat / LabGit.sh
        ↓
③ 登录 http://127.0.0.1:3000/
        ↓
④ 生成 SSH Key
        ↓
⑤ 将 .pub 公钥添加到 Gitea
        ↓
⑥ 测试 SSH
        ↓
⑦ git clone
```

日常使用：

```text
① 运行 LabGit 脚本
        ↓
② git pull
        ↓
③ 修改代码
        ↓
④ git status
        ↓
⑤ git add
        ↓
⑥ git commit
        ↓
⑦ git push
```

最常用命令：

```bash
git status
git pull
git add .
git commit -m "Describe your changes"
git push
```

---

# 31. 问题反馈时建议提供的信息

如需联系管理员排查问题，建议附上：

```bash
git --version
ssh -V
git remote -v
git status
```

SSH 认证相关问题还可以提供：

```bash
ssh -vT lab-gitea
```

排查信息中建议保留命令输出，同时省略密码、私钥内容和 Access Token。

---

# 32. 说明

课题组 Gitea 的使用可以分为三个部分：

```text
LabGit.command / LabGit.bat / LabGit.sh
    建立从个人电脑到课题组 Gitea 的访问通道

Gitea SSH Key
    完成个人身份认证并获得 Git 仓库访问能力

Git
    完成代码版本管理、同步和协作开发
```

完成首次配置后，后续使用流程与 GitHub 上的常规 Git 工作流程基本一致。
