// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PhiiCoin
 * @dev Kontrak ERC20 sederhana untuk token gaji (EWA).
 * Memiliki fungsi 'mint' yang hanya bisa dipanggil oleh Owner (Deployer).
 */
contract PhiiCoin is ERC20, Ownable {
    
    /**
     * @dev Sets the initial state of the contract: token name and symbol.
     * Juga mentransfer kepemilikan (Ownership) ke deployer.
     */
    constructor(address initialOwner) ERC20("Phii Coin", "PHII") Ownable(initialOwner) {
        // Kontrak ERC20 akan memiliki nama "Phii Coin" dan simbol "PHII"
    }

    /**
     * @dev Membuat (mencetak) token baru sejumlah 'amount' ke alamat 'to'.
     * Hanya bisa dipanggil oleh 'owner' kontrak.
     * @param to Alamat penerima token baru.
     * @param amount Jumlah token yang akan di-mint (dalam 'wei').
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
