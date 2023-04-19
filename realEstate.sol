// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract RealEstate{
  address sellerId;// seller address
  address buyerId;// buyer address
  address LandID;// land address
  address landInspectorId; // land inspector address
  mapping(address =>  bool) public isSeller; // tells whether seller is verified or not
  mapping(address =>  bool) public isBuyer; // tells whether seller is verified or not
  mapping(address =>  bool) public isLand; // tells whether land is verified or not
  mapping (address => LandInspector) public _LandInspector; // sets values to the Land Inspector struct's parameters
  mapping(address =>  Seller) public sellerMapping; // sets values to the Seller struct's parameters
  mapping(address =>  Land) public land; // sets values to the Land struct's parameters
  mapping(address =>  Buyer) public buyerMapping; // sets values to the Buyer struct's parameters
  mapping (address => uint) public depositAmount;// This tracks the amount deposited by the buyer for buying the land

struct Seller 
{
 
  string Name;
  uint Age;
  string City;
  string CNIC;
  string Email;

}

struct Buyer 

{
 
 string Name;
  uint Age;
  string City;
  string CNIC;
  string Email;

}

 struct LandInspector 
 {
 
   address Id;
   string Name;
   uint Age;
   string Designation;

}

struct Land 
{
    address LandId;
    string Area;
    string City;
    string State;
    uint LandPrice;
    address PropertyID;

}

modifier OnlyLandInspector () 
{
    require (msg.sender == _LandInspector[landInspectorId].Id);
    _;
}

modifier OnlyOwner () 
{
    require (msg.sender == sellerId);
    _;
}

modifier OnlyBuyer () 
{
    require (msg.sender == buyerId);
    _;
}

constructor (string memory _name,
             uint _age, 
             string memory _designation) 
             {

     landInspectorId = msg.sender;
    _LandInspector[msg.sender].Id = msg.sender;
    _LandInspector[msg.sender].Name = _name;
    _LandInspector[msg.sender].Age = _age;
    _LandInspector[msg.sender].Designation = _designation;
          
            }

        /**
     * @dev RegisterSeller is used to register the seller.
     * Requirement:
     * - This function can be called by anyone who wants to become seller
     * @param key - Address of the seller 
     * @param _name - Name of the seller
     * @param _age - Age of the seller
     * @param _city - City of the seller
       @param _CNIC - CNIC of the seller
     * @param _email - email address of the seller
     *
    */           

function RegisterSeller(address key, 
                        string memory _name, 
                        uint _age, 
                        string memory _city, 
                        string memory _CNIC, 
                        string memory _email) public 
                          
                          {
    require ( key != buyerId, " You can't register yourself as seller" );
    sellerId = key;
    sellerMapping[key].Name = _name;
    sellerMapping[key].Age = _age;
    sellerMapping[key].City = _city;
    sellerMapping[key].CNIC = _CNIC;
    sellerMapping[key].Email = _email;
                          }           

      /**
     * @dev addLand is used to register the land.
     * Requirement:
     * - This function can be called by only verified seller.
     * @param _LandId - address of the land
     * @param _area - Any area of the city
     * @param _city -  Any city
     * @param _state - Any state
       @param _LandPrice - Price of the land
     * @param _PropertyID - Address of the owner of the land
     *
    */

function addLand(address _LandId,
                 string memory _area, 
                 string memory _city, 
                 string memory _state, 
                 uint _LandPrice, 
                 address _PropertyID) public 
                 {

    require (msg.sender == sellerId,"You are not allowed to add the land details" );
    require (isSeller[sellerId],"Seller is not verified"); 
    LandID = _LandId;   
    land[_LandId].LandId = LandID;
    land[_LandId].Area = _area;
    land[_LandId].City = _city;
    land[_LandId].State = _state;
    land[_LandId].LandPrice = _LandPrice;
    land[_LandId].PropertyID = _PropertyID;
                 
                 }

        /**
     * @dev RegisterBuyer is used to register the buyer.
     * Requirement:
     * - This function can be called by anyone who wants to become buyer
     * @param key - Address of the buyer
     * @param _name - Name of the buyer
     * @param _age - Age of the buyer
     * @param _city - City of the buyer
       @param _CNIC - CNIC of the buyer
     * @param _email - email of the buyer 
     *
    */

function RegisterBuyer(address key, 
                       string memory _name, 
                       uint _age, 
                       string memory _city, 
                       string memory _CNIC, 
                       string memory _email) public 
                       {
    require ( key != sellerId, " You can't register yourself as Buyer" );
    buyerId = key;
    buyerMapping[key].Name = _name;
    buyerMapping[key].Age = _age;
    buyerMapping[key].City = _city;
    buyerMapping[key].CNIC = _CNIC;
    buyerMapping[key].Email = _email;

                       }
     /**
     * @dev VerifyLand is used to verify the land.
     * Requirement:
     * - This function can be called by only Land Inspector.
     * @param value - This value could be true or false which will be passed by the Only land Inspector
    */                   
function VerifyLand(bool value) public OnlyLandInspector 
{
   isLand[LandID] = value;
}
      /**
     * @dev VerifyBuyer is used to verify the Buyer.
     * Requirement:
     * - This function can be called by only Land Inspector.
     * @param value - This value could be true or false which will be passed by the Only land Inspector
    */

function VerifyBuyer(bool value) public OnlyLandInspector 
  {
   isBuyer[buyerId] = value;
  }

       /**
     * @dev VerifySeller is used to verify the Seller.
     * Requirement:
     * - This function can be called by only Land Inspector.
     * @param value - This value could be true or false which will be passed by the Only land Inspector
    */
function VerifySeller(bool value) public OnlyLandInspector 
 {
  isSeller[sellerId] = value;
 }

/* This function tracks the total amount deposited by the buyer and is only callable 
by the buyer
*/

function depositPrice() public OnlyBuyer payable 
{
 depositAmount[buyerId] += msg.value;

}

/* This function checks if the buyer details and land details are verified then the ownership will
be transferred to the buyer and property id will be changed to the buyer's address. This function is only callable 
by the current landowner
*/
function TransferOwnership() public  OnlyOwner

 {
  require (isBuyer[buyerId],"Buyer is not verified");
  require (isLand[LandID],"Land is not verified");
  require (depositAmount[buyerId] >= land[LandID].LandPrice, "Amount is not enough" );
  depositAmount[buyerId] -= land[LandID].LandPrice;
  land[LandID].PropertyID = buyerId;

 }

}
