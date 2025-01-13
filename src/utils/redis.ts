import Redis from "ioredis";

const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', {
    connectTimeout: 1000,
    lazyConnect: false,
    maxRetriesPerRequest: 1,
});

export default redis;
