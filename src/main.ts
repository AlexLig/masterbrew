import fastify from 'fastify';

const server = fastify();

server.get('/ping', async (request, reply) => {
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
      const error = username !== 'admin' ? new Error('Must be admin dude rly') : undefined;
      console.log(error)
      done(error);
    }
  },
  async (request, reply) => {
    const { username, password } = request.query;
    const customerHeader = request.headers['H-Custom'];
    // do something with request data

    return `logged in!`;
  }
);

server.listen(8080, (err, address) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log(`Server listening at ${address}`);
});
