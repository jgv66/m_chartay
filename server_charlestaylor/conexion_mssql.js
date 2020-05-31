// conexion a la base
module.exports = [
    { posicion: 0 },
	{
        empresa: 1, // CHARLES TAYLOR
        user: 'sa',
        password: 'SeniorsSFL2018',
        server: '172.28.1.23\\SOFTLAND',
        port: 1433,
        database: 'FGR',
        options: { encrypt: false }, // Use this if you're on Windows Azure
        pool: {
            max: 10,
            min: 0,
            idleTimeoutMillis: 10000
        }
    },
    {
        empresa: 2, // CHARLES TAYLOR AFFINITY
        user: 'sa',
        password: 'SeniorsSFL2018',
        server: '172.28.1.23\\SOFTLAND',
        port: 1433,
        database: 'EFL',
        options: { encrypt: false }, // Use this if you're on Windows Azure
        pool: {
            max: 10,
            min: 0,
            idleTimeoutMillis: 10000
        }
    },
    {
        empresa: 3, // FGR HANNA
        user: 'sa',
        password: 'SeniorsSFL2018',
        server: '172.28.1.23\\SOFTLAND',
        port: 1433,
        database: 'FGRHANNA',
        options: { encrypt: false }, // Use this if you're on Windows Azure
        pool: {
            max: 10,
            min: 0,
            idleTimeoutMillis: 10000
        }
    },
];