// SPDX-License-Identifier: MIT 


pragma solidity ^0.8.0;


interface Isubmit {

// STRUCTURE 
    /**
     * @dev Valores de reputação e entregas dos endereços vinculados ao IDalunos e professors
     */

    //estrutura dos dados de quem submeteu
    struct dados{        
        string email;
        uint valuePay;
    }

 }