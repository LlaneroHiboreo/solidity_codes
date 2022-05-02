// SPDX-License-Identifier: MIT
pragma solidity >0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./erc20.sol";

contract Disney{

    //----------------------------------------- DECLARACIONES INICIALES -----------------------------------------//
    //Instancia al contrato token erc20
    ERC20Basic private token;

    //Inicia variable para guardar owner address
    address payable public owner;


    //Crear constructor: numero de tokens creados por la empresa disney
    constructor () public{
        token = new ERC20Basic(10000);
        owner  = msg.sender; //propietario que despliega el contrato
    }

    //estructura de datos para manejar a los clientes de disney
    struct cliente{
        uint tokens_comprados;
        string [] atracciones_subidas;
    }

    //Mapping para el registro de clientes
    mapping (address => cliente) public Clientes;

    //----------------------------------------- GESTION DE TOKENS -----------------------------------------//

    //Funciona para establecer el precio de un token
    function precioTokens(uint _numTokens) internal pure returns(uint){
        //devuelve la conversion de tokens a ethers: 1token=1ether
        return _numTokens *(1 ether);
    }

    //Numero de tokens disponible en el contrato inteligente
    function balanceOf() public view returns(uint){
        return token.balanceOf(address(this)); //Cuantos tokens quedan en el contrato ahora mismo?
    }

    // Funcion para comprar tokens en Disney
    function compraTokens(uint _numTokensComprar) public payable{
        //establecer el precio de los tokens
        uint coste = precioTokens(_numTokensComprar);

        //requiere al comprador tener la cantidad necesaria para comprar los tokens
        require(msg.value >= coste, "Compra menos tokens o paga mas ether");
        //Cambio al pago del cliente
        uint returnValue = msg.value - coste;
        //Disney retorna la cantidad de ethers al cliente
        msg.sender.transfer(returnValue);
        
        //Balance de tokens disponibles
        uint balance = balanceOf();
        require(_numTokensComprar < balance, "Compra un numero menor de tokens");
        
        //Transfiere el numero de tokens al cliente
        token.transfer(msg.sender, _numTokensComprar);
        //Registro de tokens comprados
        Clientes[msg.sender].tokens_comprados += _numTokensComprar;
    }

    //interesa en todo momento saber quantos tokens quedan a un cliente
    function misTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }

    //Funcion que permite generar mas tokens
    function generaTokens(uint _numTokens) public Unicamente(msg.sender){ //Unicamente puede ser ejecutada la funcion por Disney
        token.increaseTotalSupply(_numTokens);
    }


    //Crea modificador para controlar las funciones ejecutables por disney
    modifier Unicamente(address _direccion){
        require(_direccion == owner, "No tienes permisos para ejecutar"); //La direccion que ejecuta esta funcion debe ser igual a la address del creador del contrato
        _;
    }

    //----------------------------------------- GESTION DE DISNEY -----------------------------------------//
    // Creacion de eventos
    event disfruta_atrccion(string, uint, address);
    event nueva_atraccion(string, uint);
    event baja_atraccion(string);
    event nueva_comida(string, uint);
    event disfruta_comida(string, uint, address);
    // Estructura de la atraccion
    struct atraccion{
        string nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }

    // Estructura de la comida
    struct comidas{
        string nombre_comida;
        uint precio_comida;
    }

    // Mapping para relacionar un numbre de una atraccion con una estructura de datos de la atraccion
    mapping(string=>atraccion) public MappingAtracciones;

    // Mapping para relacionar un numbre de la comida con una estructura de datos de la comida
    mapping(string=>comidas) public MappingComidas;

    // Array para almacenar el nombre de las atracciones
    string [] Atracciones;

    // Array para almacenar el nombre de las comidas
    string [] Comidas;

    //Historial de los clientes. Mapping que relaciona un cliente con su historial
    mapping(address=> string[]) HistorialAtracciones;

    //Historial de los clientes. Mapping que relaciona un cliente con su historial de comidas
    mapping(address=> string[]) HistorialComidas;
    // Funcion para crear atracciones. Utiliza modifier "Unicamente" de esta manera solo disney(desplegador del contrato) puede utilizarla
    function NuevaAtraccion(string memory _nombreAtraccion, uint _precio) public Unicamente(msg.sender){
        // Añade info al mapping 
        MappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);
        // Almacena en array el nombre de la atraccion
        Atracciones.push(_nombreAtraccion);
        // Emision del evento para la nueva atraccion
        emit nueva_atraccion(_nombreAtraccion, _precio);
    }

    // Funcion para crear comidas. Utiliza modifier "Unicamente" de esta manera solo disney(desplegador del contrato) puede utilizarla
    function NuevaComida(string memory _nombreComida, uint _precio) public Unicamente(msg.sender){
        // Añade info al mapping 
        MappingComidas[_nombreComida] = comidas(_nombreComida, _precio);
        // Almacena en array el nombre de la comida
        Comidas.push(_nombreComida);
        // Emision del evento para la nueva comida
        emit nueva_comida(_nombreComida, _precio);
    }

    // Dar de baja atraccion. Solo ejecutable por disney
    function bajaAtraccion(string memory _nombreAtraccion) public Unicamente(msg.sender){
        // Requiere que exista la atraccion previamente a darla de baja
        require(MappingAtracciones[_nombreAtraccion].estado_atraccion == true, "Atraccion en baja o no existe");
        // Canviar estado de atraccion a false al mapping
        MappingAtracciones[_nombreAtraccion].estado_atraccion = false;
        // Emision del evento
        emit baja_atraccion(_nombreAtraccion);
    }

    // Funcion para visualizar atracciones de disney
    function AtraccionesDisponibles() public view returns(string [] memory){
        return Atracciones;
    }

    // Funcion para visualizar menu de disney
    function ComidasDisponibles() public view returns(string [] memory){
        return Comidas;
    }

    // Funcion para pagar precio de una atraccion y subirse
    function SubirseAtraccion(string memory _nomAtraccion) public{
        //Que precio tiene la atraccion en tokens?
        uint tokensAtraccion = MappingAtracciones[_nomAtraccion].precio_atraccion;
        // Existe o se ha dado de alta la atraccion? verifica el estado de atraccion
        require(MappingAtracciones[_nomAtraccion].estado_atraccion == true, "Atraccion no disponible en estos momentos");
        // Cliente tiene el numero de tokens necesario para subirse a la atraccion
        require(MappingAtracciones[_nomAtraccion].precio_atraccion <= misTokens(), "Necesitas mas tokens para subir a la atraccion.");
    
        /* El cliente paga atraccion en Tokens.
        - Ha sido necesario crear una funcion en erc20.sol con nombre transferenciaDisney
        debido a que en caso de usar transfer o transferfrom las direcciones que se escogian eran equivocadas.
        Ya que el msg.sender que recibia el metodo transferFrom era la direccion del contrato.
        */
        token.transferenciaDisney(msg.sender, address(this), tokensAtraccion);
        
        //almazena en el hisorial de atracciones del cliente
        HistorialAtracciones[msg.sender].push(_nomAtraccion);
        // Emision del evento
        emit disfruta_atrccion(_nomAtraccion, tokensAtraccion, msg.sender);
    }

    function ComprarComida(string memory _nomComida) public{
        //Que precio tiene la comida en tokens?
        uint tokensComida = MappingComidas[_nomComida].precio_comida;

        // Cliente tiene el numero de tokens necesario para subirse a la atraccion
        require(MappingComidas[_nomComida].precio_comida <= misTokens(), "Necesitas mas tokens para subir a la atraccion.");
    
        /* El cliente paga atraccion en Tokens.
        - Ha sido necesario crear una funcion en erc20.sol con nombre transferenciaDisney
        debido a que en caso de usar transfer o transferfrom las direcciones que se escogian eran equivocadas.
        Ya que el msg.sender que recibia el metodo transferFrom era la direccion del contrato.
        */
        token.transferenciaDisney(msg.sender, address(this), tokensComida);
        
        //almazena en el hisorial de atracciones del cliente
        HistorialComidas[msg.sender].push(_nomComida);
        // Emision del evento
        emit disfruta_comida(_nomComida, tokensComida, msg.sender);
    }


    // Funcion para visualizar historial completo de atracciones subidas por el cliente
    function Historial() public view returns(string [] memory){
        return HistorialAtracciones[msg.sender];
    }

    // Funcion para visualizar historial completo de comidas  por el cliente
    function HistorialComida() public view returns(string [] memory){
        return HistorialComidas[msg.sender];
    }


    // Funcion para que cliente pueda devolver tokens
    function DevolverTokens(uint _numTokens) public payable{
        // El numero de tokens a devolver es positivo
        require(_numTokens> 0, "Necesitas devolver cantidad positiva de tokens");
        // El usuario debe tener el numero de tokens que desea devolver
        require(_numTokens <= misTokens(), "No tienes el numero de tokens a devolver");
        // El ciente devuelve los tokens
        token.transferenciaDisney(msg.sender, address(this), _numTokens);
        // Devolucion de los ethers a los clientes
        msg.sender.transfer(precioTokens(_numTokens));
    }


}   
