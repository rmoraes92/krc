import os
import logging

import httpx
import redis
import requests
from aiokafka import AIOKafkaProducer

from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse

from settings import settings


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


async def redis_client():
    return redis.Redis(host=settings.redis_host, port=6379, db=0)


async def kafka_producer():
    if not settings.kafka_servers:
        raise Exception(f"settings.kafka_servers is None")
    return AIOKafkaProducer(
        bootstrap_servers=settings.kafka_servers,
    )


async def is_krc_token_valid(token):
    async with httpx.AsyncClient() as client:
        try:
            logger.info(f"checking {token}")
            response = await client.post(
                f"http://{settings.api_proxy_host}/auth",
                json={"token": token}
            )
            if response.status_code != 200:
                return False  # Raise HTTPError for bad responses (4xx or 5xx)
            return True
        except Exception as ex:
            logger.error(ex)
            pass
    return False

class KRCTokenMiddleware:

    async def __call__(self, request: Request, call_next):
        if request.method == "OPTIONS":
            return await call_next(request)

        token = request.headers.get("X-KRC-Token")
        if not token:
            token = request.headers.get("X-Krc-Token")
        if not token:
            token = request.headers.get("x-krc-token")
        if not token:
            return JSONResponse(
                status_code=401, content={"message": "No token at X-KRC-Token"}
            )

        resp = requests.post(
            f"http://{settings.api_proxy_host}/auth", json={"token": token}
        )
        if resp.status_code != 200:
            return JSONResponse(
                status_code=400, content={"message": "X-KRC-Token is not authorized"}
            )

        request.scope["username"] = resp.json()["username"]
        return await call_next(request)
