from uuid import uuid4
from typing import Annotated


from fastapi import (
    FastAPI,
    Depends,
    HTTPException,
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

@app.post("/channels")
async def create_channel(
    req: Request,
    channel: Channel,
    r: Annotated[redis.Redis, Depends(redis_client)],
):
    print("username", req.scope["username"])
    channels = [n.decode() for n in r.lrange("channel", 0, -1)]
    if channel.name not in channels:
        r.rpush("channel", channel.name)

@app.get("/channels")
async def create_channel(
    r: Annotated[redis.Redis, Depends(redis_client)],
):
    return r.lrange("channel", 0, -1)
