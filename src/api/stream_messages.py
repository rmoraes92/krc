from aiokafka import AIOKafkaConsumer

from fastapi import (
    FastAPI,
    Depends,
    WebSocket,
)
from fastapi.middleware.cors import CORSMiddleware

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

@app.get("/stream_messages/ping")
async def pong():
    return "pong"

@app.websocket("/stream_messages/{channel_name}")
async def read_new_message(
    channel_name: str,
    websocket: WebSocket,
    # r: Annotated[redis.Redis, Depends(redis_client)],
):
    if not settings.kafka_servers:
        raise Exception(f"settings.kafka_servers is None")

    await websocket.accept()
    logger.info("socket accepted")

    krc_token = await websocket.receive_text()
    logger.info("token received")
    res = await is_krc_token_valid(krc_token)
    if not res:
        raise HTTPException(status_code=401, detail="incorrect credentials")
    logger.info("token verified")

    kc = AIOKafkaConsumer(
        channel_name,
        bootstrap_servers=settings.kafka_servers,
    )

    await kc.start()
    logger.info("kafka consumer started")

    while True:
        try:
            logger.info(f"reading kafka")
            async for msg in kc:
                msg = msg.value  # stringfied json
                await websocket.send_text(msg)
        except Exception as ex:
            logger.info(f"err: {ex}")
            break
