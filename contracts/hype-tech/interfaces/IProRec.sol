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
        bool aluno;
        bool professor;
        bool banned; //banir endereço
    }

    //estrutura do 
    struct funder{        
        uint value;//valor investido
        uint valueLoyalty;
        uint reputation; //reputação
        address personID; //não pode criar outro NFT com o mesmo
        bool banned; //banir endereço
        bool isLoyalty;
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
        bool pause;//pausar financiamento
        uint idproject;
    }

    //recompensa por entrega -- cada entrega tem um valor correto de acordo com a etapa
    function deliveryReward(uint _IDentidade, uint value)payable  external;

    //entrega e próximo estágio -- atualiza o enum e registra
    function deliverystage(uint _IDentidade,address _from, uint _delivery) external;



  }