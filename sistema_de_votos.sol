//SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;



contract Votacion{

    //Direccion del propietario del contrato
    address public owner;

    //constructor
    constructor() public{
        owner = msg.sender;
    }

    //Relacion entre nombre de candidato y hash de sus datos personales
    mapping(string=>bytes32) ID_Candidato;

    //Relacion entre nombre candidato y numero de votos
    mapping(string=>uint) votos_candidato;

    //Lista de candidatos
    string [] candidatos;

    //Lista de hashes de la identidad de los votantes
    bytes32 [] votantes;

    //Funcion para presentarse a las votaciones
    function Representar(string memory _nombre, uint _age, string memory _ID) public {
        //calcular hash de los candidatos
        bytes32 hash_Candidato = keccak256(abi.encodePacked(_nombre, _age, _ID));
        //almacenar nombre ligado a hash
        ID_Candidato[_nombre] = hash_Candidato;
        //guarda el nombre de candidato dentro array
        candidatos.push(_nombre);
    }
    //funcion para printear candidatos presentados
    function Candidatos_presentados() public view returns(string [] memory){
        return candidatos;
    }

    //funcion para votar
    function votar(string memory _candidato) public{
        //get hash del votante
        bytes32 votante = keccak256(abi.encodePacked(msg.sender));
        //verifica si el votante ya a votado
        for(uint i=0; i<votantes.length; i++){
            require(votantes[i]!=votante, "Ya has votado previamente");
        }
        //guarda hash del votante dentro array de votantes
        votantes.push(votante);
        //añadir voto al votante seleccionado
        votos_candidato[_candidato]++;
    }
    //funcion para ver votos candidato
    function ver_votos(string memory _candidato) public view returns(uint){
        return votos_candidato[_candidato];
    }

    //funcion auxiliar para pasar de uint a string
    function uint2string(uint _i) internal pure returns(string memory _uintAsString){
        if(_i == 0){
            return "0";
        }

        uint j = _i;
        uint len;
        while(j!=0){
            len++;
            j/=10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while(_i != 0){
            bstr[k--] = byte(uint8(48+_i%10));
            _i/=10;
        }
        return string(bstr);
    }

    //funcion para ver votos de cada uno de los candidatos
    function verResultados() public view returns(string memory){
        //guarda en variable candidato y sus votos
        string memory resultados; 
        //actualiza string resultados y añade candidato que ocupa posicion 'i' del array candidatos
        for(uint i = 0; i<candidatos.length; i++){
            resultados = string(abi.encodePacked(resultados,  candidatos[i], ':', uint2string(ver_votos(candidatos[i]))));
        }
        return resultados;
    }

    //Funcion que devuelve candidato con mas votos
    function Ganador() public view returns(string memory){
        //declara variable ganador
        string memory ganador=candidatos[0];
        bool flag;
        //loop para checkear numero de votos
        for(uint i=1; i<candidatos.length; i++){
            if(votos_candidato[candidatos[i]] > votos_candidato[ganador]){
                ganador = candidatos[i];
                flag = false;
            }
            else{
                //si el numero de votos es igual, flag = true indica empate
                if(votos_candidato[candidatos[i]] == votos_candidato[ganador]){
                    flag = true;
                }
            }
        }

        if(flag == true){
            return "Hay un empate entre candidatos";
        }

        return ganador;
    }
}