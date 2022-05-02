// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

contract notas{
    //direccion del profesor
    address public profesor;

    //constructor
    constructor() public{
        profesor = msg.sender; //direccion del profesor es la direccion del que despliegue el contrato
    }

    //notas se tienen que relacionar con un ID/persona(hash)
    mapping (bytes32 => uint) Notas;

    //Alumnos que piden revision dexamen
    string [] revisiones;

    //Eventos
    event alumno_evaluado(bytes32);
    event evento_revision(string);

    //Funcion evaluar alumnos: permisos restringidos a funcion UnicamenteProfessor
    function Evaluar(string memory _idAlumno, uint _nota) public UnicamenteProfessor(msg.sender){
        //obten hash del ID del alumno
        bytes32 hash_id_alumno = keccak256(abi.encodePacked(_idAlumno));
        //map hash i nota
        Notas[hash_id_alumno] = _nota;
        //emision del evento
        emit alumno_evaluado(hash_id_alumno);
    }

    //crea modificador
    modifier UnicamenteProfessor(address _direccion){
        //requiere que la direccion introducida sea la misma al owner del contrato
        require(_direccion == profesor, "NO TIENES PERMISOS PARA EJECUTAR ESTA FUNCION");
        _;
    }

    //Funcion para ver las notas de alumno
    function verNotas(string memory _idAlumno) public view returns(uint){
        //Hash id del alumno
        bytes32 hash_id_alumno = keccak256(abi.encodePacked(_idAlumno));
        //Nota asociada al hash del alumno
        uint nota_alumno = Notas[hash_id_alumno];
        return nota_alumno;
    }

    //Funcion revision de examen
    function Revision(string memory _idAlumno) public{
        //coje el array creado anteriormente y almacena el alumno
        revisiones.push(_idAlumno);
        //emision del evento revision
        emit evento_revision(_idAlumno);
    }

    //Funcion para ver revisiones d'examen
    function VerRevisiones() public view UnicamenteProfessor(msg.sender) returns(string [] memory){
        return revisiones;
    }
}