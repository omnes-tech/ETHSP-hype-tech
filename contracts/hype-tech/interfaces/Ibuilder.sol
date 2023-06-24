// SPDX-License-Identifier: MIT 


pragma solidity ^0.8.0;


interface Ibuilder {

// STRUCTURE 
    /**
     * @dev Valores de reputação e entregas dos endereços vinculados ao IDalunos e professors
     */

    //estrutura dos dados de quem submeteu
    struct dados{        
        string email;
        bool prof;
        bool aluno;
    }

    // IERC5169 
    /**
     * @dev inserimos o https://eips.ethereum.org/EIPS/eip-5169
     */

    /// @dev This event emits when the scriptURI is updated, 
    /// so wallets implementing this interface can update a cached script
    event ScriptUpdate(string[] newScriptURI);

    /// @notice Get the scriptURI for the contract
    /// @return The scriptURI
    function scriptURI() external view returns(string[] memory);

    /// @notice Update the scriptURI 
    /// emits event ScriptUpdate(scriptURI memory newScriptURI);
    function setScriptURI(string[] memory newScriptURI) external;


 }