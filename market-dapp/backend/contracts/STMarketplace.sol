pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2;

/// @title Simthunder Sim Racing Marketplace - first iteration
/// @notice Non-Cartesi blockchain code for registering sellers and sim racing assets

contract STMarketplace {    
    
    struct carSetup {
        uint256 itemId;
        string ipfsHash;
        string carBrand;
        string track;
        string simulator;
        string season;
        uint256 price;
        string _address;
    }
    
    struct skin {
        uint256 itemId;
        string ipfsHash;
        string carBrand;
        string simulator;
        uint256 price;
        string _address;
    }

    struct purchase {
        uint256 purchaseId;
        uint256 itemId;
        address buyer;
    }
    
    /// @notice Maps the 2 type of files
    mapping (address => carSetup[]) setupsBySeller;
    mapping (address => skin[]) skinsBySeller;
    
    /// @notice To track if seller address already exists
    mapping (address => bool) userExists;
    
    /// @notice Keep track of all seller addresses and existing files
    address[] private userAddresses;
    string[] private ipfsList;

    uint256 public carSetupCounter;
    uint256 public skinsCounter;
    uint256 public purchaseCounter;
    uint256 public itemCounter;

    /// @notice Keep track of all seller sales
    mapping (address => purchase[]) purchasesBySeller;

    /// @notice Events
    event ipfsSaved(string _ipfsHash, address _address);
    event carSetupSaved(address _address, string _ipfsHash, string _carBrand, string _track, string _simulator, string _season, uint256 _price);
    event skinSaved(address _address, string _ipfsHash, string _carBrand, string _simulator, uint256 _price);
    event newPurchaseRequest(address _address, uint256 itemId);
    
    /// @notice An empty constructor that creates an instance of the contract
    constructor() public{
        carSetupCounter = 0;
        skinsCounter = 0;
    }    
    
    /// @notice Registers a new car setup for sale
    function newCarSetup(string memory _ipfsHash, string memory _carBrand, string memory _track, string memory _simulator, string memory _season, uint256 _price) public {
        string memory string_address = addressToString(msg.sender);
        carSetup memory car = carSetup(itemCounter, _ipfsHash, _carBrand, _track, _simulator, _season, _price, string_address);
        itemCounter++;
        setupsBySeller[msg.sender].push(car);
        carSetupCounter++;
        ipfsList.push(_ipfsHash);
        emit carSetupSaved(msg.sender,_ipfsHash, _carBrand, _track, _simulator, _season, _price);
        if(userExists[msg.sender] == false) {
            userExists[msg.sender] = true;
            userAddresses.push(msg.sender);    
        }
    }
    
    /// @notice Registers a new car skin for sale
    function newSkin(string memory _ipfsHash, string memory _carBrand, string memory _simulator, uint256 _price) public {
        string memory string_address = addressToString(msg.sender);
        skin memory carSkin = skin(itemCounter, _ipfsHash, _carBrand,  _simulator, _price, string_address);
        itemCounter++;
        skinsBySeller[msg.sender].push(carSkin);
        skinsCounter++;
        ipfsList.push(_ipfsHash);
        emit skinSaved (msg.sender,_ipfsHash, _carBrand, _simulator, _price);
        if(userExists[msg.sender] == false) {
            userExists[msg.sender] = true;
            userAddresses.push(msg.sender);    
        }
    }

    /// @notice Registers a new purchase request
    function purchaseRequest(uint256 itemId) public returns(uint256) {
        uint256 purchaseId = purchaseCounter;
        purchaseCounter++;
        purchase memory newPurchase = purchase(purchaseCounter, itemId, msg.sender);
        
        purchasesBySeller[msg.sender].push(newPurchase);

        emit newPurchaseRequest(msg.sender,itemId);

        return purchaseId;
    }

    /// @notice Registers seller address
    function saveSeller(address _address) public returns(bool){
        if(userExists[_address] == false) {
            userExists[_address] = true;
            userAddresses.push(_address);
            return true;    
        }
        return false;
    }
    
    /// @notice Gets the list of all car setup files
    function getCarSetups() public view returns(carSetup[] memory allCars){
        carSetup[] memory cars = new carSetup[](carSetupCounter);
        uint256 i = 0;
        for(uint256 j = 0; j < userAddresses.length; j++) {
            address _address =  userAddresses[j];
            
            for(uint256 k = 0; k < setupsBySeller[_address].length; k++) {
                carSetup storage car = setupsBySeller[_address][k];
                cars[i] = car;
                i++;
            }
        }
        return cars;
    }
    
    /// @notice Gets the list of all skin files
    function getSkins() public view returns(skin[] memory allSkins){
        skin[] memory skins = new skin[](skinsCounter);
        uint256 i = 0;
        for(uint256 j = 0; j < userAddresses.length; j++) {
            address _address =  userAddresses[j];
            
            for(uint256 k = 0; k < skinsBySeller[_address].length; k++) {
                skin storage skin2 = skinsBySeller[_address][k];
                skins[i] = skin2;
                i++;
            }
        }
        return skins;
    }

    /// @notice Tests if sellers exists
    function isSeller(address _address) public view returns(bool) {
        return userExists[_address];
    }
    
    /// @notice Gets number of sellers
    function getNumberSellers() public view returns(uint256) {
        return userAddresses.length;
    }
    
    /// @notice Gets number of car setup files
    function getNumberCars() public view returns(uint256) {
        return carSetupCounter;
    }
    
    /// @notice Gets number of skin files
    function getNumberSkins() public view returns(uint256) {
        return skinsCounter;
    }
    
    /// @notice Utility method to return string from an address
    function addressToString(address _addr) public pure returns(string memory) 
    {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(51);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}