import { app } from "./app";

const port = Number(process.env.PORT ?? 3000);

app.listen({
  port,
  hostname: '0.0.0.0'
})

console.log(`Csquare Connect API running at http://${app.server?.hostname}:${app.server?.port}`);