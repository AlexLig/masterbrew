import fastify from 'fastify';
import express from 'express';

const server = fastify();

server.get('/ping', async () => {
  return 'pong\n';
});

type LoginQuery = {
  username: string;
  password: string;
};
type LoginHeaders = {
  'H-Custom': string;
};

server.get<{
  Querystring: LoginQuery;
  Headers: LoginHeaders;
}>(
  '/auth',
  {
    preValidation: (request, reply, done) => {
      const { username, password } = request.query;
      // only validate `admin` account
      const error =
        username !== 'admin' ? new Error('Must be admin dude rly') : undefined;
      done(error);
    }
  },
  async (request) => {
    const { username, password } = request.query;
    const customerHeader = request.headers['H-Custom'];
    // do something with request data

    return `logged in!`;
  }
);

server.listen(8080, (err) => {
  if (err) {
    process.exit(1);
  }
});

const app = express();

const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
