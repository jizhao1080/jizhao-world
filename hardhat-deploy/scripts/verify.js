const hre = require("hardhat");

async function main() {
  // 检查参数
  if (process.argv.length < 4) {
    console.error("❌ 错误：请提供合约地址");
    console.error("\n使用方法:");
    console.error("  npx hardhat run scripts/verify.js --network mumbai <合约地址>");
    console.error("\n示例:");
    console.error("  npx hardhat run scripts/verify.js --network mumbai 0x1234567890abcdef...");
    process.exit(1);
  }

  const contractAddress = process.argv[3];
  
  console.log("🔍 开始验证合约源码...");
  console.log("========================================");
  console.log(` 合约地址: ${contractAddress}`);
  console.log("========================================\n");

  try {
    await hre.run("verify:verify", {
      address: contractAddress,
      constructorArguments: [], // JizhaoPoints没有构造函数参数
    });

    console.log("\n✅ 合约源码验证成功！");
    console.log(` 查看已验证的合约: https://mumbai.polygonscan.com/address/${contractAddress}#code`);
  } catch (error) {
    if (error.message.toLowerCase().includes("already verified")) {
      console.log("\n️  提示：该合约源码已经验证过了");
      console.log(` 查看合约: https://mumbai.polygonscan.com/address/${contractAddress}#code`);
    } else {
      console.error("\n❌ 验证失败:", error.message);
      console.error("\n可能的原因:");
      console.error("  1. POLYGONSCAN_API_KEY未配置或无效");
      console.error("  2. 网络问题，请稍后重试");
      console.error("  3. 合约地址不正确");
      process.exit(1);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ 脚本执行失败:", error);
    process.exit(1);
  });
