import swaggerJSDoc from "swagger-jsdoc";

const options: swaggerJSDoc.Options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "API Matchup Sports",
      version: "1.0.0",
      description: "Documentação da API",
    },
    servers: [
      {
        url: "http://localhost:3000",
      },
    ],
  },
  apis: ["./src/routes/*.ts"], // onde ficam as rotas
};

export const swaggerSpec = swaggerJSDoc(options);