pragma solidity ^0.8.20;

import {CacheToken} from "./CacheToken.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract CacheProtocol {
    address peerId;

    address owner;

    uint256 createTime;

    uint256 nodeNum;

    uint256 CurTotalOrderNum;

    uint256 TotalCollerate;

    mapping( address => uint256 ) public OrderNum;

    mapping( uint256 => uint256 ) public TermTotalOrder;

    mapping( address => NodeInfo ) public Node;

    mapping( uint256 => bool ) public TokenBonded;

    struct NodeInfo {
        bool created;
        uint256 collerate;
        uint256 tokenId;
        bytes peerId;
    }

    mapping(address => uint256) public CacheReward;

    mapping(address => uint256) public RewardRecord;

    mapping(bytes32 => OrderInfo) public Order;

    struct OrderInfo {
        uint256 value;
        address creater;
        address node;
        uint256 term;
    }

    event Staking(address indexed nodeAcc, uint256 indexed tokenId);

    event OrderPayment(bytes32 indexed orderId, address indexed nodeAcc);

    event Claim(address indexed nodeAcc, uint256 reward);

    event Exit(address indexed nodeAcc);

    constructor(address peerid) {
        peerId = peerid;
        owner = msg.sender;
        createTime = block.timestamp;
    }

    function isTokenOwner(address acc, uint256 tokenId) public view returns (bool) {
        address _owner = CacheToken(peerId).ownerOf(tokenId);

        return (_owner == acc);
    }

    function staking(address nodeAcc, address tokenAcc, uint256 tokenId, bytes memory _peerId, bytes memory _signature) external payable {
        if (msg.value < 3000000000000000000000) {
            revert("Insufficient pledge amount");
        }
        
        if (isTokenOwner(tokenAcc, tokenId) == false) {
            revert("Not the token holder");
        }

        bytes32 _msgHash = getMessageHash(nodeAcc, tokenId);
        bytes32 msgHash = toEthSignedMessageHash(_msgHash);
        if (verify(msgHash, _signature, tokenAcc) == false) {
            revert("verify signature failed");
        }

        Node[nodeAcc] = NodeInfo(true, msg.value, tokenId, _peerId);
        OrderNum[nodeAcc] = 0;
        CacheReward[nodeAcc] = 0;
        RewardRecord[nodeAcc] = 0;
        TotalCollerate += msg.value;
        TokenBonded[tokenId] = true;

        emit Staking(nodeAcc, tokenId);
    }

    function cacheOrderPayment(address nodeAcc) external payable {
        if (msg.value < 100000000000000000) {
            revert("Insufficient amount");
        }

        uint256 term = getCurrencyTerm();
        bytes32 orderId = _generateOrderId(nodeAcc);
        OrderInfo memory orderInfo = OrderInfo(
            msg.value,
            msg.sender,
            nodeAcc,
            term
        );

        Order[orderId] = orderInfo;
        uint256 orderNum = msg.value / 100000000000000000;
        OrderNum[nodeAcc] += orderNum;
        if (TermTotalOrder[term] == 0) {
            TermTotalOrder[term] = TermTotalOrder[term] + orderNum + CurTotalOrderNum;
        } else {
            TermTotalOrder[term] += orderNum;
        }
        CurTotalOrderNum += orderNum;
        CacheReward[nodeAcc] += (msg.value * 80 / 100);

        emit OrderPayment(orderId, nodeAcc);
    }

    function orderClaim(bytes32 orderId) external {
        OrderInfo memory _orderInfo = Order[orderId];
        require(_orderInfo.node == msg.sender, "not order node");
        delete Order[orderId];
    }

    function claim() external {
        uint256 term = getCurrencyTerm();
        require(RewardRecord[msg.sender] < term - 1, "Please wait until the next term to claim the reward");

        NodeInfo memory _nodeInfo = Node[msg.sender];
        require(_nodeInfo.created, "Cache node not registered");

        uint256 alpha = _getAlpha();

        uint256 totalOrderNum = nodeNum + TermTotalOrder[term - 1];

        uint256 avg = nodeNum / totalOrderNum;

        uint256 numOrder = OrderNum[msg.sender];

        uint256 rewardWord = CacheReward[msg.sender];

        uint256 rewardTerm = (
            ((avg + (alpha * (numOrder - avg))) / totalOrderNum * 2 / 10) + 
            (_nodeInfo.collerate / TotalCollerate * 2 /10)
        ) * 100000000000000000000000;
            
        uint256 issueReward = (rewardWord + rewardTerm) * 40 / 100;

        CacheReward[msg.sender] = rewardWord + rewardTerm - issueReward;

        payable(msg.sender).transfer(issueReward);
        RewardRecord[msg.sender] = term - 1;
        OrderNum[msg.sender] = 0;
        CurTotalOrderNum -= numOrder;

        emit Claim(msg.sender, issueReward);
    }

    function exit() external {
        NodeInfo memory _nodeInfo = Node[msg.sender];
        require(_nodeInfo.created, "Cache node not registered");

        payable(msg.sender).transfer(_nodeInfo.collerate);

        CurTotalOrderNum -= OrderNum[msg.sender];
        delete OrderNum[msg.sender];
        delete Node[msg.sender];
        delete RewardRecord[msg.sender];
        delete CacheReward[msg.sender];
        delete TokenBonded[_nodeInfo.tokenId];

        emit Exit(msg.sender);
    }

    function _generateOrderId(address nodeAcc) private view returns (bytes32) {
        return keccak256(abi.encodePacked(block.timestamp, nodeAcc));
    }

    function _getAlpha() private view returns (uint256) {
        if (2000 + (38 * getCurrencyTerm()) < 6000) {
            return (2000 + (38 * getCurrencyTerm()));
        } else {
            return 6000;
        }
    }

    function recoverSigner(bytes32 _msgHash, bytes memory _signature) public pure returns (address) {
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }
        return ecrecover(_msgHash, v, r, s);
    }

    function openRecover(bytes32 _msgHash, bytes memory _signature) public view returns (address) {
        address signer = ECDSA.recover(_msgHash, _signature);
        require(signer != address(0), "ECDSA: invalid signature");
        require(signer == msg.sender, "MyFunction: invalid signature");

        return signer;
    }

    function verify(bytes32 _msgHash, bytes memory _signature, address _signer) public pure returns (bool) {
        return recoverSigner(_msgHash, _signature) == _signer;
    }

    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    
    function getMessageHash(address _account, uint256 _tokenId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    function getCurrencyTerm() public view returns (uint256) {
        return ((block.timestamp - createTime) / 604800);
    }
}