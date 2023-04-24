import express from 'express';
import bodyParser from 'body-parser';

const APP_PORT = process.env.APP_PORT || "5001";

const app = express();
app.use(bodyParser.json({ type: 'application/*+json' }));

app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

app.get('/dapr/subscribe', (req, res) => {
    res.json(process.env.CONTAINER_APP_NAME
        ? [
            {
                pubsubname: "pubsub-loadtest-sb",
                topic: "load",
                route: "receive"
            },
            {
                pubsubname: "pubsub-loadtest-eh",
                topic: "load",
                route: "receive"
            }
        ]
        : [
            {
                pubsubname: "pubsub-loadtest",
                topic: "load",
                route: "receive"
            }
        ]
    );
})

app.post('/receive', (req, res) => {
    console.log(req.body.data);
    res.sendStatus(200);
});

console.log(process.env);
app.listen(APP_PORT, () => {
    console.log('Receiver listening on port %d', APP_PORT);
});