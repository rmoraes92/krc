import json
from uuid import uuid4
from typing import Annotated

from fastapi import (
    FastAPI,
    Depends,
)
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware

from models import *
from clients import *

app = FastAPI()

origins = [
    "*",
    "http://localhost",
    "http://localhost:8080",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

krctokenmiddleware = KRCTokenMiddleware()
app.add_middleware(
    BaseHTTPMiddleware,
    dispatch=krctokenmiddleware,
)

@app.post("/messages")
async def new_message(
    req: Request,
    msg: NewMessage,
    kp: Annotated[AIOKafkaProducer, Depends(kafka_producer)],
    r: Annotated[redis.Redis, Depends(redis_client)],
):
    username = req.scope["username"]
    logger.info(f"new msg from {username} at {msg.channel}: {msg.body}")

    kafka_msg = json.dumps({
        "author": username,
        "message": msg.body,
    }).encode("utf8")

    await kp.start()
    try:
        # Produce message
        await kp.send_and_wait(msg.channel, kafka_msg)
    finally:
        # Wait for all pending messages to be delivered or expire.
        await kp.stop()

    # channel history for admin and premium users
    r.rpush(msg.channel, json.dumps({"author": username, "body": msg.body}))
