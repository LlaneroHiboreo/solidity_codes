// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";



//Juan Gabriel ---> 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//Juan Amengual ---> 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//María Santos ---> 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

//Interface de nuestro token ERC20
interface IERC20{
    //Devuelve la cantidad de tokens en existencia
    function totalSupply() external view returns (uint256);

    //Devuelve la cantidad de rokens para una dirección indicada por parámetro
    function balanceOf(address account) external view returns (uint256);

    //Devuelve el número de token que el spender podrá gastar en nombre del propietario (owner)
    function allowance(address owner, address spender) external view returns (uint256);

    //Devuelve un valor booleano resultado de la operación indicada
    function transfer(address recipient, uint256 amount) external returns (bool);

    //Devuelve un valor booleano con el resultado de la operación de gasto
    function approve(address spender, uint256 amount) external returns (bool);

    //Devuelve un valor booleano con el resultado de la operación de paso de una cantidad de tokens usando el método allowance()
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



    //Evento que se debe emitir cuando una cantidad de tokens pase de un origen a un destino
    event Transfer(address indexed from, address indexed to, uint256 value);

    //Evento que se debe emitir cuando se establece una asignación con el mmétodo allowance()
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//Implementación de las funciones del token ERC20
contract ERC20Basic is IERC20{

    string public constant name = "ERC20BlockchainAZ";
    string public constant symbol = "ERC";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);


    using SafeMath for uint256;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint256 totalSupply_;

    constructor (uint256 initialSupply) public{
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }


    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }

    function allowance(address owner, address delegate) public override view returns (uint256){
        return allowed[owner][delegate];
    }

    function transfer(address recipient, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}

/******************************
COMMENTED VERSION BUT WITH BUGS
                |
                Y
******************************/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

//cartera principal---->0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//cartera1 ---> 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//cartera2 ---> 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
//cartera3 ---> 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
//interface de nuesto token erc20
interface IERC20{
    //funcion que devuelve la cantidad de tokens en existencia (Security function)
    function totalSupply() external view returns(uint256); //implementada en el contrato

    //Funcion que devuelve la cantidad de tokens dada una direccion
    function balanceOf(address account)  external view returns(uint256);

    //Devuelve el numero de tokens que el spender puede gastar en nombre del propietario (owner)
    function allowance(address owner, address spender) external view returns(uint256);

    //Funcion que devuelve bool resultado de una transferencia
    function transfer(address recipient, uint256 amount) external returns(bool);

    //Funcion que devuelve bool con el resultado de la operacion de gasto(emisor puede gastar?)
    function approve(address spender, uint256 amount) external returns(bool);

    //Funcion que devuelve bool con el resultado de la operacion de paso a una cantidad de tokens usando la funcion allowance()
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

    //Evento que se debe emitir cuando una cantidad de tokens pase de un origen a un destino
    event Transfer(address indexed from, address indexed to, uint256 value);

    //Evento que se debe emitir cuando se establece una asignacion con el metodo allowance
    event Approval(address indexed owner, address indexed spender, uint256 value);
} 

//contract que adquire propiedades de la interface. Funciones del token
contract ERC20Basic is IERC20{
    
    //Define name token
    string public constant name = "ERC20BlockchainAZ";
    string public constant symbol = "ERC";
    uint8 public constant decimals = 18;
    
    //Eventos
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);

    //Crear mappings
    //cada direccion le correspondra tantos tokens
    mapping(address=>uint) balances;
    //cada direccion le corresponde un mapping de direccion con cantidades
    mapping(address=>mapping(address=>uint)) allowed;
    
    //define total supply, no se puede modificar
    uint256 totalSupply_; //la barrabaixa es per veurel millor

    //define constructor
    constructor (uint256 initialSupply) public{
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }

    //invoca libreria safemath para todas las operaciones con uint256
    using SafeMath for uint256;

    function totalSupply() public override view returns(uint256){
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTokensAmount) public{
        totalSupply_+= newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }
    //Funcion que devuelve la cantidad de tokens dada una direccion
    function balanceOf(address tokenOwner) public override view returns(uint256){
        return balances[tokenOwner];
    }

    //Devuelve el numero de tokens que el spender puede gastar en nombre del propietario (owner)
    function allowance(address owner, address delegate) public override view returns(uint256){
        return allowed[owner][delegate];
    }

    //Funcion que devuelve bool resultado de una transferencia
    function transfer(address recipient, uint256 numTokens) public override returns(bool){
        require(numTokens<=balances[msg.sender]); //primero chequeas que tienes tokens
        balances[msg.sender] = balances[msg.sender].sub(numTokens); //segundo te quitas el numero de tokens
        //si giras el orden, nuevos tokens puede existir
        balances[recipient] = balances[recipient].add(numTokens);
        
        //notificar al sistema distribuido de la transaccion
        emit Transfer(msg.sender, recipient, numTokens);

        return true;
    }

    //Funcion que devuelve bool con el resultado de la operacion de gasto(emisor puede gastar?)
    function approve(address delegate, uint256 numTokens) public override returns(bool){
        
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    //Funcion que devuelve bool con el resultado de la operacion de transaccion de una cantidad de tokens usando la funcion allowance()
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns(bool){
        //propietario(owner) requiere que disponga del numero de tokens qque el comprador(buyer) quiere comprar
        require(numTokens <= balances[owner]);
        //token los vende el intermediaro no el owner, el numTokens debe ser igual o menor a la cantidad delegada 
        require(numTokens <= allowed[owner][msg.sender]);

        //primero quitas los tokens al owner
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        //segundo añades el numero de tokens al comprador
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }


}