const hre = require("hardhat");

async function main() {
  console.log("🚀 开始部署寂照积分合约...");
  console.log("========================================");

  // 获取部署者地址
  const [deployer] = await hre.ethers.getSigners();
  console.log(`\n 部署账户: ${deployer.address}`);
  
  // 检查余额
  const balance = await deployer.getBalance();
  console.log(`💰 账户余额: ${hre.ethers.utils.formatEther(balance)} MATIC`);
  
  if (balance.lt(hre.ethers.utils.parseEther("0.01"))) {
    console.error("\n❌ 错误：MATIC余额不足，请先获取测试币！");
    console.error("   获取地址: https://faucet.polygon.technology/");
    process.exit(1);
  }

  // 部署合约
  console.log("\n 正在编译并部署合约...");
  const JizhaoPoints = await hre.ethers.getContractFactory("JizhaoPoints");
  const jizhaoPoints = await JizhaoPoints.deploy();

  await jizhaoPoints.deployed();

  const contractAddress = jizhaoPoints.address;
  const deployTx = jizhaoPoints.deployTransaction;
  
  console.log("\n✅ 合约部署成功！");
  console.log("========================================");
  console.log(`📄 合约名称: 寂照积分 (JZP)`);
  console.log(` 合约地址: ${contractAddress}`);
  console.log(`📦 部署交易: ${deployTx.hash}`);
  console.log(`⛽ Gas使用: ${deployTx.gasLimit.toString()}`);
  console.log(` 区块浏览器: https://mumbai.polygonscan.com/address/${contractAddress}`);
  console.log("========================================");

  // 等待确认
  console.log("\n⏳ 等待交易确认...");
  await deployTx.wait(2);
  console.log("✅ 交易已确认（2个区块）");

  // 验证合约信息
  console.log("\n📊 合约信息:");
  console.log(`   - 代币名称: ${await jizhaoPoints.name()}`);
  console.log(`   - 代币符号: ${await jizhaoPoints.symbol()}`);
  console.log(`   - 小数位: ${await jizhaoPoints.decimals()}`);
  console.log(`   - 总供应量: ${await jizhaoPoints.totalSupply()}`);
  console.log(`   - 部署者余额: ${await jizhaoPoints.balanceOf(deployer.address)}`);

  console.log("\n 下一步操作:");
  console.log(`   1. 在Polygonscan上验证合约源码:`);
  console.log(`      npx hardhat verify --network mumbai ${contractAddress}`);
  console.log(`   2. 添加铸造者权限:`);
  console.log(`      调用 addMinter(您的后端服务器地址)`);
  console.log(`   3. 开始铸造积分:`);
  console.log(`      调用 mintByMinutes(用户地址, 禅修分钟数)`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ 部署失败:", error);
    process.exit(1);
  });
