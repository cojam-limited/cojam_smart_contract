pragma solidity 0.7.1;

/*
import "./ERC20/IERC20.sol";
import "./library/MarketManager.sol";
import "./library/Ownable.sol";
*/

//import "./kip7/KIP7Lockable.sol";
import "./kip7/KIP7Burnable.sol";
import "./library/Pausable.sol";
import "./library/Freezable.sol";
import "./library/MarketManager.sol";
import "./library/Ownable.sol";
import "./library/UserManager.sol";

contract CojamMarket is MarketManager, Ownable, UserManager {
    event TokenReceived(
        address receiver,
        uint256 market,
        uint256 betting,
        uint256 received
    );
    event RetrievedMarket(uint256 market, uint256 amount);
    event FinishMarket(uint256 market);
    event SuccessMarket(
        uint256 market,
        uint256 answer,
        uint256 creatorFee,
        uint256 cojamFee,
        uint256 charityFee,
        uint256 remains
    );
    event AdjournMarket(uint256 market);
    event ApproveMarket(uint256 market);
    event DraftMarket(
        uint256 market,
        string title,
        address creator,
        uint256 creatorFee,
        uint256 creatorFeePercentage,
        uint256 cojamFeePercentage,
        uint256 charityFeePercentage
    );
    event AddAnswerKeys(uint256 market, uint256[] answerKeys);
    event SetAccount(string key, address account);
    event Bet(uint256 market, uint256 answer, uint256 betting, uint256 tokens);

    event LockUser(address user);
    event UnlockUser(address user);

    using SafeMath for uint256;

    KIP7 baseToken;

    address internal _cojamFeeAccount;
    address internal _charityFeeAccount;
    address internal _remainAccount;

    constructor(address token) public {
        baseToken = KIP7(token);
    }

    /**
     * 마켓의 정보를 가져오는 함수
     * */
    function getMarket(uint256 marketKey)
        external
        view
        returns (
            uint256,
            string memory,
            address,
            string memory,
            uint256[] memory,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Market memory market = _getMarket(marketKey);
        uint256[] memory answerKeys = _getAnswerKeys(marketKey);
        return (
            marketKey,
            market.title,
            market.creator,
            market.status,
            answerKeys,
            market.approveTime,
            market.finishTime,
            market.successTime,
            market.adjournTime,
            market.marketTotalTokens,
            market.marketRemainTokens
        );
    }

    /**
     * 마켓의 수수료 정보를 가져오는 함수
     * */
    function getMarketFee(uint256 marketKey)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Market memory market = _getMarket(marketKey);
        return (
            market.creatorFee,
            market.creatorFeePercentage,
            market.cojamFeePercentage,
            market.charityFeePercentage
        );
    }

    /**
     * Answer의 정보를 가져오는 함수
     * */
    function getAnswer(uint256 answerKey)
        external
        view
        returns (
            uint256,
            uint256,
            uint256[] memory
        )
    {
        Answer memory answer = _getAnswer(answerKey); // Answer가 존재하는지 확인하기 위한 코드 (결과값이 사용되진 않음)
        return (answer.marketKey, answerKey, _getBettingKeys(answerKey));
    }

    /**
     * Betting 정보를 가져오는 함수
     * */
    function getBetting(uint256 bettingKey)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            uint256
        )
    {
        Betting memory betting = _getBetting(bettingKey);

        return (
            betting.marketKey,
            betting.answerKey,
            bettingKey,
            betting.voter,
            betting.tokens,
            betting.createTime
        );
    }

    /**
     * 수수료 계좌 등 정보를 가져오는 함수
     * */
    function getAccounts()
        external
        view
        returns (
            address,
            address,
            address,
            address
        )
    {
        return _getAccounts();
    }

    function _getAccounts()
        internal
        view
        returns (
            address,
            address,
            address,
            address
        )
    {
        return (_owner, _cojamFeeAccount, _charityFeeAccount, _remainAccount);
    }

    /**
     * 해당 마켓에서 사용자가 가져갈 수 있는 토큰을 계산하는 함수
     * */
    function availableReceiveTokens(uint256 marketKey, uint256 bettingKey)
        external
        view
        returns (uint256)
    {
        return _availableReceiveTokens(marketKey, bettingKey);
    }

    /**
     * 해당 마켓에서 사용자가 가져갈 수 있는 토큰을 가져오는 함수
     * */
    function receiveToken(uint256 marketKey, uint256 bettingKey)
        external
        returns (bool)
    {
        uint256 receiveTokens = _availableReceiveTokens(marketKey, bettingKey);

        Market storage market = _markets[marketKey];
        dividendToken(market, msg.sender, receiveTokens);
        _bettings[bettingKey].tokens = 0;

        emit TokenReceived(msg.sender, marketKey, bettingKey, receiveTokens);

        return true;
    }

    /**
     * 유효기간이 지난 마켓의 토큰들을 관리자가 회수할 수 있는지의 여부를 계산하는 함수
     * */
    function isRetrievable(uint256 marketKey) external view returns (bool) {
        return _isRetrievable(marketKey);
    }

    /**
     * 유효기간이 지난 마켓의 토큰들을 관리자가 회수하는 함수
     * */
    function retrieveTokens(uint256 marketKey)
        external
        onlyOwner
        returns (bool)
    {
        require(
            _isRetrievable(marketKey),
            "Market/Retrieve: Cannot Retrieve before 180 days"
        );

        Market storage market = _markets[marketKey];
        uint256 remains = market.marketRemainTokens;
        dividendToken(market, _remainAccount, remains);

        emit RetrievedMarket(marketKey, remains);

        return true;
    }

    /**
     * 사용자가 더이상 배팅을 할 수 없도록 마켓 상태를 finished로 변경하는 함수
     * */
    function finishMarket(uint256 marketKey) external onlyOwner returns (bool) {
        _finishMarket(marketKey);

        emit FinishMarket(marketKey);
        return true;
    }

    /**
     * 관리자가 마켓의 상태를 success으로 변경하고, 발생한 수수료를 각 계좌에 보내는 함수
     * */
    function successMarket(uint256 marketKey, uint256 answerKey)
        external
        onlyOwner
        returns (bool)
    {
        _setSuccessMarket(marketKey, answerKey);

        Market storage market = _markets[marketKey];

        uint256 marketRemainTokens = market.marketRemainTokens;

        uint256 creatorFee =
            market.creatorFee.add(
                (marketRemainTokens.mul(market.creatorFeePercentage)).div(100)
            );
        uint256 cojamFee =
            (marketRemainTokens.mul(market.cojamFeePercentage)).div(100);
        uint256 charityFee =
            (marketRemainTokens.mul(market.charityFeePercentage)).div(100);

        dividendToken(market, market.creator, creatorFee);
        dividendToken(market, _cojamFeeAccount, cojamFee);
        dividendToken(market, _charityFeeAccount, charityFee);

        emit SuccessMarket(
            marketKey,
            answerKey,
            creatorFee,
            cojamFee,
            charityFee,
            market.marketRemainTokens
        );

        return true;
    }

    /**
     * 관리자가 마켓의 상태를 adjourn으로 변경하는 함수
     * */
    function adjournMarket(uint256 marketKey)
        external
        onlyOwner
        returns (bool)
    {
        _setAdjournMarket(marketKey);

        emit AdjournMarket(marketKey);

        return true;
    }

    /**
     * 마켓 종료 후 계산 된 배당 토큰들을 사용자들에게 지급하는 함수
     * */
    function dividendToken(
        Market storage market,
        address to,
        uint256 token
    ) internal {
        market.marketRemainTokens = market.marketRemainTokens.sub(token);
        baseToken.transfer(to, token);
    }

    /**
     * 수수료 계좌를 관리자 권한으로 변경할 수 있는 함수
     * */
    function setAccount(string calldata key, address account)
        external
        onlyOwner
        returns (bool)
    {
        emit SetAccount(key, account);
        return _setAccount(key, account);
    }

    function _setAccount(string memory key, address account)
        internal
        returns (bool)
    {
        if (
            keccak256(abi.encodePacked(key)) ==
            keccak256(abi.encodePacked("cojamFeeAccount"))
        ) {
            _cojamFeeAccount = account;
        } else if (
            keccak256(abi.encodePacked(key)) ==
            keccak256(abi.encodePacked("charityFeeAccount"))
        ) {
            _charityFeeAccount = account;
        } else if (
            keccak256(abi.encodePacked(key)) ==
            keccak256(abi.encodePacked("remainAccount"))
        ) {
            _remainAccount = account;
        } else {
            return false;
        }
        return true;
    }

    /**
     * 사용자가 마켓에 베팅을 하는 함수
     * */
    function bet(
        uint256 marketKey,
        uint256 answerKey,
        uint256 bettingKey,
        uint256 tokens
    )
        external
        bettable(marketKey, answerKey, bettingKey, tokens)
        returns (bool)
    {
        _bet(marketKey, answerKey, bettingKey, msg.sender, tokens); // 데이터 변경이 실패하면 거래 전으로 돌리기
        baseToken.transferFrom(msg.sender, address(this), tokens);
        emit Bet(marketKey, answerKey, bettingKey, tokens);

        return true;
    }

    /**
     * 사용자가 해당 값으로 배팅이 가능한지 확인하는 함수
     * */
    function availableBet(
        uint256 marketKey,
        uint256 answerKey,
        uint256 bettingKey,
        uint256 tokens
    )
        external
        view
        bettable(marketKey, answerKey, bettingKey, tokens)
        returns (bool)
    {
        if (baseToken.balanceOf(msg.sender) < tokens) {
            // sender의 잔여 토큰이 충분해야 한다.
            return false;
        }

        return true;
    }

    /**
     * 관리자가 마켓을 추가하는 함수
     * 마켓 컨트랙트에 등록 하는 함수 draft
     **/
    function draftMarket(
        uint256 marketKey,
        address creator,
        string calldata title,
        uint256 creatorFee,
        uint256 creatorFeePercentage,
        uint256 cojamFeePercentage,
        uint256 charityFeePercentage
    ) external onlyOwner returns (bool) {
        _draftMarket(
            marketKey,
            creator,
            title,
            DRAFT_MARKET_KEY,
            creatorFee,
            creatorFeePercentage,
            cojamFeePercentage,
            charityFeePercentage
        );

        emit DraftMarket(
            marketKey,
            title,
            creator,
            creatorFee,
            creatorFeePercentage,
            cojamFeePercentage,
            charityFeePercentage
        );

        return true;
    }

    /**
     * 관리자가 마켓을 추가하는 함수
     * 승인이 된 마켓이므로 상태는 approve
     **/
    function approveMarket(uint256 marketKey)
        external
        onlyOwner
        returns (bool)
    {
        _approveMarket(marketKey, APPROVE_MARKET_KEY);

        emit ApproveMarket(marketKey);

        return true;
    }

    function addAnswerKeys(uint256 marketKey, uint256[] calldata answerKeys)
        external
        onlyOwner
        returns (bool)
    {
        _addAnswerKeys(marketKey, answerKeys);

        emit AddAnswerKeys(marketKey, answerKeys);
        return true;
    }

    /**
     * 관리자가 마켓을 추가하는 함수
     * 승인이 된 마켓이므로 상태는 approve
     **/
    /*    function approveMarket(uint256 marketKey, address creator, string memory title, uint256 creatorFeePercentage, uint256 creatorFee, uint256 cojamFeePercentage, uint256 charityFeePercentage, uint256[] memory answerKeys) public isOwner() isAllowedUser(creator) returns(bool) {
        _approveMarket(marketKey, creator, title, APPROVE_MARKET_KEY, creatorFeePercentage, creatorFee, cojamFeePercentage, charityFeePercentage, answerKeys);

        return true;
    }*/

    /**
     * 관리자가 사용자의 차단 여부를 확인하는 함수
     * */
    function isLock(address target) external view returns (bool) {
        return _containsLockUser(target);
    }

    /**
     * 관리자가 사용자를 차단하는 함수
     * */
    function lock(address[] memory targets)
        public
        onlyOwner
        returns (bool[] memory)
    {
        bool[] memory results = new bool[](targets.length);

        for (uint256 ii = 0; ii < targets.length; ii++) {
            require(_owner != targets[ii], "can not lock owner"); // 관리자 주소가 컨트롤 되어서는 안 된다!
            results[ii] = _insertLockUser(targets[ii]);
            emit LockUser(targets[ii]);
        }

        return results;
    }

    /**
     * 관리자가 사용자를 차단해제 하는 함수
     * */
    function unlock(address[] memory targets)
        public
        onlyOwner
        returns (bool[] memory)
    {
        bool[] memory results = new bool[](targets.length);

        for (uint256 ii = 0; ii < targets.length; ii++) {
            require(_owner != targets[ii], "can not unlock owner"); // 관리자 주소가 컨트롤 되어서는 안 된다!
            results[ii] = _removeLockUser(targets[ii]);
            emit UnlockUser(targets[ii]);
        }

        return results;
    }
}
