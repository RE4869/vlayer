#!/bin/bash

# 作者: K2 节点教程分享 | Author: K2 Node Guide
# 推特: https://x.com/BtcK241918
# 电报频道: https://t.me/+FZHZVA_gEOJhOWM1

# 会话名
SCREEN_SESSION_NAME="vlayer_prove"

# 显示菜单
function show_menu() {
    clear
    echo "╔══════════════════════════════════════════════╗"
    echo "║      🚀 Vlayer 一键安装与管理脚本 | One-click Script     ║"
    echo "║ 作者: K2 节点教程分享 | Author: K2 Node Guide            ║"
    echo "║ 📢 Telegram: https://t.me/+FZHZVA_gEOJhOWM1             ║"
    echo "╚══════════════════════════════════════════════╝"
    echo "1️⃣ 安装环境 | Install Environment"
    echo "2️⃣ 查看日志 | View Logs (进入会话)"
    echo "3️⃣ 退出脚本 | Exit Script"
    echo "----------------------------------------------"
    echo -n "👉 请输入选择 [1-3] | Enter your choice [1-3]: "
}

# 安装环境函数
function install_environment() {
    echo "🔄 更新系统中... | Updating system..."
    sudo apt update -y

    echo "📦 安装基础依赖... | Installing dependencies..."
    sudo apt install -y unzip git curl screen

    # Node.js
    if ! command -v node &> /dev/null; then
        echo "🧱 安装 Node.js v20 | Installing Node.js v20..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt install -y nodejs
    else
        echo "✅ Node.js 已安装 | Already installed."
    fi

    # Foundry
    if ! command -v forge &> /dev/null; then
        echo "🔨 安装 Foundry | Installing Foundry..."
        curl -sSL https://foundry.paradigm.xyz | bash
        export PATH="$HOME/.foundry/bin:$PATH"
        echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> ~/.bashrc
        foundryup
    else
        echo "✅ Foundry 已安装 | Already installed."
    fi

    # Bun
    if ! command -v bun &> /dev/null; then
        echo "⚡ 安装 Bun | Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
        echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc
    else
        echo "✅ Bun 已安装 | Already installed."
    fi

    # Vlayer 安装
    if ! command -v vlayer &> /dev/null; then
        echo "🌐 安装 Vlayer | Installing Vlayer..."
        curl -SL https://install.vlayer.xyz | bash
    else
        echo "✅ Vlayer 已安装 | Already installed."
    fi

    # 初始化项目
    cd /root
    echo "📁 初始化 simple 项目 | Initializing project..."
    vlayer init simple --template simple-web-proof --force

    # 构建合约
    cd /root/simple
    forge build

    # 安装依赖
    cd /root/simple/vlayer
    bun install

    echo "🔐 请输入你的 JWT | Please input your JWT:"
    read -p "VLAYER_API_TOKEN= " JWT

    echo "🔑 请输入你的 EVM 私钥 | Please input your EVM private key:"
    read -p "EXAMPLES_TEST_PRIVATE_KEY= " PRIVATE_KEY

    # 保存配置
    cat <<EOL > /root/simple/vlayer/.env.testnet.local
VLAYER_API_TOKEN=$JWT
EXAMPLES_TEST_PRIVATE_KEY=$PRIVATE_KEY
EOL

    echo "✅ 配置文件已保存 | Config saved: /root/simple/vlayer/.env.testnet.local"

    # 创建并保持会话运行
    echo "🚀 启动后台任务并每 10 分钟运行一次 | Starting prove:testnet every 10 minutes..."
    screen -dmS $SCREEN_SESSION_NAME bash -c 'while true; do cd /root/simple/vlayer && bun run prove:testnet; sleep 600; done'

    echo "✅ 已启动会话 $SCREEN_SESSION_NAME"
    echo "📺 你可以通过菜单进入查看日志 | Use menu to view logs."
    echo "📌 提示：按 CTRL+A+D 可退出 screen 会话 | Press CTRL+A+D to exit screen view"
    read -p "👉 按回车键返回菜单 | Press Enter to return to menu..."
}

# 查看日志（直接进入会话）
function view_logs() {
    if screen -list | grep -q "$SCREEN_SESSION_NAME"; then
        echo "📺 正在进入会话 screen -r $SCREEN_SESSION_NAME..."
        echo "📌 提示：按 CTRL+A+D 可退出 screen 会话 | Press CTRL+A+D to exit"
        sleep 2
        screen -r $SCREEN_SESSION_NAME
    else
        echo "❌ 没有运行中的会话 | No active screen session found."
        read -p "👉 按回车返回菜单 | Press Enter to return to menu..."
    fi
}

# 主循环
while true; do
    show_menu
    read choice
    case $choice in
        1) install_environment ;;
        2) view_logs ;;
        3) echo "👋 再见！| Goodbye!" ; break ;;
        *) echo "❌ 无效选择 | Invalid choice." ;;
    esac
done
