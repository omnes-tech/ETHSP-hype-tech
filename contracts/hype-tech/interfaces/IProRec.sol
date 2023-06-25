// SPDX-License-Identifier: MIT 


pragma solidity ^0.8.0;


interface IProRec {

    enum Delivery{first, second, third, last}


    // STRUCTURE 
    /**
     * @dev Valores de reputação e entregas dos endereços vinculados ao IDalunos e professors
     */

    //estrutura dos alunos e professores
    struct builder{        
        uint delivery;//entrega de etapas
        uint reputation; //reputação
        address personID; //não pode criar outro NFT com o mesmo
        uint projectId;
        bool banned; //banir endereço
        string link;
    }

    //estrutura do 
    struct funder{        
        uint value;//valor investido
        uint valueLoyalty;
        uint reputation; //reputação
        address personID; //não pode criar outro NFT com o mesmo
        bool banned; //banir endereço
    }

    struct submit{        
        uint quantity;//entrega de etapas
        uint reputation; //reputação
        address personID; //não pode criar outro NFT com o mesmo
        bool banned; //banir endereço
    }

    struct Project{        
        uint quantity;//total de pessoas que estão financiando
        uint totalvalue; //total arrecadado
        address[] takers;
        bool pause;//pausar financiamento
        uint idproject;
        bool delivered;
    }

    //recompensa por entrega -- cada entrega tem um valor correto de acordo com a etapa
    // function deliveryReward(uint _IDentidade, uint value)payable  external;

    //entrega e próximo estágio -- atualiza o enum e registra
    // function deliverystage(uint _IDentidade,address _from, uint _delivery) external;



  }