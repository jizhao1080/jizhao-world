# 寂照积分 - Hardhat一键部署工程

## 📦 项目简介

基于Hardhat的Polygon Mumbai测试网一键部署工具，用于部署**寂照积分（JZP）**ERC-20代币合约。

##  快速开始

### 1. 安装依赖

```bash
cd hardhat-deploy
npm install
```

### 2. 配置环境变量

复制 `.env.example` 为 `.env`：

```bash
copy .env.example .env
```

编辑 `.env` 文件，填入以下信息：

```env
# Polygon Mumbai测试网RPC节点
MUMBAI_RPC_URL=https://polygon-mumbai.rpc.thirdweb.com

# 您的钱包私钥（从MetaMask导出，不要带0x前缀）
PRIVATE_KEY=您的私钥_请替换此处

# Polygonscan API Key（用于验证合约）
# 获取地址：https://polygonscan.com/myapikey
POLYGONSCAN_API_KEY=您的API_Key_请替换此处
```

#### 🔑 如何获取私钥？
1. 打开MetaMask钱包
2. 点击账户 → 账户详情 → 导出私钥
3. 输入密码后复制私钥（**不要包含0x前缀**）

#### 🔑 如何获取Polygonscan API Key？
1. 访问 https://polygonscan.com/myapikey
2. 注册/登录账号
3. 创建新的API Key（免费）

### 3. 获取测试币

部署前需要MATIC测试币支付Gas费：

- **官方水龙头**: https://faucet.polygon.technology/
- **备选水龙头**: https://mumbaifaucet.com/

每次可领取0.5 MATIC，足够多次部署使用。

### 4. 一键部署合约

```bash
npx hardhat run scripts/deploy.js --network mumbai
```

部署成功后会显示：
- ✅ 合约地址
- 📦 交易哈希
-  Gas使用情况
- 🔗 区块浏览器链接

### 5. 验证合约源码（可选但推荐）

```bash
npx hardhat run scripts/verify.js --network mumbai <合约地址>
```

例如：
```bash
npx hardhat run scripts/verify.js --network mumbai 0x1234567890abcdef...
```

验证后可在Polygonscan上查看和交互合约。

## 📁 项目结构

```
hardhat-deploy/
├── contracts/              # 智能合约目录
│   └── JizhaoPoints.sol    # 寂照积分ERC-20合约
├── scripts/                # 部署脚本
│   ├── deploy.js           # 一键部署脚本
│   ── verify.js           # 合约验证脚本
── hardhat.config.js       # Hardhat配置文件
├── .env                    # 环境变量（需手动创建）
├── .env.example            # 环境变量模板
├── .gitignore              # Git忽略配置
├── package.json            # 项目依赖
└── README.md               # 本文档
```

## ️ 合约功能

### 核心特性
- **代币名称**: 寂照积分
- **代币符号**: JZP
- **小数位**: 0（整数积分）
- **每日上限**: 100积分/地址
- **铸造规则**: 1分钟禅修 = 1积分

### 主要函数

#### 查询函数
- `balanceOf(address)` - 查询余额
- `getTodayMinted(address)` - 查询今日已获积分
- `getRemainingDailyLimit(address)` - 查询今日剩余额度

#### 管理员函数
- `addMinter(address)` - 添加铸造者
- `removeMinter(address)` - 移除铸造者
- `mintByMinutes(address, uint256)` - 按分钟数铸造积分
- `setPaused(bool)` - 暂停/恢复合约

## 🛠️ 常见问题

### 1. ❌ Gas不足 / 余额不足
**原因**: 钱包中MATIC测试币不足  
**解决**: 
- 前往 https://faucet.polygon.technology/ 领取测试币
- 确保余额 > 0.01 MATIC

### 2. ❌ 网络连接超时
**原因**: RPC节点不稳定或网络问题  
**解决**:
- 更换RPC节点（修改 `.env` 中的 `MUMBAI_RPC_URL`）
- 备用节点: `https://rpc-mumbai.maticvigil.com`
- 检查网络连接

### 3. ❌ 私钥错误 / Invalid signer
**原因**: 私钥格式不正确  
**解决**:
- 确保私钥是64位十六进制字符串
- **不要**包含 `0x` 前缀
- 从MetaMask重新导出私钥

### 4. ❌ 合约验证失败
**原因**: API Key无效或网络问题  
**解决**:
- 检查 `POLYGONSCAN_API_KEY` 是否正确配置
- 前往 https://polygonscan.com/myapikey 重新生成
- 等待几分钟后重试

### 5. ❌ 编译错误
**原因**: Solidity版本不匹配  
**解决**:
- 确保合约使用 `pragma solidity ^0.8.20;`
- 检查 `hardhat.config.js` 中 `solidity: "0.8.20"`

## 🔒 安全提示

⚠️ **重要**:
1. **永远不要**将 `.env` 文件提交到Git仓库
2. **永远不要**在公开场合分享您的私钥
3. 生产环境建议使用硬件钱包或多签钱包
4. 定期轮换API Key

##  技术支持

如有问题，请联系如元（通义灵码）或查阅：
- Hardhat文档: https://hardhat.org/docs
- Polygon文档: https://docs.polygon.technology/
- ERC-20标准: https://eips.ethereum.org/EIPS/eip-20

---

**寂照世界 · 清净无扰** 
