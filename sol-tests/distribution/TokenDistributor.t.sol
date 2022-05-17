// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8;

import "forge-std/Test.sol";

import "../../contracts/distribution/TokenDistributor.sol";
import "../../contracts/distribution/ITokenDistributorParty.sol";
import "../../contracts/globals/Globals.sol";
import "../TestUtils.sol";
import "./DummyTokenDistributorParty.sol";

contract TokenDistributorTest is Test, TestUtils {
  address immutable ADMIN_ADDRESS = address(1);
  address payable immutable DISTRIBUTION_ADDRESS = payable(address(2));
  IERC20 immutable ETH_TOKEN = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
  Globals globals;
  TokenDistributor distributor;
  DummyTokenDistributorParty dummyParty = new DummyTokenDistributorParty();
  
  function setUp() public {
    vm.deal(ADMIN_ADDRESS, 500 ether);
    globals = new Globals(ADMIN_ADDRESS);
    vm.prank(ADMIN_ADDRESS);
    globals.setAddress(LibGlobals.GLOBAL_DAO_WALLET, ADMIN_ADDRESS);
    // TODO: why had to do this? getting weird error
    distributor = TokenDistributor(payable(address(new TokenDistributor(globals))));
  }
  
  function testEthDistributionSimple() public {
    vm.prank(ADMIN_ADDRESS);
    globals.setUint256(LibGlobals.GLOBAL_DAO_DISTRIBUTION_SPLIT, 0.025 ether); // 2.5%

    payable(address(distributor)).transfer(1.337 ether);
    vm.prank(address(dummyParty)); // must create from party
    TokenDistributor.DistributionInfo memory ds = distributor.createDistribution(ETH_TOKEN);
    
    assertEq(DISTRIBUTION_ADDRESS.balance, 0);
    vm.prank(ADMIN_ADDRESS);
    distributor.partyDaoClaim(ds, DISTRIBUTION_ADDRESS);
    assertEq(DISTRIBUTION_ADDRESS.balance, 0.033425 ether);
    
    vm.deal(address(3), 5 ether);
    dummyParty.setOwner(address(3), 3);
    dummyParty.setShare(3, 0.34 ether);
    
    // 0.4432155
    
    console.log(address(3).balance);
    uint256 startGas = gasleft();
    vm.prank(address(3));
    distributor.claim(ds, 3, payable(address(3)));
    uint256 endGas = gasleft();
    
    // uint256 gasUsed = endGas - startGas;
    // console.log(gasUsed);
    // console.log(address(3).balance);
    
    
    
    // TODO: need to check ownerOf?
  }
  
  // TODO: emergency fns?
  
  // TODO: ERC 20
  
  // TODO: multiple distributions
  
  // TODO: what happens if called with zero amount?
}