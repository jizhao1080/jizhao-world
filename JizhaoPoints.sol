// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 寂照积分 (Jizhao Points)
 * @dev Polygon链上的功德积分代币
 *      - 1分钟禅修 = 1积分
 *      - 每日上限100积分
 *      - 只有授权地址可以铸造积分
 */
contract JizhaoPoints {
    // ==================== 基础信息 ====================
    string public constant name = "\u5bc2\u7167\u79ef\u5206"; // 寂照积分
    string public constant symbol = "JZP";
    uint8 public constant decimals = 0; // 积分为整数，无小数位
    uint256 public totalSupply;
    
    // ==================== 状态变量 ====================
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    // 授权的管理员地址（可以铸造积分）
    mapping(address => bool) public minters;
    
    // 记录每个地址每日已获得的积分
    mapping(address => mapping(uint256 => uint256)) public dailyMinted;
    
    // 每日上限
    uint256 public constant DAILY_LIMIT = 100;
    
    // 暂停状态
    bool public paused;
    
    // 合约所有者
    address public owner;
    
    // ==================== 事件 ====================
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount, uint256 timestamp);
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);
    event Paused(bool status);
    
    // ==================== 修饰器 ====================
    modifier onlyOwner() {
        require(msg.sender == owner, "JZP: 仅所有者可执行");
        _;
    }
    
    modifier onlyMinter() {
        require(minters[msg.sender], "JZP: 非授权铸造者");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "JZP: 合约已暂停");
        _;
    }
    
    // ==================== 构造函数 ====================
    constructor() {
        owner = msg.sender;
        minters[msg.sender] = true;
        paused = false;
    }
    
    // ==================== ERC-20 标准函数 ====================
    
    /**
     * @dev 转账
     */
    function transfer(address to, uint256 amount) external whenNotPaused returns (bool) {
        require(to != address(0), "JZP: 不能转入零地址");
        require(balanceOf[msg.sender] >= amount, "JZP: 余额不足");
        
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    /**
     * @dev 授权转账额度
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    /**
     * @dev 从授权账户转账
     */
    function transferFrom(address from, address to, uint256 amount) external whenNotPaused returns (bool) {
        require(to != address(0), "JZP: 不能转入零地址");
        require(balanceOf[from] >= amount, "JZP: 余额不足");
        require(allowance[from][msg.sender] >= amount, "JZP: 授权额度不足");
        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
    
    // ==================== 核心功能：铸造积分 ====================
    
    /**
     * @dev 为指定地址铸造积分（基于禅修时长）
     * @param recipient 接收积分的地址
     * @param minutes 禅修时长（分钟）
     */
    function mintByMinutes(address recipient, uint256 minutes) external onlyMinter whenNotPaused {
        require(recipient != address(0), "JZP: 不能转入零地址");
        require(minutes > 0, "JZP: 禅修时长必须大于0");
        
        // 计算今日已获得的积分
        uint256 today = _getCurrentDay();
        uint256 alreadyMinted = dailyMinted[recipient][today];
        
        // 检查是否超过每日上限
        require(alreadyMinted + minutes <= DAILY_LIMIT, "JZP: 超过每日100积分上限");
        
        // 铸造积分
        uint256 amount = minutes; // 1分钟 = 1积分
        balanceOf[recipient] += amount;
        totalSupply += amount;
        dailyMinted[recipient][today] += amount;
        
        emit Transfer(address(0), recipient, amount);
        emit Mint(recipient, amount, block.timestamp);
    }
    
    /**
     * @dev 直接铸造指定数量的积分
     */
    function mint(address recipient, uint256 amount) external onlyMinter whenNotPaused {
        require(recipient != address(0), "JZP: 不能转入零地址");
        require(amount > 0, "JZP: 铸造数量必须大于0");
        
        // 检查每日上限
        uint256 today = _getCurrentDay();
        uint256 alreadyMinted = dailyMinted[recipient][today];
        require(alreadyMinted + amount <= DAILY_LIMIT, "JZP: 超过每日100积分上限");
        
        balanceOf[recipient] += amount;
        totalSupply += amount;
        dailyMinted[recipient][today] += amount;
        
        emit Transfer(address(0), recipient, amount);
        emit Mint(recipient, amount, block.timestamp);
    }
    
    // ==================== 管理员功能 ====================
    
    /**
     * @dev 添加铸造者
     */
    function addMinter(address minter) external onlyOwner {
        require(minter != address(0), "JZP: 无效地址");
        require(!minters[minter], "JZP: 已是铸造者");
        
        minters[minter] = true;
        emit MinterAdded(minter);
    }
    
    /**
     * @dev 移除铸造者
     */
    function removeMinter(address minter) external onlyOwner {
        require(minters[minter], "JZP: 不是铸造者");
        
        minters[minter] = false;
        emit MinterRemoved(minter);
    }
    
    /**
     * @dev 暂停/恢复合约
     */
    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
        emit Paused(_paused);
    }
    
    /**
     * @dev 转移所有权
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "JZP: 无效地址");
        owner = newOwner;
    }
    
    // ==================== 查询功能 ====================
    
    /**
     * @dev 查询某地址今日已获得多少积分
     */
    function getTodayMinted(address user) external view returns (uint256) {
        return dailyMinted[user][_getCurrentDay()];
    }
    
    /**
     * @dev 查询某地址今日还可以获得多少积分
     */
    function getRemainingDailyLimit(address user) external view returns (uint256) {
        uint256 today = _getCurrentDay();
        uint256 alreadyMinted = dailyMinted[user][today];
        return DAILY_LIMIT - alreadyMinted;
    }
    
    // ==================== 内部函数 ====================
    
    /**
     * @dev 获取当前日期（Unix时间戳的天数）
     */
    function _getCurrentDay() internal view returns (uint256) {
        return block.timestamp / 86400; // 86400秒 = 1天
    }
}
