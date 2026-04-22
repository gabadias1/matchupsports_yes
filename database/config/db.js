const { Pool } = require('pg');

//Estabelece a conexão com o banco de dados
const pool = new Pool({
    user: 'admin',
    host: 'localhost',
    database: 'reservas',
    password: 'admin',
    port: '5433' //Mudar a porta caso for rodar o projeto nas máquinas dos laboratórios da utfpr 
});

//Monta a query para a criação do 
const initDatabase = async () => {
    const query = `
        CREATE TABLE IF NOT EXISTS usuario(
            id SERIAL PRIMARY KEY,
            nome VARCHAR(100) NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            senha VARCHAR(255) NOT NULL,
            tipo VARCHAR(50) NOT NULL -- Tipo do usuário 'jogador' ou 'proprietario'
        );
        
        CREATE TABLE IF NOT EXISTS estabelecimento (
            id SERIAL PRIMARY KEY,
            proprietario_id INTEGER REFERENCES usuario(id),
            nome_local VARCHAR(150) NOT NULL,
            endereco TEXT NOT NULL
        );
        
        CREATE TABLE IF NOT EXISTS quadra (
            id SERIAL PRIMARY KEY,
            estabelecimento_id INTEGER REFERENCES estabelecimento(id),
            identificacao VARCHAR(100) NOT NULL,
            descricao TEXT
        );
        
        --Adicionando informações padrões (SEED)
        --Usuário:
        INSERT INTO usuario (nome, email, senha, tipo) 
        VALUES ('Carlos Silva Moranguinho', 'carlos@arena.com', 'senha123', 'proprietario');

        --Estabelecimento:
        INSERT INTO estabelecimento (proprietario_id, nome_local, endereco)
        VALUES ('1', 'Arena do Moranguinho', 'Av. Armelindo Trombini 500');

        --Quadra:
        INSERT INTO quadra (estabelecimento_id, identificacao, descricao)
        VALUES ('1', 'Quadra 1 - Beach Tennis', 'Arena de simples')
        ` ;

    try{
        await pool.query(query);
        console.log('Banco de dados inicializado!');
    }catch (error){
        console.error('Erro ao inicialiar o banco de dados!', error);
    }
}

initDatabase();

module.exports = pool;