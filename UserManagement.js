const app = require('express')();
const PORT = 8080;

app.listen(
    PORT,
    () => console.log('it is alive on http://localhost:${PORT}')
)